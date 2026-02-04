package com.fitness.fitnessTrackerBackend.dto;

import lombok.Data;

@Data
public class WODResponseDto {
    private String name;
    private String type;
    private String category;
    private Integer durationInSeconds;
    private String durationDisplay;
    private String movements;
    private String description;
    private String fullDescription;
}