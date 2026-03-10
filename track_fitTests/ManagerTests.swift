//
//  ManagerTests.swift
//  track_fitTests
//

import Testing
import Foundation
@testable import track_fit

@Suite("Manager Tests")
struct ManagerTests {

    @Test("Test LiveActivityManager early exits")
    func testLiveActivityManager() async throws {
        let manager = LiveActivityManager.shared
        
        manager.startPlanActivity(planName: "Test Plan", firstExerciseName: "Pushups", totalSets: 3)
        manager.updatePlanActivity(currentExerciseName: "Pushups", currentSet: 2, totalSets: 3, isResting: true, restEndDate: Date().addingTimeInterval(60))
        manager.endActivity()
    }

    @Test("Test HealthKitManager early exits")
    @MainActor
    func testHealthKitManager() async throws {
        let manager = HealthKitManager.shared
        
        manager.requestAuthorization()
        
        manager.fetchLatestWeight { weight in
            #expect(weight == nil)
        }
        
        manager.fetchAverageHeartRate(startDate: Date().addingTimeInterval(-3600), endDate: Date()) { bpm in
            #expect(bpm == nil)
        }
        
        manager.saveStrengthWorkout(startDate: Date().addingTimeInterval(-3600), endDate: Date(), energyBurned: 300)
    }
}
