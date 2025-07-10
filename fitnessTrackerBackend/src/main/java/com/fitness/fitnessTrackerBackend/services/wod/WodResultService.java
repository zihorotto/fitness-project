package com.fitness.fitnessTrackerBackend.services.wod;


import java.util.List;

import com.fitness.fitnessTrackerBackend.dto.WodResultDto;
import com.fitness.fitnessTrackerBackend.dto.WodResultResponseDto;
import com.fitness.fitnessTrackerBackend.entity.WodResult;

public interface WodResultService  { 
    WodResult saveResult(WodResultDto  result);
    List<WodResultResponseDto> getResultsByWodId(Long wodId);
}