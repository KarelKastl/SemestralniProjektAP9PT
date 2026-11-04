import Foundation

/// Denní výzva: pro stejný den stejných 10 otázek (B1).
nonisolated enum DailyChallenge {
    static let config = GameConfig(mode: .flag, isDaily: true)

    /// Semínko z kalendářního dne, např. 20261104.
    static func seed(for date: Date, calendar: Calendar = .current) -> UInt64 {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        let year = UInt64(parts.year ?? 0)
        let month = UInt64(parts.month ?? 0)
        let day = UInt64(parts.day ?? 0)
        return year * 10_000 + month * 100 + day
    }
}

extension DailyChallenge {
    /// Výsledek dnešní výzvy, pokud už byla odehraná. Jedna hra denně.
    static func result(in results: [GameResult], on date: Date, calendar: Calendar = .current) -> GameResult? {
        results.first { $0.isDaily && calendar.isDate($0.date, inSameDayAs: date) }
    }
}
