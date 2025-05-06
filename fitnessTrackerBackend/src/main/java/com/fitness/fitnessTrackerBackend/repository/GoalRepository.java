package com.fitness.fitnessTrackerBackend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.fitness.fitnessTrackerBackend.entity.Goal;

@Repository
public interface GoalRepository extends JpaRepository<Goal, Long> {
}
