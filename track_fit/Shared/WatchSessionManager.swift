import Foundation
import WatchConnectivity
import Combine

struct PlannedWorkoutTransfer: Codable, Identifiable {
    var id: String
    var name: String
    var exercises: [PlannedExerciseTransfer]
}

struct PlannedExerciseTransfer: Codable {
    var exerciseName: String
    var targetSets: Int
    var targetReps: String
    var restDurationSeconds: Int
    var restAfterExerciseSeconds: Int
    var order: Int
}

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    
    @Published var activeExerciseName: String?
    @Published var activeWorkoutStartDate: Date?
    @Published var plans: [PlannedWorkoutTransfer] = []
    
    // Broadcast events via Combine instead of single closures so multiple listeners can react
    let setLoggedPublisher = PassthroughSubject<(String, Double, Int), Never>()
    let workoutStartedPublisher = PassthroughSubject<Void, Never>()
    let workoutFinishedPublisher = PassthroughSubject<Void, Never>()
    let workoutSummaryPublisher = PassthroughSubject<(Double, Double), Never>()
    
    // Legacy closures for existing simple UI listeners
    var onPlansReceived: (([PlannedWorkoutTransfer]) -> Void)?
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            
            if let data = session.receivedApplicationContext["plansData"] as? Data {
                if let decodedPlans = try? JSONDecoder().decode([PlannedWorkoutTransfer].self, from: data) {
                    self.plans = decodedPlans
                }
            }
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

    func sendWorkoutSummary(averageHeartRate: Double, totalCaloriesBurned: Double) {
        guard WCSession.default.activationState == .activated else { return }
        
        let message: [String: Any] = [
            "type": "workoutSummary",
            "averageHeartRate": averageHeartRate,
            "totalCaloriesBurned": totalCaloriesBurned
        ]
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Failed to send workout summary: \(error.localizedDescription)")
        }
    }
    
    func sendPlans(_ plans: [PlannedWorkoutTransfer]) {
        guard WCSession.default.activationState == .activated else { return }
        
        if let data = try? JSONEncoder().encode(plans) {
            let context: [String: Any] = [
                "type": "syncPlans",
                "plansData": data
            ]
            
            try? WCSession.default.updateApplicationContext(context)
            
            WCSession.default.sendMessage(context, replyHandler: nil) { error in
                print("Failed to send plans: \(error.localizedDescription)")
            }
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
                    self.setLoggedPublisher.send((name, weight, reps))
                }
            case "workoutStatus":
                if let isStarted = message["isStarted"] as? Bool {
                    if isStarted {
                        self.activeWorkoutStartDate = Date()
                        self.workoutStartedPublisher.send(())
                    } else {
                        self.activeWorkoutStartDate = nil
                        self.activeExerciseName = nil
                        self.workoutFinishedPublisher.send(())
                    }
                }
            case "workoutSummary":
                if let hr = message["averageHeartRate"] as? Double,
                   let cal = message["totalCaloriesBurned"] as? Double {
                    self.workoutSummaryPublisher.send((hr, cal))
                }
            case "syncPlans":
                if let data = message["plansData"] as? Data {
                    if let decodedPlans = try? JSONDecoder().decode([PlannedWorkoutTransfer].self, from: data) {
                        self.plans = decodedPlans
                        self.onPlansReceived?(decodedPlans)
                    }
                }
            default:
                break
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            if let data = applicationContext["plansData"] as? Data {
                if let decodedPlans = try? JSONDecoder().decode([PlannedWorkoutTransfer].self, from: data) {
                    self.plans = decodedPlans
                    self.onPlansReceived?(decodedPlans)
                }
            }
        }
    }
}
