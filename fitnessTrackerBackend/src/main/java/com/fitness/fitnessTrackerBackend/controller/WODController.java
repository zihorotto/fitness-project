package com.fitness.fitnessTrackerBackend.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fitness.fitnessTrackerBackend.entity.WOD;
import com.fitness.fitnessTrackerBackend.services.wod.WODService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/wods")
@RequiredArgsConstructor
@CrossOrigin("*")
public class WODController {

    private final WODService wodService;

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
}