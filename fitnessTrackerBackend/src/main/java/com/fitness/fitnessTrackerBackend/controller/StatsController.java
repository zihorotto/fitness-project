package com.fitness.fitnessTrackerBackend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fitness.fitnessTrackerBackend.dto.GraphDTO;
import com.fitness.fitnessTrackerBackend.services.stats.StatsService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api")
@CrossOrigin("*")
@RequiredArgsConstructor
public class StatsController {

    private final StatsService statsService;

    @GetMapping("/stats")
    public ResponseEntity<?> getStats() {
        return ResponseEntity.ok(statsService.getStats());
    }
    
    @GetMapping("/graphs")
    public ResponseEntity<?> getGraphStats() {
       GraphDTO graphDTO = statsService.getGraphStats();

       if(graphDTO != null) {
        return ResponseEntity.ok(graphDTO);
       } else {
        return ResponseEntity.status(404).body("null");
       }
    }

}
