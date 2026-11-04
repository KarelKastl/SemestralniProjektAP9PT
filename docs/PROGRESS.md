# Průběh

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
