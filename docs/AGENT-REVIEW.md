# Sebereview agenta

Doplňováno po každé featuře podle kontrolního seznamu z promptu.

## F1
- Endpoint, klíč, stránkování → ✅ `Vlajkar/Vlajkar/Networking/CountriesClient.swift`
- Vlajky PNG, `.externalStorage`, nejvýš 6 najednou, průběh → ✅ `Persistence/CountrySync.swift`, `Models/Country.swift`
- Česká chyba a Zkusit znovu → ✅ `Views/Home/SetupView.swift`, test A2
- Prázdný kód → ✅ přeskočeno, test `insertsNewCountriesAndSkipsRecordsWithoutCode`
- `@Observable`, předání přes `.environment` → ✅ `CountrySync`, `AppDependencies`
- Nalezeno v review: test zálohy nic neověřoval, přepsán na přesné počty.
- Predikce: částečné selhání vlajek a klíč v aplikaci (ADR-002).

## F2
- 10 otázek, skóre, série, stav, časovač, vnější generátor → ✅ `Game/GameEngine.swift`
- Špatné možnosti ze stejného regionu, jinak svět → ✅ `Game/QuestionGenerator.swift`
- Země bez dat se do otázky nedostane → ✅ `eligibleCountries`
- Dvojité ťuknutí → ✅ test `doubleTapCountsOnce`
- Nalezeno v review: stejně pojmenovaná hlavní města by vytvořila dvě stejné možnosti, opraveno a otestováno.
- Predikce: vypršení časovače během přechodu na další otázku.

## F3
- Vlajka a 4/6 možností, barvy, haptika, Další, ukazatel → ✅ `Views/Game/GameView.swift`
- Žádné dekódování v `body` → ✅ `Utilities/FlagImageCache.swift`
- `@Observable`, stav v enginu, hra vytvořena jednou → ✅ `Views/Game/GameScreen.swift`
- VoiceOver popisek vlajky neprozradí zemi → ✅ `QuestionPrompt`
- Předání environmentu a `#Preview` → ✅ `PreviewData`
- Predikce: dlouhé názvy zemí ve 2×3 mřížce.

## F4
- Hlavní město a Víc/méně, česká čísla → ✅ `Views/Game/GameView.swift`, `Utilities/Formatting.swift`
- `Form`, region, 4/6, časovač, OSN, `@AppStorage` → ✅ `Views/Home/HomeView.swift`
- Vypršení časovače = špatně → ✅ `GameEngine.tick`, test A9
- Predikce: časovač a přechod na další otázku, `.task(id:)` ho ruší.

## F5
- Výsledek, nový rekord, uložení jednou → ✅ `Views/Game/ResultView.swift`
- `@Query`, nejnovější nahoře, mazání objektu → ✅ `Views/History/HistoryView.swift`
- Prázdná historie → ✅ `ContentUnavailableView`
- Predikce: dvojité uložení při návratu na výsledek, hlídá `savedEngineID`.
