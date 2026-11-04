import Foundation

#if DEBUG
import UIKit

/// `-uiTestOffline`: každý požadavek skončí chybou bez připojení.
nonisolated struct OfflineCountriesClient: CountriesFetching {
    func fetchCountries() async throws -> [CountryDTO] { throw CountriesError.noConnection }
    func fetchFlag(from url: URL) async throws -> Data { throw CountriesError.noConnection }
}

/// `-uiTestStubAPI`: vrací přibalená data a vygenerované vlajky, UI testy tak nevolají skutečné API.
nonisolated struct StubCountriesClient: CountriesFetching {
    func fetchCountries() async throws -> [CountryDTO] {
        try await Task.sleep(for: .milliseconds(300))
        // Pomalý průběh s prodlevami nechá XCUITest zachytit obrazovku stahování.
        return try Array(BundledCountries.load().filter(\.isUsable).prefix(60))
    }

    func fetchFlag(from url: URL) async throws -> Data {
        try await Task.sleep(for: .seconds(1))
        return TestFlag.png(seed: url.lastPathComponent)
    }
}

nonisolated enum TestFlag {
    /// Malá barevná vlajka odvozená z textu, aby se testy obešly bez sítě.
    static func png(seed: String) -> Data {
        let hash = seed.unicodeScalars.reduce(UInt32(17)) { ($0 &* 31) &+ $1.value }
        let hue = CGFloat(hash % 360) / 360
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 64, height: 40), format: format).pngData { context in
            UIColor(hue: hue, saturation: 0.7, brightness: 0.8, alpha: 1).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 64, height: 40))
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 14, width: 64, height: 12))
        }
    }
}
#endif
