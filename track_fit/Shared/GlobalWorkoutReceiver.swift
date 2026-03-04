import Foundation
import SwiftData
import Combine

@MainActor
class GlobalWorkoutReceiver {
    private let context: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    init(context: ModelContext) {
        self.context = context
        
        WatchSessionManager.shared.setLoggedPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] (exerciseName, weight, reps) in
                self?.handleLoggedSet(exerciseName: exerciseName, weight: weight, reps: reps)
            }
            .store(in: &cancellables)
    }
    
    private func handleLoggedSet(exerciseName: String, weight: Double, reps: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        do {
            let allLogs = try context.fetch(FetchDescriptor<StrengthWorkoutLog>())
            
            // Find a workout log for today and this matching exercise (so we append to it)
            var activeLog = allLogs.first { log in
                Calendar.current.isDate(log.date, inSameDayAs: today) && log.exercise?.name == exerciseName
            }
            
            if activeLog == nil {
                let exercises = try context.fetch(FetchDescriptor<StrengthExercise>())
                if let exercise = exercises.first(where: { $0.name == exerciseName }) {
                    let newLog = StrengthWorkoutLog(date: Date(), exercise: exercise)
                    context.insert(newLog)
                    activeLog = newLog
                }
            }
            
            if let log = activeLog {
                let newSet = StrengthSetLog(weight: weight, reps: reps)
                log.sets.append(newSet)
                try context.save()
            }
        } catch {
            print("Failed to save background set: \(error)")
        }
    }
}