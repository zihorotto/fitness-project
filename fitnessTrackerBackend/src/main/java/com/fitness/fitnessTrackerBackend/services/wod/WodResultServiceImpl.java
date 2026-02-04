package com.fitness.fitnessTrackerBackend.services.wod;


import java.time.LocalDateTime;
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
        System.out.println("Saving WOD result with ID: " + dto.getWodId());
        if (dto.getWodId() == null || dto.getWodId() <= 0) {
            throw new RuntimeException("Invalid WOD ID: " + dto.getWodId());
        }
        
        WOD wod = wodRepository.findById(dto.getWodId())
            .orElseThrow(() -> new RuntimeException("WOD not found with id " + dto.getWodId()));

        WodResult result = new WodResult();
        result.setWod(wod);
        result.setDurationInSeconds(dto.getDurationInSeconds());
        result.setReps(dto.getReps());
        result.setSavedAt(LocalDateTime.now());
        WodResult saved = wodResultRepository.save(result);
        System.out.println("WOD result saved with ID: " + saved.getId());
        return saved;
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
        dto.setSavedAt(entity.getSavedAt().toString());
        return dto;
    }
}
