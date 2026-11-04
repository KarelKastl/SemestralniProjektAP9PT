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
}
