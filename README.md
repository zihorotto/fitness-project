# Fitness Project – README

## English

### Tech Stack

- **Frontend:** Angular 18, Ng-Zorro, Chart.js, Tailwind CSS
- **Backend:** Spring Boot (Java 17+), Spring Security, PostgreSQL
- **AI Integration:** OpenAPI (GPT-4)
- **Communication:** REST API (JSON)
- **Other:** Docker (optional for DB)

### Requirements

- Node.js (v18+ recommended)
- npm (v9+)
- Angular CLI (`npm install -g @angular/cli`)
- Java 17+
- Maven
- PostgreSQL (or Docker)
- OpenAPI API Key (for AI-generated WODs)

🖼️ Project Screenshots / 🖼️ Projektscreenshots

Below are some screenshots illustrating the project: /
Unten finden Sie einige Screenshots, die das Projekt veranschaulichen:

![Create Wod](./fitnessTrackerFrontend/public/create.jpg)

![Wod 1](./fitnessTrackerFrontend/public/wod1.jpg)

![Wod 2](./fitnessTrackerFrontend/public/wod2.jpg)

![Wods](./fitnessTrackerFrontend/public/wods.jpg)

![Wod Board](./fitnessTrackerFrontend/public/wodboard.jpg)

![Timer](./fitnessTrackerFrontend/public/timer.jpg)


### Local Setup – Step by Step

1. **Clone the repository**

   ```bash
   git clone <repo-url>
   cd Fitness
   ```

2. **Backend (Spring Boot)**

   - Go to `fitnessTrackerBackend`:
     ```bash
     cd fitnessTrackerBackend
     ```
   - Configure your PostgreSQL connection in `src/main/resources/application.properties`.
   - Add your OpenAPI API key to the application properties or environment variables.
   - Start PostgreSQL locally or with Docker:
     ```bash
     docker run --name fitness-postgres -e POSTGRES_PASSWORD=yourpw -e POSTGRES_DB=fitness -p 5432:5432 -d postgres
     ```
   - Start the backend:
     ```bash
     .\mvnw.cmd spring-boot:run   # Windows
     # or
     mvn spring-boot:run
     ```
   - The backend runs on [http://localhost:8080](http://localhost:8080)

3. **Frontend (Angular)**

   - Go to `fitnessTrackerFrontend`:
     ```bash
     cd fitnessTrackerFrontend
     ```
   - Install dependencies:
     ```bash
     npm install
     ```
   - Start the frontend:
     ```bash
     ng serve
     ```
   - The app runs on [http://localhost:4200](http://localhost:4200)

4. **Usage**
   - Open the frontend in your browser.
   - AI-generated WODs are powered by OpenAPI integration in the backend.

---

## Deutsch

### Tech Stack

- **Frontend:** Angular 18, Ng-Zorro, Chart.js, Tailwind CSS
- **Backend:** Spring Boot (Java 17+), Spring Security, PostgreSQL
- **KI-Integration:** OpenAPI (GPT-4)
- **Kommunikation:** REST API (JSON)
- **Sonstiges:** Docker (optional für DB)

### Voraussetzungen

- Node.js (empfohlen v18+)
- npm (v9+)
- Angular CLI (`npm install -g @angular/cli`)
- Java 17+
- Maven
- PostgreSQL (oder Docker)
- OpenAPI API Key (für KI-generierte WODs)

### Lokale Einrichtung – Schritt für Schritt

1. **Repository klonen**

   ```bash
   git clone <repo-url>
   cd Fitness
   ```

2. **Backend (Spring Boot)**

   - Wechsle in das Verzeichnis `fitnessTrackerBackend`:
     ```bash
     cd fitnessTrackerBackend
     ```
   - Konfiguriere deine PostgreSQL-Verbindung in `src/main/resources/application.properties`.
   - Füge deinen OpenAPI API Key zu den Application Properties oder Umgebungsvariablen hinzu.
   - Starte PostgreSQL lokal oder mit Docker:
     ```bash
     docker run --name fitness-postgres -e POSTGRES_PASSWORD=deinpasswort -e POSTGRES_DB=fitness -p 5432:5432 -d postgres
     ```
   - Starte das Backend:
     ```bash
     .\mvnw.cmd spring-boot:run   # Windows
     # oder
     mvn spring-boot:run
     ```
   - Das Backend läuft auf [http://localhost:8080](http://localhost:8080)

3. **Frontend (Angular)**

   - Wechsle in das Verzeichnis `fitnessTrackerFrontend`:
     ```bash
     cd fitnessTrackerFrontend
     ```
   - Installiere die Abhängigkeiten:
     ```bash
     npm install
     ```
   - Starte das Frontend:
     ```bash
     ng serve
     ```
   - Die App läuft auf [http://localhost:4200](http://localhost:4200)

4. **Benutzung**
   - Öffne das Frontend im Browser.
   - KI-generierte WODs werden durch die OpenAPI-Integration im Backend bereitgestellt.

---
