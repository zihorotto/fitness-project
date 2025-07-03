package com.fitness.fitnessTrackerBackend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fitness.fitnessTrackerBackend.entity.WodResult;

public interface WodResultRepository  extends JpaRepository<WodResult, Long> {
}
