package com.fitness.fitnessTrackerBackend.services.activity;

import java.util.List;

import com.fitness.fitnessTrackerBackend.dto.ActivityDTO;

public interface ActivityService {
    ActivityDTO postActivity(ActivityDTO activityDTO);
    List<ActivityDTO> getAllActivities();
}
