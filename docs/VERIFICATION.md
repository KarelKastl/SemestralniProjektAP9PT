# Ověření

Datum 4. 11. 2026. Simulátor iPhone 12 mini, iOS 27.2, Xcode 27.2.

## Souhrn
- `./test.sh all`: unit testy 63/63, UI testy 25/25, 3 screenshotové testy přeskočeny (běží přes `./screenshots.sh`), čas 8 min 52 s, `** TEST SUCCEEDED **`.
- Čistý Release build pro simulátor: bez chyb a varování.
- Build pro iPhone: bez chyb a varování.
- Přepínače `uiTest` v binárce Release nejsou, `strings` našel 0 výskytů.
- Skutečné API v simulátoru: 250 zemí, 193 členů OSN, 250 vlajek.
- Skutečný iPhone 12 mini, iOS 27.2: aplikace nainstalovaná a spuštěná přes `devicectl`, databáze z telefonu obsahuje 250 zemí, 193 členů OSN a 250 vlajek.

## Akceptační kritéria
| Kritérium | Automatický důkaz | Ruční postup na iPhonu | Výsledek agenta | Poznámka člověka |
| --- | --- | --- | --- | --- |
| A1 | `testA01_firstLaunchDownloadsData` | Smažte aplikaci, spusťte ji se sítí, sledujte „Stahuji vlajky“. | ✅ | |
| A2 | `testA02_offlineShowsErrorAndFallback` | Smažte aplikaci, zapněte režim Letadlo, spusťte ji. | ✅ | |
| A3 | `testA03_restartKeepsDataOffline` | Odehrajte hru, ukončete aplikaci, zapněte režim Letadlo, odehrajte další. | ✅ | |
| A4 | `testA04_flagModeFullGame` | Odehrajte režim Vlajka celý. | ✅ | |
| A5 | `testA05_sixOptionsFitWithoutScrolling` | Nastavte 6 možností a zkontrolujte, že nic nechybí. | ✅ | |
| A6 | `testA06_capitalMode` | Spusťte Hlavní město. | ✅ | |
| A7 | `testA07_populationMode` | Spusťte Víc/méně a zkontrolujte česká čísla. | ✅ | |
| A8 | `testA08_settingsPersist` | Změňte nastavení a restartujte aplikaci. | ✅ | |
| A9 | `testA09_timerExpiryCountsAsWrong` | Zapněte časovač a 15 sekund nic nedělejte. | ✅ | |
| A10 | `testA10_resultAndHistoryDelete` | Dohrajte hru a smažte ji swipem. | ✅ | |
| A11 | `testA11_emptyStates` | Otevřete prázdnou historii a atlas. | ✅ | |
| A12 | `testA12_atlasSearchAndFilter` | Hledejte „cesko“ a filtrujte region. | ✅ | |
| A13 | `testA13_atlasDetail` | Otevřete zemi a zkontrolujte mapu. | ✅ | |
| A14 | `testA14_refreshKeepsProgress` | Ťukněte na Aktualizovat data zemí a zkontrolujte atlas. | ✅ | |

## Restart test
`testA03_restartKeepsDataOffline` hraje na trvalém úložišti, aplikaci ukončí a druhé spuštění je bez fixtures a s klientem bez sítě. Historie, atlas i vlajky přišly z databáze. Ruční kontrola přes `xcrun simctl terminate` a `xcrun simctl launch` na úložišti se skutečnými daty: před ukončením 250 zemí, 250 vlajek, 36 her, 5 objevených zemí, po dalším spuštění stejné hodnoty. Screenshot `docs/screenshots/F5-po-restartu-svetly.png`.

## Test bez sítě
`testA02`, `testA03` a `testR6` používají `-uiTestOffline`. Skutečný režim Letadlo čeká na ruční ověření.

## Odolnost
`RobustnessUITests` R1–R7 a B1–B3 prošly, přehled je v `docs/AGENT-REVIEW.md`.

## Ověřeno člověkem na iPhonu (4. 11. 2026)
- Ikona aplikace: ✅ červenobílá vlajka.
- Zkratka v aplikaci Zkratky: ✅ otevře denní výzvu.
- Režim Letadlo: ✅ hra ukládá data i bez sítě.

## Čeká na ruční ověření
2. VoiceOver: projděte hru a ověřte, že vlajka zní „Vlajka, hádej zemi“.
3. Velké písmo na iPhonu: Nastavení → Zpřístupnění → Velikost textu.
4. Mapa: v simulátoru se při screenshotech nenačetly dlaždice, ověřte detail země se sítí. Bez sítě mapa dlaždice nemá, zbytek aplikace funguje.
5. Haptika: odezva po odpovědi je cítit jen na zařízení.
7. Výpadek sítě během stahování vlajek na reálném zařízení.
8. Běh na iOS 17: v Xcode je jen simulátor 27.2, kompatibilitu hlídá kompilátor.

Bezplatný podpis platí 7 dní, potom aplikaci znovu spusťte z Xcode.

## Jak ověřit zkratku B3 na iPhonu
1. Otevřete aplikaci Zkratky a ťukněte na +.
2. Do hledání napište Vlajkař a vyberte „Zahraj denní výzvu“.
3. Ťukněte na ▶ dole. Vlajkař se otevře rovnou v denní výzvě.

Pokud jste dnešní výzvu už odehráli, zkratka otevře jen domovskou obrazovku. Pro nové spuštění smažte dnešní řádek „Denní výzva“ v Historii. Hlasové spuštění přes Siri ověřené není, na prezentaci použijte aplikaci Zkratky.

## Screenshoty
`docs/screenshots/`, přípony `-svetly`, `-tmavy`, `-velke`.
