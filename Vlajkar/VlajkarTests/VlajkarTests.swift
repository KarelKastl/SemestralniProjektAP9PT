import Foundation
import Testing
@testable import Vlajkar

/// Kostra aplikace (F0).
struct LaunchOptionsTests {
    @Test func parsesUITestArguments() {
        let options = LaunchOptions.parse([
            "app", "-uiTestFixtures", "-uiTestOffline", "-uiTestSeed", "42", "-uiTestTimer", "2",
        ])

        #expect(options.usesFixtures)
        #expect(options.isOffline)
        #expect(options.seed == 42)
        #expect(options.timerSeconds == 2)
    }

    @Test func ignoresIncompleteSeed() {
        let options = LaunchOptions.parse(["app", "-uiTestSeed"])

        #expect(options.seed == nil)
    }
}
