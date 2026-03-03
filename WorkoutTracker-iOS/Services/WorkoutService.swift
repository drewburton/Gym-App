import Foundation

class WorkoutService {
    
    static let shared = WorkoutService()
    
    private let databaseService = DatabaseService.shared
    
    private init() {}
    
    func saveWorkout(_ workout: Workout) {
        _ = databaseService.createWorkout(workout)
    }
    
    func fetchWorkouts() -> [Workout] {
        return databaseService.getAllWorkouts()
    }
    
    func deleteWorkout(_ workout: Workout) {
        if let workoutId = workout.id {
            _ = databaseService.deleteWorkout(workoutId)
        }
    }
    
    func createWorkoutFromTemplate(_ templateId: Int64, workoutType: WorkoutType) -> Int64? {
        return databaseService.createWorkoutFromTemplate(templateId, workoutType: workoutType)
    }
    
    func getTemplates() -> [WorkoutTemplate] {
        return databaseService.getAllTemplates()
    }
    
    func getExercises() -> [Exercise] {
        return databaseService.getAllExercises()
    }
    
    func getExercisesByMuscleGroup(_ muscleGroup: MuscleGroup) -> [Exercise] {
        return databaseService.getExercisesByMuscleGroup(muscleGroup)
    }
    
    func getLastSets(forExerciseId exerciseId: Int64) -> [WorkoutSet] {
        return databaseService.getLastSets(forExerciseId: exerciseId)
    }
}
