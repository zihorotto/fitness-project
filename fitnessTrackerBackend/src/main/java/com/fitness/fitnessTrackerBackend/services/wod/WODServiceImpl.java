package com.fitness.fitnessTrackerBackend.services.wod;

import java.util.List;

import org.springframework.stereotype.Service;

import com.fitness.fitnessTrackerBackend.entity.WOD;
import com.fitness.fitnessTrackerBackend.repository.WODRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class WODServiceImpl implements WODService {

    private final WODRepository wodRepository;

    @Override
    public List<WOD> getWODs(String search) {
        if (search != null && !search.isBlank()) {
            return wodRepository.findByNameContainingIgnoreCase(search);
        }
        return wodRepository.findAll();
    }
}