import Foundation
import SwiftData

/// Výsledek jedné dokončené hry (F5).
@Model
final class GameResult {
    var date: Date
    var mode: String
    var region: String
    var score: Int
    var total: Int
    var bestStreak: Int
    var duration: TimeInterval
    var isDaily: Bool

    init(
        date: Date,
        mode: GameMode,
        region: String,
        score: Int,
        total: Int,
        bestStreak: Int,
        duration: TimeInterval,
        isDaily: Bool = false
    ) {
        self.date = date
        self.mode = mode.rawValue
        self.region = region
        self.score = score
        self.total = total
        self.bestStreak = bestStreak
        self.duration = duration
        self.isDaily = isDaily
    }

    var gameMode: GameMode { GameMode(rawValue: mode) ?? .flag }
}
