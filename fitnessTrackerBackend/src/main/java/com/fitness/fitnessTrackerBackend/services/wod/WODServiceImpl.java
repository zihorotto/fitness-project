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
            return wodRepository.findByNameContainingIgnoreCase(search); // Ha van keresési kulcsszó, használjuk a keresést.
        } else {
            return wodRepository.findAll(); // Ha nincs keresési kulcsszó, akkor az összes WOD-ot lekérjük.
        }
    }

    @Override
    public WOD getWODById(Long id) {
        return wodRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("WOD not found with id " + id));
    }

    @Override
    public List<WOD> searchWODs(String query) {
        return wodRepository.findByNameContainingIgnoreCase(query);
    }
}
