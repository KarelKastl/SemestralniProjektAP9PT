import XCTest

/// Akceptační kritéria A1–A14. Čísla testů odpovídají `docs/PRD.md`.
final class VlajkarUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(_ arguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launch()
        return app
    }

    @MainActor
    func testA01_firstLaunchDownloadsData() throws {
        let app = launch(["-uiTestStubAPI", "-uiTestStore", "A01", "-uiTestReset"])

        let progress = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Stahuji vlajky'"))
        XCTAssertTrue(progress.firstMatch.waitForExistence(timeout: 10))
        XCTAssertTrue(app.navigationBars["Vlajkař"].waitForExistence(timeout: 40))
    }

    @MainActor
    func testA02_offlineShowsErrorAndFallback() throws {
        let app = launch(["-uiTestOffline", "-uiTestStore", "A02", "-uiTestReset"])

        XCTAssertTrue(app.staticTexts["setup.error"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Zkusit znovu"].exists)
        app.buttons["Zkusit znovu"].tap()
        XCTAssertTrue(app.staticTexts["setup.error"].waitForExistence(timeout: 10))

        app.buttons["Pokračovat s přibalenými daty"].tap()
        XCTAssertTrue(app.navigationBars["Vlajkař"].waitForExistence(timeout: 10))
    }
}
