import Foundation

/// Filtr regionu v nastavení hry (F4). `rawValue` odpovídá hodnotě z API.
nonisolated enum RegionFilter: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case world
    case europe = "Europe"
    case asia = "Asia"
    case africa = "Africa"
    case americas = "Americas"
    case oceania = "Oceania"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .world: "Celý svět"
        case .europe: "Evropa"
        case .asia: "Asie"
        case .africa: "Afrika"
        case .americas: "Amerika"
        case .oceania: "Oceánie"
        }
    }

    /// Název regionu z API pro zobrazení v atlasu.
    static func title(forAPIRegion region: String) -> String {
        if region == "Antarctic" { return "Antarktida" }
        return RegionFilter(rawValue: region)?.title ?? region
    }
}

/// Parametry jedné hry.
nonisolated struct GameConfig: Hashable, Sendable {
    var mode: GameMode
    var region: RegionFilter = .world
    var optionCount = 4
    var usesTimer = false
    var unMembersOnly = true
    var isDaily = false
}
