//
//  ContentView.swift
//  track_fit Watch App Watch App
//
//  Created by Antonio Navarro Cano on 2/3/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sessionManager = WatchSessionManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                if let activeExercise = sessionManager.activeExerciseName {
                    WatchWorkoutActiveView(exerciseName: activeExercise)
                } else if sessionManager.activeWorkoutStartDate != nil {
                    VStack(spacing: 12) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        
                        Text("Workout Active")
                            .font(.headline)
                        
                        Text("Start an exercise on your iPhone to log sets from your wrist.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "iphone.and.arrow.forward")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Ready to Track")
                            .font(.headline)
                        
                        Text("Start a workout on your iPhone to begin logging.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
            .navigationTitle("TrackFit")
        }
    }
}

#Preview {
    ContentView()
}
