package com.fitness.fitnessTrackerBackend.services.wod;

import java.util.List;
import java.util.NoSuchElementException;

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
        if (search != null && !search.isEmpty()) {
            return wodRepository.findByNameContainingIgnoreCase(search);
        } else {
            return wodRepository.findAll();
        }
    }

    @Override
    public WOD getWODById(Long id) {
        return wodRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("WOD not found with id " + id));
    }

    @Override
    public List<WOD> searchWODs(String searchTerm) {
        return wodRepository.searchWODs(searchTerm);
    }

    @Override
    public WOD createWOD(WOD wod) {
        boolean exists = wodRepository.existsByNameIgnoreCase(wod.getName());
        if (exists) {
            throw new RuntimeException("WOD with name '" + wod.getName() + "' already exists.");
        }
        return wodRepository.save(wod);
    }
}
