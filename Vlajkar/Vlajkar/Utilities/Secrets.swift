import Foundation

/// API klíč z gitignorovaného `Secrets.plist` (ADR-002).
nonisolated enum Secrets {
    static var restCountriesAPIKey: String? {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let values = NSDictionary(contentsOf: url),
            let key = values["RestCountriesAPIKey"] as? String,
            !key.isEmpty
        else { return nil }
        return key
    }
}
