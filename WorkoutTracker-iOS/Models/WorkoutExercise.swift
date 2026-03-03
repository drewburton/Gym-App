import Foundation

struct WorkoutExercise: Identifiable, Codable {
    var id: Int64?
    var workoutId: Int64
    var exerciseId: Int64
    var sortOrder: Int
    
    init(
        id: Int64? = nil,
        workoutId: Int64,
        exerciseId: Int64,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        self.sortOrder = sortOrder
    }
}
