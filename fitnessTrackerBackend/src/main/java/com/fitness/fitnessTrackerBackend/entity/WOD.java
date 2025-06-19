package com.fitness.fitnessTrackerBackend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Data
@Table(name = "wods")
public class WOD {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String type; // pl. "AMRAP", "FOR TIME"
    private String category; // pl. "HERO", "BENCHMARK"

    @Column(name = "duration_in_minutes")
    private Integer durationInMinutes;

    @Column(name = "description", length = 2000)
    private String description;

    @Column(name = "full_description", length = 5000)
    private String fullDescription;
}