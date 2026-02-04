package com.fitness.fitnessTrackerBackend.dto;

import lombok.Data;

@Data
public class WODRequestDto {
    private String name;
    private String type;
    private String category;
    private String description;
    private Integer durationInSeconds; // Duration in seconds
    private String durationDisplay; // Format: MM:SS (e.g., "10:20")
    private String movements;
}

