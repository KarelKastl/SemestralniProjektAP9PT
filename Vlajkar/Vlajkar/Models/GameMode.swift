import Foundation

/// Herní režimy (F3, F4).
nonisolated enum GameMode: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case flag
    case capital
    case population

    var id: String { rawValue }

    var title: String {
        switch self {
        case .flag: "Vlajka"
        case .capital: "Hlavní město"
        case .population: "Víc, nebo méně obyvatel"
        }
    }

    var symbol: String {
        switch self {
        case .flag: "flag.fill"
        case .capital: "building.columns.fill"
        case .population: "person.2.fill"
        }
    }
}
