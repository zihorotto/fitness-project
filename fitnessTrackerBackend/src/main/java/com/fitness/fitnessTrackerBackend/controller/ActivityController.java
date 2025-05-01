package com.fitness.fitnessTrackerBackend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.HttpStatus;

import com.fitness.fitnessTrackerBackend.dto.ActivityDTO;
import com.fitness.fitnessTrackerBackend.services.activity.ActivityService;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;


@RestController
@RequestMapping("/api")
@CrossOrigin("*")
@RequiredArgsConstructor
public class ActivityController {

    private final ActivityService activityService;


    @PostMapping("/activity")
    public ResponseEntity<?> postActivity(@RequestBody ActivityDTO dto) {
        ActivityDTO creativeActivity = activityService.postActivity(dto);

        if(creativeActivity != null)
            return ResponseEntity.status(HttpStatus.CREATED).body(creativeActivity);
        else
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error creating activity");
    }


    @GetMapping("/activities")
    public ResponseEntity<?> getAllActivities() {
        try {
            return ResponseEntity.ok(activityService.getAllActivities());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error retrieving activities");
        }
    }

}
