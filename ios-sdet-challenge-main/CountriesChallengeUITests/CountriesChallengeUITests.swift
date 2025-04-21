//
//  CountriesChallengeUITests.swift
//  CountriesChallengeUITests
//

import XCTest

final class CountriesChallengeUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.

        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    // MARK: - Countries List Screen Tests
    
    func testCountriesListScreen() throws {
        // Verify the table view exists
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.exists, "Table view should exist")
        
        // Wait for data to load
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Table should load cells")
        
        // Verify we have multiple countries
        let cellsCount = tableView.cells.count
        XCTAssertGreaterThan(cellsCount, 1, "Should have loaded multiple countries")
        
        // Verify cells have the expected elements
        if let firstCell = tableView.cells.element(boundBy: 0) {
            XCTAssertTrue(firstCell.staticTexts.firstMatch.exists, "Cell should have text")
        }
        
        // Test scrolling
        tableView.swipeUp()
        tableView.swipeDown()
    }
    
    // MARK: - Country Detail Screen Tests
    
    func testCountryDetailScreen() throws {
        // Access the first country
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 5), "Table view should exist")
        
        // Tap the first country cell
        let firstCell = tableView.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First cell should exist")
        firstCell.tap()
        
        // Verify we have navigated to the detail screen
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5), "Scroll view should exist in detail screen")
        
        // Verify detail elements exist
        XCTAssertTrue(scrollView.staticTexts.firstMatch.exists, "Detail screen should have text")
        
        // Test scrolling in the detail view
        scrollView.swipeUp()
        scrollView.swipeDown()
        
        // Go back to the list
        app.navigationBars.buttons.firstMatch.tap()
        
        // Verify we are back at the list
        XCTAssertTrue(tableView.exists, "Should be back at the table view")
    }
    
    // MARK: - Search Functionality Tests
    
    func testSearchFunctionality() throws {
        // Verify search bar exists
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 5), "Search bar should exist")
        
        // Tap search bar
        searchBar.tap()
        
        // Enter search query (e.g., "United")
        searchBar.typeText("United")
        
        // Wait for search results
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 5), "Table view should exist")
        
        // Verify search results appear
        let cells = tableView.cells
        XCTAssertTrue(cells.firstMatch.waitForExistence(timeout: 5), "Search results should appear")
        
        // Verify filtered results contain the search term
        let cellTexts = cells.staticTexts.allElementsBoundByIndex.map { $0.label }
        let foundMatchingCell = cellTexts.contains { $0.contains("United") }
        XCTAssertTrue(foundMatchingCell, "Search results should contain the search term")
        
        // Clear search
        searchBar.buttons["Clear text"].tap()
        
        // Cancel search
        if let cancelButton = app.buttons["Cancel"] {
            cancelButton.tap()
        }
        
        // Verify we return to the original list
        XCTAssertTrue(tableView.cells.count > cells.count, "Should show more countries after clearing search")
    }
}
