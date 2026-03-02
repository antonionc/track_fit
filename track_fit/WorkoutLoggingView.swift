import SwiftUI
import SwiftData

struct WorkoutLoggingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StrengthExercise.name) private var exercises: [StrengthExercise]
    
    @State private var selectedExercise: StrengthExercise?
    @State private var sets: [SetInput] = [SetInput(weight: "", reps: "")]
    @State private var date = Date()
    
    struct SetInput: Identifiable {
        let id = UUID()
        var weight: String
        var reps: String
    }
    
    var body: some View {
        Form {
            Section(header: Text("Exercise")) {
                if exercises.isEmpty {
                    Text("Please add an exercise from the Exercises tab first.")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    Picker("Select Exercise", selection: $selectedExercise) {
                        Text("Select an exercise").tag(nil as StrengthExercise?)
                        ForEach(exercises) { exercise in
                            Text(exercise.name).tag(exercise as StrengthExercise?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            
            Section(header: Text("Sets")) {
                ForEach($sets) { $set in
                    HStack {
                        TextField("Weight", text: $set.weight)
                            .keyboardType(.decimalPad)
                        TextField("Reps", text: $set.reps)
                            .keyboardType(.numberPad)
                    }
                }
                .onDelete(perform: deleteSets)
                
                Button(action: addSet) {
                    Label("Add Set", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Log Workout")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveWorkout()
                }
                .disabled(selectedExercise == nil || sets.isEmpty)
            }
        }
    }
    
    private func addSet() {
        let lastSet = sets.last
        sets.append(SetInput(weight: lastSet?.weight ?? "", reps: lastSet?.reps ?? ""))
    }
    
    private func deleteSets(at offsets: IndexSet) {
        sets.remove(atOffsets: offsets)
    }
    
    private func saveWorkout() {
        guard let exercise = selectedExercise else { return }
        
        let log = StrengthWorkoutLog(date: date, exercise: exercise)
        modelContext.insert(log)
        
        var validSetsCount = 0
        for setInput in sets {
            if let weight = Double(setInput.weight), let reps = Int(setInput.reps) {
                let setLog = StrengthSetLog(weight: weight, reps: reps)
                log.sets.append(setLog)
                validSetsCount += 1
            }
        }
        
        // Save to HealthKit
        if validSetsCount > 0 {
            // Estimate duration: 2 minutes per set
            let estimatedMinutes = validSetsCount * 2
            let endDate = Calendar.current.date(byAdding: .minute, value: estimatedMinutes, to: date) ?? date
            // Estimate energy: 5 calories per minute
            let estimatedCalories = Double(estimatedMinutes * 5)
            
            HealthKitManager.shared.saveStrengthWorkout(
                startDate: date,
                endDate: endDate,
                energyBurned: estimatedCalories
            )
        }
        
        dismiss()
    }
}

#Preview {
    WorkoutLoggingView()
        .modelContainer(for: [StrengthExercise.self, StrengthWorkoutLog.self, StrengthSetLog.self], inMemory: true)
}
