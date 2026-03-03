import Foundation

struct WorkoutSet: Identifiable, Codable {
    var id: Int64?
    var workoutExerciseId: Int64
    var setNumber: Int
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var completedAt: Date?
    
    init(
        id: Int64? = nil,
        workoutExerciseId: Int64,
        setNumber: Int,
        weight: Double,
        reps: Int,
        isCompleted: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.workoutExerciseId = workoutExerciseId
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}
