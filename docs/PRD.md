# Vlajkař – PRD

## Cíl
Zeměpisný kvíz pro iPhone 12 mini. Aplikace jednou stáhne země z REST Countries v5, uloží je do SwiftData a pak funguje úplně offline včetně vlajek. Pamatuje si historii her, rekordy a atlas objevených zemí.

## Funkce
| ID | Funkce | Stručně |
| --- | --- | --- |
| F1 | Stažení dat | Stránkované stažení, vlajky po nejvýš 6 najednou, průběh, chyba, záloha |
| F2 | GameEngine | 10 otázek, skóre, série, stav otázky, časovač, vnější generátor náhody |
| F3 | Režim Vlajka | Vlajka a 4 nebo 6 možností bez scrollu, barvy, haptika |
| F4 | Další režimy a nastavení | Hlavní město, Víc/méně obyvatel, region, možnosti, časovač, OSN |
| F5 | Výsledek a historie | Výsledek, uložení, seznam, mazání, rekordy |
| F6 | Atlas | Objevené země, hledání, filtr, detail s mapou |
| F7 | Obnovení dat | Upsert bez ztráty postupu |
| F8 | Doladění | 375 bodů, tmavý režim, velké písmo, VoiceOver, ikona, výkon |
| B1 | Denní výzva | Stejných 10 otázek pro daný den, jedna hra denně |
| B2 | Graf úspěšnosti | Swift Charts z `GameResult` |
| B3 | App Intent | „Zahraj denní výzvu“ pro Zkratky a Siri |

## Okrajové případy
- API vrací 254 záznamů, 4 bez kódu se přeskočí (Abcházie, Severní Kypr, Somaliland, Jižní Osetie).
- Země bez hlavního města se nedostane do režimu Hlavní město, země bez vlajky do režimu Vlajka.
- Země s populací 0 se nedostane do režimu Víc/méně.
- Region s méně zeměmi než možností doplní špatné odpovědi z celého světa.
- Prázdná databáze, výpadek sítě, chyba klíče a vyčerpaný limit.
- Rychlé dvojité ťuknutí, vypršení časovače během animace, odchod ze hry uprostřed.

## Mimo rozsah
Foundation Models, české překlady hlavních měst, iPad, Mac, účty, online žebříčky, jiné API.

## Akceptační kritéria
| ID | Udělám → musím vidět | UI test | Ověřil agent | Ověřil člověk |
| --- | --- | --- | --- | --- |
| A1 | Spustím aplikaci s prázdnou databází → vidím průběh stahování a pak domovskou obrazovku | `testA01_firstLaunchDownloadsData` | ✅ | – |
| A2 | Spustím bez sítě s prázdnou databází → vidím českou chybu, „Zkusit znovu“ a můžu pokračovat s přibalenými daty | `testA02_offlineShowsErrorAndFallback` | ✅ | – |
| A3 | Odehraju hru → ukončím aplikaci → spustím bez sítě → odehraju další hru a vidím vlajky i historii a atlas | `testA03_restartKeepsDataOffline` | ✅ | ✅ |
| A4 | Hraju režim Vlajka → po odpovědi vidím správně/špatně, zvýrazněnou správnou odpověď a Další, ukazatel otázek 1/10 až 10/10 | `testA04_flagModeFullGame` | ✅ | – |
| A5 | Nastavím 6 možností → všechna tlačítka jsou na iPhonu 12 mini vidět bez scrollu | `testA05_sixOptionsFitWithoutScrolling` | ✅ | – |
| A6 | Hraju Hlavní město → vidím zemi a volím z měst | `testA06_capitalMode` | ✅ | – |
| A7 | Hraju Víc/méně → ťuknu na zemi a vidím obě čísla česky | `testA07_populationMode` | ✅ | – |
| A8 | Změním nastavení hry → restartuji → nastavení zůstane | `testA08_settingsPersist` | ✅ | – |
| A9 | Zapnu časovač → nechám ho vypršet → otázka je špatně | `testA09_timerExpiryCountsAsWrong` | ✅ | – |
| A10 | Dohraju hru → vidím výsledek → hra je v historii → smažu ji swipem | `testA10_resultAndHistoryDelete` | ✅ | – |
| A11 | Otevřu prázdnou historii a prázdný atlas → vidím vysvětlující prázdný stav | `testA11_emptyStates` | ✅ | – |
| A12 | Objevím země → v atlasu je hledám bez diakritiky, filtruji region a vidím „Objeveno x / 193“ | `testA12_atlasSearchAndFilter` | ✅ | – |
| A13 | Otevřu zemi v atlasu → vidím vlajku, údaje, statistiku a mapu | `testA13_atlasDetail` | ✅ | ✅ |
| A14 | Aktualizuji data → vidím počty aktualizovaných a přidaných a objevené země zůstanou | `testA14_refreshKeepsProgress` | ✅ | – |

Bonusy B1, B2 a B3 jsou hotové. Testy `testB1`, `testB2`, `testB3`. Sloupec *Ověřil člověk* vyplňte po ruční kontrole podle `docs/VERIFICATION.md`.
