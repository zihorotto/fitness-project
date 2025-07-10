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
    public ResponseEntity<WodResult> saveWodResult(@RequestBody WodResultDto dto) {
        WodResult saved = wodResultService.saveResult(dto);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/wod/{wodId}")
    public ResponseEntity<List<WodResultResponseDto>> getResultsByWodId(@PathVariable Long wodId) {
        List<WodResultResponseDto> results = wodResultService.getResultsByWodId(wodId);
        return ResponseEntity.ok(results);
    }

}