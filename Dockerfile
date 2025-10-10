# Multi-stage build for optimalisering
FROM maven:3.9.4-eclipse-temurin-17 AS builder

# Sett arbeidsmappe
WORKDIR /app

# Kopier Maven filer først (for caching)
COPY pom.xml .
COPY src ./src

# Bygg applikasjonen
RUN mvn clean package -DskipTests -Dspring.profiles.active=prod

# Production stage
FROM eclipse-temurin:17-jre-alpine

# Installer curl for health checks
RUN apk add --no-cache curl

# Opprett non-root bruker for sikkerhet
RUN addgroup -g 1001 -S appuser && \
    adduser -u 1001 -S appuser -G appuser

# Arbeidsmappe
WORKDIR /app

# Kopier JAR fra builder stage
COPY --from=builder /app/target/spss-viewer-*.jar app.jar

# Sett rettigheter
RUN chown appuser:appuser app.jar

# Bytt til non-root bruker
USER appuser

# Eksponér port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# JVM optimalisering for container
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Dspring.profiles.active=prod"

# Start applikasjon
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]