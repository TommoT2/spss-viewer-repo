package com.spss.parser;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*") // Allow all origins for testing
public class SpssController {
    
    private final SpssParser spssParser = new SpssParser();
    
    @PostMapping(value = "/parse", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> parseSpssFile(@RequestParam("file") MultipartFile file) {
        try {
            // Validate file
            if (file.isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(createErrorResponse("No file uploaded"));
            }
            
            if (!file.getOriginalFilename().toLowerCase().endsWith(".sav")) {
                return ResponseEntity.badRequest()
                    .body(createErrorResponse("File must be a .sav file"));
            }
            
            // Parse the file
            SpssParser.SpssData spssData = spssParser.parse(file.getBytes());
            String jsonResult = spssParser.toJson(spssData);
            
            // Return success response
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("filename", file.getOriginalFilename());
            response.put("size", file.getSize());
            response.put("result", jsonResult);
            
            return ResponseEntity.ok(response);
            
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(createErrorResponse("Error parsing file: " + e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(createErrorResponse("Unexpected error: " + e.getMessage()));
        }
    }
    
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "SPSS Parser API");
        health.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(health);
    }
    
    @GetMapping("/docs")
    public ResponseEntity<Map<String, Object>> docs() {
        Map<String, Object> docs = new HashMap<>();
        docs.put("service", "SPSS Parser API");
        docs.put("version", "1.0.0");
        docs.put("endpoints", Map.of(
            "POST /api/parse", "Upload and parse .sav file",
            "GET /api/health", "Check service health",
            "GET /api/docs", "This documentation"
        ));
        return ResponseEntity.ok(docs);
    }
    
    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("error", message);
        error.put("timestamp", System.currentTimeMillis());
        return error;
    }
}