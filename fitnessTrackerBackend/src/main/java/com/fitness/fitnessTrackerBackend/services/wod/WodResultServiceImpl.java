package com.fitness.fitnessTrackerBackend.services.wod;


import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.fitness.fitnessTrackerBackend.dto.WodResultDto;
import com.fitness.fitnessTrackerBackend.dto.WodResultResponseDto;
import com.fitness.fitnessTrackerBackend.entity.WOD;
import com.fitness.fitnessTrackerBackend.entity.WodResult;
import com.fitness.fitnessTrackerBackend.repository.WODRepository;
import com.fitness.fitnessTrackerBackend.repository.WodResultRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class WodResultServiceImpl  implements WodResultService  {

    private final WodResultRepository  wodResultRepository;
    private final WODRepository wodRepository;

    @Override
    public WodResult saveResult(WodResultDto dto) {
        WOD wod = wodRepository.findById(dto.getWodId())
            .orElseThrow(() -> new RuntimeException("WOD not found with id " + dto.getWodId()));

        WodResult result = new WodResult();
        result.setWod(wod);  // itt már WOD entitást adhatsz át
        result.setDurationInSeconds(dto.getDurationInSeconds());
        result.setReps(dto.getReps());
        return wodResultRepository.save(result);
    }

    @Override
    public List<WodResultResponseDto> getResultsByWodId(Long wodId) {
        return wodResultRepository.findByWodId(wodId)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    private WodResultResponseDto mapToDto(WodResult entity) {
        WodResultResponseDto dto = new WodResultResponseDto();
        dto.setId(entity.getId());
        dto.setWodId(entity.getWod().getId());
        dto.setDurationInSeconds(entity.getDurationInSeconds());
        dto.setReps(entity.getReps());
        dto.setSavedAt(entity.getSavedAt());
        return dto;
    }
}
