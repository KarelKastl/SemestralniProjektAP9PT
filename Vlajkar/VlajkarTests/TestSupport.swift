import Foundation
import SwiftData
@testable import Vlajkar

enum TestData {
    static func sampleCountries() throws -> [CountryDTO] {
        let url = try require2(Bundle(for: BundleToken.self).url(forResource: "sample", withExtension: "json"))
        return try JSONDecoder().decode([CountryDTO].self, from: Data(contentsOf: url))
    }

    static func dto(
        code: String,
        name: String? = nil,
        capital: String? = "Město",
        region: String = "Europe",
        population: Int = 1000,
        un: Bool = true,
        flagURL: String? = nil
    ) -> CountryDTO {
        CountryDTO(
            names: .init(common: name ?? code, official: name ?? code, translations: nil),
            codes: .init(alpha3: code),
            capitals: capital.map { [.init(name: $0)] } ?? [],
            flag: .init(urlPNG: flagURL ?? "https://example.com/\(code).png"),
            region: region,
            subregion: "",
            coordinates: .init(lat: 1, lng: 2),
            memberships: .init(un: un),
            population: population
        )
    }

    @MainActor
    static func context() throws -> ModelContext {
        let schema = Schema([Country.self, GameResult.self])
        let container = try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true))
        return ModelContext(container)
    }
}

private final class BundleToken {}

struct MissingValue: Error {}

func require2<T>(_ value: T?) throws -> T {
    guard let value else { throw MissingValue() }
    return value
}
