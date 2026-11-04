import Foundation
import SwiftData

#if DEBUG
/// `-uiTestFixtures`: naplní prázdnou databázi přibalenými daty a vygenerovanými vlajkami.
enum FixtureLoader {
    static func loadIfNeeded(into context: ModelContext, discovered: [String] = []) throws {
        guard try context.fetchCount(FetchDescriptor<Country>()) == 0 else { return }
        try CountrySync.upsert(BundledCountries.load(), into: context)
        for country in try context.fetch(FetchDescriptor<Country>()) where !country.flagURL.isEmpty {
            country.flagPNG = TestFlag.png(seed: country.code)
            if discovered.contains(country.code) {
                country.discoveredAt = .now
                country.correctCount = 1
            }
        }
        try context.save()
    }
}
#endif
