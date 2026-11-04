import Foundation

/// Přibalená záloha `countries-fallback.json` pro výpadek API (F1).
nonisolated enum BundledCountries {
    static func load(from bundle: Bundle = .main) throws -> [CountryDTO] {
        guard let url = bundle.url(forResource: "countries-fallback", withExtension: "json") else {
            throw CountriesError.invalidData
        }
        do {
            return try JSONDecoder().decode([CountryDTO].self, from: Data(contentsOf: url))
        } catch {
            throw CountriesError.invalidData
        }
    }
}
