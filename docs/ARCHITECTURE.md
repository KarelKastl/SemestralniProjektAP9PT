# Architektura

Průběžně doplňováno po každé featuře. Finální verze je ve fázi Finále.

## Tok dat
```mermaid
flowchart LR
  API[REST Countries v5] -->|JSON| Client[CountriesClient]
  Client -->|CountryDTO| Sync[CountrySync]
  Sync -->|upsert a vlajky| DB[(SwiftData)]
  DB -->|QuizCountry| Engine[GameEngine]
  Engine -->|odpovědi, výsledek| Recorder[ProgressRecorder]
  Recorder --> DB
```
