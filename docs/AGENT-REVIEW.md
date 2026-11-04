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
