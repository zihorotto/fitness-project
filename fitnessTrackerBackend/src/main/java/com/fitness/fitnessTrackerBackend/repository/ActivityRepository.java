package com.fitness.fitnessTrackerBackend.repository;

import com.fitness.fitnessTrackerBackend.entity.Activity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ActivityRepository extends JpaRepository<Activity, Long> {


}
