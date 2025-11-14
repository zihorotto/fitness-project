package com.fitness.fitnessTrackerBackend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class WodRequest {
    
    private String name;
    private String type = "AMRAP"; // AMRAP, EMOM, FOR_TIME, etc.
    private String category = "GENERAL"; // STRENGTH, CARDIO, GENERAL, etc.
    private Integer durationInMinutes = 20;
    private String movements; // comma separated list
    private String experience = "INTERMEDIATE"; // BEGINNER, INTERMEDIATE, ADVANCED
    private String equipment; // available equipment
}