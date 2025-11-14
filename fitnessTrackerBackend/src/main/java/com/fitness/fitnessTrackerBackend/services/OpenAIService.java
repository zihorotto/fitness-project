package com.fitness.fitnessTrackerBackend.services;

import com.fitness.fitnessTrackerBackend.config.OpenAIConfig;
import com.fitness.fitnessTrackerBackend.dto.openai.OpenAIRequest;
import com.fitness.fitnessTrackerBackend.dto.openai.OpenAIResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class OpenAIService {

    private final RestTemplate restTemplate;
    private final OpenAIConfig openAIConfig;

    public String generateCompletion(String prompt) {
        try {
            // Create the request
            OpenAIRequest.Message systemMessage = new OpenAIRequest.Message(
                    "system", 
                    "You are a certified CrossFit coach and fitness expert. Create high-quality, safe, and effective workouts."
            );
            
            OpenAIRequest.Message userMessage = new OpenAIRequest.Message("user", prompt);
            
            OpenAIRequest request = new OpenAIRequest();
            request.setModel(openAIConfig.getModel());
            request.setMessages(List.of(systemMessage, userMessage));
            request.setMaxTokens(1000);
            request.setTemperature(0.7);

            // Set headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(openAIConfig.getApiKey());

            // Create HTTP entity
            HttpEntity<OpenAIRequest> entity = new HttpEntity<>(request, headers);

            // Make the request
            String url = openAIConfig.getBaseUrl() + "/chat/completions";
            log.info("Sending request to OpenAI: {}", url);
            
            ResponseEntity<OpenAIResponse> response = restTemplate.postForEntity(url, entity, OpenAIResponse.class);
            
            if (response.getBody() != null && 
                response.getBody().getChoices() != null && 
                !response.getBody().getChoices().isEmpty()) {
                
                return response.getBody().getChoices().get(0).getMessage().getContent();
            }
            
            throw new RuntimeException("No response received from OpenAI");
            
        } catch (Exception e) {
            log.error("Error calling OpenAI API: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to generate workout: " + e.getMessage());
        }
    }
}