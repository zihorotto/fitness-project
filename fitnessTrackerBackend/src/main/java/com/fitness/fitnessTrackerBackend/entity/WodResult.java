package com.fitness.fitnessTrackerBackend.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "wod_results")
@Data
public class WodResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long wodId;

    private Integer durationInSeconds;

    private Integer reps;

    private LocalDateTime savedAt;

    public WodResult() {
        this.savedAt = LocalDateTime.now();
    }
}