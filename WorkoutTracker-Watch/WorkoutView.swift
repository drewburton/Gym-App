import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var connectivityService: WatchConnectivityService
    @State private var currentWeight: Double = 100.0
    @State private var currentReps: Int = 10
    @State private var isResting = false
    @State private var restTimeRemaining = 90
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let data = connectivityService.activeWorkoutData,
                   let exerciseName = data["currentExerciseName"] as? String {
                    Text(exerciseName)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
                
                HStack {
                    VStack {
                        Text("Weight")
                            .font(.caption2)
                        Text("\(Int(currentWeight))")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .focusable()
                    .digitalCrownRotation($currentWeight, from: 0, through: 500, by: 2.5, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
                    
                    VStack {
                        Text("Reps")
                            .font(.caption2)
                        Text("\(currentReps)")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .focusable()
                    .digitalCrownRotation(Binding(get: { Double(currentReps) }, set: { currentReps = Int($0) }), from: 0, through: 100, by: 1, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
                }
                
                if isResting {
                    VStack {
                        Text("Rest")
                            .font(.caption)
                        Text(formatTime(restTimeRemaining))
                            .font(.title3)
                            .foregroundColor(.orange)
                    }
                    .onReceive(timer) { _ in
                        if restTimeRemaining > 0 {
                            restTimeRemaining -= 1
                        } else {
                            isResting = false
                            WKInterfaceDevice.current().play(.success)
                        }
                    }
                } else {
                    Button(action: {
                        isResting = true
                        restTimeRemaining = 90
                        WKInterfaceDevice.current().play(.click)
                    }) {
                        Text("Complete Set")
                    }
                    .tint(.green)
                }
            }
        }
    }
    
    func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
