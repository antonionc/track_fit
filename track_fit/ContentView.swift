//
//  ContentView.swift
//  track_fit
//
//  Created by Antonio Navarro Cano on 11/9/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            PlansListView()
                .tabItem {
                    Label("Plans", systemImage: "list.clipboard.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StrengthWorkoutLog.date, order: .reverse) private var workoutLogs: [StrengthWorkoutLog]
    
    @State private var latestWeight: Double?
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        
                        quickActionsSection
                        
                        recentWorkoutsSection
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                fetchHealthData()
            }
        }
    }
    
    private func fetchHealthData() {
        if HealthKitManager.shared.isAuthorized {
            HealthKitManager.shared.fetchLatestWeight { weight in
                self.latestWeight = weight
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Track Fit")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("Let's crush it today!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.top)
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                NavigationLink(destination: WorkoutLoggingView()) {
                    dashboardCard(title: "Log Workout", icon: "plus.circle.fill", color: .blue)
                }
                
                NavigationLink(destination: ExerciseListView()) {
                    dashboardCard(title: "Exercises", icon: "list.bullet.circle.fill", color: .green)
                }
            }
            
            NavigationLink(destination: ProgressChartView()) {
                dashboardCard(title: "View Progress", icon: "chart.bar.fill", color: .orange)
            }
        }
    }
    
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Workouts")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink(destination: WorkoutHistoryView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if workoutLogs.isEmpty {
                Text("No workouts recorded yet.")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(12)
            } else {
                ForEach(workoutLogs.prefix(5)) { log in
                    NavigationLink(destination: WorkoutDetailView(workout: log)) {
                        WorkoutRow(log: log)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private func dashboardCard(title: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.Colors.cardBackground)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.Colors.cardBorder, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct WorkoutRow: View {
    let log: StrengthWorkoutLog
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(log.exercise?.name ?? "Unknown Exercise")
                    .font(.body.bold())
                    .foregroundColor(.primary)
                Text(log.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("\(log.sets.count) sets")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .clipShape(Capsule())
        }
        .padding()
        .background(Theme.Colors.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [StrengthExercise.self, StrengthWorkoutLog.self, StrengthSetLog.self], inMemory: true)
}
