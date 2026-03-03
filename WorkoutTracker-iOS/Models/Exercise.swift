import Foundation

struct Exercise: Identifiable, Codable {
    var id: Int64?
    var name: String
    var muscleGroup: MuscleGroup
    var equipmentType: EquipmentType
    var notes: String?
    var createdAt: Date
    
    init(
        id: Int64? = nil,
        name: String,
        muscleGroup: MuscleGroup,
        equipmentType: EquipmentType,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.equipmentType = equipmentType
        self.notes = notes
        self.createdAt = createdAt
    }
}
