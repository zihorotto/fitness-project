package com.fitness.fitnessTrackerBackend.services.workout;

import java.util.List;

import com.fitness.fitnessTrackerBackend.dto.WorkoutDTO;

public interface WorkoutService {
    WorkoutDTO postWorkout(WorkoutDTO workoutDTO);

    List<WorkoutDTO> getWorkouts();

}
