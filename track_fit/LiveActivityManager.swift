import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<WorkoutPlanAttributes>?
    
    func startPlanActivity(planName: String, firstExerciseName: String, totalSets: Int) {
        print("LiveActivityManager: Attempting to start plan activity for \(planName)")
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { 
            print("LiveActivityManager: Activities are NOT enabled!")
            return 
        }
        
        endActivity()
        
        let attributes = WorkoutPlanAttributes(planName: planName)
        let contentState = WorkoutPlanAttributes.ContentState(
            currentExerciseName: firstExerciseName,
            currentSet: 1,
            totalSets: totalSets,
            isResting: false,
            restEndDate: nil
        )
        let activityContent = ActivityContent(state: contentState, staleDate: nil)
        
        do {
            currentActivity = try Activity<WorkoutPlanAttributes>.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )
            print("Started Live Activity for Plan \(planName)")
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updatePlanActivity(currentExerciseName: String, currentSet: Int, totalSets: Int, isResting: Bool, restEndDate: Date?) {
        guard let activity = currentActivity else { return }
        
        Task {
            let updatedState = WorkoutPlanAttributes.ContentState(
                currentExerciseName: currentExerciseName,
                currentSet: currentSet,
                totalSets: totalSets,
                isResting: isResting,
                restEndDate: restEndDate
            )
            let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
            
            await activity.update(updatedContent)
            print("Updated Live Activity for \(currentExerciseName)")
        }
    }
    
    func endActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            let finalState = activity.content.state
            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            await activity.end(finalContent, dismissalPolicy: .immediate)
            self.currentActivity = nil
            print("Ended Live Activity")
        }
    }
}
