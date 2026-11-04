# Předávka

**Stav:** F1–F8 a B1–B3 hotové, kritéria A1–A14 mají zelené UI testy, unit testy 63/63, UI testy 25/25, build bez varování. Aplikace běží na iPhonu 12 mini se skutečnými daty: 250 zemí, 193 v OSN, 250 vlajek.

**Co není hotové:** ruční ověření (`docs/VERIFICATION.md`, sekce „Čeká na ruční ověření“) a sloupec *Ověřil člověk* v `docs/PRD.md`.

**Známá omezení:**
- API klíč je v aplikaci čitelný (ADR-002), po projektu ho vyměňte.
- Mapa potřebuje síť. V simulátoru se dlaždice při screenshotech nenačetly, na iPhonu je potřeba je ověřit.
- Bezplatný podpis platí 7 dní.
- Běh na iOS 17 nebyl spuštěný, v Xcode je jen simulátor 27.2.
- Commity jsou lokální. Push udělejte v aplikaci GitHub.

**Pro psaní dokumentace a prezentace:**
| Potřebuji | Soubor |
| --- | --- |
| Zadání a kritéria | `docs/PRD.md` |
| Architektura a mapa kódu | `docs/ARCHITECTURE.md` |
| Rozhodnutí | `docs/DECISIONS.md` |
| Důkazy | `docs/VERIFICATION.md`, `docs/screenshots/` |
| Průběh a odchylky | `docs/PROGRESS.md` |
| Review a nalezené chyby | `docs/AGENT-REVIEW.md` |
| Podklady k obhajobě | `docs/PRESENTATION.md` |

**Spuštění:** `README.md`. Pravidla pro další práci: `CLAUDE.md`.
