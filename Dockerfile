# Use official OpenJDK runtime with Alpine Linux
FROM eclipse-temurin:17-jre-alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Create application directory
WORKDIR /app

# Copy the built JAR file (assuming Maven build creates this)
COPY target/spss-viewer-*.jar app.jar

# Create non-root user for security
RUN addgroup -S appuser && adduser -S appuser -G appuser
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Start the application
ENTRYPOINT ["java", \
    "-Djava.security.egd=file:/dev/./urandom", \
    "-Dspring.profiles.active=prod", \
    "-Xmx512m", \
    "-Xms256m", \
    "-XX:+UseG1GC", \
    "-jar", \
    "app.jar"]