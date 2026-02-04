package com.fitness.fitnessTrackerBackend.controller;


import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fitness.fitnessTrackerBackend.dto.WodResultDto;
import com.fitness.fitnessTrackerBackend.dto.WodResultResponseDto;
import com.fitness.fitnessTrackerBackend.entity.WodResult;
import com.fitness.fitnessTrackerBackend.services.wod.WodResultService;

import java.util.List;

import org.springframework.http.*;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/wod-results")
@RequiredArgsConstructor
@CrossOrigin("*")
public class WodResultController  {

      private final WodResultService wodResultService;


    @PostMapping
    public ResponseEntity<WodResultResponseDto> saveWodResult(@RequestBody WodResultDto dto) {
        try {
            WodResult saved = wodResultService.saveResult(dto);
            
            // Convert to DTO with String date
            WodResultResponseDto response = new WodResultResponseDto();
            response.setId(saved.getId());
            response.setWodId(saved.getWod().getId());
            response.setDurationInSeconds(saved.getDurationInSeconds());
            response.setReps(saved.getReps());
            response.setSavedAt(saved.getSavedAt().toString());
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            System.err.println("Error saving WOD result: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
        }
    }

    @GetMapping("/wod/{wodId}")
    public ResponseEntity<List<WodResultResponseDto>> getResultsByWodId(@PathVariable Long wodId) {
        List<WodResultResponseDto> results = wodResultService.getResultsByWodId(wodId);
        return ResponseEntity.ok(results);
    }

}