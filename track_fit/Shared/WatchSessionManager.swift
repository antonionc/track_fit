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
    
    // Plan Tracking Publishers
    let planStartedPublisher = PassthroughSubject<(String, String, Int), Never>()
    let planUpdatedPublisher = PassthroughSubject<(String, Int, Int, Bool, Date?), Never>()
    let planEndedPublisher = PassthroughSubject<Void, Never>()
    
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
    
    func sendPlanStarted(planName: String, firstExerciseName: String, totalSets: Int) {
        guard WCSession.default.activationState == .activated else { return }
        let msg: [String: Any] = [
            "type": "planStarted",
            "planName": planName,
            "firstExerciseName": firstExerciseName,
            "totalSets": totalSets
        ]
        WCSession.default.sendMessage(msg, replyHandler: nil)
    }
    
    func sendPlanUpdated(currentExerciseName: String, currentSet: Int, totalSets: Int, isResting: Bool, restEndDate: Date?) {
        guard WCSession.default.activationState == .activated else { return }
        var msg: [String: Any] = [
            "type": "planUpdated",
            "currentExerciseName": currentExerciseName,
            "currentSet": currentSet,
            "totalSets": totalSets,
            "isResting": isResting
        ]
        if let restEndDate = restEndDate {
            msg["restEndDate"] = restEndDate.timeIntervalSince1970
        }
        WCSession.default.sendMessage(msg, replyHandler: nil)
    }
    
    func sendPlanEnded() {
        guard WCSession.default.activationState == .activated else { return }
        WCSession.default.sendMessage(["type": "planEnded"], replyHandler: nil)
    }
    
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
            case "planStarted":
                if let name = message["planName"] as? String,
                   let firstEx = message["firstExerciseName"] as? String,
                   let total = message["totalSets"] as? Int {
                    self.planStartedPublisher.send((name, firstEx, total))
                }
            case "planUpdated":
                if let ex = message["currentExerciseName"] as? String,
                   let set = message["currentSet"] as? Int,
                   let total = message["totalSets"] as? Int,
                   let isResting = message["isResting"] as? Bool {
                    let dateDouble = message["restEndDate"] as? Double
                    let date = dateDouble != nil ? Date(timeIntervalSince1970: dateDouble!) : nil
                    self.planUpdatedPublisher.send((ex, set, total, isResting, date))
                }
            case "planEnded":
                self.planEndedPublisher.send(())
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
