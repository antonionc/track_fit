import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    let workout: StrengthWorkoutLog
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(workout.exercise?.name ?? "Unknown Exercise")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                    
                    Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Vitals Summary")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 20) {
                            vitalMetric(icon: "heart.fill", color: .red, title: "Avg HR", value: workout.averageHeartRate != nil ? String(format: "%.0f BPM", workout.averageHeartRate!) : "--")
                            vitalMetric(icon: "flame.fill", color: .orange, title: "Calories", value: workout.totalCaloriesBurned != nil ? String(format: "%.0f kcal", workout.totalCaloriesBurned!) : "--")
                        }
                    }
                    .padding()
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sets (\(workout.sets.count))")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if workout.sets.isEmpty {
                            Text("No sets recorded.")
                                .foregroundColor(.gray)
                                .font(.body)
                        } else {
                            ForEach(workout.sets.sorted(by: { $0.timestamp < $1.timestamp })) { set in
                                HStack {
                                    Text("\(set.weight, specifier: "%.1f") kg")
                                        .font(.body.bold())
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(set.reps) reps")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Theme.Colors.cardBackground)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func vitalMetric(icon: String, color: Color, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
