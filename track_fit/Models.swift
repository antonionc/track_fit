import Foundation
import SwiftData

@Model
final class StrengthExercise {
    var name: String
    var muscleGroup: String?
    
    @Relationship(deleteRule: .cascade, inverse: \StrengthWorkoutLog.exercise)
    var logs: [StrengthWorkoutLog] = []
    
    init(name: String, muscleGroup: String? = nil) {
        self.name = name
        self.muscleGroup = muscleGroup
    }
}

@Model
final class StrengthWorkoutLog {
    var date: Date
    var exercise: StrengthExercise?
    var averageHeartRate: Double?
    var totalCaloriesBurned: Double?
    
    @Relationship(deleteRule: .cascade)
    var sets: [StrengthSetLog] = []
    
    init(date: Date = Date(), exercise: StrengthExercise? = nil) {
        self.date = date
        self.exercise = exercise
    }
}

@Model
final class StrengthSetLog {
    var weight: Double
    var reps: Int
    var timestamp: Date
    
    init(weight: Double, reps: Int, timestamp: Date = Date()) {
        self.weight = weight
        self.reps = reps
        self.timestamp = timestamp
    }
}
