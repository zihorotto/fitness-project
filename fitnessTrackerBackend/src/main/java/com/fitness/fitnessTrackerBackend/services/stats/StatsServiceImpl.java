package com.fitness.fitnessTrackerBackend.services.stats;

import org.springframework.stereotype.Service;

import com.fitness.fitnessTrackerBackend.dto.StatsDTO;
import com.fitness.fitnessTrackerBackend.repository.ActivityRepository;
import com.fitness.fitnessTrackerBackend.repository.GoalRepository;
import com.fitness.fitnessTrackerBackend.repository.WorkoutRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class StatsServiceImpl implements StatsService {

    private final GoalRepository goalRepository;
    private final ActivityRepository activityRepository;
    private final WorkoutRepository workoutRepository;

    @Override
    public StatsDTO getStats(){
        Long achievedGoals  = goalRepository.countAchievedGoals();
        Long notAchievedGoals  = goalRepository.countNotAchievedGoals();

        Integer totalSteps = activityRepository.getTotalSteps();
        Double totalDistance = activityRepository.getTotalDistance();
        Integer totalActivityCaloriesBurned = activityRepository.getTotalCaloriesBurned();

        Integer totalWorkoutDuration = workoutRepository.getTotalDuration();
        Integer totalWorkoutCaloriesBurned = workoutRepository.getTotalCaloriesBurned();

        int totalCaloriesBurned = (totalActivityCaloriesBurned != null ? totalActivityCaloriesBurned : 0) + (totalWorkoutCaloriesBurned != null ? totalWorkoutCaloriesBurned : 0);

        StatsDTO dto = new StatsDTO();
        dto.setAchievedGoals(achievedGoals != null ? achievedGoals : 0);
        dto.setNotAchievedGoals(notAchievedGoals != null ? notAchievedGoals : 0);

        dto.setSteps(totalSteps != null ? totalSteps : 0);
        dto.setDistance(totalDistance != null ? totalDistance : 0.0);
        dto.setTotalCaloriesBurned(totalCaloriesBurned);
        dto.setDuration(totalWorkoutDuration != null ? totalWorkoutDuration : 0);

        return dto;
    }

}
