package com.fitness.fitnessTrackerBackend.services.wod;

import java.util.List;

import com.fitness.fitnessTrackerBackend.entity.WOD;

public interface WODService {
    List<WOD> getWODs(String search); 
}