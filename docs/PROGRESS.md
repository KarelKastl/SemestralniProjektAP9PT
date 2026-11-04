# Průběh

### Finále – předávka · 4. 11. 2026
Hotovo: všechny F1–F8, B1–B3, A1–A14 zelené, dokumentace a předávka.
NEsplněno / odchylky: `Secrets.plist` místo `Secrets.xcconfig` (ADR-002), screenshoty F4–F7 vznikly ve F8.
Build: OK bez varování · Unit testy: 62/62 · UI testy: 25/25
Důkazy: `docs/VERIFICATION.md`, `docs/screenshots/`, data z reálného iPhonu 250/193/250.
Čeká na ruční ověření: seznam ve `docs/VERIFICATION.md`.
Další krok: ruční kontrola, push v aplikaci GitHub, výměna API klíče po dokončení.

### Fáze 10 – Bonusy · 4. 11. 2026
Hotovo: B1 `Game/DailyChallenge.swift`, B2 `Views/History/SuccessChartView.swift`, B3 `Game/PlayDailyChallengeIntent.swift`, přepínání záložek a cesta hry v `Views/Home/MainTabView.swift`.
Rozhodl jsem sám: ADR-014.
Build: OK, varování App Intents zmizelo · Unit testy: 62/62 · UI testy: 25/25
Nalezeno ve screenshotu: časová osa slila hry z jednoho dne, osa X je teď pořadí her.

### Fáze 9 – Rozbij to · 4. 11. 2026
Hotovo: sedm scénářů v `Vlajkar/VlajkarUITests/RobustnessUITests.swift` a dva nové unit testy.
Výsledek: dvojité ťuknutí, odchod ze hry, Oceánie se 6 možnostmi, největší písmo, otočení, aktualizace bez sítě a opakovaná hra fungují.
Nalezeno a opraveno: tlačítko „Pokračovat“ se v dialogu na iOS 27 nezobrazovalo; vlajky se při stahování ukládaly až na konci, teď po 25; stará hláška o aktualizaci zůstávala v Nastavení.
Build: OK · Unit testy: 54/54 · UI testy: 22/22
Čeká na ruční ověření: skutečná ztráta sítě během stahování vlajek na iPhonu.
Další krok: bonusy B1, B2, B3.

### Fáze 8 – F8 Doladění pro iPhone 12 mini · 4. 11. 2026
Hotovo: ikona `Assets.xcassets/AppIcon.appiconset`, velké písmo ve `Views/Game/GameView.swift`, VoiceOver popisky, dekódování vlajek mimo `body`, screenshoty všech obrazovek ve třech variantách, Release build a build pro iPhone.
NEsplněno / odchylky: launch screen je automaticky generovaný systémem (ADR-013). Screenshoty pro F4 až F7 vznikly až v této fázi.
Build: OK, jediné varování `appintentsmetadataprocessor` zmizí s B3 · Unit testy: 52/52 · UI testy: 15/15
Nalezeno testem: s velkým písmem nešlo klepnout na „Zobrazit výsledek“. Tlačítko s dlouhým textem bez šířky v popisku nedostalo klepnutí. Šířka je teď v popisku, hlídá to `testF8_largeTextFullGame`.
Nalezeno buildem: Release build nešel přeložit, protože `#Preview` používaly data dostupná jen v DEBUG. Náhledy jsou v `#if DEBUG`.
Ověřeno: `uiTest` přepínače v binárce Release nejsou (`strings` našel 0 výskytů).
Čeká na ruční ověření: VoiceOver naslech, skutečné dlaždice mapy, chování na iPhonu.
Další krok: Fáze 9.

### Fáze 7 – F7 Obnovení dat · 4. 11. 2026
Hotovo: `Views/Settings/SettingsView.swift` a upsert v `Persistence/CountrySync.swift`. Zachová `discoveredAt`, `correctCount`, `wrongCount` i uložené vlajky a doplní chybějící.
Build: OK · Unit testy: 52/52 · UI testy: 14/14, test A14
Další krok: F8.

### Fáze 6 – F6 Atlas · 4. 11. 2026
Hotovo: `Views/Atlas/AtlasView.swift`, `Views/Atlas/CountryDetailView.swift`, `Game/AtlasFilter.swift`.
Rozhodl jsem sám: ADR-012.
Přidáno navíc: přepínač `-uiTestDiscover`.
Nalezeno testem: `.searchable` se v iOS 27 samo nezobrazilo, nastaveno `displayMode: .always`.
Build: OK · UI testy: A3, A11, A12, A13 zelené
Další krok: F7.

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
Žádné blokující. Ruční ověření je ve `docs/VERIFICATION.md`.
