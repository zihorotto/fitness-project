package com.fitness.fitnessTrackerBackend.services;

import com.fitness.fitnessTrackerBackend.dto.WodRequest;
import com.fitness.fitnessTrackerBackend.dto.WodResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class WodGeneratorService {

    private final OpenAIService openAIService;

    public WodResponse generateWod(WodRequest request) {
        log.info("Generating WOD: {}", request.getName());
        
        String prompt = buildPrompt(request);
        String generatedContent = openAIService.generateCompletion(prompt);
        
        return parseWodResponse(request, generatedContent);
    }

    private String buildPrompt(WodRequest request) {
        StringBuilder prompt = new StringBuilder();
        int minutes = request.getDurationInSeconds() != null ? request.getDurationInSeconds() / 60 : 20;
        
        prompt.append("Create a CrossFit workout with the following specifications:\n\n");
        prompt.append("WOD Name: ").append(request.getName()).append("\n");
        prompt.append("Type: ").append(request.getType()).append("\n");
        prompt.append("Category: ").append(request.getCategory()).append("\n");
        prompt.append("Duration: ").append(minutes).append(" minutes\n");
        prompt.append("Experience Level: ").append(request.getExperience()).append("\n");
        
        if (request.getMovements() != null && !request.getMovements().isEmpty()) {
            prompt.append("Required Movements: ").append(request.getMovements()).append("\n");
        }
        
        if (request.getEquipment() != null && !request.getEquipment().isEmpty()) {
            prompt.append("Available Equipment: ").append(request.getEquipment()).append("\n");
        }
        
        prompt.append("\nPlease structure the response as follows:\n");
        prompt.append("1. A brief description of the workout's purpose and intensity (1-2 sentences)\n");
        prompt.append("2. The workout structure with specific exercises, reps, and timing\n");
        prompt.append("3. Coaching tips including pacing, scaling options, and safety considerations\n\n");
        
        prompt.append("Make sure the workout is:\n");
        prompt.append("- Safe and appropriate for the specified experience level\n");
        prompt.append("- Achievable within the time limit\n");
        prompt.append("- Focused on the specified category (").append(request.getCategory()).append(")\n");
        prompt.append("- Following proper ").append(request.getType()).append(" format\n");
        
        return prompt.toString();
    }

    private WodResponse parseWodResponse(WodRequest request, String generatedContent) {
        // Split the generated content into sections
        String[] sections = generatedContent.split("\n\n");
        
        String description = "";
        String fullDescription = generatedContent;
        String coachingTips = "";
        
        // Try to extract description and coaching tips
        if (sections.length >= 2) {
            description = sections[0].trim();
            
            // Look for coaching tips section (usually contains words like "tips", "coaching", "scaling")
            for (int i = sections.length - 1; i >= 0; i--) {
                String section = sections[i].toLowerCase();
                if (section.contains("tip") || section.contains("coaching") || 
                    section.contains("scaling") || section.contains("pace") ||
                    section.contains("safety")) {
                    coachingTips = sections[i].trim();
                    break;
                }
            }
        }
        
        WodResponse response = new WodResponse();
        response.setName(request.getName());
        response.setType(request.getType());
        response.setCategory(request.getCategory());
        response.setDurationInSeconds(request.getDurationInSeconds());
        response.setDurationDisplay(request.getDurationDisplay() != null ? request.getDurationDisplay() : formatSeconds(request.getDurationInSeconds()));
        response.setMovements(request.getMovements());
        response.setExperience(request.getExperience());
        response.setDescription(description.isEmpty() ? "High-intensity functional fitness workout" : description);
        response.setFullDescription(fullDescription);
        response.setCoachingTips(coachingTips.isEmpty() ? "Focus on proper form and listen to your body" : coachingTips);
        
        return response;
    }
    
    private String formatSeconds(Integer seconds) {
        if (seconds == null || seconds < 60) return "1:00";
        int minutes = seconds / 60;
        int secs = seconds % 60;
        return String.format("%d:%02d", minutes, secs);
    }
}