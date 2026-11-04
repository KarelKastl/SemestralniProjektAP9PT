import XCTest

final class VlajkarUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testF0_appLaunchesToHome() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestFixtures"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Vlajkař"].firstMatch.waitForExistence(timeout: 10))
    }
}
