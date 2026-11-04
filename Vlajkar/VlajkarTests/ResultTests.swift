import Foundation
import SwiftData
import Testing
@testable import Vlajkar

/// F5: uložení výsledku a rekordy.
@MainActor
struct ResultTests {
    private func summary(score: Int, mode: GameMode = .flag) -> GameSummary {
        GameSummary(config: GameConfig(mode: mode, region: .europe), score: score, total: 10, bestStreak: 2, duration: 30)
    }

    @Test func savesResult() throws {
        let context = try TestData.context()

        try ProgressRecorder.save(summary(score: 7), in: context)

        let result = try #require(try context.fetch(FetchDescriptor<GameResult>()).first)
        #expect(result.score == 7)
        #expect(result.region == "Evropa")
        #expect(result.gameMode == .flag)
        #expect(result.duration == 30)
    }

    @Test func recordOnlyWhenBeatingSameMode() throws {
        let context = try TestData.context()

        #expect(try ProgressRecorder.save(summary(score: 5), in: context))
        #expect(try !ProgressRecorder.save(summary(score: 5), in: context))
        #expect(try !ProgressRecorder.save(summary(score: 3), in: context))
        #expect(try ProgressRecorder.save(summary(score: 6), in: context))
        #expect(try ProgressRecorder.save(summary(score: 1, mode: .capital), in: context))
    }

    @Test func zeroScoreIsNotARecord() throws {
        let context = try TestData.context()

        #expect(try !ProgressRecorder.save(summary(score: 0), in: context))
    }

    @Test func bestScoresPerMode() {
        let results = [
            GameResult(date: .now, mode: .flag, region: "", score: 3, total: 10, bestStreak: 1, duration: 1),
            GameResult(date: .now, mode: .flag, region: "", score: 8, total: 10, bestStreak: 1, duration: 1),
            GameResult(date: .now, mode: .population, region: "", score: 4, total: 10, bestStreak: 1, duration: 1),
        ]
        let best = HistoryStats.bestScores(in: results)

        #expect(best.map(\.mode) == [.flag, .population])
        #expect(best.map(\.score) == [8, 4])
    }

    @Test func formatsCzechNumbersAndTime() {
        #expect(Formatting.number(10903655) == "10\u{a0}903\u{a0}655")
        #expect(Formatting.duration(75) == "1:15")
        #expect(Formatting.duration(5) == "0:05")
    }
}

/// F6: filtr atlasu.
@MainActor
struct AtlasFilterTests {
    private func country(_ code: String, _ name: String, region: String = "Europe") -> Country {
        Country(
            code: code, nameCS: name, officialNameCS: name, capital: nil, region: region, subregion: nil,
            population: 1, isUNMember: true, latitude: 0, longitude: 0, flagURL: ""
        )
    }

    @Test func searchIgnoresDiacriticsAndCase() {
        let countries = [country("CZE", "Česko"), country("DEU", "Německo")]

        #expect(AtlasFilter.apply(countries, search: "cesko", region: .world).map(\.code) == ["CZE"])
        #expect(AtlasFilter.apply(countries, search: "NĚMECKO", region: .world).map(\.code) == ["DEU"])
        #expect(AtlasFilter.apply(countries, search: "  ", region: .world).count == 2)
    }

    @Test func filtersByRegion() {
        let countries = [country("CZE", "Česko"), country("JPN", "Japonsko", region: "Asia")]

        #expect(AtlasFilter.apply(countries, search: "", region: .asia).map(\.code) == ["JPN"])
    }

    @Test func sortsCzechAlphabetically() {
        let countries = [country("ZMB", "Zambie"), country("CZE", "Česko"), country("CAN", "Kanada"), country("CHN", "Čína")]
        let names = AtlasFilter.apply(countries, search: "", region: .world).map(\.nameCS)

        #expect(names == ["Česko", "Čína", "Kanada", "Zambie"])
    }

    @Test func regionTitlesAreCzech() {
        #expect(RegionFilter.title(forAPIRegion: "Antarctic") == "Antarktida")
        #expect(RegionFilter.title(forAPIRegion: "Europe") == "Evropa")
    }
}
