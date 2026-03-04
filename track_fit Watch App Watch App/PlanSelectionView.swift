import SwiftUI

struct PlanSelectionView: View {
    @StateObject private var sessionManager = WatchSessionManager.shared
    
    var body: some View {
        List {
            if sessionManager.plans.isEmpty {
                Text("No plans available. Create a plan on your iPhone and it will sync here.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                ForEach(sessionManager.plans) { plan in
                    NavigationLink(destination: GuidedWorkoutView(plan: plan)) {
                        VStack(alignment: .leading) {
                            Text(plan.name)
                                .font(.headline)
                            Text("\(plan.exercises.count) exercises")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Plans")
    }
}

#Preview {
    PlanSelectionView()
}
