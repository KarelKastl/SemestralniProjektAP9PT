import Foundation
import Observation
import SwiftData

/// Výsledek uložení dat zemí (F7 ho ukazuje uživateli).
struct SyncSummary: Equatable {
    var updated = 0
    var added = 0
    var skipped = 0
}

enum SyncPhase: Equatable {
    case idle
    case downloadingCountries
    case downloadingFlags(done: Int, total: Int)
    case failed(message: String)
    case finished(SyncSummary)

    var isRunning: Bool {
        switch self {
        case .downloadingCountries, .downloadingFlags: true
        default: false
        }
    }
}

/// Stáhne země a vlajky a uloží je do SwiftData.
@Observable
final class CountrySync {
    static let maxConcurrentFlagDownloads = 6

    private(set) var phase: SyncPhase = .idle
    private let client: any CountriesFetching

    init(client: any CountriesFetching) {
        self.client = client
    }

    /// F1 a F7: stáhne data, provede upsert a doplní chybějící vlajky.
    func sync(context: ModelContext) async {
        guard !phase.isRunning else { return }
        phase = .downloadingCountries
        do {
            let countries = try await client.fetchCountries()
            let summary = try Self.upsert(countries, into: context)
            try await downloadMissingFlags(context: context)
            phase = .finished(summary)
        } catch is CancellationError {
            phase = .idle
        } catch {
            phase = .failed(message: error.localizedDescription)
        }
    }

    /// F1: záloha, když API selže. Vlajky chybí, takže režim Vlajka tyto země nepoužije.
    func useBundledData(context: ModelContext) {
        do {
            let summary = try Self.upsert(BundledCountries.load(), into: context)
            phase = .finished(summary)
        } catch {
            phase = .failed(message: error.localizedDescription)
        }
    }

    func reset() {
        guard !phase.isRunning else { return }
        phase = .idle
    }

    /// F7: upsert podle `code`. Nikdy nemaže a nesahá na `discoveredAt`, `correctCount`, `wrongCount` ani na vlajku.
    @discardableResult
    static func upsert(_ countries: [CountryDTO], into context: ModelContext) throws -> SyncSummary {
        let existing = try context.fetch(FetchDescriptor<Country>())
        var byCode = Dictionary(existing.map { ($0.code, $0) }, uniquingKeysWith: { first, _ in first })
        var summary = SyncSummary()

        for dto in countries {
            guard dto.isUsable else {
                summary.skipped += 1
                continue
            }
            if let country = byCode[dto.codes.alpha3] {
                apply(dto, to: country)
                summary.updated += 1
            } else {
                let country = Country(
                    code: dto.codes.alpha3,
                    nameCS: dto.nameCS,
                    officialNameCS: dto.officialNameCS,
                    capital: dto.capitalName,
                    region: dto.region,
                    subregion: dto.subregionName,
                    population: dto.population,
                    isUNMember: dto.memberships.un,
                    latitude: dto.coordinates.lat,
                    longitude: dto.coordinates.lng,
                    flagURL: dto.flag.urlPNG
                )
                context.insert(country)
                byCode[dto.codes.alpha3] = country
                summary.added += 1
            }
        }
        try context.save()
        return summary
    }

    private static func apply(_ dto: CountryDTO, to country: Country) {
        country.nameCS = dto.nameCS
        country.officialNameCS = dto.officialNameCS
        country.capital = dto.capitalName
        country.region = dto.region
        country.subregion = dto.subregionName
        country.population = dto.population
        country.isUNMember = dto.memberships.un
        country.latitude = dto.coordinates.lat
        country.longitude = dto.coordinates.lng
        country.flagURL = dto.flag.urlPNG
    }

    private func downloadMissingFlags(context: ModelContext) async throws {
        let countries = try context.fetch(FetchDescriptor<Country>()).filter { $0.flagPNG == nil && !$0.flagURL.isEmpty }
        let total = countries.count
        var done = 0
        var failures = 0
        var byCode = Dictionary(uniqueKeysWithValues: countries.map { ($0.code, $0) })
        var pending = countries.compactMap { country in
            URL(string: country.flagURL).map { (country.code, $0) }
        }
        pending.reverse()
        phase = .downloadingFlags(done: 0, total: total)

        let client = client
        try await withThrowingTaskGroup(of: (String, Data?).self) { group in
            func addNext() {
                guard let (code, url) = pending.popLast() else { return }
                group.addTask {
                    do {
                        return (code, try await client.fetchFlag(from: url))
                    } catch is CancellationError {
                        throw CancellationError()
                    } catch {
                        return (code, nil)
                    }
                }
            }
            // F1: nejvýš 6 požadavků najednou, další začne až po dokončení předchozího.
            for _ in 0 ..< Self.maxConcurrentFlagDownloads { addNext() }

            while let (code, data) = try await group.next() {
                if let data {
                    byCode.removeValue(forKey: code)?.flagPNG = data
                } else {
                    failures += 1
                }
                done += 1
                phase = .downloadingFlags(done: done, total: total)
                // Průběžné ukládání: ukončení aplikace nezahodí už stažené vlajky.
                if done.isMultiple(of: 25) { try context.save() }
                addNext()
            }
        }
        try context.save()

        if failures > 0 {
            throw FlagDownloadError(failures: failures)
        }
    }
}

struct FlagDownloadError: LocalizedError {
    let failures: Int

    var errorDescription: String? {
        "Nepodařilo se stáhnout \(failures) vlajek. Zkontrolujte připojení a zkuste to znovu."
    }
}
