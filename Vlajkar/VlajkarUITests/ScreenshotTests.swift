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
    private func openTab(_ app: XCUIApplication, _ title: String) {
        app.tabBars.buttons[title].tap()
    }

    @MainActor
    private func playGame(_ app: XCUIApplication, mode: String) throws {
        app.buttons["home.start.\(mode)"].tap()
        for question in 1 ... 10 {
            XCTAssertTrue(app.buttons["game.option.0"].waitForExistence(timeout: 10))
            if question == 2 {
                usleep(600_000)
                try save("F\(mode == "flag" ? 3 : 4)-hra-\(mode)")
            }
            app.buttons["game.option.1"].tap()
            if question == 2 {
                usleep(600_000)
                try save("F\(mode == "flag" ? 3 : 4)-odpoved-\(mode)")
            }
            // Velké písmo posouvá tlačítko Další animací, klepnutí musí počkat na její konec.
            usleep(500_000)
            app.buttons["game.next"].tap()
        }
        XCTAssertTrue(app.staticTexts["result.score"].waitForExistence(timeout: 5))
        usleep(600_000)
        try save("F5-vysledek-\(mode)")
        app.buttons["result.done"].tap()
    }

    @MainActor
    func testCaptureAllScreens() throws {
        let app = launchRealData()
        try save("F4-domov")
        try playGame(app, mode: "flag")
        try playGame(app, mode: "capital")
        try playGame(app, mode: "population")

        openTab(app, "Historie")
        usleep(600_000)
        try save("F5-historie")

        openTab(app, "Atlas")
        XCTAssertTrue(app.staticTexts["atlas.counter"].waitForExistence(timeout: 5))
        usleep(600_000)
        try save("F6-atlas")
        let row = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'atlas.row.'")).firstMatch
        row.tap()
        usleep(800_000)
        try save("F6-detail")
        app.swipeUp()
        sleep(2)
        try save("F6-detail-mapa")
        app.navigationBars.buttons.firstMatch.tap()

        openTab(app, "Nastavení")
        usleep(600_000)
        try save("F7-nastaveni")
    }

    @MainActor
    func testCaptureSixOptions() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestStore", "Screenshots", "-uiTestSeed", "5", "-game.optionCount", "6", "-game.usesTimer", "YES"]
        app.launch()
        app.buttons["home.start.flag"].tap()
        XCTAssertTrue(app.buttons["game.option.5"].waitForExistence(timeout: 10))
        usleep(600_000)
        try save("F4-sest-moznosti")
    }

    @MainActor
    func testCaptureErrorAndEmptyStates() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestOffline", "-uiTestStore", "ShotsEmpty", "-uiTestReset"]
        app.launch()
        XCTAssertTrue(app.staticTexts["setup.error"].waitForExistence(timeout: 10))
        try save("F1-chyba")
        app.buttons["Pokračovat s přibalenými daty"].tap()
        XCTAssertTrue(app.navigationBars["Vlajkař"].waitForExistence(timeout: 10))
        app.buttons["home.start.flag"].tap()
        usleep(800_000)
        try save("F1-bez-vlajek")
        app.buttons.firstMatch.tap()
        openTab(app, "Historie")
        usleep(500_000)
        try save("F5-historie-prazdna")
        openTab(app, "Atlas")
        usleep(500_000)
        try save("F6-atlas-prazdny")
    }
}
