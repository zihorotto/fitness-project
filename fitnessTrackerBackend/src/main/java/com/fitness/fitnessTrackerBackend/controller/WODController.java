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

import com.fitness.fitnessTrackerBackend.dto.WODRequestDto;
import com.fitness.fitnessTrackerBackend.dto.WODResponseDto;
import com.fitness.fitnessTrackerBackend.dto.WodRequest;
import com.fitness.fitnessTrackerBackend.dto.WodResponse;
import com.fitness.fitnessTrackerBackend.entity.WOD;
import com.fitness.fitnessTrackerBackend.services.wod.WODService;
import com.fitness.fitnessTrackerBackend.services.WodGeneratorService;
import org.springframework.http.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api/wods")
@RequiredArgsConstructor
@CrossOrigin("*")
@Slf4j
public class WODController {

    private final WODService wodService;
    private final WodGeneratorService wodGeneratorService;
    
    @PostMapping("/generate")
    public ResponseEntity<WodResponse> generateWOD(@RequestBody WodRequest request) {
        try {
            log.info("Generating WOD with GPT-4.1: {}", request.getName());
            
            WodResponse response = wodGeneratorService.generateWod(request);
            
            log.info("Successfully generated WOD: {}", response.getName());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("Error generating WOD: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

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
        try {
            log.info("Generating WOD with OpenAI: {}", dto.getName());
            
            // Convert DTO to new request format
            WodRequest request = new WodRequest();
            request.setName(dto.getName());
            request.setType(dto.getType());
            request.setCategory(dto.getCategory());
            request.setDurationInMinutes(dto.getDurationInMinutes());
            request.setMovements(dto.getMovements());
            request.setExperience("INTERMEDIATE"); // Default value
            
            // Generate WOD using OpenAI
            WodResponse generated = wodGeneratorService.generateWod(request);
            
            if (generated == null || generated.getFullDescription() == null || generated.getFullDescription().isEmpty()) {
                log.error("Failed to generate WOD content");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
            }

            // Map to entity and save
            WOD saved = wodService.createWOD(mapResponseToEntity(generated));
            log.info("Successfully saved WOD: {}", saved.getId());
            
            return new ResponseEntity<>(saved, HttpStatus.CREATED);
            
        } catch (Exception e) {
            log.error("Error generating and saving WOD: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    private WOD mapResponseToEntity(WodResponse response) {
        WOD wod = new WOD();
        wod.setName(response.getName());
        wod.setType(response.getType());
        wod.setCategory(response.getCategory());
        wod.setDurationInMinutes(response.getDurationInMinutes());
        wod.setMovements(response.getMovements());
        wod.setDescription(response.getDescription());
        wod.setFullDescription(response.getFullDescription());
        return wod;
    }

}