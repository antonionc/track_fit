//
//  track_fitUITests.swift
//  track_fitUITests
//
//  Created by Antonio Navarro Cano on 11/9/25.
//

import XCTest

final class track_fitUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testAppNavigationFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Verify we start on Dashboard
        XCTAssertTrue(app.staticTexts["Track Fit"].waitForExistence(timeout: 2))
        
        // 2. Navigate to Plans Tab
        app.tabBars.buttons["Plans"].tap()
        XCTAssertTrue(app.navigationBars.staticTexts["Workout Plans"].waitForExistence(timeout: 2) || app.staticTexts["Workout Plans"].exists)
        
        // 3. Navigate to Profile Tab
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["Profile"].waitForExistence(timeout: 2) || app.navigationBars.staticTexts["Profile"].exists)
        
        // 4. Go back to Dashboard
        app.tabBars.buttons["Dashboard"].tap()
        
        // 5. Dashboard Quick Actions: Log Workout
        app.buttons["Log Workout"].tap()
        // Wait for WorkoutLoggingView to appear
        XCTAssertTrue(app.staticTexts["Log Workout"].waitForExistence(timeout: 2) || app.navigationBars.staticTexts["Log Workout"].exists)
        app.navigationBars.buttons.firstMatch.tap() // Back button
        
        // 6. Dashboard Quick Actions: Exercises
        app.buttons["Exercises"].tap()
        XCTAssertTrue(app.staticTexts["Exercises"].waitForExistence(timeout: 2) || app.navigationBars.staticTexts["Exercises"].exists)
        app.navigationBars.buttons.firstMatch.tap() // Back button
        
        // 7. Dashboard Quick Actions: View Progress
        app.buttons["View Progress"].tap()
        XCTAssertTrue(app.staticTexts["Progress"].waitForExistence(timeout: 2) || app.navigationBars.staticTexts["Progress"].exists)
        app.navigationBars.buttons.firstMatch.tap() // Back button
    }
}
