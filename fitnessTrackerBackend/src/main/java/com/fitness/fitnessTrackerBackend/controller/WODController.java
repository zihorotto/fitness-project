package com.fitness.fitnessTrackerBackend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fitness.fitnessTrackerBackend.services.wod.WODService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/wods")
@RequiredArgsConstructor
@CrossOrigin("*")
public class WODController {

    private final WODService wodService;

    @GetMapping
    public ResponseEntity<?> getWODs(@RequestParam(required = false) String search) {
        return ResponseEntity.ok(wodService.getWODs(search));
    }
}