package com.fitness.fitnessTrackerBackend.repository;

import com.fitness.fitnessTrackerBackend.entity.WOD;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface WODRepository extends JpaRepository<WOD, Long> {
    List<WOD> findByNameContainingIgnoreCase(String search);
}