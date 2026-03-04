import SwiftUI
import WatchKit

struct RestTimerView: View {
    @Environment(\.dismiss) private var dismiss
    
    let durationSeconds: Int
    let onDone: (() -> Void)?
    
    @State private var timeRemaining: Int
    @State private var timer: Timer?
    
    init(durationSeconds: Int, onDone: (() -> Void)? = nil) {
        self.durationSeconds = durationSeconds
        self.onDone = onDone
        _timeRemaining = State(initialValue: durationSeconds)
    }
    
    var body: some View {
        VStack {
            Text("Rest")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(timeString(from: timeRemaining))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(timeRemaining == 0 ? .green : .white)
                .monospacedDigit()
            
            Button(action: {
                timer?.invalidate()
                if let onDone = onDone {
                    onDone()
                } else {
                    dismiss()
                }
            }) {
                Text(timeRemaining == 0 ? (onDone != nil ? "Next Set" : "Done") : "Skip")
            }
            .tint(timeRemaining == 0 ? .green : .gray)
            .padding(.top)
        }
        .onAppear(perform: startTimer)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                // Alert wrist firmly that rest is over
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
