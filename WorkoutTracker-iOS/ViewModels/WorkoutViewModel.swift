import Foundation

class WorkoutViewModel {
    
    private(set) var workouts: [Workout] = []
    private let databaseService = DatabaseService.shared
    
    func loadWorkouts() {
        workouts = databaseService.getAllWorkouts()
    }
    
    func addWorkout(_ workout: Workout) {
        if let id = databaseService.createWorkout(workout) {
            var newWorkout = workout
            newWorkout.id = id
            workouts.insert(newWorkout, at: 0)
        }
    }
    
    func getWorkouts() -> [Workout] {
        return workouts
    }
    
    func deleteWorkout(at index: Int) {
        guard index < workouts.count else { return }
        let workout = workouts[index]
        if let workoutId = workout.id {
            _ = databaseService.deleteWorkout(workoutId)
        }
        workouts.remove(at: index)
    }
    
    func completeWorkout(at index: Int) {
        guard index < workouts.count else { return }
        let workout = workouts[index]
        if let workoutId = workout.id {
            _ = databaseService.completeWorkout(workoutId)
            loadWorkouts()
        }
    }
}
