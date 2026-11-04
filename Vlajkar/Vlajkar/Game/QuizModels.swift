import Foundation

/// Hodnotová kopie země pro herní logiku. `GameEngine` tak nezávisí na SwiftData.
nonisolated struct QuizCountry: Identifiable, Hashable, Sendable {
    var code: String
    var name: String
    var capital: String?
    var region: String
    var population: Int
    var isUNMember: Bool
    var hasFlag: Bool

    var id: String { code }
}

extension QuizCountry {
    init(_ country: Country) {
        self.init(
            code: country.code,
            name: country.nameCS,
            capital: country.capital,
            region: country.region,
            population: country.population,
            isUNMember: country.isUNMember,
            hasFlag: country.flagPNG != nil
        )
    }
}

nonisolated struct QuizOption: Identifiable, Hashable, Sendable {
    var country: QuizCountry
    var title: String

    var id: String { country.code }
}

nonisolated struct QuizQuestion: Identifiable, Hashable, Sendable {
    var id: Int
    var mode: GameMode
    /// Země, na kterou se otázka ptá. Ve Víc/méně je to lidnatější země.
    var subject: QuizCountry
    var options: [QuizOption]

    var correctOptionID: String { subject.code }
}

/// Stav aktuální otázky. `wrong(selected: nil)` znamená vypršený časovač.
nonisolated enum QuestionState: Equatable, Sendable {
    case waiting
    case correct(selected: String)
    case wrong(selected: String?)

    var isAnswered: Bool { self != .waiting }
}
