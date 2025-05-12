package com.fitness.fitnessTrackerBackend.services.stats;

import com.fitness.fitnessTrackerBackend.dto.GraphDTO;
import com.fitness.fitnessTrackerBackend.dto.StatsDTO;

public interface StatsService {

StatsDTO getStats();

GraphDTO getGraphStats();

}
