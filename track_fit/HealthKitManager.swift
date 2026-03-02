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
        let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        
        let typesToShare: Set = [workoutType, energyBurnedType]
        let typesToRead: Set = [workoutType, energyBurnedType, bodyMassType, heartRateType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if let error = error {
                    print("HealthKit Authorization Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchLatestWeight(completion: @escaping (Double?) -> Void) {
        guard let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass), isAuthorized else {
            completion(nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: bodyMassType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let sample = samples?.first as? HKQuantitySample, error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            // Using kilograms for weight
            let weightInKg = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
            DispatchQueue.main.async {
                completion(weightInKg)
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchAverageHeartRate(startDate: Date, endDate: Date, completion: @escaping (Double?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate), isAuthorized else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, statistics, error in
            guard let stats = statistics, let average = stats.averageQuantity(), error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // Heart rate is typically beats-per-minute
            let bpm = average.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async {
                completion(bpm)
            }
        }
        
        healthStore.execute(query)
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
