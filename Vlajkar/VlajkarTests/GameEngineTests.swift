import Foundation
import SwiftData
import Testing
@testable import Vlajkar

private func country(
    _ code: String,
    region: String = "Europe",
    capital: String? = nil,
    population: Int = 1000,
    un: Bool = true,
    flag: Bool = true
) -> QuizCountry {
    QuizCountry(
        code: code,
        name: "Země \(code)",
        capital: capital ?? "Město \(code)",
        region: region,
        population: population,
        isUNMember: un,
        hasFlag: flag
    )
}

private func world(count: Int = 40) -> [QuizCountry] {
    (0 ..< count).map { index in
        country("C\(index)", region: index % 2 == 0 ? "Europe" : "Asia", population: 1000 + index)
    }
}

/// F2: generování otázek.
struct QuestionGeneratorTests {
    @Test(arguments: GameMode.allCases)
    func generatesTenQuestionsWithUniqueSubjects(mode: GameMode) {
        var rng = SeededGenerator(seed: 1)
        let questions = QuestionGenerator.makeQuestions(from: world(), config: GameConfig(mode: mode), using: &rng)

        #expect(questions.count == 10)
        #expect(Set(questions.map(\.subject.code)).count == 10)
    }

    @Test(arguments: [4, 6])
    func optionsAreUniqueAndContainCorrectAnswer(optionCount: Int) {
        var rng = SeededGenerator(seed: 2)
        let config = GameConfig(mode: .flag, optionCount: optionCount)
        let questions = QuestionGenerator.makeQuestions(from: world(), config: config, using: &rng)

        for question in questions {
            #expect(question.options.count == optionCount)
            #expect(Set(question.options.map(\.id)).count == optionCount)
            #expect(Set(question.options.map(\.title)).count == optionCount)
            #expect(question.options.contains { $0.id == question.correctOptionID })
        }
    }

    @Test func wrongOptionsComeFromSameRegionWhenPossible() {
        var rng = SeededGenerator(seed: 3)
        let questions = QuestionGenerator.makeQuestions(from: world(), config: GameConfig(mode: .flag), using: &rng)

        for question in questions {
            #expect(question.options.allSatisfy { $0.country.region == question.subject.region })
        }
    }

    @Test func regionWithFewerCountriesThanOptionsUsesWholeWorld() {
        var rng = SeededGenerator(seed: 4)
        let small = (0 ..< 3).map { country("O\($0)", region: "Oceania") }
        let config = GameConfig(mode: .flag, region: .oceania, optionCount: 6)
        let questions = QuestionGenerator.makeQuestions(from: small + world(), config: config, using: &rng)

        #expect(questions.count == 3)
        #expect(questions.allSatisfy { $0.options.count == 6 && $0.subject.region == "Oceania" })
    }

    @Test func emptyCountryListGivesNoQuestions() {
        var rng = SeededGenerator(seed: 5)

        #expect(QuestionGenerator.makeQuestions(from: [], config: GameConfig(mode: .flag), using: &rng).isEmpty)
    }

    @Test func skipsCountriesWithoutRequiredData() {
        let noFlag = country("NOF", flag: false)
        var noCapital = country("NOC")
        noCapital.capital = nil
        let noPopulation = country("NOP", population: 0)
        let all = [noFlag, noCapital, noPopulation] + world()

        #expect(!QuestionGenerator.eligibleCountries(all, config: GameConfig(mode: .flag)).contains(noFlag))
        #expect(!QuestionGenerator.eligibleCountries(all, config: GameConfig(mode: .capital)).contains(noCapital))
        #expect(!QuestionGenerator.eligibleCountries(all, config: GameConfig(mode: .population)).contains(noPopulation))
    }

    @Test func unFilterExcludesNonMembersFromOptionsToo() {
        var rng = SeededGenerator(seed: 6)
        let nonMembers = (0 ..< 20).map { country("X\($0)", un: false) }
        let questions = QuestionGenerator.makeQuestions(from: nonMembers + world(), config: GameConfig(mode: .capital), using: &rng)

        #expect(questions.allSatisfy { $0.options.allSatisfy(\.country.isUNMember) })
    }

    @Test func duplicateCapitalNamesAreNotOfferedTwice() {
        var rng = SeededGenerator(seed: 7)
        let twins = (0 ..< 8).map { country("T\($0)", capital: $0 < 4 ? "Kingston" : "Město \($0)") }
        let questions = QuestionGenerator.makeQuestions(from: twins, config: GameConfig(mode: .capital), using: &rng)

        for question in questions {
            #expect(Set(question.options.map(\.title)).count == question.options.count)
        }
    }

    @Test func populationSubjectIsMorePopulousOption() {
        var rng = SeededGenerator(seed: 8)
        let questions = QuestionGenerator.makeQuestions(from: world(), config: GameConfig(mode: .population), using: &rng)

        for question in questions {
            #expect(question.options.count == 2)
            let larger = question.options.max { $0.country.population < $1.country.population }
            #expect(larger?.id == question.correctOptionID)
        }
    }

    @Test func populationSkipsTies() {
        var rng = SeededGenerator(seed: 9)
        let tied = (0 ..< 5).map { country("E\($0)", population: 500) }

        #expect(QuestionGenerator.makeQuestions(from: tied, config: GameConfig(mode: .population), using: &rng).isEmpty)
    }

    @Test func sameSeedGivesSameQuestionsRegardlessOfInputOrder() {
        var first = SeededGenerator(seed: 10)
        var second = SeededGenerator(seed: 10)
        let config = GameConfig(mode: .flag)
        let a = QuestionGenerator.makeQuestions(from: world(), config: config, using: &first)
        let b = QuestionGenerator.makeQuestions(from: world().reversed(), config: config, using: &second)

        #expect(a == b)
    }

    @Test func splitMix64MatchesReferenceVector() {
        var rng = SeededGenerator(seed: 1234567)

        #expect(rng.next() == 6457827717110365317)
        #expect(rng.next() == 3203168211198807973)
    }
}

/// F2: průběh hry.
@MainActor
struct GameEngineTests {
    private func makeEngine(
        config: GameConfig = GameConfig(mode: .flag),
        secondsLimit: Int = 15,
        now: @escaping () -> Date = Date.init
    ) -> GameEngine {
        var rng = SeededGenerator(seed: 42)
        return GameEngine(config: config, countries: world(), generator: &rng, secondsLimit: secondsLimit, now: now)
    }

    private func correctID(_ engine: GameEngine) throws -> String {
        try #require(engine.currentQuestion).correctOptionID
    }

    private func wrongID(_ engine: GameEngine) throws -> String {
        let question = try #require(engine.currentQuestion)
        return try #require(question.options.first { $0.id != question.correctOptionID }).id
    }

    @Test func correctAnswerAddsScoreAndStreak() throws {
        let engine = makeEngine()
        let outcome = engine.answer(try correctID(engine))

        #expect(outcome?.isCorrect == true)
        #expect(engine.score == 1)
        #expect(engine.streak == 1)
        #expect(engine.state.isAnswered)
    }

    @Test func wrongAnswerResetsStreakAndKeepsBest() throws {
        let engine = makeEngine()
        engine.answer(try correctID(engine))
        engine.next()
        engine.answer(try correctID(engine))
        engine.next()
        engine.answer(try wrongID(engine))

        #expect(engine.score == 2)
        #expect(engine.streak == 0)
        #expect(engine.bestStreak == 2)
    }

    @Test func doubleTapCountsOnce() throws {
        let engine = makeEngine()
        let id = try correctID(engine)
        engine.answer(id)
        let second = engine.answer(id)

        #expect(second == nil)
        #expect(engine.score == 1)
    }

    @Test func unknownOptionIsIgnored() {
        let engine = makeEngine()

        #expect(engine.answer("???") == nil)
        #expect(engine.state == .waiting)
    }

    @Test func doubleTapOnNextAdvancesOnce() throws {
        let engine = makeEngine()
        engine.answer(try correctID(engine))
        engine.next()
        engine.next()

        #expect(engine.currentIndex == 1)
    }

    @Test func answerAfterFinishIsIgnored() throws {
        let engine = makeEngine()
        for _ in 0 ..< 10 {
            engine.answer(try correctID(engine))
            engine.next()
        }

        #expect(engine.answer("C0") == nil)
        #expect(engine.score == 10)
    }

    @Test func nextRequiresAnswer() {
        let engine = makeEngine()
        engine.next()

        #expect(engine.currentIndex == 0)
    }

    @Test func finishesAfterLastQuestionAndMeasuresDuration() throws {
        var time = Date(timeIntervalSince1970: 0)
        let engine = makeEngine(now: { time })
        for _ in 0 ..< 10 {
            engine.answer(try correctID(engine))
            time += 3
            engine.next()
        }

        #expect(engine.isFinished)
        #expect(engine.score == 10)
        #expect(engine.bestStreak == 10)
        #expect(engine.duration == 30)
    }

    @Test func timerExpiryIsWrongAnswer() throws {
        let engine = makeEngine(config: GameConfig(mode: .flag, usesTimer: true), secondsLimit: 2)
        engine.answer(try correctID(engine))
        engine.next()

        #expect(engine.tick() == nil)
        let outcome = engine.tick()

        #expect(outcome?.isCorrect == false)
        #expect(engine.state == .wrong(selected: nil))
        #expect(engine.streak == 0)
    }

    @Test func tickDuringAnsweredQuestionDoesNothing() throws {
        let engine = makeEngine(config: GameConfig(mode: .flag, usesTimer: true), secondsLimit: 1)
        engine.answer(try correctID(engine))

        #expect(engine.tick() == nil)
        #expect(engine.score == 1)
    }

    @Test func timerIsIgnoredWhenDisabled() {
        let engine = makeEngine(secondsLimit: 1)

        #expect(engine.tick() == nil)
        #expect(engine.state == .waiting)
    }

    @Test func nextQuestionRestartsTimer() throws {
        let engine = makeEngine(config: GameConfig(mode: .flag, usesTimer: true), secondsLimit: 5)
        engine.tick()
        engine.answer(try correctID(engine))
        engine.next()

        #expect(engine.remainingSeconds == 5)
    }

    @Test func emptyGameIsFinishedImmediately() {
        var rng = SeededGenerator(seed: 1)
        let engine = GameEngine(config: GameConfig(mode: .flag), countries: [], generator: &rng)

        #expect(engine.isFinished)
        #expect(engine.total == 0)
        #expect(engine.currentQuestion == nil)
    }
}

/// Objevené země.
@MainActor
struct ProgressRecorderTests {
    @Test func firstCorrectAnswerDiscoversCountryOnce() throws {
        let context = try TestData.context()
        try CountrySync.upsert([TestData.dto(code: "AAA")], into: context)
        let first = Date(timeIntervalSince1970: 100)

        try ProgressRecorder.record(AnswerOutcome(countryCode: "AAA", isCorrect: true), in: context, at: first)
        try ProgressRecorder.record(AnswerOutcome(countryCode: "AAA", isCorrect: true), in: context, at: first + 50)
        try ProgressRecorder.record(AnswerOutcome(countryCode: "AAA", isCorrect: false), in: context)

        let country = try #require(try context.fetch(FetchDescriptor<Country>()).first)
        #expect(country.discoveredAt == first)
        #expect(country.correctCount == 2)
        #expect(country.wrongCount == 1)
    }

    @Test func wrongAnswerDoesNotDiscover() throws {
        let context = try TestData.context()
        try CountrySync.upsert([TestData.dto(code: "AAA")], into: context)

        try ProgressRecorder.record(AnswerOutcome(countryCode: "AAA", isCorrect: false), in: context)

        #expect(try context.fetch(FetchDescriptor<Country>()).first?.discoveredAt == nil)
    }
}
