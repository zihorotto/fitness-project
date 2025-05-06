package com.fitness.fitnessTrackerBackend.services.goal;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.fitness.fitnessTrackerBackend.dto.GoalDTO;
import com.fitness.fitnessTrackerBackend.entity.Goal;
import com.fitness.fitnessTrackerBackend.repository.GoalRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class GoalServiceImpl implements GoalService {
    
    private final GoalRepository goalRepository;
    

    @Override
    public GoalDTO postGoal(GoalDTO dto) {
       Goal goal = new Goal();

        goal.setDesription(dto.getDesription());
        goal.setStartDate(dto.getStartDate());
        goal.setEndDate(dto.getEndDate());
        goal.setAchieved(false);

        return goalRepository.save(goal).getGoalDTO();
    }


    @Override
    public List<GoalDTO> getGoals() {
        List<Goal> goals = goalRepository.findAll();
        return goals.stream().map(Goal::getGoalDTO).collect(Collectors.toList());
    }

    
}
