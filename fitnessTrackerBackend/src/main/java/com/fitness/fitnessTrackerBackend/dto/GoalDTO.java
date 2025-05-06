package com.fitness.fitnessTrackerBackend.dto;

import java.util.Date;

import lombok.Data;

@Data
public class GoalDTO {

    private Long id;

    private String desription;

    private Date startDate;

    private Date endDate;

    private boolean achieved;

}
