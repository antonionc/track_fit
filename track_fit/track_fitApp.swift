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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [StrengthExercise.self, StrengthWorkoutLog.self, StrengthSetLog.self])
        }
    }
}
