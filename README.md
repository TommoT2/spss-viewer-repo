# SPSS Viewer Repository

🔍 **Java-bibliotek for parsing av SPSS .sav-filer med REST API og web frontend**

## Oversikt

Dette prosjektet tilbyr en komplett løsning for å parse og visualisere SPSS (.sav) datafiler. Det består av tre hovedkomponenter:

1. **📚 Kjernebibliotek** - Standalone Java-parser for .sav-filer
2. **🔗 REST API** - Spring Boot-server for filbehandling via HTTP
3. **🌐 Web Frontend** - Brukervenlig grensesnitt for fileopplasting og resultatvisning

## 🏗️ Prosjektstruktur

```
spss-viewer-repo/
├── src/main/java/com/spss/parser/
│   ├── SpssParser.java          # Kjernebiblioteket for .sav parsing
│   ├── SpssApiServer.java       # Spring Boot REST API server
│   └── SpssController.java      # Controller for API-endepunkter
├── src/main/resources/
│   ├── application.properties   # Spring Boot konfigurasjon
│   └── application.yml         # Alternativ YAML-konfigurasjon
├── public/                     # GitHub Pages frontend
│   ├── index.html              # Hovedside for fileopplasting
│   ├── script.js               # JavaScript for API-kommunikasjon
│   └── style.css               # Styling for brukergrensesnitt
├── .github/workflows/
│   └── deploy.yml              # CI/CD for automatisk deployment
├── pom.xml                     # Maven-konfigurasjon
└── README.md                   # Denne dokumentasjonen
```

## 🚀 Kom i gang

### Forutsetninger

- Java 17 eller høyere
- Maven 3.6+
- Git

### 💻 Lokal utvikling

1. **Klon repositoriet:**
   ```bash
   git clone https://github.com/TommoT2/spss-viewer-repo.git
   cd spss-viewer-repo
   ```

2. **Bygg prosjektet:**
   ```bash
   mvn clean compile
   ```

3. **Kjør testene:**
   ```bash
   mvn test
   ```

4. **Start API-serveren:**
   ```bash
   mvn spring-boot:run
   ```
   Serveren starter på `http://localhost:8080`

5. **Åpne frontend:**
   Åpne `public/index.html` i nettleseren eller serve via lokal webserver

## 📡 API Dokumentasjon

### Endepunkter

| Method | Endpoint | Beskrivelse |
|--------|----------|-------------|
| POST | `/api/parse` | Last opp og parser .sav fil |
| GET | `/api/health` | Helsesjekk for server |
| GET | `/api/docs` | API-dokumentasjon |

### Eksempel på bruk

```bash
# Last opp SPSS fil
curl -X POST -F "file=@data.sav" http://localhost:8080/api/parse

# Sjekk server-status
curl http://localhost:8080/api/health
```

## 🌐 Frontend Funksjonalitet

- **📤 Fileopplasting**: Drag-and-drop eller filvelger for .sav filer
- **⚙️ API-konfigurasjon**: Sett inn egen API server URL
- **📊 Resultatvisning**: Strukturert visning av parsede data
- **💾 Eksport**: Last ned resultater som JSON eller CSV
- **📋 Kopiering**: Kopier JSON til utklippstavlen

## 🚢 Deployment

### GitHub Pages (Frontend)

1. Gå til repository **Settings** → **Pages**
2. Velg **Source**: Deploy from a branch
3. Velg **Branch**: `main` og folder: `/public`
4. Klikk **Save**

Frontend blir tilgjengelig på:
`https://TommoT2.github.io/spss-viewer-repo/`

### API Server Deployment

#### 1. Google Cloud Run
```bash
# Bygg JAR
mvn clean package -DskipTests

# Deploy til Cloud Run
gcloud run deploy spss-parser \
  --source . \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated
```

#### 2. Docker
```dockerfile
FROM openjdk:17-jdk-slim
COPY target/spss-viewer-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

#### 3. Heroku
```bash
# Installer Heroku CLI og login
heroku create spss-parser-app
heroku buildpacks:set heroku/java
git push heroku main
```

## 📦 Distribusjon som Bibliotek

### Maven Central

For å publisere til Maven Central:

1. **Konfigurér pom.xml** med nødvendig metadata
2. **Sett opp GPG-signering** for artifacts
3. **Registrer deg** på Sonatype OSSRH
4. **Deploy** via Maven:

```bash
mvn clean deploy -P release
```

### GitHub Packages

```xml
<dependency>
  <groupId>com.spss</groupId>
  <artifactId>spss-viewer</artifactId>
  <version>1.0.0</version>
</dependency>
```

### JitPack

Legg til i din `pom.xml`:

```xml
<repository>
  <id>jitpack.io</id>
  <url>https://jitpack.io</url>
</repository>

<dependency>
  <groupId>com.github.TommoT2</groupId>
  <artifactId>spss-viewer-repo</artifactId>
  <version>main-SNAPSHOT</version>
</dependency>
```

## 🔧 Konfigurasjon

### Environment Variables

| Variabel | Beskrivelse | Standard |
|----------|-------------|----------|
| `PORT` | Server port | `8080` |
| `SPRING_PROFILES_ACTIVE` | Aktiv profil | `prod` |
| `CORS_ALLOWED_ORIGINS` | Tillatte CORS origins | `*` |

### Profiler

- **development**: Debug logging, utviklingsinnstillinger
- **production**: Optimalisert for produksjon, minimal logging

## 🧪 Testing

```bash
# Kjør alle tester
mvn test

# Kjør med coverage
mvn jacoco:prepare-agent test jacoco:report

# Integration tester
mvn verify
```

## 📊 Monitorering

### Health Checks

- **Endpoint**: `GET /api/health`
- **Response**: JSON med status og timestamp

### Metrics (Actuator)

Aktivert via Spring Boot Actuator:
- `/actuator/health`
- `/actuator/metrics`
- `/actuator/info`

## 🤝 Bidrag

1. **Fork** repositoriet
2. **Opprett** en feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** endringene (`git commit -m 'Add some AmazingFeature'`)
4. **Push** til branch (`git push origin feature/AmazingFeature`)
5. **Åpne** en Pull Request

## 📝 Lisens

Distribuert under MIT License. Se `LICENSE` for mer informasjon.

## 🔗 Lenker

- **GitHub Repository**: [https://github.com/TommoT2/spss-viewer-repo](https://github.com/TommoT2/spss-viewer-repo)
- **Frontend Demo**: [https://TommoT2.github.io/spss-viewer-repo/](https://TommoT2.github.io/spss-viewer-repo/)
- **Issues**: [https://github.com/TommoT2/spss-viewer-repo/issues](https://github.com/TommoT2/spss-viewer-repo/issues)

## 🏆 Anerkjennelser

- Spring Boot for excellent REST framework
- Jackson for JSON processing
- GitHub Pages for free hosting

---

**Laget med ❤️ for SPSS dataanalyse**