import SwiftUI
import SwiftData

struct CreatePlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \StrengthExercise.name) private var availableExercises: [StrengthExercise]
    
    @State private var planName: String = ""
    @State private var items: [ExerciseItemInput] = []
    
    struct ExerciseItemInput: Identifiable {
        let id = UUID()
        var exercise: StrengthExercise?
        var targetSets: Int = 3
        var targetReps: String = "8-10"
        var restDuration: Int = 90
        var restAfterExercise: Int = 120
    }
    
    var body: some View {
        Form {
            Section(header: Text("Plan Details")) {
                TextField("Plan Name", text: $planName)
            }
            
            Section(header: Text("Exercises")) {
                List {
                    ForEach($items) { $item in
                        VStack(alignment: .leading, spacing: 10) {
                            Picker("Exercise", selection: $item.exercise) {
                                Text("Select").tag(nil as StrengthExercise?)
                                ForEach(availableExercises) { exercise in
                                    Text(exercise.name).tag(exercise as StrengthExercise?)
                                }
                            }
                            
                            Stepper("Sets: \(item.targetSets)", value: $item.targetSets, in: 1...10)
                            
                            HStack {
                                Text("Reps:")
                                TextField("e.g. 5, 8-10", text: $item.targetReps)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            Stepper("Rest between sets: \(item.restDuration)s", value: $item.restDuration, in: 0...300, step: 15)
                            Stepper("Rest after exercise: \(item.restAfterExercise)s", value: $item.restAfterExercise, in: 0...600, step: 15)
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: moveItems)
                }
                
                Button(action: {
                    items.append(ExerciseItemInput())
                }) {
                    Label("Add Exercise", systemImage: "plus.circle")
                }
            }
        }
        .navigationTitle("New Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { savePlan() }
                    .disabled(planName.isEmpty || !items.contains(where: { $0.exercise != nil }))
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    private func savePlan() {
        let newPlan = PlannedWorkout(name: planName)
        modelContext.insert(newPlan)
        
        for (index, input) in items.enumerated() {
            if let exercise = input.exercise {
                let item = PlannedExerciseItem(
                    exercise: exercise,
                    targetSets: input.targetSets,
                    targetReps: input.targetReps,
                    restDurationSeconds: input.restDuration,
                    restAfterExerciseSeconds: input.restAfterExercise,
                    order: index
                )
                modelContext.insert(item)
                newPlan.exercises.append(item)
            }
        }
        
        try? modelContext.save()
        
        dismiss()
    }
}
