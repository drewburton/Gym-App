import Foundation

enum WorkoutType: String, CaseIterable, Codable {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case upperBody = "Upper Body"
    case lowerBody = "Lower Body"
    case fullBody = "Full Body"
    case custom = "Custom"
    
    var displayName: String {
        return rawValue
    }
}
