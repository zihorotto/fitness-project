package com.fitness.fitnessTrackerBackend.controller;

import java.util.List;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import com.fitness.fitnessTrackerBackend.dto.WODRequestDto;
import com.fitness.fitnessTrackerBackend.dto.WODResponseDto;
import com.fitness.fitnessTrackerBackend.entity.WOD;
import com.fitness.fitnessTrackerBackend.services.wod.WODService;
import org.springframework.http.*;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/wods")
@RequiredArgsConstructor
@CrossOrigin("*")
public class WODController {

    private final WODService wodService;
    public WOD mapResponseToEntity(WODResponseDto dto) {
        WOD wod = new WOD();
        wod.setName(dto.getName());
        wod.setType(dto.getType());
        wod.setCategory(dto.getCategory());
        wod.setDurationInMinutes(dto.getDurationInMinutes());
        wod.setMovements(dto.getMovements());
        wod.setDescription(dto.getDescription());
        wod.setFullDescription(dto.getFullDescription());
        return wod;
    }
    @PostMapping
    public ResponseEntity<WOD> createWOD(@RequestBody WOD wod) {
        WOD createdWOD = wodService.createWOD(wod);
        return new ResponseEntity<>(createdWOD, HttpStatus.CREATED);
    }
    
    @GetMapping
    public ResponseEntity<?> getWODs(@RequestParam(required = false) String search) {
        return ResponseEntity.ok(wodService.getWODs(search));
    }

    @GetMapping("/{id}")
    public WOD getWODById(@PathVariable Long id) {
        return wodService.getWODById(id);
    }

    @GetMapping("/search")
    public List<WOD> searchWODs(@RequestParam String searchTerm) {
        return wodService.searchWODs(searchTerm);
    }

    @PostMapping("/generate-and-save")
    public ResponseEntity<WOD> generateAndSaveWOD(@RequestBody WODRequestDto dto) {
        System.out.println("Received WOD name: " + dto.getName()); 
        RestTemplate rest = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<WODRequestDto> entity = new HttpEntity<>(dto, headers);

        ResponseEntity<WODResponseDto> response = rest.postForEntity(
            "http://localhost:5000/generate-wod",
            entity,
            WODResponseDto.class
        );

        WODResponseDto generated = response.getBody();

        if (generated == null || generated.getFullDescription() == null || generated.getFullDescription().isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }

        WOD saved = wodService.createWOD(mapResponseToEntity(generated));   
        return new ResponseEntity<>(saved, HttpStatus.CREATED);     
    }

}