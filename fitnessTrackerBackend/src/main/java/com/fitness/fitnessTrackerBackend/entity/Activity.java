package com.fitness.fitnessTrackerBackend.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.Data;
import java.util.Date;

import com.fitness.fitnessTrackerBackend.dto.ActivityDTO;

import jakarta.persistence.Table;

@Entity
@Data
@Table(name = "activities")
public class Activity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Date date;

    private int steps;

    private double distance;

    private int caloriesBurned;

    public ActivityDTO getActivityDTO() {
        ActivityDTO activityDTO = new ActivityDTO();
        activityDTO.setId(id);
        activityDTO.setDate(date);
        activityDTO.setSteps(steps);
        activityDTO.setDistance(distance);
        activityDTO.setCaloriesBurned(caloriesBurned);
        return activityDTO;
    }
}
