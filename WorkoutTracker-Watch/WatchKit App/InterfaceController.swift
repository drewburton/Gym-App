import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var workoutLabel: WKInterfaceLabel!
    @IBOutlet weak var timerLabel: WKInterfaceLabel!

    private var workoutTimer: Timer?
    private var elapsedTime: TimeInterval = 0

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        workoutLabel.setText("Ready to Workout")
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    @IBAction func startWorkoutTapped() {
        workoutLabel.setText("Workout in Progress")
        startTimer()
    }

    @IBAction func stopWorkoutTapped() {
        stopTimer()
        workoutLabel.setText("Workout Completed")
    }

    private func startTimer() {
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
            self?.updateTimerLabel()
        }
    }

    private func stopTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }

    private func updateTimerLabel() {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        timerLabel.setText(String(format: "%02d:%02d", minutes, seconds))
    }
}
