import SwiftUI
import SwiftData

struct PlansListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlannedWorkout.name) private var plans: [PlannedWorkout]
    
    @State private var showingCreatePlan = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(plans) { plan in
                    NavigationLink(destination: PlanDetailView(plan: plan)) {
                        VStack(alignment: .leading) {
                            Text(plan.name)
                                .font(.headline)
                            Text("\(plan.exercises.count) exercises")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deletePlans)
            }
            .navigationTitle("Workout Plans")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingCreatePlan = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreatePlan) {
                NavigationStack {
                    CreatePlanView()
                }
            }
            .overlay {
                if plans.isEmpty {
                    ContentUnavailableView(
                        "No Plans",
                        systemImage: "clipboard",
                        description: Text("Create your first guided workout plan.")
                    )
                }
            }
            .onAppear(perform: syncPlansToWatch)
            .onChange(of: plans) { _ in
                syncPlansToWatch()
            }
        }
    }
    
    private func syncPlansToWatch() {
        let transfers = plans.map { plan in
            PlannedWorkoutTransfer(
                id: plan.id.hashValue.description, // using hashValue as simple ID for now
                name: plan.name,
                exercises: plan.exercises.sorted(by: { $0.order < $1.order }).map { item in
                    PlannedExerciseTransfer(
                        exerciseName: item.exercise?.name ?? "Unknown",
                        targetSets: item.targetSets,
                        targetReps: item.targetReps,
                        restDurationSeconds: item.restDurationSeconds,
                        restAfterExerciseSeconds: item.restAfterExerciseSeconds,
                        order: item.order
                    )
                }
            )
        }
        WatchSessionManager.shared.sendPlans(transfers)
    }
    
    private func deletePlans(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(plans[index])
            }
        }
    }
}

struct PlanDetailView: View {
    var plan: PlannedWorkout
    @State private var isWorkoutActive = false
    
    var body: some View {
        VStack {
            List {
                ForEach(plan.exercises.sorted(by: { $0.order < $1.order })) { item in
                    VStack(alignment: .leading) {
                        Text(item.exercise?.name ?? "Unknown Exercise")
                            .font(.headline)
                        HStack {
                            Text("\(item.targetSets) sets x \(item.targetReps)")
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Rest: \(item.restDurationSeconds)s")
                                Text("Next Ex: \(item.restAfterExerciseSeconds)s")
                                    .font(.caption2)
                            }
                            .foregroundColor(.secondary)
                        }
                        .font(.subheadline)
                    }
                }
            }
            
            Button(action: { isWorkoutActive = true }) {
                Text("Start Workout")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding()
        }
        .navigationTitle(plan.name)
        .fullScreenCover(isPresented: $isWorkoutActive) {
            NavigationStack {
                ActivePlanWorkoutView(plan: plan)
            }
        }
    }
}

#Preview {
    PlansListView()
        .modelContainer(for: [PlannedWorkout.self, PlannedExerciseItem.self, StrengthExercise.self], inMemory: true)
}
