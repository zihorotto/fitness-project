package com.fitness.fitnessTrackerBackend.services.goal;

import java.util.List;

import com.fitness.fitnessTrackerBackend.dto.GoalDTO;

public interface GoalService {
    GoalDTO postGoal(GoalDTO dto);
    List<GoalDTO> getGoals();
}
