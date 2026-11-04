import Foundation

/// Hledání a filtr atlasu (F6). Bez ohledu na diakritiku a velikost písmen.
enum AtlasFilter {
    static func normalized(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Formatting.czech)
    }

    static func apply(_ countries: [Country], search: String, region: RegionFilter) -> [Country] {
        let query = normalized(search.trimmingCharacters(in: .whitespacesAndNewlines))
        return countries
            .filter { region == .world || $0.region == region.rawValue }
            .filter { query.isEmpty || normalized($0.nameCS).contains(query) }
            .sorted { $0.nameCS.compare($1.nameCS, locale: Formatting.czech) == .orderedAscending }
    }
}
