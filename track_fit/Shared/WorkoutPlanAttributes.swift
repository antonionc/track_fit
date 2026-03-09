import ActivityKit
import Foundation

struct WorkoutPlanAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentExerciseName: String
        var currentSet: Int
        var totalSets: Int
        var isResting: Bool
        var restEndDate: Date?
    }

    var planName: String
}
