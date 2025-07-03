package com.fitness.fitnessTrackerBackend.dto;

import lombok.Data;

@Data
public class WODRequestDto {
    private String name;
    private String type;
    private String category;
    private Integer durationInMinutes;
    private String movements;
}

