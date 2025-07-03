package com.fitness.fitnessTrackerBackend.controller;


import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fitness.fitnessTrackerBackend.entity.WodResult;
import com.fitness.fitnessTrackerBackend.services.wod.WodResultService;

import org.springframework.http.*;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/wod-results")
@RequiredArgsConstructor
@CrossOrigin("*")
public class WodResultController  {

      private final WodResultService wodResultService;


        @PostMapping
        public ResponseEntity<WodResult> saveWodResult(@RequestBody WodResult wodResult) {
            WodResult saved = wodResultService.saveResult(wodResult);
            return ResponseEntity.ok(saved);
        }

}