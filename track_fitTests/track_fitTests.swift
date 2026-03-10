//
//  ModelsTests.swift
//  track_fitTests
//

import Testing
import SwiftData
import Foundation
@testable import track_fit

@Suite("Models Tests")
struct ModelsTests {

    let container: ModelContainer

    init() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: 
            StrengthExercise.self,
            StrengthWorkoutLog.self,
            StrengthSetLog.self,
            PlannedWorkout.self,
            PlannedExerciseItem.self,
            configurations: configuration
        )
    }

    @Test("Test StrengthExercise initialization")
    func testStrengthExerciseInit() throws {
        let exercise = StrengthExercise(name: "Bench Press", muscleGroup: "Chest")
        #expect(exercise.name == "Bench Press")
        #expect(exercise.muscleGroup == "Chest")
        #expect(exercise.logs.isEmpty)
    }

    @Test("Test StrengthWorkoutLog initialization")
    func testStrengthWorkoutLogInit() throws {
        let date = Date()
        let exercise = StrengthExercise(name: "Squat")
        let log = StrengthWorkoutLog(date: date, exercise: exercise)
        
        #expect(log.date == date)
        #expect(log.exercise?.name == "Squat")
        #expect(log.sets.isEmpty)
        #expect(log.averageHeartRate == nil)
        #expect(log.totalCaloriesBurned == nil)
    }

    @Test("Test StrengthSetLog initialization")
    func testStrengthSetLogInit() throws {
        let date = Date()
        let setLog = StrengthSetLog(weight: 100.0, reps: 10, timestamp: date)
        
        #expect(setLog.weight == 100.0)
        #expect(setLog.reps == 10)
        #expect(setLog.timestamp == date)
    }

    @Test("Test PlannedWorkout initialization")
    func testPlannedWorkoutInit() throws {
        let plan = PlannedWorkout(name: "Push Day")
        #expect(plan.name == "Push Day")
        #expect(plan.exercises.isEmpty)
    }

    @Test("Test PlannedExerciseItem initialization")
    func testPlannedExerciseItemInit() throws {
        let exercise = StrengthExercise(name: "Overhead Press")
        let item = PlannedExerciseItem(
            exercise: exercise,
            targetSets: 3,
            targetReps: "8-12",
            restDurationSeconds: 90,
            restAfterExerciseSeconds: 120,
            order: 1
        )
        
        #expect(item.exercise?.name == "Overhead Press")
        #expect(item.targetSets == 3)
        #expect(item.targetReps == "8-12")
        #expect(item.restDurationSeconds == 90)
        #expect(item.restAfterExerciseSeconds == 120)
        #expect(item.order == 1)
    }
}
