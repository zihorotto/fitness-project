package com.fitness.fitnessTrackerBackend.services.wod;


import org.springframework.stereotype.Service;

import com.fitness.fitnessTrackerBackend.entity.WodResult;
import com.fitness.fitnessTrackerBackend.repository.WodResultRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class WodResultServiceImpl  implements WodResultService  {

    private final WodResultRepository  wodResultRepository;

    @Override
    public WodResult saveResult(WodResult result) {
        return wodResultRepository.save(result);
    }
}
