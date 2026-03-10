import SwiftUI
import SwiftData
import Charts

struct ProgressChartView: View {
    @Query private var workoutLogs: [StrengthWorkoutLog]
    @State private var selectedExercise: StrengthExercise?
    @State private var latestWeight: Double?
    
    enum ProgressMetric: String, CaseIterable, Identifiable {
        case maxWeight = "Max Weight"
        case totalReps = "Total Reps"
        case totalSets = "Total Sets"
        case volume = "Volume"
        case strengthToWeight = "Ratio (Max/BW)"
        case averageHeartRate = "Avg HR"
        case calories = "Calories"
        
        var id: String { rawValue }
    }
    
    @State private var selectedMetric: ProgressMetric = .volume
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack {
            HStack {
                Picker("Metric", selection: $selectedMetric) {
                    ForEach(ProgressMetric.allCases) { metric in
                        Text(metric.rawValue).tag(metric)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }
            .padding(.top)

            Picker("Filter Exercise", selection: $selectedExercise) {
                Text("All Exercises").tag(nil as StrengthExercise?)
                let exercises = Array(Set(workoutLogs.compactMap { $0.exercise }))
                ForEach(exercises) { exercise in
                    Text(exercise.name).tag(exercise as StrengthExercise?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)
            .padding(.bottom)
            
            if selectedMetric == .strengthToWeight && latestWeight == nil {
                Text("Body weight data not available from Apple Health.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                Chart {
                    ForEach(filteredLogs) { log in
                        let metricValue: Double? = {
                            switch selectedMetric {
                            case .maxWeight:
                                return log.sets.map({ $0.weight }).max()
                            case .totalReps:
                                let reps = log.sets.map({ $0.reps }).reduce(0, +)
                                return reps > 0 ? Double(reps) : nil
                            case .totalSets:
                                let setsCount = log.sets.count
                                return setsCount > 0 ? Double(setsCount) : nil
                            case .volume:
                                let volume = log.sets.map({ $0.weight * Double($0.reps) }).reduce(0, +)
                                return volume > 0 ? volume : nil
                            case .strengthToWeight:
                                guard let bw = latestWeight, bw > 0 else { return nil }
                                if let maxWeight = log.sets.map({ $0.weight }).max(), maxWeight > 0 {
                                    return maxWeight / bw
                                }
                                return nil
                            case .averageHeartRate:
                                return log.averageHeartRate
                            case .calories:
                                return log.totalCaloriesBurned
                            }
                        }()
                        
                        if let value = metricValue {
                            LineMark(
                                x: .value("Date", log.date),
                                y: .value(selectedMetric.rawValue, value)
                            )
                            .foregroundStyle(by: .value("Exercise", log.exercise?.name ?? "Other"))
                            
                            PointMark(
                                x: .value("Date", log.date),
                                y: .value(selectedMetric.rawValue, value)
                            )
                            .foregroundStyle(by: .value("Exercise", log.exercise?.name ?? "Other"))
                        }
                    }
                }
                .frame(height: 300)
                .padding()
                
                Spacer()
            }
        }
        .navigationTitle("Progress")
        .onAppear {
            if HealthKitManager.shared.isAuthorized {
                HealthKitManager.shared.fetchLatestWeight { weight in
                    self.latestWeight = weight
                }
            }
        }
        }
    }
    
    private var filteredLogs: [StrengthWorkoutLog] {
        if let selected = selectedExercise {
            return workoutLogs.filter { $0.exercise?.id == selected.id }
        }
        return workoutLogs
    }
}

#Preview {
    ProgressChartView()
        .modelContainer(for: [StrengthExercise.self, StrengthWorkoutLog.self, StrengthSetLog.self], inMemory: true)
}
