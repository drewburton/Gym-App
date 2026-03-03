import Foundation

struct ActiveWorkoutState: Identifiable, Codable {
    var id: Int64?
    var workoutId: Int64?
    var currentExerciseIndex: Int
    var currentSetNumber: Int
    var timerEndTime: Date?
    var isTimerRunning: Bool
    var lastSyncedAt: Date?
    
    init(
        id: Int64? = nil,
        workoutId: Int64? = nil,
        currentExerciseIndex: Int = 0,
        currentSetNumber: Int = 1,
        timerEndTime: Date? = nil,
        isTimerRunning: Bool = false,
        lastSyncedAt: Date? = nil
    ) {
        self.id = id
        self.workoutId = workoutId
        self.currentExerciseIndex = currentExerciseIndex
        self.currentSetNumber = currentSetNumber
        self.timerEndTime = timerEndTime
        self.isTimerRunning = isTimerRunning
        self.lastSyncedAt = lastSyncedAt
    }
    
    var remainingRestTime: TimeInterval? {
        guard isTimerRunning, let timerEndTime = timerEndTime else { return nil }
        let remaining = timerEndTime.timeIntervalSinceNow
        return remaining > 0 ? remaining : nil
    }
}
