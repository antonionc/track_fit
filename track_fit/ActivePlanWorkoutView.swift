import SwiftUI

struct ActivePlanWorkoutView: View {
    let plan: PlannedWorkout
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentExerciseIndex = 0
    @State private var currentSetIndex = 1
    @State private var isResting = false
    @State private var restEndDate: Date? = nil
    @State private var weight: String = ""
    @State private var reps: String = ""
    
    // Sort exercises by order
    private var exercises: [PlannedExerciseItem] {
        plan.exercises.sorted(by: { $0.order < $1.order })
    }
    
    private var currentExercise: PlannedExerciseItem? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack {
                if let exercise = currentExercise {
                    if isResting {
                        // Show rest timer sheet or view
                        let restTime = (currentSetIndex == exercise.targetSets) ? exercise.restAfterExerciseSeconds : exercise.restDurationSeconds
                        restView(durationSeconds: restTime)
                    } else {
                        activeExerciseView(exercise: exercise)
                    }
                } else {
                    Text("Workout Complete!")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                    
                    Button("Finish") {
                        LiveActivityManager.shared.endActivity()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
        .navigationTitle(plan.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let exercise = currentExercise {
                LiveActivityManager.shared.startPlanActivity(
                    planName: plan.name,
                    firstExerciseName: exercise.exercise?.name ?? "Exercise",
                    totalSets: exercise.targetSets
                )
            }
        }
        .onDisappear {
            // End activity if the user leaves the view before finishing
            if currentExerciseIndex < exercises.count {
               LiveActivityManager.shared.endActivity()
            }
        }
    }
    
    private func activeExerciseView(exercise: PlannedExerciseItem) -> some View {
        VStack(spacing: 20) {
            Text(exercise.exercise?.name ?? "Unknown")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            
            Text("Set \(currentSetIndex) of \(exercise.targetSets)")
                .font(.title3)
                .foregroundColor(.blue)
            
            Text("Target: \(exercise.targetReps) reps")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            VStack(spacing: 15) {
                HStack {
                    Text("Weight")
                        .font(.headline)
                    TextField("kg/lbs", text: $weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Reps")
                        .font(.headline)
                    TextField("count", text: $reps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
            }
            .padding()
            .background(Theme.Colors.cardBackground)
            .cornerRadius(12)
            
            Spacer()
            
            Button(action: logSet) {
                Text(currentSetIndex == exercise.targetSets && currentExerciseIndex == exercises.count - 1 ? "Finish Workout" : "Log & Rest")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .padding(.bottom)
        }
        .padding()
    }
    
    private func restView(durationSeconds: Int) -> some View {
        VStack {
            Text("Rest")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
            
            if let endDate = restEndDate {
                Text(timerInterval: Date()...endDate, countsDown: true)
                    .font(.system(size: 80, weight: .bold, design: .monospaced))
                    .foregroundColor(.cyan)
                    .padding()
            }
            
            Spacer()
            
            Button("Skip Rest") {
                finishRest()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .font(.title3)
            .padding()
        }
        .padding()
        .onAppear {
            restEndDate = Date().addingTimeInterval(TimeInterval(durationSeconds))
        }
    }
    
    private func logSet() {
        guard let exercise = currentExercise else { return }
        
        // Normally we would save this to SwiftData Log, but avoiding it to keep it simple, or we can save it.
        // Let's assume GlobalWorkoutReceiver doesn't catch iOS sets dynamically yet.
        
        if currentSetIndex == exercise.targetSets && currentExerciseIndex == exercises.count - 1 {
            // Workout complete! No rest needed.
            currentExerciseIndex += 1
            LiveActivityManager.shared.endActivity()
        } else {
            isResting = true
            let restTime = (currentSetIndex == exercise.targetSets) ? exercise.restAfterExerciseSeconds : exercise.restDurationSeconds
            let endDate = Date().addingTimeInterval(TimeInterval(restTime))
            restEndDate = endDate
            
            // Update Activity
            LiveActivityManager.shared.updatePlanActivity(
                currentExerciseName: exercise.exercise?.name ?? "Exercise",
                currentSet: currentSetIndex,
                totalSets: exercise.targetSets,
                isResting: true,
                restEndDate: endDate
            )
        }
    }
    
    private func finishRest() {
        guard let exercise = currentExercise else { return }
        isResting = false
        restEndDate = nil
        
        if currentSetIndex < exercise.targetSets {
            currentSetIndex += 1
        } else {
            // Move to next exercise
            currentExerciseIndex += 1
            currentSetIndex = 1
            weight = ""
        }
        reps = ""
        
        if let nextExercise = currentExercise {
            LiveActivityManager.shared.updatePlanActivity(
                currentExerciseName: nextExercise.exercise?.name ?? "Exercise",
                currentSet: currentSetIndex,
                totalSets: nextExercise.targetSets,
                isResting: false,
                restEndDate: nil
            )
        }
    }
}
