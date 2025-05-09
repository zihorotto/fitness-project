package com.fitness.fitnessTrackerBackend.services.workout;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.fitness.fitnessTrackerBackend.dto.WorkoutDTO;
import com.fitness.fitnessTrackerBackend.entity.Workout;
import com.fitness.fitnessTrackerBackend.repository.WorkoutRepository;

import lombok.RequiredArgsConstructor;


@Service
@RequiredArgsConstructor
public class WorkoutServiceImpl implements WorkoutService{

    private final WorkoutRepository workoutRepository;

    @Override
    public WorkoutDTO postWorkout(WorkoutDTO workoutDTO) {
        Workout workout = new Workout();
        workout.setType(workoutDTO.getType());
        workout.setDate(workoutDTO.getDate());
        workout.setDuration(workoutDTO.getDuration());
        workout.setCaloriesBurned(workoutDTO.getCaloriesBurned());

        return workoutRepository.save(workout).getWorkoutDTO();
    }

    @Override
    public List<WorkoutDTO> getWorkouts() {
        List<Workout> workouts = workoutRepository.findAll();
        return workouts.stream().map(Workout::getWorkoutDTO).collect(Collectors.toList());
    }
    
}
