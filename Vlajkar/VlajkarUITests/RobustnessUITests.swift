import XCTest

/// Fáze 9 „Rozbij to“: scénáře testera, který chce aplikaci rozbít.
final class RobustnessUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDown() async throws {
        await MainActor.run { XCUIDevice.shared.orientation = .portrait }
    }

    @MainActor
    private func launch(_ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestFixtures", "-uiTestSeed", "7", "-uiTestResetDefaults"] + extra
        app.launch()
        return app
    }

    @MainActor
    func testR1_doubleTapAnswerCountsOnce() throws {
        let app = launch()
        app.buttons["home.start.flag"].tap()
        let option = app.buttons["game.option.0"]
        XCTAssertTrue(option.waitForExistence(timeout: 10))

        option.doubleTap()

        let score = app.staticTexts["game.score"].label
        XCTAssertTrue(score == "Skóre 0" || score == "Skóre 1", score)
        XCTAssertEqual(app.staticTexts["game.progress"].label, "Otázka 1/10")
    }

    @MainActor
    func testR2_leavingGameDoesNotSaveResult() throws {
        let app = launch()
        app.buttons["home.start.flag"].tap()
        XCTAssertTrue(app.buttons["game.option.0"].waitForExistence(timeout: 10))
        app.buttons["game.option.0"].tap()

        app.buttons["Ukončit"].firstMatch.tap()
        app.buttons["Pokračovat"].firstMatch.tap()
        XCTAssertTrue(app.staticTexts["game.progress"].exists)

        app.buttons["Ukončit"].firstMatch.tap()
        app.buttons["Ukončit hru"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Vlajkař"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Historie"].tap()
        XCTAssertTrue(app.staticTexts["Zatím žádná hra"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testR3_oceaniaWithSixOptions() throws {
        let app = launch(["-game.region", "Oceania", "-game.optionCount", "6", "-game.unMembersOnly", "NO"])
        app.buttons["home.start.capital"].tap()

        XCTAssertTrue(app.staticTexts["game.country"].waitForExistence(timeout: 10))
        for index in 0 ..< 6 {
            XCTAssertTrue(app.buttons["game.option.\(index)"].isHittable)
        }
    }

    @MainActor
    func testR4_largestTextHomeAndGameStayUsable() throws {
        let app = launch(["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL", "-game.optionCount", "6"])
        app.buttons["home.start.flag"].tap()
        let option = app.buttons["game.option.5"]
        XCTAssertTrue(option.waitForExistence(timeout: 10))

        // Na největší písmo se smí scrollovat, ale každé tlačítko musí být dosažitelné.
        app.swipeUp()
        option.tap()
        let next = app.buttons["game.next"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        sleep(1)
        next.tap()
        XCTAssertTrue(app.staticTexts["game.progress"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testR5_rotationKeepsPortraitLayout() throws {
        let app = launch()
        app.buttons["home.start.flag"].tap()
        XCTAssertTrue(app.buttons["game.option.3"].waitForExistence(timeout: 10))

        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(1)

        XCTAssertEqual(app.windows.firstMatch.frame.width, 375)
        XCTAssertTrue(app.buttons["game.option.3"].isHittable)
    }

    @MainActor
    func testR6_refreshOfflineShowsErrorAndKeepsData() throws {
        let app = launch(["-uiTestOffline"])
        app.tabBars.buttons["Nastavení"].tap()
        app.buttons["settings.refresh"].tap()

        XCTAssertTrue(app.staticTexts["settings.error"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Hra"].tap()
        app.buttons["home.start.flag"].tap()
        XCTAssertTrue(app.buttons["game.option.0"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testR7_playAgainSavesEachGameOnce() throws {
        let app = launch()
        app.buttons["home.start.population"].tap()
        for round in 1 ... 2 {
            for _ in 1 ... 10 {
                XCTAssertTrue(app.buttons["game.option.0"].waitForExistence(timeout: 10))
                app.buttons["game.option.0"].tap()
                app.buttons["game.next"].tap()
            }
            XCTAssertTrue(app.buttons[round == 1 ? "result.again" : "result.done"].waitForExistence(timeout: 5))
            app.buttons[round == 1 ? "result.again" : "result.done"].tap()
        }
        app.tabBars.buttons["Historie"].tap()
        let rows = app.descendants(matching: .any).matching(identifier: "history.row")
        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(rows.count, 2)
    }
}
