import SwiftUI
import WatchKit

struct GuidedWorkoutView: View {
    let plan: PlannedWorkoutTransfer
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentExerciseIndex = 0
    @State private var currentSetIndex = 1
    @State private var isResting = false
    @State private var weight: Double = 0.0
    
    // Sort exercises by order
    private var exercises: [PlannedExerciseTransfer] {
        plan.exercises.sorted(by: { $0.order < $1.order })
    }
    
    private var currentExercise: PlannedExerciseTransfer? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    var body: some View {
        VStack {
            if let exercise = currentExercise {
                if isResting {
                    // Show rest timer sheet or view
                    RestTimerView(durationSeconds: exercise.restDurationSeconds, onDone: finishRest)
                } else {
                    activeExerciseView(exercise: exercise)
                }
            } else {
                Text("Workout Complete!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                
                Button("Finish") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .navigationTitle(plan.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func activeExerciseView(exercise: PlannedExerciseTransfer) -> some View {
        VStack {
            Text(exercise.exerciseName)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("Set \(currentSetIndex) of \(exercise.targetSets)")
                .font(.subheadline)
                .foregroundColor(.blue)
            
            Text("Target: \(exercise.targetReps) reps")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack {
                Button(action: { weight = max(0, weight - 2.5) }) {
                    Image(systemName: "minus")
                }
                .frame(width: 40)
                
                Text(String(format: "%.1f kg", weight))
                    .font(.system(.title3, design: .rounded).bold())
                    .frame(maxWidth: .infinity)
                
                Button(action: { weight += 2.5 }) {
                    Image(systemName: "plus")
                }
                .frame(width: 40)
            }
            .padding(.bottom)
            
            Button(action: logSet) {
                Text("Log & Rest")
                    .bold()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding(.horizontal)
    }
    
    private func logSet() {
        guard let exercise = currentExercise else { return }
        
        // Use WatchSessionManager to send the logged set
        WatchSessionManager.shared.sendLogSet(
            exerciseName: exercise.exerciseName,
            weight: weight,
            reps: Int(exercise.targetReps.split(separator: "-").last ?? "0") ?? 0 // simple parse for target
        )
        
        isResting = true
    }
    
    private func finishRest() {
        guard let exercise = currentExercise else { return }
        isResting = false
        
        if currentSetIndex < exercise.targetSets {
            currentSetIndex += 1
        } else {
            // Move to next exercise
            currentExerciseIndex += 1
            currentSetIndex = 1
            weight = 0.0 // reset default weight or keep previous
        }
    }
}


