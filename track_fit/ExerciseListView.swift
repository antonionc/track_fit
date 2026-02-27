import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StrengthExercise.name) private var exercises: [StrengthExercise]
    @State private var showingAddExercise = false
    
    var body: some View {
        List {
            ForEach(exercises) { exercise in
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.headline)
                    if let group = exercise.muscleGroup {
                        Text(group)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteExercises)
        }
        .navigationTitle("Exercises")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddExercise = true }) {
                    Label("Add Exercise", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView()
        }
    }
    
    private func deleteExercises(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(exercises[index])
        }
    }
}

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var muscleGroup = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    TextField("Name", text: $name)
                    TextField("Muscle Group", text: $muscleGroup)
                }
            }
            .navigationTitle("New Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newExercise = StrengthExercise(name: name, muscleGroup: muscleGroup.isEmpty ? nil : muscleGroup)
                        modelContext.insert(newExercise)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ExerciseListView()
        .modelContainer(for: StrengthExercise.self, inMemory: true)
}
