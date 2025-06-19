package com.fitness.fitnessTrackerBackend.repository;

import com.fitness.fitnessTrackerBackend.entity.WOD;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface WODRepository extends JpaRepository<WOD, Long> {
    List<WOD> findByNameContainingIgnoreCase(String name);

    @Query(value = "SELECT * FROM wods w WHERE " +
                   "LOWER(w.name) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
                   "LOWER(w.description) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
                   "LOWER(w.type) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
                   "LOWER(w.category) LIKE LOWER(CONCAT('%', :searchTerm, '%'))", nativeQuery = true)
    List<WOD> searchWODs(@Param("searchTerm") String searchTerm);


    boolean existsByNameIgnoreCase(String name);

}