import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StrengthWorkoutLog.date, order: .reverse) private var workoutLogs: [StrengthWorkoutLog]
    
    var body: some View {
        List {
            ForEach(workoutLogs) { log in
                NavigationLink(destination: WorkoutDetailView(workout: log)) {
                    VStack(alignment: .leading) {
                        Text(log.exercise?.name ?? "Unknown Exercise")
                            .font(.headline)
                        Text(log.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .onDelete(perform: deleteLog)
        }
        .navigationTitle("Workout History")
        .overlay {
            if workoutLogs.isEmpty {
                ContentUnavailableView(
                    "No Workouts",
                    systemImage: "dumbbell",
                    description: Text("You haven't recorded any workouts yet.")
                )
            }
        }
    }
    
    private func deleteLog(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(workoutLogs[index])
            }
        }
    }
}

#Preview {
    NavigationView {
        WorkoutHistoryView()
    }
    .modelContainer(for: [StrengthExercise.self, StrengthWorkoutLog.self, StrengthSetLog.self], inMemory: true)
}