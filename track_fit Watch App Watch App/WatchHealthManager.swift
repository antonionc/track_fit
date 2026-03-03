import Foundation
import HealthKit
import Combine

class WatchHealthManager: NSObject, ObservableObject, HKLiveWorkoutBuilderDelegate, HKWorkoutSessionDelegate {
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    @Published var isAuthorized: Bool = false
    @Published var isWorkoutActive: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var liveHeartRate: Double = 0
    @Published var activeEnergyBurned: Double = 0
    
    // Summary metrics to send to iPhone
    var averageHeartRate: Double = 0
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if let error = error {
                    print("Watch HealthKit Auth Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func startWorkout() {
        guard isAuthorized else { return }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            
            session?.delegate = self
            builder?.delegate = self
            
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            
            session?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date()) { success, error in
                DispatchQueue.main.async {
                    self.isWorkoutActive = success
                }
            }
        } catch {
            print("Failed to start workout session: \(error.localizedDescription)")
        }
    }
    
    func endWorkout() {
        session?.end()
        builder?.endCollection(withEnd: Date()) { success, error in
            self.builder?.finishWorkout { workout, error in
                DispatchQueue.main.async {
                    self.isWorkoutActive = false
                    if let workout = workout {
                        self.processWorkoutSummary(workout)
                    }
                }
            }
        }
    }
    
    private func processWorkoutSummary(_ workout: HKWorkout) {
        // Retrieve energy burned and send it to iPhone
        let totalEnergy = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? self.activeEnergyBurned
        
        // Let's send what we tracked locally if workout object doesn't have an easily accessible average HR
        // Usually you'd query sample data for HR, but we've been tracking an approximation during the live session or we can just send the latest.
        // For simplicity in this tracking app, we will send the accumulated metrics.
        
        WatchSessionManager.shared.sendWorkoutSummary(
            averageHeartRate: self.averageHeartRate > 0 ? self.averageHeartRate : self.liveHeartRate,
            totalCaloriesBurned: totalEnergy
        )
        
        // Reset metrics for next workout
        self.elapsedTime = 0
        self.liveHeartRate = 0
        self.activeEnergyBurned = 0
        self.averageHeartRate = 0
    }
    
    // MARK: - HKLiveWorkoutBuilderDelegate
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) { }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            
            DispatchQueue.main.async {
                switch quantityType {
                case HKQuantityType.quantityType(forIdentifier: .heartRate):
                    let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                    let value = statistics?.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                    if let val = value {
                        self.liveHeartRate = val
                    }
                    if let avg = statistics?.averageQuantity()?.doubleValue(for: heartRateUnit) {
                        self.averageHeartRate = avg
                    }
                    
                case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                    let energyUnit = HKUnit.kilocalorie()
                    let value = statistics?.sumQuantity()?.doubleValue(for: energyUnit)
                    if let val = value {
                        self.activeEnergyBurned = val
                    }
                    
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - HKWorkoutSessionDelegate
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        if toState == .running {
            DispatchQueue.main.async {
                self.isWorkoutActive = true
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error.localizedDescription)")
    }
}
