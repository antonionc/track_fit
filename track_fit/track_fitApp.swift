//
//  track_fitApp.swift
//  track_fit
//
//  Created by Antonio Navarro Cano on 11/9/25.
//

import SwiftUI
import SwiftData

@main
struct track_fitApp: App {
    let container: ModelContainer
    let globalReceiver: GlobalWorkoutReceiver

    init() {
        _ = WatchSessionManager.shared
        do {
            container = try ModelContainer(for: StrengthExercise.self, StrengthWorkoutLog.self, StrengthSetLog.self, PlannedWorkout.self, PlannedExerciseItem.self)
            globalReceiver = GlobalWorkoutReceiver(context: container.mainContext)
            
            // Check if there are any exercises
            let descriptor = FetchDescriptor<StrengthExercise>()
            let existingExercises = try container.mainContext.fetchCount(descriptor)
            
            if existingExercises == 0 {
                // Prepopulate
                let defaultExercises = [
                    StrengthExercise(name: "Butterfly Chest press", muscleGroup: "Chest"),
                    StrengthExercise(name: "Lateral pulldown", muscleGroup: "Back"),
                    StrengthExercise(name: "Leg press", muscleGroup: "Legs"),
                    StrengthExercise(name: "Chest Press", muscleGroup: "Chest"),
                    StrengthExercise(name: "Row", muscleGroup: "Back"),
                    StrengthExercise(name: "Leg Curl", muscleGroup: "Legs"),
                    StrengthExercise(name: "Biceps Curl", muscleGroup: "Arms"),
                    StrengthExercise(name: "Shoulder Press", muscleGroup: "Shoulders")
                ]
                
                for exercise in defaultExercises {
                    container.mainContext.insert(exercise)
                }
            }
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    HealthKitManager.shared.requestAuthorization()
                }
        }
        .modelContainer(container)
    }
}
