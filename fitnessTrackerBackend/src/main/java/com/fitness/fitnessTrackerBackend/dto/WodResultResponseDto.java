package com.fitness.fitnessTrackerBackend.dto;

import lombok.Data;

@Data
public class WodResultResponseDto {
    private Long id;
    private Long wodId;
    private Integer durationInSeconds;
    private Integer reps;
    private String savedAt;
}
