package com.fitness.fitnessTrackerBackend.entity;


import java.sql.Date;

import com.fitness.fitnessTrackerBackend.dto.WorkoutDTO;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "workouts")
public class Workout {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String type;

    private Date date;

    private int duration;

    private int caloriesBurned;

    public WorkoutDTO getWorkoutDTO() {
        WorkoutDTO workoutDTO = new WorkoutDTO();
        workoutDTO.setId(id);
        workoutDTO.setType(type);
        workoutDTO.setDate(date);
        workoutDTO.setDuration(duration);
        workoutDTO.setCaloriesBurned(caloriesBurned);
        return workoutDTO;
    }

}
