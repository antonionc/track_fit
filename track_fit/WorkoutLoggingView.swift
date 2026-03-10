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
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Exercise Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Exercise")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
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
                            .onChange(of: selectedExercise) { _, newValue in
                                if let name = newValue?.name {
                                    watchSession.sendActiveExercise(name)
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    }
                    .cardStyle()
                    
                    // Sets Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Sets")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer()
                            Button(action: addSet) {
                                Label("Add Set", systemImage: "plus")
                            }
                            .font(.subheadline.bold())
                        }
                        
                        VStack(spacing: 10) {
                            ForEach($sets) { $set in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Weight")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        TextField("0", text: $set.weight)
                                            .keyboardType(.decimalPad)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                    VStack(alignment: .leading) {
                                        Text("Reps")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        TextField("0", text: $set.reps)
                                            .keyboardType(.numberPad)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                    
                                    Button(action: {
                                        if let index = sets.firstIndex(where: { $0.id == set.id }) {
                                            sets.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .padding(.top, 16)
                                }
                                Divider()
                            }
                        }
                    }
                    .cardStyle()
                }
                .padding()
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
        }
        .onReceive(watchSession.setLoggedPublisher) { (exerciseName, weight, reps) in
            // Only append if it matches the current exercise
            if self.selectedExercise?.name == exerciseName {
                // Replace empty initial row
                if self.sets.count == 1 && self.sets[0].weight.isEmpty && self.sets[0].reps.isEmpty {
                    self.sets[0] = SetInput(weight: String(weight), reps: String(reps))
                } else {
                    self.sets.append(SetInput(weight: String(weight), reps: String(reps)))
                }
            }
        }
        .onReceive(watchSession.workoutSummaryPublisher) { hr, cal in
            self.watchAverageHeartRate = hr
            self.watchTotalCalories = cal
        }
        .onDisappear {
            watchSession.sendWorkoutStatus(isStarted: false)
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
