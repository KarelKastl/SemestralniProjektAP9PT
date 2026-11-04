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

## F6
- `@Query`, hledání bez diakritiky, filtr, ukazatel → ✅ `Views/Atlas/AtlasView.swift`, `Game/AtlasFilter.swift`
- Detail s `Map` a `Marker` → ✅ `Views/Atlas/CountryDetailView.swift`
- `NavigationStack`, `NavigationLink(value:)`, `.navigationDestination(for:)` → ✅
- Nalezeno v review: Antarktida má šířku -90, střed mapy je omezený na ±80.

## F7
- Upsert podle `code`, nikdy nemaže → ✅ `CountrySync.upsert`, test `upsertKeepsPlayerProgressAndFlag`, A14
- Počty aktualizovaných a přidaných → ✅ `Views/Settings/SettingsView.swift`
- Predikce: souběh dvou aktualizací hlídá `phase.isRunning`.

## F8
- 375 bodů, tmavý režim, velké písmo → ✅ `docs/screenshots/*-svetly.png`, `*-tmavy.png`, `*-velke.png`
- VoiceOver: vlajka neprozradí zemi → ✅ `QuestionPrompt`, hlasový naslech čeká na člověka
- Ikona → ✅ `Assets.xcassets/AppIcon.appiconset`
- Výkon: žádné dekódování v `body` → ✅ `Utilities/FlagImageCache.swift`
- Nalezeno: nefunkční poslední tlačítko s velkým písmem, nepřeložitelný Release build, ztlumené zodpovězené možnosti.

## Fáze 9 – Rozbij to
| Scénář | Výsledek | Důkaz |
| --- | --- | --- |
| Dvojité ťuknutí na odpověď | ✅ počítá se jednou | `testR1`, `doubleTapCountsOnce` |
| Dvojité ťuknutí na Další | ✅ posun o jednu | `doubleTapOnNextAdvancesOnce` |
| Odchod ze hry uprostřed | ✅ hra se neuloží | `testR2` |
| Ztráta sítě při vlajkách | ✅ hotové vlajky zůstanou, opakování doplní zbytek | `failedFlagIsDownloadedOnRetry` |
| Oceánie se 6 možnostmi | ✅ | `testR3` |
| Největší písmo | ✅ scrolluje a jde dohrát | `testR4`, `testF8_largeTextFullGame` |
| Tmavý režim | ✅ | `docs/screenshots/*-tmavy.png` |
| Otočení | ✅ aplikace zůstane na výšku | `testR5` |
| Aktualizace bez sítě | ✅ chyba, data zůstanou | `testR6` |
| Hrát znovu | ✅ každá hra se uloží jednou | `testR7` |

## Bonusy
- B1 stejné otázky pro den, jedna hra denně → ✅ `Game/DailyChallenge.swift`, `testB1`
- B2 Swift Charts z `GameResult` → ✅ `Views/History/SuccessChartView.swift`, `testB2`
- B3 App Intent otevře hru → ✅ `Game/PlayDailyChallengeIntent.swift`, `testB3`, spuštění ze Zkratek čeká na člověka

## Celkové hodnocení agenta
Dobře: testy odhalily skutečné chyby, které by člověk snadno přehlédl. Špatně: první verze F3 obsahovala kód z F4 a Release build se nezkoušel průběžně.

## Predikce: kde bych na místě studenta hledal chybu
1. Klíč v aplikaci je čitelný, u reálného produktu by patřil na server.
2. Filtr OSN a ukazatel atlasu počítají různé množiny zemí.
3. Rekord se počítá ze skóre, ne z procent, region s méně otázkami tak nemůže rekord překonat.
4. Denní výzva závisí na datech v telefonu, po aktualizaci dat se může otázka změnit.
