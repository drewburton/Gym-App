import Foundation

enum EquipmentType: String, CaseIterable, Codable {
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case machine = "Machine"
    case cable = "Cable"
    case bodyweight = "Bodyweight"
    case kettlebell = "Kettlebell"
    case bands = "Bands"
    case other = "Other"
    
    var displayName: String {
        return rawValue
    }
}
