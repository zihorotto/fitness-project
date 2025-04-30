package com.fitness.fitnessTrackerBackend.services.activity;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.fitness.fitnessTrackerBackend.repository.ActivityRepository;

import lombok.RequiredArgsConstructor;
import com.fitness.fitnessTrackerBackend.dto.ActivityDTO;
import com.fitness.fitnessTrackerBackend.entity.Activity;

@Service
@RequiredArgsConstructor
public class ActivityServiceImpl implements ActivityService {

    private final ActivityRepository activityRepository;

    @Override
    public ActivityDTO postActivity(ActivityDTO activityDTO) {
        Activity activity = new Activity();

        activity.setDate(activityDTO.getDate());
        activity.setSteps(activityDTO.getSteps());
        activity.setDistance(activityDTO.getDistance());
        activity.setCaloriesBurned(activityDTO.getCaloriesBurned());

        return activityRepository.save(activity).getActivityDTO();

    }

    @Override
    public List<ActivityDTO> getAllActivities() {
        List<Activity> activities = activityRepository.findAll();
        return activities.stream().map(Activity::getActivityDTO).collect(Collectors.toList());
    }

}
