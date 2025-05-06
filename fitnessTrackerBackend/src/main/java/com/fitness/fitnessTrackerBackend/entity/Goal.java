package com.fitness.fitnessTrackerBackend.entity;

import java.util.Date;

import com.fitness.fitnessTrackerBackend.dto.GoalDTO;

import jakarta.persistence.Entity;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import jakarta.persistence.GeneratedValue;


@Entity
@Data
@Table(name = "goals")
public class Goal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String desription;

    private Date startDate;

    private Date endDate;

    private boolean achieved;

    public GoalDTO getGoalDTO() {
        GoalDTO goalDTO = new GoalDTO();

        goalDTO.setId(id);
        goalDTO.setDesription(desription);
        goalDTO.setStartDate(startDate);
        goalDTO.setEndDate(endDate);
        goalDTO.setAchieved(achieved);

        return goalDTO;
    }

}
