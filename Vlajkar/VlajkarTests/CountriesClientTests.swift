import Foundation
import Testing
@testable import Vlajkar

/// F1: dekódování a klient REST Countries v5.
struct CountriesClientTests {
    private func response(_ status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: CountriesClient.endpoint, statusCode: status, httpVersion: nil, headerFields: nil)!
    }

    @Test func decodesSampleCountries() throws {
        let countries = try TestData.sampleCountries()
        let czechia = try require2(countries.first { $0.codes.alpha3 == "CZE" })

        #expect(czechia.nameCS == "Česko")
        #expect(czechia.officialNameCS == "Česká republika")
        #expect(czechia.capitalName == "Prague")
        #expect(czechia.memberships.un)
        #expect(czechia.flag.urlPNG.hasSuffix(".png"))
    }

    @Test func handlesEdgeCaseRecords() throws {
        let countries = try TestData.sampleCountries()
        let antarctica = try require2(countries.first { $0.codes.alpha3 == "ATA" })
        let bolivia = try require2(countries.first { $0.codes.alpha3 == "BOL" })
        let abkhazia = try require2(countries.first { $0.names.common == "Abkhazia" })

        #expect(antarctica.capitalName == nil)
        #expect(antarctica.subregionName == nil)
        #expect(bolivia.capitalName == "Sucre")
        #expect(!abkhazia.isUsable)
        #expect(abkhazia.nameCS == "Abkhazia")
    }

    @Test func bundledFallbackContainsAllCountries() throws {
        let countries = try BundledCountries.load(from: Bundle(for: AppDependencies.self))

        #expect(countries.count == 254)
        #expect(countries.filter(\.isUsable).count == 250)
        #expect(countries.filter(\.memberships.un).count == 193)
    }

    @Test func buildsAuthorizedPageRequest() throws {
        let request = CountriesClient.pageRequest(offset: 100, apiKey: "klic")
        let query = try require2(request.url?.query())

        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer klic")
        #expect(query.contains("limit=100"))
        #expect(query.contains("offset=100"))
        #expect(query.contains("flag.url_png"))
    }

    @Test func followsPagesUntilNoMore() async throws {
        let page1 = #"{"data":{"objects":[],"meta":{"total":2,"offset":0,"more":false}}}"#
        let response = response(200)
        let client = CountriesClient(apiKey: "klic") { _ in (Data(page1.utf8), response) }

        let countries = try await client.fetchCountries()

        #expect(countries.isEmpty)
    }

    @Test func requestsEveryPage() async throws {
        let dto = TestData.dto(code: "AAA")
        let object = try String(data: JSONEncoder().encode(dto), encoding: .utf8) ?? ""
        let response = response(200)
        let offsets = Recorder()
        let client = CountriesClient(apiKey: "klic") { request in
            let offset = request.url?.query()?.contains("offset=0") == true ? 0 : 1
            await offsets.add(offset)
            let more = offset == 0
            let body = #"{"data":{"objects":[\#(object)],"meta":{"total":2,"offset":\#(offset),"more":\#(more)}}}"#
            return (Data(body.utf8), response)
        }

        let countries = try await client.fetchCountries()

        #expect(countries.count == 2)
        #expect(await offsets.values == [0, 1])
    }

    @Test func requiresKey() async {
        let client = CountriesClient(apiKey: nil) { _ in throw URLError(.notConnectedToInternet) }

        await #expect(throws: CountriesError.missingKey) {
            try await client.fetchCountries()
        }
    }

    @Test func mapsTransportFailureToNoConnection() async {
        let client = CountriesClient(apiKey: "klic") { _ in throw URLError(.notConnectedToInternet) }

        await #expect(throws: CountriesError.noConnection) {
            try await client.fetchCountries()
        }
    }

    @Test(arguments: [
        (401, CountriesError.unauthorized),
        (429, CountriesError.rateLimited),
        (500, CountriesError.server(500)),
    ])
    func mapsHTTPStatus(status: Int, expected: CountriesError) async {
        let response = response(status)
        let client = CountriesClient(apiKey: "klic") { _ in (Data(), response) }

        await #expect(throws: expected) {
            try await client.fetchCountries()
        }
    }

    @Test func rejectsMalformedJSON() async {
        let response = response(200)
        let client = CountriesClient(apiKey: "klic") { _ in (Data("{}".utf8), response) }

        await #expect(throws: CountriesError.invalidData) {
            try await client.fetchCountries()
        }
    }
}

actor Recorder {
    private(set) var values: [Int] = []

    func add(_ value: Int) {
        values.append(value)
    }
}
