import Foundation

/// Spouštěcí přepínače pro UI testy. Mimo DEBUG build se nepoužijí (ADR-006).
nonisolated struct LaunchOptions: Sendable {
    var usesFixtures = false
    var isOffline = false
    var seed: UInt64?
    var storeName: String?
    var resetsStore = false
    var timerSeconds: Int?
    var stubsAPI = false
    var resetsDefaults = false

    static let current: LaunchOptions = {
        #if DEBUG
        parse(ProcessInfo.processInfo.arguments)
        #else
        LaunchOptions()
        #endif
    }()

    static func parse(_ arguments: [String]) -> LaunchOptions {
        var options = LaunchOptions()
        func value(after flag: String) -> String? {
            guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else { return nil }
            return arguments[index + 1]
        }
        options.usesFixtures = arguments.contains("-uiTestFixtures")
        options.isOffline = arguments.contains("-uiTestOffline")
        options.resetsStore = arguments.contains("-uiTestReset")
        options.stubsAPI = arguments.contains("-uiTestStubAPI")
        options.resetsDefaults = arguments.contains("-uiTestResetDefaults")
        options.seed = value(after: "-uiTestSeed").flatMap(UInt64.init)
        options.storeName = value(after: "-uiTestStore")
        options.timerSeconds = value(after: "-uiTestTimer").flatMap(Int.init)
        return options
    }
}
