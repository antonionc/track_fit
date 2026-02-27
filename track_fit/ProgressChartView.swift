import SwiftUI
import SwiftData
import Charts

struct ProgressChartView: View {
    @Query private var workoutLogs: [StrengthWorkoutLog]
    @State private var selectedExercise: StrengthExercise?
    
    enum ProgressMetric: String, CaseIterable, Identifiable {
        case maxWeight = "Max Weight"
        case totalReps = "Total Reps"
        case totalSets = "Total Sets"
        case volume = "Volume"
        
        var id: String { rawValue }
    }
    
    @State private var selectedMetric: ProgressMetric = .volume
    
    var body: some View {
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
        .navigationTitle("Progress")
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
