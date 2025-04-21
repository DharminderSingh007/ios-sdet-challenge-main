//
//  CountriesChallengeUITestsLaunchTests.swift
//  CountriesChallengeUITests
//

import XCTest

final class CountriesChallengeUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify app launched correctly
        XCTAssertTrue(app.isRunning)
        
        // Verify main screen elements
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 5), "Table view should appear after launch")
        
        // Verify navigation bar
        let navBar = app.navigationBars.firstMatch
        XCTAssertTrue(navBar.exists, "Navigation bar should exist")
        
        // Take screenshot for visual verification
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
