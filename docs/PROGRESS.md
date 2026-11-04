# Průběh

### Fáze 5 – F5 Výsledek a historie · 4. 11. 2026
Hotovo: `Views/Game/ResultView.swift`, `Persistence/ProgressRecorder.swift` (`save`), `Views/History/HistoryView.swift`, `Game/HistoryStats.swift`, `Views/Home/MainTabView.swift`.
NEsplněno / odchylky: žádné.
Přidáno navíc: tlačítko Hrát znovu.
Build: OK · Unit testy: 48/48 · UI testy: A1, A2, A4–A10 zelené
Další krok: F6 Atlas.

### Fáze 4 – F4 Další režimy a nastavení · 4. 11. 2026
Hotovo: režimy Hlavní město a Víc/méně v `Views/Game/GameView.swift`, nastavení ve `Form` a `@AppStorage` ve `Views/Home/HomeView.swift`, časovač v `GameEngine.tick`.
NEsplněno / odchylky: část kódu F4 skončila omylem v commitu F3, testy a dokumentace jsou v commitu F4.
Přidáno navíc: přepínač `-uiTestResetDefaults` a nastavení přes argumenty v UI testech.
Build: OK · Unit testy: 43/43 · UI testy: 8/8
Důkazy: `testA05`–`testA09`. Screenshoty těchto obrazovek jsou ve fázi F8.

### Fáze 3 – F3 Režim Vlajka · 4. 11. 2026
Hotovo: `Views/Game/GameScreen.swift`, `Views/Game/GameView.swift`, `Views/Components/FlagView.swift`, `Utilities/FlagImageCache.swift`, `Utilities/Formatting.swift`, zatím základní `Views/Game/ResultView.swift`.
NEsplněno / odchylky: žádné. Přidáno navíc: potvrzení ukončení hry, ikony správně/špatně kvůli barvoslepým (ADR-010).
Build: OK · Unit testy: 43/43 · UI testy: 3/3 (A1, A2, A4)
Důkazy: `docs/screenshots/F3-*.png` se skutečnými vlajkami, světlý, tmavý, velké písmo.
Nalezeno ve screenshotech: výchozí styl tlumil zodpovězené možnosti, nahrazen vlastním stylem.
Další krok: F4.

### Fáze 2 – F2 GameEngine · 4. 11. 2026
Hotovo: `Game/GameEngine.swift`, `Game/QuestionGenerator.swift`, `Game/QuizModels.swift`, `Game/GameConfig.swift`, `Game/SeededGenerator.swift`, `Persistence/ProgressRecorder.swift`.
NEsplněno / odchylky: žádné. Přidáno navíc: `ProgressRecorder` zapisuje objevené země hned po odpovědi.
Rozhodl jsem sám: ADR-009.
Build: OK · Unit testy: 43/43 · UI testy: 2/2
Důkazy: `GameEngineTests`, `QuestionGeneratorTests`, referenční vektor SplitMix64.
Další krok: F3 Herní obrazovka.

### Fáze 1 – F1 Stažení dat · 4. 11. 2026
Hotovo: `CountryDTO` a `CountriesPage` (`Vlajkar/Vlajkar/Models/CountryDTO.swift`), klient se stránkováním a chybami (`Networking/CountriesClient.swift`), upsert a vlajky po 6 (`Persistence/CountrySync.swift`), průběh, chyba a záloha (`Views/Home/SetupView.swift`, `Networking/BundledCountries.swift`).
NEsplněno / odchylky: žádné. Přidáno navíc: tlačítko „Pokračovat s přibalenými daty“ (ADR-007).
Rozhodl jsem sám: ADR-007, ADR-008.
Build: OK · Unit testy: 18/18 · UI testy: 2/2 (A1, A2)
Důkazy: skutečné stažení ze živého API v simulátoru: 250 zemí, 193 v OSN, 250 vlajek, Česko/Prague/10903655. `docs/screenshots/F1-stahovani-svetly.png`.
Čeká na ruční ověření: první stažení na iPhonu.
Další krok: F2 GameEngine.

### Fáze 0 – kostra a dokumentace · 4. 11. 2026
Hotovo: nastavení iOS 17, Swift 6, jen iPhone, sdílené schéma, `.gitignore`, struktura složek, `Country`, `GameResult`, `GameMode`, `LaunchOptions`, `AppDependencies`, `VlajkarApp`, `RootView`, `HomeView`, data API v `docs/api/`, dokumentace.
NEsplněno / odchylky: `Secrets.plist` místo `Secrets.xcconfig` (ADR-002). Přidáno navíc: `test.sh`, další spouštěcí přepínače (ADR-006).
Rozhodl jsem sám: ADR-002, 003, 005, 006.
Build: OK · Unit testy: 2/2 · UI testy: 1/1
Důkazy: `./test.sh all`
Čeká na ruční ověření: nic.
Další krok: F1 Stažení dat.

## Otevřené problémy
Zatím žádné.
