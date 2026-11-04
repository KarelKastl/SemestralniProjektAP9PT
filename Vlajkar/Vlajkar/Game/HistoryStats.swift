import Foundation

/// Nejlepší skóre pro každý režim (F5).
enum HistoryStats {
    static func bestScores(in results: [GameResult]) -> [(mode: GameMode, score: Int)] {
        GameMode.allCases.compactMap { mode in
            results.filter { $0.gameMode == mode }.map(\.score).max().map { (mode, $0) }
        }
    }
}
