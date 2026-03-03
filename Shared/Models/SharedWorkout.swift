import Foundation

struct SharedWorkout: Codable {
    let id: UUID
    let name: String
    let duration: TimeInterval
    let date: Date
    let caloriesBurned: Int
}

struct SharedExercise: Codable {
    let id: UUID
    let name: String
    let sets: Int
    let reps: Int
    let weight: Double
}

struct SharedWorkoutData {
    var workouts: [SharedWorkout] = []

    mutating func addWorkout(_ workout: SharedWorkout) {
        workouts.append(workout)
    }

    func getWorkouts() -> [SharedWorkout] {
        return workouts
    }
}
