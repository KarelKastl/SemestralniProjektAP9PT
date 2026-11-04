import Foundation
import Testing
@testable import Vlajkar

/// B1: denní výzva.
@MainActor
struct DailyChallengeTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Prague")!
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    private func countries() -> [QuizCountry] {
        (0 ..< 60).map {
            QuizCountry(code: "C\($0)", name: "Země \($0)", capital: "Město \($0)", region: "Europe", population: 1, isUNMember: true, hasFlag: true)
        }
    }

    @Test func seedIsSameDuringWholeDay() {
        #expect(DailyChallenge.seed(for: date(2026, 11, 4, hour: 1), calendar: calendar) == 20261104)
        #expect(DailyChallenge.seed(for: date(2026, 11, 4, hour: 23), calendar: calendar) == 20261104)
    }

    @Test func sameDayGivesSameQuestionsAndNextDayDiffers() {
        func questions(_ seed: UInt64) -> [QuizQuestion] {
            var generator = SeededGenerator(seed: seed)
            return QuestionGenerator.makeQuestions(from: countries(), config: DailyChallenge.config, using: &generator)
        }

        #expect(questions(20261104) == questions(20261104))
        #expect(questions(20261104) != questions(20261105))
    }

    @Test func findsOnlyTodaysDailyResult() {
        let today = date(2026, 11, 4)
        let results = [
            GameResult(date: today, mode: .flag, region: "", score: 5, total: 10, bestStreak: 1, duration: 1),
            GameResult(date: date(2026, 11, 3), mode: .flag, region: "", score: 6, total: 10, bestStreak: 1, duration: 1, isDaily: true),
        ]

        #expect(DailyChallenge.result(in: results, on: today, calendar: calendar) == nil)

        let daily = GameResult(date: today, mode: .flag, region: "", score: 7, total: 10, bestStreak: 1, duration: 1, isDaily: true)
        #expect(DailyChallenge.result(in: results + [daily], on: today, calendar: calendar)?.score == 7)
    }
}

/// B2: data grafu.
@MainActor
struct SuccessPointsTests {
    @Test func pointsAreChronologicalPercentages() {
        let results = [
            GameResult(date: Date(timeIntervalSince1970: 200), mode: .flag, region: "", score: 9, total: 10, bestStreak: 1, duration: 1),
            GameResult(date: Date(timeIntervalSince1970: 100), mode: .flag, region: "", score: 1, total: 7, bestStreak: 1, duration: 1),
        ]
        let points = HistoryStats.successPoints(in: results)

        #expect(points.map(\.percent) == [14, 90])
    }

    @Test func keepsOnlyLatestGames() {
        let results = (0 ..< 40).map {
            GameResult(date: Date(timeIntervalSince1970: Double($0)), mode: .flag, region: "", score: 1, total: 1, bestStreak: 1, duration: 1)
        }
        let points = HistoryStats.successPoints(in: results)

        #expect(points.count == 30)
        #expect(points.first?.date == Date(timeIntervalSince1970: 10))
    }

    @Test func skipsGamesWithoutQuestions() {
        let result = GameResult(date: .now, mode: .flag, region: "", score: 0, total: 0, bestStreak: 0, duration: 0)

        #expect(HistoryStats.successPoints(in: [result]).isEmpty)
    }
}

/// Jednoduchá hodnota sdílená s pozorovatelem v testu.
final class Mutex: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: Bool

    init(_ value: Bool) {
        stored = value
    }

    var value: Bool {
        lock.withLock { stored }
    }

    func set(_ value: Bool) {
        lock.withLock { stored = value }
    }
}

/// B3: akce pro Zkratky.
struct DailyChallengeRequestTests {
    @Test func requestIsConsumedOnce() throws {
        let defaults = try #require(UserDefaults(suiteName: "vlajkar.tests.\(UUID().uuidString)"))

        #expect(!DailyChallengeRequest.consume(in: defaults))
        DailyChallengeRequest.make(in: defaults)
        #expect(DailyChallengeRequest.consume(in: defaults))
        #expect(!DailyChallengeRequest.consume(in: defaults))
    }

    @Test func requestNotifiesRunningApp() async throws {
        let defaults = try #require(UserDefaults(suiteName: "vlajkar.tests.\(UUID().uuidString)"))
        let received = Mutex(false)
        let token = NotificationCenter.default.addObserver(
            forName: DailyChallengeRequest.notification, object: nil, queue: nil
        ) { _ in received.set(true) }
        defer { NotificationCenter.default.removeObserver(token) }

        DailyChallengeRequest.make(in: defaults)

        #expect(received.value)
    }

    // Běžící hostitelská aplikace požadavek hned spotřebuje, proto test sleduje upozornění.
    @Test func intentCreatesRequest() async throws {
        let received = Mutex(false)
        let token = NotificationCenter.default.addObserver(
            forName: DailyChallengeRequest.notification, object: nil, queue: nil
        ) { _ in received.set(true) }
        defer { NotificationCenter.default.removeObserver(token) }

        _ = try await PlayDailyChallengeIntent().perform()

        #expect(received.value)
    }
}
