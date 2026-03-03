import Foundation

struct WorkoutTemplate: Identifiable, Codable {
    var id: Int64?
    var name: String
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: Int64? = nil,
        name: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
