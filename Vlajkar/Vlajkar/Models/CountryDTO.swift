import Foundation

/// Tvar záznamu z REST Countries v5. Jen dekódování, do databáze se nepíše (F1).
nonisolated struct CountryDTO: Codable, Equatable, Sendable {
    struct Names: Codable, Equatable, Sendable {
        var common: String
        var official: String
        var translations: [String: Translation]?
    }

    struct Translation: Codable, Equatable, Sendable {
        var common: String
        var official: String
    }

    struct Codes: Codable, Equatable, Sendable {
        var alpha3: String

        enum CodingKeys: String, CodingKey {
            case alpha3 = "alpha_3"
        }
    }

    struct Capital: Codable, Equatable, Sendable {
        var name: String
    }

    struct Coordinates: Codable, Equatable, Sendable {
        var lat: Double
        var lng: Double
    }

    struct Memberships: Codable, Equatable, Sendable {
        var un: Bool
    }

    struct Flag: Codable, Equatable, Sendable {
        var urlPNG: String

        enum CodingKeys: String, CodingKey {
            case urlPNG = "url_png"
        }
    }

    var names: Names
    var codes: Codes
    var capitals: [Capital]
    var flag: Flag
    var region: String
    var subregion: String
    var coordinates: Coordinates
    var memberships: Memberships
    var population: Int

    /// F1: záznamy bez kódu (Abcházie, Severní Kypr, Somaliland, Jižní Osetie) nejde bezpečně uložit.
    var isUsable: Bool { !codes.alpha3.isEmpty }
    var nameCS: String { names.translations?["ces"]?.common ?? names.common }
    var officialNameCS: String { names.translations?["ces"]?.official ?? names.official }
    var capitalName: String? { capitals.first?.name }
    var subregionName: String? { subregion.isEmpty ? nil : subregion }
}

/// Obálka jedné stránky odpovědi z v5.
nonisolated struct CountriesPage: Decodable, Sendable {
    struct Payload: Decodable, Sendable {
        var objects: [CountryDTO]
        var meta: Meta
    }

    struct Meta: Decodable, Sendable {
        var total: Int
        var offset: Int
        var more: Bool
    }

    var data: Payload
}
