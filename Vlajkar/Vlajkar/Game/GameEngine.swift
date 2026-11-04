import Foundation
import Observation

/// Herní stav jedné hry. Neví nic o SwiftUI ani SwiftData (F2).
@Observable
final class GameEngine {
    static let secondsPerQuestion = 15

    let config: GameConfig
    let questions: [QuizQuestion]
    private let secondsLimit: Int
    private let now: () -> Date
    private let startedAt: Date

    private(set) var currentIndex = 0
    private(set) var state: QuestionState = .waiting
    private(set) var score = 0
    private(set) var streak = 0
    private(set) var bestStreak = 0
    private(set) var remainingSeconds: Int
    private(set) var isFinished = false
    private(set) var finishedAt: Date?

    init(
        config: GameConfig,
        countries: [QuizCountry],
        generator: inout some RandomNumberGenerator,
        secondsLimit: Int = GameEngine.secondsPerQuestion,
        now: @escaping () -> Date = Date.init
    ) {
        self.config = config
        self.secondsLimit = secondsLimit
        self.now = now
        startedAt = now()
        remainingSeconds = secondsLimit
        questions = QuestionGenerator.makeQuestions(from: countries, config: config, using: &generator)
        isFinished = questions.isEmpty
    }

    var currentQuestion: QuizQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    var total: Int { questions.count }
    var questionNumber: Int { min(currentIndex + 1, total) }
    var isLastQuestion: Bool { currentIndex >= total - 1 }
    var duration: TimeInterval { (finishedAt ?? now()).timeIntervalSince(startedAt) }

    /// Vrací vyhodnocenou otázku, nebo `nil`, když odpověď nic nezměnila (dvojité ťuknutí).
    @discardableResult
    func answer(_ optionID: String) -> AnswerOutcome? {
        guard state == .waiting, !isFinished, let question = currentQuestion else { return nil }
        guard question.options.contains(where: { $0.id == optionID }) else { return nil }

        if optionID == question.correctOptionID {
            state = .correct(selected: optionID)
            score += 1
            streak += 1
            bestStreak = max(bestStreak, streak)
            return AnswerOutcome(countryCode: question.subject.code, isCorrect: true)
        }
        state = .wrong(selected: optionID)
        streak = 0
        return AnswerOutcome(countryCode: question.subject.code, isCorrect: false)
    }

    /// Odečte sekundu. Po vypršení je otázka špatně (F4). Vrací vyhodnocení jen v okamžiku vypršení.
    @discardableResult
    func tick() -> AnswerOutcome? {
        guard config.usesTimer, state == .waiting, !isFinished, let question = currentQuestion else { return nil }
        remainingSeconds = max(remainingSeconds - 1, 0)
        guard remainingSeconds == 0 else { return nil }
        state = .wrong(selected: nil)
        streak = 0
        return AnswerOutcome(countryCode: question.subject.code, isCorrect: false)
    }

    var summary: GameSummary {
        GameSummary(config: config, score: score, total: total, bestStreak: bestStreak, duration: duration)
    }

    func next() {
        guard state.isAnswered, !isFinished else { return }
        if isLastQuestion {
            finishedAt = now()
            isFinished = true
        } else {
            currentIndex += 1
            state = .waiting
            remainingSeconds = secondsLimit
        }
    }
}

/// Souhrn dokončené hry pro uložení (F5).
nonisolated struct GameSummary: Equatable, Sendable {
    var config: GameConfig
    var score: Int
    var total: Int
    var bestStreak: Int
    var duration: TimeInterval
}

nonisolated struct AnswerOutcome: Equatable, Sendable {
    var countryCode: String
    var isCorrect: Bool
}
