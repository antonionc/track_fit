import SwiftUI
import WatchKit

struct WatchWorkoutActiveView: View {
    @EnvironmentObject private var healthManager: WatchHealthManager
    
    let exerciseName: String
    
    @State private var weight: Double = 20.0
    @State private var reps: Int = 10
    @State private var showingRestTimer = false
    
    var body: some View {
        VStack(spacing: 8) {
            if healthManager.isWorkoutActive {
                HStack(spacing: 12) {
                    HStack(spacing: 2) {
                        Image(systemName: "heart.fill").foregroundColor(.red).font(.caption2)
                        Text(String(format: "%.0f", healthManager.liveHeartRate))
                            .font(.system(.footnote, design: .rounded).bold())
                            .foregroundColor(.red)
                    }
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill").foregroundColor(.orange).font(.caption2)
                        Text(String(format: "%.0f", healthManager.activeEnergyBurned))
                            .font(.system(.footnote, design: .rounded).bold())
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Text(exerciseName)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            HStack {
                VStack {
                    Text("Weight")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 2) {
                        Button(action: { if weight > 2.5 { weight -= 2.5 }}) {
                            Image(systemName: "minus.square.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.blue)
                        
                        Text(String(format: "%.1f", weight))
                            .font(.system(.title3, design: .rounded).bold())
                            .frame(minWidth: 40)
                        
                        Button(action: { weight += 2.5 }) {
                            Image(systemName: "plus.square.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text("Reps")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 2) {
                        Button(action: { if reps > 1 { reps -= 1 }}) {
                            Image(systemName: "minus.square.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.green)
                        
                        Text("\(reps)")
                            .font(.system(.title3, design: .rounded).bold())
                            .frame(minWidth: 30)
                        
                        Button(action: { reps += 1 }) {
                            Image(systemName: "plus.square.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.green)
                    }
                }
            }
            .padding(.vertical, 4)
            
            Button(action: logSet) {
                Text("Log Set")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .tint(.blue)
            .padding(.top, 4)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingRestTimer) {
            RestTimerView(durationSeconds: 60)
        }
    }
    
    private func logSet() {
        // Send message to iPhone via WatchConnectivity
        WatchSessionManager.shared.sendLogSet(exerciseName: exerciseName, weight: weight, reps: reps)
        
        // Show rest timer and gently tap wrist
        showingRestTimer = true
        WKInterfaceDevice.current().play(.success)
    }
}
