import Foundation
import SwiftData
import Testing
@testable import Vlajkar

/// Řízený zástupce API: počítá souběh a umí selhat.
actor FakeBackend {
    var active = 0
    var maxActive = 0
    var failingCodes: Set<String> = []

    func setFailing(_ codes: Set<String>) { failingCodes = codes }

    func flag(_ url: URL) async throws -> Data {
        active += 1
        maxActive = max(maxActive, active)
        try await Task.sleep(for: .milliseconds(5))
        active -= 1
        if failingCodes.contains(url.lastPathComponent) { throw CountriesError.noConnection }
        return Data([1, 2, 3])
    }
}

struct FakeClient: CountriesFetching {
    var countries: [CountryDTO]
    var error: CountriesError?
    var backend = FakeBackend()

    func fetchCountries() async throws -> [CountryDTO] {
        if let error { throw error }
        return countries
    }

    func fetchFlag(from url: URL) async throws -> Data {
        try await backend.flag(url)
    }
}

/// F1 a F7: ukládání dat.
@MainActor
struct CountrySyncTests {
    @Test func insertsNewCountriesAndSkipsRecordsWithoutCode() throws {
        let context = try TestData.context()
        let summary = try CountrySync.upsert([TestData.dto(code: "AAA"), TestData.dto(code: "")], into: context)
        let countries = try context.fetch(FetchDescriptor<Country>())

        #expect(summary == SyncSummary(updated: 0, added: 1, skipped: 1))
        #expect(countries.map(\.code) == ["AAA"])
    }

    // F7: nejdůležitější vlastnost obnovení dat.
    @Test func upsertKeepsPlayerProgressAndFlag() throws {
        let context = try TestData.context()
        try CountrySync.upsert([TestData.dto(code: "AAA", population: 1)], into: context)
        let country = try #require(try context.fetch(FetchDescriptor<Country>()).first)
        let date = Date(timeIntervalSince1970: 1000)
        country.discoveredAt = date
        country.correctCount = 3
        country.wrongCount = 2
        country.flagPNG = Data([9])

        let summary = try CountrySync.upsert(
            [TestData.dto(code: "AAA", population: 2), TestData.dto(code: "BBB")],
            into: context
        )
        let countries = try context.fetch(FetchDescriptor<Country>())
        let updated = try #require(countries.first { $0.code == "AAA" })

        #expect(summary == SyncSummary(updated: 1, added: 1, skipped: 0))
        #expect(countries.count == 2)
        #expect(updated.population == 2)
        #expect(updated.discoveredAt == date)
        #expect(updated.correctCount == 3)
        #expect(updated.wrongCount == 2)
        #expect(updated.flagPNG == Data([9]))
    }

    @Test func downloadsFlagsWithLimitedConcurrency() async throws {
        let context = try TestData.context()
        let countries = (0 ..< 30).map { TestData.dto(code: "C\($0)") }
        let client = FakeClient(countries: countries)
        let sync = CountrySync(client: client)

        await sync.sync(context: context)

        let stored = try context.fetch(FetchDescriptor<Country>())
        #expect(stored.count == 30)
        #expect(stored.allSatisfy { $0.flagPNG != nil })
        #expect(await client.backend.maxActive <= CountrySync.maxConcurrentFlagDownloads)
        #expect(await client.backend.maxActive > 1)
        #expect(sync.phase == .finished(SyncSummary(updated: 0, added: 30, skipped: 0)))
    }

    @Test func reportsNetworkErrorAndCanRetry() async throws {
        let context = try TestData.context()
        let sync = CountrySync(client: FakeClient(countries: [], error: .noConnection))

        await sync.sync(context: context)

        #expect(sync.phase == .failed(message: CountriesError.noConnection.errorDescription ?? ""))
    }

    @Test func failedFlagIsDownloadedOnRetry() async throws {
        let context = try TestData.context()
        let client = FakeClient(countries: [TestData.dto(code: "AAA"), TestData.dto(code: "BBB")])
        await client.backend.setFailing(["BBB.png"])
        let sync = CountrySync(client: client)

        await sync.sync(context: context)
        guard case .failed = sync.phase else {
            Issue.record("Očekávaná chyba vlajky")
            return
        }
        #expect(try context.fetch(FetchDescriptor<Country>()).filter { $0.flagPNG != nil }.count == 1)

        await client.backend.setFailing([])
        await sync.sync(context: context)

        #expect(try context.fetch(FetchDescriptor<Country>()).allSatisfy { $0.flagPNG != nil })
    }

    @Test func bundledDataWorkWithoutFlags() throws {
        let context = try TestData.context()
        let sync = CountrySync(client: FakeClient(countries: [], error: .noConnection))

        sync.useBundledData(context: context)

        let countries = try context.fetch(FetchDescriptor<Country>())
        #expect(countries.count == 250)
        #expect(countries.allSatisfy { $0.flagPNG == nil })
        #expect(sync.phase == .finished(SyncSummary(updated: 0, added: 250, skipped: 4)))
    }
}
