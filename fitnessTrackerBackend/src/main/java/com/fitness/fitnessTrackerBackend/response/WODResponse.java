package com.fitness.fitnessTrackerBackend.response;

import java.util.List;

import com.fitness.fitnessTrackerBackend.entity.WOD;

import lombok.Data;

@Data
public class WODResponse {
    private List<WOD> wods;
    public List<WOD> getWods() {
        return wods;
    }
}
