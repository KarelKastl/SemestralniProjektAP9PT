import XCTest

/// Ukládá důkazní screenshoty do `docs/screenshots/`. Spouští se jen přes `screenshots.sh`.
final class ScreenshotTests: XCTestCase {
    private var directory = ""
    private var suffix = ""

    override func setUpWithError() throws {
        continueAfterFailure = false
        let environment = ProcessInfo.processInfo.environment
        directory = environment["SCREENSHOT_DIR"] ?? ""
        suffix = environment["SCREENSHOT_SUFFIX"] ?? "svetly"
        try XCTSkipIf(directory.isEmpty, "Screenshoty se pořizují jen přes screenshots.sh")
    }

    @MainActor
    private func save(_ name: String) throws {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        try data.write(to: URL(fileURLWithPath: directory).appendingPathComponent("\(name)-\(suffix).png"))
    }

    @MainActor
    private func launchRealData() -> XCUIApplication {
        let app = XCUIApplication()
        // Skutečná data a vlajky z prvního stažení, další běhy už API nevolají.
        app.launchArguments = ["-uiTestStore", "Screenshots", "-uiTestSeed", "11"]
        app.launch()
        XCTAssertTrue(app.navigationBars["Vlajkař"].waitForExistence(timeout: 120))
        return app
    }

    @MainActor
    func testCaptureGame() throws {
        let app = launchRealData()
        try save("F3-domov")
        app.buttons["home.start.flag"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["game.flag"].waitForExistence(timeout: 10))
        sleep(1)
        try save("F3-hra")
        app.buttons["game.option.1"].tap()
        sleep(1)
        try save("F3-odpoved")
    }
}
