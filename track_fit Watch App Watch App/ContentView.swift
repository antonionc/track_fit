//
//  ContentView.swift
//  track_fit Watch App Watch App
//
//  Created by Antonio Navarro Cano on 2/3/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sessionManager = WatchSessionManager.shared
    @EnvironmentObject private var healthManager: WatchHealthManager
    
    var body: some View {
        NavigationView {
            VStack {
                if let activeExercise = sessionManager.activeExerciseName {
                    WatchWorkoutActiveView(exerciseName: activeExercise)
                } else if sessionManager.activeWorkoutStartDate != nil || healthManager.isWorkoutActive {
                    // Check if HealthKit workout is running independently or tracked via iPhone
                    VStack(spacing: 8) {
                        if healthManager.isWorkoutActive {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text(String(format: "%.0f BPM", healthManager.liveHeartRate))
                                    .font(.system(.title3, design: .rounded).bold())
                                    .foregroundColor(.red)
                            }
                            
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text(String(format: "%.0f kcal", healthManager.activeEnergyBurned))
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(.orange)
                            }
                        } else {
                            Image(systemName: "figure.run.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            
                            Text("Workout Active")
                                .font(.headline)
                        }
                        
                        Text(healthManager.isWorkoutActive ? "Ready for next exercise from iPhone." : "Start an exercise on your iPhone to log sets from your wrist.")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            
                        if healthManager.isWorkoutActive {
                            Button(action: {
                                healthManager.endWorkout()
                            }) {
                                Text("End Session")
                                    .font(.caption)
                                    .bold()
                            }
                            .tint(.red)
                            .padding(.top, 4)
                        } else {
                            Button(action: {
                                healthManager.startWorkout()
                            }) {
                                Text("Start Vitals Session")
                                    .font(.caption)
                                    .bold()
                            }
                            .tint(.green)
                            .padding(.top, 4)
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "iphone.and.arrow.forward")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Ready to Track")
                            .font(.headline)
                        
                        if healthManager.isAuthorized {
                            Button(action: {
                                healthManager.startWorkout()
                            }) {
                                Text("Start Session")
                                    .bold()
                            }
                            .tint(.green)
                        } else {
                            Button("Authorize HealthKit") {
                                healthManager.requestAuthorization()
                            }
                            .tint(.blue)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("TrackFit")
            .onAppear {
                healthManager.requestAuthorization()
            }
        }
    }
}

#Preview {
    ContentView()
}
