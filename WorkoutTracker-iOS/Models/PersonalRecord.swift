import Foundation

struct PersonalRecord: Identifiable, Codable {
    var id: Int64?
    var exerciseId: Int64
    var weight: Double
    var reps: Int
    var achievedAt: Date
    
    init(
        id: Int64? = nil,
        exerciseId: Int64,
        weight: Double,
        reps: Int,
        achievedAt: Date = Date()
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.weight = weight
        self.reps = reps
        self.achievedAt = achievedAt
    }
    
    static func estimate1RM(weight: Double, reps: Int) -> Double {
        if reps <= 0 { return 0 }
        if reps == 1 { return weight }
        return weight * (1 + Double(reps) / 30.0)
    }
    
    var estimated1RM: Double {
        return PersonalRecord.estimate1RM(weight: weight, reps: reps)
    }
}
