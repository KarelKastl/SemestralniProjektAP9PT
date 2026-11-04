import Foundation
import SwiftData

#if DEBUG
/// Ukázková data pro náhledy (pravidlo 2).
enum PreviewData {
    static let dependencies = AppDependencies(options: LaunchOptions(usesFixtures: true))
    static let engine: GameEngine = {
        var generator = SeededGenerator(seed: 1)
        let countries = (try? dependencies.container.mainContext.fetch(FetchDescriptor<Country>()))?.map { QuizCountry($0) } ?? []
        return GameEngine(config: GameConfig(mode: .flag), countries: countries, generator: &generator)
    }()
}
#endif
