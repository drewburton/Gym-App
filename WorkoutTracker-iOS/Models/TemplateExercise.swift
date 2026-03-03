import Foundation

struct TemplateExercise: Identifiable, Codable {
    var id: Int64?
    var templateId: Int64
    var exerciseId: Int64
    var defaultSets: Int
    var defaultWeight: Double
    var defaultReps: Int
    var defaultRestSeconds: Int
    var sortOrder: Int
    
    init(
        id: Int64? = nil,
        templateId: Int64,
        exerciseId: Int64,
        defaultSets: Int = 3,
        defaultWeight: Double = 0,
        defaultReps: Int = 10,
        defaultRestSeconds: Int = 90,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.templateId = templateId
        self.exerciseId = exerciseId
        self.defaultSets = defaultSets
        self.defaultWeight = defaultWeight
        self.defaultReps = defaultReps
        self.defaultRestSeconds = defaultRestSeconds
        self.sortOrder = sortOrder
    }
}
