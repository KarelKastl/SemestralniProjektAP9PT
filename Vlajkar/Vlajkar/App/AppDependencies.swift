import Foundation
import Observation
import SwiftData

/// Sdílené závislosti aplikace. Vzniká jednou ve `VlajkarApp` a drží se jako `@State`.
@Observable
final class AppDependencies {
    let options: LaunchOptions
    let container: ModelContainer

    init(options: LaunchOptions = .current) {
        self.options = options
        container = Self.makeContainer(options: options)
    }

    private static func makeContainer(options: LaunchOptions) -> ModelContainer {
        let schema = Schema([Country.self, GameResult.self])
        do {
            let configuration: ModelConfiguration
            if let storeName = options.storeName {
                // Restart test potřebuje skutečný soubor, který přežije ukončení aplikace.
                let url = URL.applicationSupportDirectory.appending(path: "\(storeName).store")
                if options.resetsStore { try? removeStore(at: url) }
                try FileManager.default.createDirectory(at: .applicationSupportDirectory, withIntermediateDirectories: true)
                configuration = ModelConfiguration(schema: schema, url: url)
            } else {
                configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: options.usesFixtures)
            }
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Databázi se nepodařilo otevřít: \(error)")
        }
    }

    private static func removeStore(at url: URL) throws {
        let directory = url.deletingLastPathComponent()
        let name = url.lastPathComponent
        let files = try FileManager.default.contentsOfDirectory(atPath: directory.path(percentEncoded: false))
        for file in files where file.hasPrefix(name) {
            try FileManager.default.removeItem(at: directory.appending(path: file))
        }
    }
}
