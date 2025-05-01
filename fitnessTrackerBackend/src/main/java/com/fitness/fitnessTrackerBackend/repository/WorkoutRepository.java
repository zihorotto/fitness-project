package com.fitness.fitnessTrackerBackend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.fitness.fitnessTrackerBackend.entity.Workout;

@Repository
public interface WorkoutRepository extends JpaRepository<Workout, Long> {

}
