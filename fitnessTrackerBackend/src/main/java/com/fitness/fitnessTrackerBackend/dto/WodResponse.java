package com.fitness.fitnessTrackerBackend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class WodResponse {
    
    private String name;
    private String type;
    private String category;
    private Integer durationInMinutes;
    private String movements;
    private String experience;
    private String description; // Short description
    private String fullDescription; // Full workout with exercises
    private String coachingTips; // Safety and performance tips
}