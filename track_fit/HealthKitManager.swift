import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    @Published var isAuthorized: Bool = false
    
    // We only need authorization if HealthKit is available on the device
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let workoutType = HKObjectType.workoutType()
        let energyBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let typesToShare: Set = [workoutType, energyBurnedType]
        let typesToRead: Set = [workoutType, energyBurnedType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if let error = error {
                    print("HealthKit Authorization Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func saveStrengthWorkout(startDate: Date, endDate: Date, energyBurned: Double? = nil) {
        guard HKHealthStore.isHealthDataAvailable(), isAuthorized else { return }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        
        let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: nil)
        
        builder.beginCollection(withStart: startDate) { success, error in
            guard success else {
                print("Failed to begin collection: \(error?.localizedDescription ?? "")")
                return
            }
            
            let finishBlock = {
                builder.endCollection(withEnd: endDate) { success, error in
                    guard success else {
                        print("Failed to end collection: \(error?.localizedDescription ?? "")")
                        return
                    }
                    builder.finishWorkout { workout, error in
                        if let error = error {
                            print("Failed to finish workout: \(error.localizedDescription)")
                        } else {
                            print("Successfully saved workout")
                        }
                    }
                }
            }
            
            if let energy = energyBurned,
               let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                let quantity = HKQuantity(unit: .kilocalorie(), doubleValue: energy)
                let sample = HKQuantitySample(type: energyType, quantity: quantity, start: startDate, end: endDate)
                
                builder.add([sample]) { success, error in
                    guard success else {
                        print("Failed to add samples: \(error?.localizedDescription ?? "")")
                        return
                    }
                    finishBlock()
                }
            } else {
                finishBlock()
            }
        }
    }
}
