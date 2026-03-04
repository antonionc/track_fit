import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<RestTimerAttributes>?
    
    func startActivity(exerciseName: String, endDate: Date, nextSetNumber: Int) {
        print("LiveActivityManager: Attempting to start activity for \(exerciseName)")
        // Ensure Live Activities are supported and enabled
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { 
            print("LiveActivityManager: Activities are NOT enabled!")
            return 
        }
        
        // If there's an existing activity, end it before starting a new one
        endActivity()
        
        let attributes = RestTimerAttributes(exerciseName: exerciseName)
        let contentState = RestTimerAttributes.ContentState(
            endDate: endDate,
            nextSetNumber: nextSetNumber
        )
        let activityContent = ActivityContent(state: contentState, staleDate: nil)
        
        do {
            currentActivity = try Activity<RestTimerAttributes>.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )
            print("Started Live Activity for \(exerciseName)")
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }
    
    func endActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            let finalState = RestTimerAttributes.ContentState(
                endDate: Date(),
                nextSetNumber: activity.content.state.nextSetNumber
            )
            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            await activity.end(finalContent, dismissalPolicy: .immediate)
            self.currentActivity = nil
            print("Ended Live Activity")
        }
    }
}
