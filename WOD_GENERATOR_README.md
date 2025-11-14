# Fitness App - WOD Generator with GPT-4.1

## Konfiguráció

### 1. OpenAI API Key beállítása

**Módszer 1: .env fájl (ajánlott)**
Szerkeszd a `.env` fájlt a backend mappában:

```env
OPENAI_API_KEY=sk-proj-your-real-api-key-here
```

**Módszer 2: Environment változók**

**Windows PowerShell:**

```powershell
$env:OPENAI_API_KEY="your-openai-api-key-here"
```

**Linux/Mac:**

```bash
export OPENAI_API_KEY="your-openai-api-key-here"
```

**Konfiguráció prioritás:**

1. `.env` fájl értékek (legmagasabb prioritás)
2. System properties (`-DOPENAI_API_KEY=...`)
3. Environment változók
4. Default értékek

### 2. Application Properties

A `application.properties` már konfigurálva van:

```properties
# OpenAI Configuration (API key loaded from .env file via OpenAIConfig)
openai.base-url=https://api.openai.com/v1
openai.model=gpt-4o
openai.timeout=30000
```

**Fontos:** Az API kulcs a `.env` fájlból töltődik be automatikusan, nem kell az `application.properties`-ben megadni.

## API Endpointok

### 1. WOD Generálás (csak generálás, nem ment el)

```http
POST /api/wods/generate
Content-Type: application/json

{
    "name": "Morning AMRAP",
    "type": "AMRAP",
    "category": "GENERAL",
    "durationInMinutes": 15,
    "movements": "push-ups, air squats, burpees",
    "experience": "INTERMEDIATE",
    "equipment": "bodyweight only"
}
```

### 2. WOD Generálás és Mentés (régi endpoint OpenAI-ra frissítve)

```http
POST /api/wods/generate-and-save
Content-Type: application/json

{
    "name": "Evening Strength",
    "type": "EMOM",
    "category": "STRENGTH",
    "durationInMinutes": 20,
    "movements": "deadlifts, pull-ups, push-ups"
}
```

## Változások

### Eltávolított komponensek:

- ❌ Python Flask service (ai-service mappa teljes eltávolítása)
- ❌ Python Transformers library
- ❌ Helyi ML modellek
- ❌ Python függőségek és környezet

### Új funkciók:

- ✅ OpenAI GPT-4.1 integráció Java-ban
- ✅ Java-based WOD generátor
- ✅ Egységes `openai.base-url` konfiguráció
- ✅ Fejlettebb prompt engineering
- ✅ Teljes Spring Boot integráció
- ✅ Hibakezelés és logging
- ✅ .env fájl támogatás

## Előnyök

1. **Egységes technológiai stack** - minden Java/Spring Boot
2. **Jobb AI minőség** - GPT-4.1 vs helyi modellek
3. **Könnyebb deployment** - nincs szükség Python környezetre
4. **Jobb skálázhatóság** - OpenAI API vs helyi számítások
5. **Fejlettebb promptok** - specializált fitness coaching

## Tesztelés

```bash
# Alkalmazás indítása
mvn spring-boot:run

# Test endpoint
curl http://localhost:8080/api/wods/test

# WOD generálás teszt
curl -X POST http://localhost:8080/api/wods/generate \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test WOD",
    "type": "AMRAP",
    "category": "GENERAL",
    "durationInMinutes": 15,
    "movements": "push-ups, squats"
  }'
```
