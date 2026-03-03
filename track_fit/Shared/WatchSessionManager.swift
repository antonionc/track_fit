import Foundation
import WatchConnectivity
import Combine

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    
    @Published var activeExerciseName: String?
    @Published var activeWorkoutStartDate: Date?
    
    // Add closure properties to handle events in the views/models
    var onLogSetReceived: ((String, Double, Int) -> Void)?
    var onWorkoutStarted: (() -> Void)?
    var onWorkoutFinished: (() -> Void)?
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WCSession activation state: (\(activationState.rawValue)). Error: \(String(describing: error))")
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
    
    // MARK: - Sending Messages
    
    func sendActiveExercise(_ name: String) {
        guard WCSession.default.activationState == .activated else { return }
        
        let message = ["type": "activeExercise", "name": name]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send active exercise: \(error.localizedDescription)")
        }
    }
    
    func sendLogSet(exerciseName: String, weight: Double, reps: Int) {
        guard WCSession.default.activationState == .activated else { return }
        
        let message: [String: Any] = [
            "type": "logSet",
            "exerciseName": exerciseName,
            "weight": weight,
            "reps": reps
        ]
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send set log: \(error.localizedDescription)")
        }
    }
    
    func sendWorkoutStatus(isStarted: Bool) {
        guard WCSession.default.activationState == .activated else { return }
        
        let message: [String: Any] = [
            "type": "workoutStatus",
            "isStarted": isStarted
        ]
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send workout status: \(error.localizedDescription)")
        }
    }

    // MARK: - Receiving Messages
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            guard let type = message["type"] as? String else { return }
            
            switch type {
            case "activeExercise":
                if let name = message["name"] as? String {
                    self.activeExerciseName = name
                }
            case "logSet":
                if let name = message["exerciseName"] as? String,
                   let weight = message["weight"] as? Double,
                   let reps = message["reps"] as? Int {
                    self.onLogSetReceived?(name, weight, reps)
                }
            case "workoutStatus":
                if let isStarted = message["isStarted"] as? Bool {
                    if isStarted {
                        self.activeWorkoutStartDate = Date()
                        self.onWorkoutStarted?()
                    } else {
                        self.activeWorkoutStartDate = nil
                        self.activeExerciseName = nil
                        self.onWorkoutFinished?()
                    }
                }
            default:
                break
            }
        }
    }
}
