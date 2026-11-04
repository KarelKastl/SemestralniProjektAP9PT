# Podklady k prezentaci (10 minut)

## Osnova slajdů
1. Vlajkař: co to je a pro koho.
2. Ukázka aplikace: tři režimy, atlas, historie.
3. Architektura: API → SwiftData → GameEngine → Views.
4. Offline: vlajky jako `.externalStorage`.
5. Co se změnilo: REST Countries v3.1 přestalo fungovat, přechod na v5.
6. Testování: 62 unit testů, 25 UI testů, A1–A14.
7. Chyby nalezené testy a screenshoty.
8. Práce s agentem: co šlo dobře a co ne.
9. Čísla projektu.
10. Závěr a otázky.

## Demo krok za krokem
1. Ukažte domovskou obrazovku a nastavení.
2. Zahrajte dvě otázky režimu Vlajka, jednu špatně.
3. Přepněte na 6 možností a ukažte mřížku.
4. Zapněte režim Letadlo a ukažte, že vlajky fungují.
5. Otevřete Historii s grafem.
6. Otevřete Atlas, hledejte „cesko“ bez diakritiky a otevřete detail. Mapu ukažte se sítí.
7. V Nastavení ťukněte na aktualizaci a ukažte, že atlas zůstal.

## Pět ukázek kódu
| Co | Kde |
| --- | --- |
| Herní stav | `Vlajkar/Vlajkar/Game/GameEngine.swift:51` |
| Odlišné možnosti a region | `Vlajkar/Vlajkar/Game/QuestionGenerator.swift:17` |
| Upsert, který nemaže postup | `Vlajkar/Vlajkar/Persistence/CountrySync.swift:72` |
| Stahování vlajek po 6 | `Vlajkar/Vlajkar/Persistence/CountrySync.swift:121` |
| Hledání bez diakritiky | `Vlajkar/Vlajkar/Game/AtlasFilter.swift:9` |

## Co agent udělal dobře a špatně
**Dobře:** ověřil API před psaním kódu a našel jeho vypnutí, testy pro každé kritérium, důkazy ze screenshotů, hlídání klíče před commitem.

**Špatně:** Release build se nezkoušel průběžně, kód F4 skončil v commitu F3, screenshoty F4 až F7 vznikly až ve F8.

## Nalezené chyby a opravy
| Chyba | Jak se našla | Oprava |
| --- | --- | --- |
| REST Countries v3.1 vypnuté | Kontrola `curl` | Přechod na v5 s klíčem |
| S velkým písmem nešlo ťuknout na „Zobrazit výsledek“ | UI test | Šířka v popisku tlačítka |
| Release build nešel přeložit | Čistý build | `#if DEBUG` kolem náhledů |
| Zodpovězené možnosti byly ztlumené | Screenshot | Vlastní styl tlačítka |
| Hledání v atlasu nebylo vidět | UI test | `displayMode: .always` |
| Stejně pojmenovaná města v možnostech | Review | Kontrola unikátních názvů |
| Tlačítko Pokračovat v dialogu chybělo | UI test | Odstraněna role `.cancel` |
| Vlajky se ukládaly až na konci | Fáze Rozbij to | Ukládání po 25 |
| Graf slil hry z jednoho dne | Screenshot | Osa podle pořadí her |

## Čísla projektu
39 souborů Swiftu v aplikaci, 2 400 řádků aplikace, 1 400 řádků testů, 62 unit testů, 25 UI testů, 14 akceptačních kritérií, 14 rozhodnutí, 12 commitů.

## Připravené odpovědi
1. **Kde je filtrování?** `Vlajkar/Vlajkar/Game/AtlasFilter.swift:9`.
2. **Kde žije stav?** V `GameEngine`, `Vlajkar/Vlajkar/Game/GameEngine.swift:6`.
3. **Kde se ukazuje chyba?** `Vlajkar/Vlajkar/Views/Home/SetupView.swift:43`.
4. **Proč `@Observable`?** Přesnější sledování změn, kurz nepoužívá `ObservableObject`.
5. **Proč se vlajky ukládají do databáze?** `AsyncImage` bez sítě nic nenačte.
6. **Proč nejsou města česky?** API je česky nemá a nevymýšlíme překlady, ADR-004.
7. **Jak testujete offline?** Přepínač `-uiTestOffline`, `Vlajkar/Vlajkar/App/LaunchOptions.swift:15`. Skutečný režim Letadlo ověřuji ručně.
8. **Jak jsou testy zopakovatelné?** Generátor SplitMix64 a pevné semínko.
9. **Proč je klíč v aplikaci?** Školní kompromis, ADR-002. V produktu by byl na serveru.
10. **Co se stane při výpadku API?** Česká chyba, Zkusit znovu nebo přibalená data bez vlajek.
