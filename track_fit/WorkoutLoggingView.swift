import SwiftUI
import SwiftData

struct WorkoutLoggingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StrengthExercise.name) private var exercises: [StrengthExercise]
    
    @State private var selectedExercise: StrengthExercise?
    @State private var sets: [SetInput] = [SetInput(weight: "", reps: "")]
    @State private var date = Date()
    @State private var watchAverageHeartRate: Double?
    @State private var watchTotalCalories: Double?
    
    @StateObject private var watchSession = WatchSessionManager.shared
    
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
                    .onChange(of: selectedExercise) { newValue in
                        if let name = newValue?.name {
                            watchSession.sendActiveExercise(name)
                        }
                    }
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
        .onAppear {
            watchSession.sendWorkoutStatus(isStarted: true)
            if let name = selectedExercise?.name {
                watchSession.sendActiveExercise(name)
            }
            
            watchSession.onLogSetReceived = { exerciseName, weight, reps in
                // Only append if it matches the current exercise
                if self.selectedExercise?.name == exerciseName {
                    // Replace empty initial row
                    if self.sets.count == 1 && self.sets[0].weight.isEmpty && self.sets[0].reps.isEmpty {
                        self.sets[0] = SetInput(weight: String(weight), reps: String(reps))
                    } else {
                        self.sets.append(SetInput(weight: String(weight), reps: String(reps)))
                    }
                    
                    // Start Live Activity for Rest Timer (assuming 60s for now, syncing with watch timer)
                    let nextSet = self.sets.count + 1
                    let endDate = Calendar.current.date(byAdding: .second, value: 60, to: Date()) ?? Date()
                    LiveActivityManager.shared.startActivity(exerciseName: exerciseName, endDate: endDate, nextSetNumber: nextSet)
                }
            }
            
            watchSession.onWorkoutSummaryReceived = { hr, cal in
                self.watchAverageHeartRate = hr
                self.watchTotalCalories = cal
            }
        }
        .onDisappear {
            watchSession.sendWorkoutStatus(isStarted: false)
            watchSession.onLogSetReceived = nil
            LiveActivityManager.shared.endActivity()
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
        LiveActivityManager.shared.endActivity()
        guard let exercise = selectedExercise else { return }
        
        let log = StrengthWorkoutLog(date: date, exercise: exercise)
        log.averageHeartRate = watchAverageHeartRate
        log.totalCaloriesBurned = watchTotalCalories
        modelContext.insert(log)
        
        var validSetsCount = 0
        for setInput in sets {
            if let weight = Double(setInput.weight), let reps = Int(setInput.reps) {
                let setLog = StrengthSetLog(weight: weight, reps: reps)
                log.sets.append(setLog)
                validSetsCount += 1
            }
        }
        
        // Save to HealthKit only if not already handled by Watch
        if validSetsCount > 0 && watchAverageHeartRate == nil {
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
