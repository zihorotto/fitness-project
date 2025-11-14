package com.fitness.fitnessTrackerBackend.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenAIConfig {

    private final Dotenv dotenv;

    public OpenAIConfig(Dotenv dotenv) {
        this.dotenv = dotenv;
    }

    @Value("${openai.base-url:https://api.openai.com/v1}")
    private String baseUrl;

    @Value("${openai.model:gpt-4o}")
    private String model;

    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }

    public String getApiKey() {
        // Try to get from .env file first, then from system properties
        String apiKey = dotenv.get("OPENAI_API_KEY");
        if (apiKey == null || apiKey.isEmpty()) {
            apiKey = System.getProperty("OPENAI_API_KEY");
        }
        if (apiKey == null || apiKey.isEmpty()) {
            apiKey = System.getenv("OPENAI_API_KEY");
        }
        return apiKey;
    }

    public String getApiUrl() {
        return baseUrl;
    }

    public String getBaseUrl() {
        String envBaseUrl = dotenv.get("OPENAI_BASE_URL");
        return (envBaseUrl != null && !envBaseUrl.isEmpty()) ? envBaseUrl : baseUrl;
    }

    public String getModel() {
        String envModel = dotenv.get("OPENAI_MODEL");
        return (envModel != null && !envModel.isEmpty()) ? envModel : model;
    }
}