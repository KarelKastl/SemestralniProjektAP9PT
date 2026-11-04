# Vlajkař – pravidla pro agenta

Semestrální projekt AP9PT. Zeměpisný kvíz pro iPhone ve SwiftUI a SwiftData. Čeština v UI i dokumentaci, identifikátory anglicky.

## Autonomie
- Neptej se, rozhodni nejblíže zadání a zapiš do `docs/DECISIONS.md`.
- Neskončíš, dokud neplatí Definice hotového projektu. Bod obnovy je `docs/PROGRESS.md`.
- Nejvýš 3 pokusy o stejný problém, pak jednodušší řešení, zápis a další featura. Testy nemaž ani nevypínej.
- Pracuj jen v repozitáři a simulátorech. Žádné `sudo`, žádné mazání mimo projekt, žádný push.

## Platforma
iPhone 12 mini, iOS 27.2, 375 × 812 bodů. Minimum Deployments iOS 17.0. Swift 6, SwiftUI, SwiftData, MapKit, Swift Testing, XCUITest. Žádné knihovny třetích stran, žádné Foundation Models.

## Architektura
```
REST Countries v5 → CountriesClient → CountryDTO → CountrySync (upsert + vlajky) → SwiftData
SwiftData → QuizCountry → GameEngine (@Observable) → ProgressRecorder → SwiftData
```
Views jen zobrazují a posílají akce. Logika je v `Game/`, `Networking/` a `Persistence/`.

## Pravidla 1–11
1. Sdílený stav `@Observable` + `.environment` + `@Environment(Typ.self)`, objekt jednou jako `@State`. Nikdy `ObservableObject`, `@Published`, `@StateObject`, `@EnvironmentObject`.
2. Každý `#Preview` dostane environment a `.modelContainer(for:inMemory:)` s ukázkovými daty.
3. Jen `NavigationStack`, stabilní `Hashable` hodnoty, žádné `id: \.self` nad objekty, žádné `.id(UUID())`.
4. Ve filtrovaném seznamu se maže objekt z filtrovaného pole.
5. `@Model final class`, `.modelContainer` na `WindowGroup`, `@Query`, zápis přes `modelContext`.
6. API neměň: jen REST Countries v5 a jeho CDN vlajek. Při výpadku přibalená záloha.
7. Logika patří do `GameEngine` a služeb. Nová logika = nový test.
8. UI česky, čísla a data s českým locale. Žádné pevné rozměry velkých prvků.
9. Dělej jen PRD, co je navíc, zapiš do `PROGRESS.md` a `DECISIONS.md`.
10. Hotové je jen to, co ověřil build, test nebo screenshot. Ostatní „čeká na ruční ověření“.
11. Stručné české komentáře u netriviálních míst s odkazem na featuru.

## API klíč
Je v `~/.vlajkar_api_key` a v `Vlajkar/Vlajkar/Secrets.plist`, který je v `.gitignore`. Nikdy ho nezapisuj do kódu, commitů, dokumentů ani výpisů. Před commitem spusť `git grep -nI "$(cat ~/.vlajkar_api_key)"`, nesmí nic najít. Pro nový klon viz `Config/Secrets.example.plist`.

## Příkazy
```bash
./test.sh all    # build, unit a UI testy na simulátoru iPhone 12 mini
./test.sh unit
./test.sh ui
```
Simulátor: `CBAC7EA9-2478-4723-ADBD-2BEC3E01353B`. iPhone: `00008101-000610C22693001E`.
Build pro iPhone bez `-allowProvisioningUpdates`:
```bash
cd Vlajkar && xcodebuild -project Vlajkar.xcodeproj -scheme Vlajkar -destination 'platform=iOS,id=00008101-000610C22693001E' -derivedDataPath ../build/device build
```
Screenshoty: `./screenshots.sh`, ruční `xcrun simctl io <id> screenshot docs/screenshots/F3-hra-svetly.png`, režim `xcrun simctl ui <id> appearance dark`, písmo `xcrun simctl ui <id> content_size accessibility-large`.

## Dokumenty
`docs/PRD.md`, `ARCHITECTURE.md`, `DECISIONS.md`, `PROGRESS.md`, `VERIFICATION.md`, `AGENT-REVIEW.md`, `LAB-NOTES.md`, `PRESENTATION.md`, `HANDOFF.md`, `README.md`. Aktualizuj je po každé featuře.

## Definice hotového projektu
F1–F8 hotové; build bez chyb a varování; všechny testy zelené; A1–A14 mají výsledek v `PRD.md` a důkaz ve `VERIFICATION.md`; restart a offline test prošly; screenshoty všech obrazovek (světlý, tmavý, velké písmo); bonusy hotové nebo zdůvodněné; všechny dokumenty aktuální; vše commitnuté.
