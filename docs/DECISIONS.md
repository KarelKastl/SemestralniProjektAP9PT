# Rozhodnutí

## ADR-001 · 4. 11. 2026 · REST Countries v5 místo v3.1
**Kontext:** verze v1–v4 jsou vypnuté. **Rozhodnutí:** použít `api.restcountries.com/countries/v5`. **Alternativy:** sada mledoze bez klíče nemá počet obyvatel. **Důsledky:** nutný klíč, stránkování, jiná struktura. **Kdo rozhodl:** já, na doporučení agenta.

## ADR-002 · 4. 11. 2026 · API klíč v `Secrets.plist` místo `Secrets.xcconfig`
**Kontext:** prompt navrhoval `Config/Secrets.xcconfig` přes build setting. Nový formát `project.xcproj` nemá ověřený zápis pro základní konfiguraci. **Rozhodnutí:** gitignorovaný `Vlajkar/Vlajkar/Secrets.plist`, který se díky synchronizované složce přibalí do aplikace. Šablona je `Config/Secrets.example.plist`. **Důsledky:** bez souboru se projekt sestaví a použije přibalená data. Klíč je v aplikaci čitelný, což je pro školní projekt vědomý kompromis. **Kdo rozhodl:** agent sám.

## ADR-003 · 4. 11. 2026 · Jen iPhone na výšku
**Kontext:** herní obrazovka se má vejít bez scrollu, na šířku má iPhone 12 mini výšku jen 375 bodů. **Rozhodnutí:** jen iPhone, jen portrét. Otočení telefonu tím nemůže rozbít rozložení. **Alternativy:** samostatné rozložení na šířku, mimo rozsah. **Kdo rozhodl:** agent sám.

## ADR-004 · 4. 11. 2026 · Hlavní města anglicky
**Kontext:** API je vrací anglicky a české překlady nedodává. **Rozhodnutí:** zobrazovat je beze změny. **Kdo rozhodl:** zadání.

## ADR-005 · 4. 11. 2026 · Vývojový region čeština
**Kontext:** systémové prvky (mazání, hledání) mají být česky. **Rozhodnutí:** `development` lokalizace projektu je `cs`. **Kdo rozhodl:** agent sám.

## ADR-006 · 4. 11. 2026 · Spouštěcí přepínače jen v DEBUG
**Kontext:** UI testy potřebují pevná data a pevnou náhodu. **Rozhodnutí:** `LaunchOptions.current` čte argumenty jen v DEBUG: `-uiTestFixtures`, `-uiTestOffline`, `-uiTestSeed`, `-uiTestStore`, `-uiTestReset`, `-uiTestTimer`, `-uiTestStubAPI`. Poslední čtyři jsou navíc proti zadání, potřebuje je restart test, test časovače a test stahování. **Kdo rozhodl:** zadání a agent.

## ADR-007 · 4. 11. 2026 · Záloha na tlačítko
**Kontext:** zadání chce při chybě hlášku a „Zkusit znovu“ a zároveň zálohu. **Rozhodnutí:** chyba ukáže „Zkusit znovu“ i „Pokračovat s přibalenými daty“. Bez vlajek je režim Vlajka nedostupný, dokud je nedoplní F7. **Kdo rozhodl:** agent sám.

## ADR-008 · 4. 11. 2026 · Chybějící vlajky po částečném selhání
**Kontext:** výpadek během stahování vlajek. **Rozhodnutí:** hotové vlajky se uloží, opakování stáhne jen chybějící. **Kdo rozhodl:** agent sám.

## ADR-009 · 4. 11. 2026 · Hodnotový `QuizCountry` a méně než 10 otázek
**Kontext:** `GameEngine` nemá záviset na SwiftData a region může mít méně než 10 vhodných zemí. **Rozhodnutí:** engine dostává `QuizCountry`. Pokud je zemí méně, hra má méně otázek a země se neopakují. Ve Víc/méně se dvojice se stejným počtem obyvatel přeskakuje a v postupu se počítá lidnatější země. **Kdo rozhodl:** agent sám.

## ADR-010 · 4. 11. 2026 · Ukončení hry a ikony u výsledku
**Kontext:** odchod ze hry uprostřed a barvy nestačí všem uživatelům. **Rozhodnutí:** tlačítko Ukončit s potvrzením, rozehraná hra se neuloží, ale objevené země zůstanou. Výsledek odpovědi má i ikonu. **Kdo rozhodl:** agent sám.

## ADR-011 · 4. 11. 2026 · Skutečná data pro screenshoty
**Kontext:** testovací data mají vygenerované vlajky. **Rozhodnutí:** `ScreenshotTests` používá samostatné úložiště naplněné jednou ze skutečného API, další běhy API nevolají. Běží jen přes `screenshots.sh`, jinak se přeskočí. **Kdo rozhodl:** agent sám.

## ADR-012 · 4. 11. 2026 · Ukazatel atlasu počítá členy OSN
**Kontext:** v atlasu jsou i země mimo OSN, ukazatel má tvar „Objeveno 57 / 193“. **Rozhodnutí:** čitatel i jmenovatel počítají jen členy OSN, seznam ukazuje všechny objevené země. **Kdo rozhodl:** agent sám.
