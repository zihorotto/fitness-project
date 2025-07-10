package com.fitness.fitnessTrackerBackend.dto;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class WodResultDto {

    private Long id;
    private Long wodId;
    private Integer durationInSeconds;
    private Integer reps;
    private LocalDateTime savedAt;
}
