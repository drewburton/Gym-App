import Foundation

struct Workout: Identifiable, Codable {
    var id: Int64?
    var templateId: Int64?
    var workoutType: WorkoutType
    var startedAt: Date
    var completedAt: Date?
    var notes: String?
    
    init(
        id: Int64? = nil,
        templateId: Int64? = nil,
        workoutType: WorkoutType,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.templateId = templateId
        self.workoutType = workoutType
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.notes = notes
    }
    
    var isCompleted: Bool {
        return completedAt != nil
    }
    
    var duration: TimeInterval? {
        guard let completedAt = completedAt else { return nil }
        return completedAt.timeIntervalSince(startedAt)
    }
}
