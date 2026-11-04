import Foundation
import SwiftData

/// Zapisuje postup hráče do SwiftData: objevené země a výsledek hry.
enum ProgressRecorder {
    /// F6: země je objevená po první správné odpovědi. Datum se už nepřepisuje.
    static func record(_ outcome: AnswerOutcome, in context: ModelContext, at date: Date = .now) throws {
        let code = outcome.countryCode
        var descriptor = FetchDescriptor<Country>(predicate: #Predicate { $0.code == code })
        descriptor.fetchLimit = 1
        guard let country = try context.fetch(descriptor).first else { return }

        if outcome.isCorrect {
            country.correctCount += 1
            if country.discoveredAt == nil { country.discoveredAt = date }
        } else {
            country.wrongCount += 1
        }
        try context.save()
    }

    /// F5: uloží výsledek a vrátí, jestli jde o nový rekord režimu.
    @discardableResult
    static func save(
        _ summary: GameSummary,
        in context: ModelContext,
        at date: Date = .now
    ) throws -> Bool {
        let mode = summary.config.mode.rawValue
        let previous = try context.fetch(FetchDescriptor<GameResult>(predicate: #Predicate { $0.mode == mode }))
        let isRecord = summary.score > (previous.map(\.score).max() ?? 0)
        context.insert(GameResult(
            date: date,
            mode: summary.config.mode,
            region: summary.config.region.title,
            score: summary.score,
            total: summary.total,
            bestStreak: summary.bestStreak,
            duration: summary.duration,
            isDaily: summary.config.isDaily
        ))
        try context.save()
        return isRecord
    }
}
