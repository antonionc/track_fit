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
    
    @MainActor
    func testWorkoutHistoryNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to Workout History
        let seeAllButton = app.buttons["See All"]
        XCTAssertTrue(seeAllButton.waitForExistence(timeout: 3))
        seeAllButton.tap()
        
        XCTAssertTrue(app.navigationBars["Workout History"].waitForExistence(timeout: 2) || app.staticTexts["Workout History"].waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testCreatePlanAndStartWorkout() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Create an exercise
        app.buttons["Exercises"].tap()
        app.navigationBars.buttons["Add Exercise"].tap()
        
        let exNameField = app.textFields["Name"]
        XCTAssertTrue(exNameField.waitForExistence(timeout: 2))
        exNameField.tap()
        exNameField.typeText("Squat")
        
        app.navigationBars.buttons["Save"].tap()
        app.navigationBars.buttons.firstMatch.tap()
        
        // 2. Create Plan
        app.tabBars.buttons["Plans"].tap()
        app.navigationBars.buttons["Add"].tap()
        
        let planNameField = app.textFields["Plan Name"]
        XCTAssertTrue(planNameField.waitForExistence(timeout: 2))
        planNameField.tap()
        planNameField.typeText("Leg Day")
        
        app.buttons["Add Exercise"].tap()
        
        // Tap Picker. The label is usually "Exercise, Select"
        let picker = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Exercise'")).firstMatch
        if picker.waitForExistence(timeout: 2) {
            picker.tap()
            let squatOption = app.buttons["Squat"].firstMatch
            if squatOption.waitForExistence(timeout: 2) {
                squatOption.tap()
            }
        }
        
        app.navigationBars.buttons["Save"].tap()
        
        // Wait and start
        let planRow = app.staticTexts["Leg Day"].firstMatch
        if planRow.waitForExistence(timeout: 3) {
            planRow.tap()
            app.buttons["Start Workout"].tap()
            
            // Advance through workout
            let logRest = app.buttons["Log & Rest"]
            if logRest.waitForExistence(timeout: 3) {
                logRest.tap()
                let skip = app.buttons["Skip Rest"]
                if skip.waitForExistence(timeout: 2) {
                    skip.tap()
                }
            }
            
            // Assuming default plan has 3 sets, click 2 more times to finish
            if logRest.exists { logRest.tap(); if app.buttons["Skip Rest"].waitForExistence(timeout: 1) { app.buttons["Skip Rest"].tap() } }
            if app.buttons["Finish Workout"].waitForExistence(timeout: 2) {
                app.buttons["Finish Workout"].tap()
            }
            if app.buttons["Finish"].waitForExistence(timeout: 2) {
                app.buttons["Finish"].tap()
            }
        }
        
        // 3. Clean up the plan we just created
        app.tabBars.buttons["Plans"].tap()
        let planToDelete = app.staticTexts["Leg Day"].firstMatch
        if planToDelete.waitForExistence(timeout: 2) {
            planToDelete.swipeLeft()
            app.buttons["Delete"].tap()
        }
    }
}
