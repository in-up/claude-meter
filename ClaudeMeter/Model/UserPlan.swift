import Foundation

enum UserPlan: String, CaseIterable, Codable {
    case free = "Free"
    case pro = "Pro"
    case team = "Team"
    case max = "Max"
    
    var iconName: String {
        switch self {
        case .free: return "person"
        case .pro: return "star.fill"
        case .team: return "building.2.fill"
        case .max: return "crown.fill"
        }
    }
}
