package com.fitness.fitnessTrackerBackend.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fitness.fitnessTrackerBackend.dto.GoalDTO;
import com.fitness.fitnessTrackerBackend.services.goal.GoalService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@CrossOrigin("*")
public class GoalController {

    private final GoalService goalService;

    @PostMapping("/goal")
    public ResponseEntity<?> postGoal(@RequestBody GoalDTO dto) {
        try {
            return ResponseEntity.status(HttpStatus.CREATED).body(goalService.postGoal(dto));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error creating workout");
        }
    }

    @GetMapping("/goals")
    public ResponseEntity<?> getGoals() {
        try {
            return ResponseEntity.ok(goalService.getGoals());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error retrieving workouts");
        }
    }

    @GetMapping("/goal/status/{id}")
    public ResponseEntity<?> updateStatus(Long id) {
        try {
            return ResponseEntity.ok(goalService.updateStatus(id));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
}
