import SwiftUI
import WatchKit

struct GuidedWorkoutView: View {
    let plan: PlannedWorkoutTransfer
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentExerciseIndex = 0
    @State private var currentSetIndex = 1
    @State private var isResting = false
    @State private var weight: Double = 0.0
    @State private var reps: Int?
    
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
                    let restTime = (currentSetIndex == exercise.targetSets) ? exercise.restAfterExerciseSeconds : exercise.restDurationSeconds
                    RestTimerView(durationSeconds: restTime, onDone: finishRest)
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
                VStack {
                    Text("Weight")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 2) {
                        Button(action: { if weight > 2.5 { weight -= 2.5 }}) {
                            Image(systemName: "minus.square.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.blue)
                        
                        Text(String(format: "%.1f", weight))
                            .font(.system(.title3, design: .rounded).bold())
                            .frame(minWidth: 40)
                        
                        Button(action: { weight += 2.5 }) {
                            Image(systemName: "plus.square.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text("Reps")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 2) {
                        Button(action: { 
                            let r = reps ?? Int(exercise.targetReps.split(separator: "-").last ?? "0") ?? 0
                            reps = max(1, r - 1)
                        }) {
                            Image(systemName: "minus.square.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.green)
                        
                        Text("\(reps ?? Int(exercise.targetReps.split(separator: "-").last ?? "0") ?? 0)")
                            .font(.system(.title3, design: .rounded).bold())
                            .frame(minWidth: 30)
                        
                        Button(action: { 
                            let r = reps ?? Int(exercise.targetReps.split(separator: "-").last ?? "0") ?? 0
                            reps = r + 1
                        }) {
                            Image(systemName: "plus.square.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.green)
                    }
                }
            }
            .padding(.bottom)
            
            Button(action: logSet) {
                Text(currentSetIndex == exercise.targetSets && currentExerciseIndex == exercises.count - 1 ? "Finish Workout" : "Log & Rest")
                    .bold()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding(.horizontal)
    }
    
    private func logSet() {
        guard let exercise = currentExercise else { return }
        
        let actualReps = reps ?? Int(exercise.targetReps.split(separator: "-").last ?? "0") ?? 0
        WatchSessionManager.shared.sendLogSet(
            exerciseName: exercise.exerciseName,
            weight: weight,
            reps: actualReps
        )
        
        if currentSetIndex == exercise.targetSets && currentExerciseIndex == exercises.count - 1 {
            // Workout complete! No rest needed.
            currentExerciseIndex += 1
        } else {
            isResting = true
        }
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
        reps = nil
    }
}


