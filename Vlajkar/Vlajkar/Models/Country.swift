import Foundation
import SwiftData

/// Země uložená v databázi. Pole `discoveredAt`, `correctCount` a `wrongCount` jsou postup hráče
/// a synchronizace je nikdy nepřepisuje (F7).
@Model
final class Country {
    @Attribute(.unique) var code: String
    var nameCS: String
    var officialNameCS: String
    var capital: String?
    var region: String
    var subregion: String?
    var population: Int
    var isUNMember: Bool
    var latitude: Double
    var longitude: Double
    var flagURL: String
    // F1: PNG je mimo hlavní databázi, ale funguje offline.
    @Attribute(.externalStorage) var flagPNG: Data?
    var discoveredAt: Date?
    var correctCount: Int
    var wrongCount: Int

    init(
        code: String,
        nameCS: String,
        officialNameCS: String,
        capital: String?,
        region: String,
        subregion: String?,
        population: Int,
        isUNMember: Bool,
        latitude: Double,
        longitude: Double,
        flagURL: String,
        flagPNG: Data? = nil,
        discoveredAt: Date? = nil,
        correctCount: Int = 0,
        wrongCount: Int = 0
    ) {
        self.code = code
        self.nameCS = nameCS
        self.officialNameCS = officialNameCS
        self.capital = capital
        self.region = region
        self.subregion = subregion
        self.population = population
        self.isUNMember = isUNMember
        self.latitude = latitude
        self.longitude = longitude
        self.flagURL = flagURL
        self.flagPNG = flagPNG
        self.discoveredAt = discoveredAt
        self.correctCount = correctCount
        self.wrongCount = wrongCount
    }
}
