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

    /// Pevná data, pevná náhoda a výchozí nastavení.
    @MainActor
    private func launchFixtures(_ extra: [String] = []) -> XCUIApplication {
        launch(["-uiTestFixtures", "-uiTestSeed", "7", "-uiTestResetDefaults"] + extra)
    }

    @MainActor
    private func playWholeGame(_ app: XCUIApplication, mode: String = "flag") {
        app.buttons["home.start.\(mode)"].tap()
        for _ in 1 ... 10 {
            XCTAssertTrue(app.buttons["game.option.0"].waitForExistence(timeout: 10))
            answerFirstOption(app)
            app.buttons["game.next"].tap()
        }
        XCTAssertTrue(app.staticTexts["result.score"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func openTab(_ app: XCUIApplication, _ title: String) {
        app.tabBars.buttons[title].tap()
    }

    @MainActor
    private func answerFirstOption(_ app: XCUIApplication) {
        app.buttons["game.option.0"].tap()
        XCTAssertTrue(app.buttons["game.next"].waitForExistence(timeout: 5))
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

    @MainActor
    func testA04_flagModeFullGame() throws {
        let app = launchFixtures()
        app.buttons["home.start.flag"].tap()

        XCTAssertTrue(app.descendants(matching: .any)["game.flag"].waitForExistence(timeout: 10))
        for number in 1 ... 10 {
            XCTAssertEqual(app.staticTexts["game.progress"].label, "Otázka \(number)/10")
            let option = app.buttons["game.option.0"]
            XCTAssertTrue(option.isEnabled)
            option.tap()
            let answers = app.buttons.matching(NSPredicate(format: "value == 'Správná odpověď'"))
            XCTAssertEqual(answers.count, 1)
            XCTAssertFalse(option.isEnabled)
            app.buttons["game.next"].tap()
        }
        XCTAssertTrue(app.staticTexts["result.score"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testA05_sixOptionsFitWithoutScrolling() throws {
        let app = launchFixtures(["-game.optionCount", "6"])
        app.buttons["home.start.flag"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["game.flag"].waitForExistence(timeout: 10))

        XCTAssertEqual(app.scrollViews.count, 0)
        for index in 0 ..< 6 {
            XCTAssertTrue(app.buttons["game.option.\(index)"].isHittable, "Možnost \(index) není vidět")
        }
        XCTAssertLessThanOrEqual(app.windows.firstMatch.frame.width, 375)
        answerFirstOption(app)
        XCTAssertTrue(app.buttons["game.next"].isHittable)
    }

    @MainActor
    func testA06_capitalMode() throws {
        let app = launchFixtures()
        app.buttons["home.start.capital"].tap()

        XCTAssertTrue(app.staticTexts["game.country"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Hlavní město země"].exists)
        for index in 0 ..< 4 {
            XCTAssertTrue(app.buttons["game.option.\(index)"].isHittable)
        }
        answerFirstOption(app)
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "value == 'Správná odpověď'")).count, 1)
    }

    @MainActor
    func testA07_populationMode() throws {
        let app = launchFixtures()
        app.buttons["home.start.population"].tap()

        XCTAssertTrue(app.staticTexts["game.question"].waitForExistence(timeout: 10))
        answerFirstOption(app)
        let first = app.staticTexts["game.population.0"]
        let second = app.staticTexts["game.population.1"]
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        XCTAssertTrue(second.exists)
        // Česky formátované číslo má mezery mezi tisíci, ne čárky.
        XCTAssertFalse(first.label.contains(","))
        XCTAssertFalse(second.label.contains(","))
    }

    @MainActor
    func testA08_settingsPersist() throws {
        var app = launchFixtures()
        app.switches["home.timer"].switches.firstMatch.tap()
        app.buttons["6"].tap()
        app.terminate()

        app = launch(["-uiTestFixtures"])
        XCTAssertEqual(app.switches["home.timer"].value as? String, "1")
        XCTAssertTrue(app.buttons["6"].isSelected)
    }

    @MainActor
    func testA09_timerExpiryCountsAsWrong() throws {
        let app = launchFixtures(["-game.usesTimer", "YES", "-uiTestTimer", "2"])
        app.buttons["home.start.flag"].tap()

        let next = app.buttons["game.next"]
        XCTAssertTrue(app.staticTexts["game.timer"].waitForExistence(timeout: 10))
        let expired = app.staticTexts["Čas vypršel"]
        XCTAssertTrue(expired.waitForExistence(timeout: 10))
        XCTAssertTrue(next.isHittable)
        XCTAssertEqual(app.staticTexts["game.score"].label, "Skóre 0")
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "value == 'Správná odpověď'")).count, 1)
    }

    @MainActor
    func testA10_resultAndHistoryDelete() throws {
        let app = launchFixtures()
        playWholeGame(app)
        let streak = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Nejlepší série'"))
        XCTAssertTrue(streak.firstMatch.exists)
        app.buttons["result.done"].tap()

        openTab(app, "Historie")
        let row = app.descendants(matching: .any).matching(identifier: "history.row").firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.swipeLeft()
        app.buttons["Smazat"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Zatím žádná hra"].waitForExistence(timeout: 5))
    }
}
