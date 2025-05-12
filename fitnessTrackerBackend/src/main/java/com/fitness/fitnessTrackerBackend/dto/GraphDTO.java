package com.fitness.fitnessTrackerBackend.dto;

import java.util.List;

import lombok.Data;

@Data
public class GraphDTO {

    private List<WorkoutDTO> workouts;
    
    private List<ActivityDTO> activities;
}
