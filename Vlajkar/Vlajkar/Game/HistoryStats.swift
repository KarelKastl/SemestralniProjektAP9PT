import Foundation

/// Nejlepší skóre pro každý režim (F5).
enum HistoryStats {
    /// B2: posledních 30 her od nejstarší, procenta správných odpovědí.
    static func successPoints(in results: [GameResult], limit: Int = 30) -> [SuccessPoint] {
        results
            .filter { $0.total > 0 }
            .sorted { $0.date < $1.date }
            .suffix(limit)
            .enumerated()
            .map { index, result in
                SuccessPoint(id: index, date: result.date, percent: result.score * 100 / result.total)
            }
    }

    static func bestScores(in results: [GameResult]) -> [(mode: GameMode, score: Int)] {
        GameMode.allCases.compactMap { mode in
            results.filter { $0.gameMode == mode }.map(\.score).max().map { (mode, $0) }
        }
    }
}

nonisolated struct SuccessPoint: Identifiable, Equatable, Sendable {
    var id: Int
    var date: Date
    var percent: Int
}
