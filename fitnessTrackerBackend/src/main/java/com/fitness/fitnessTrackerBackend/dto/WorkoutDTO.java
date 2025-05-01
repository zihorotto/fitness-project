package com.fitness.fitnessTrackerBackend.dto;

import java.sql.Date;

import lombok.Data;

@Data
public class WorkoutDTO {
    private Long id;

    private String type;

    private Date date;

    private int duration;

    private int caloriesBurned;
}
