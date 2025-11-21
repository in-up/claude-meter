import Foundation

enum UsageType: String, CaseIterable, Codable {
    case session = "Session"        // 세션 한도
    case weekly = "Weekly"          // 주간 한도
    case opus = "Opus Only"         // Opus 모델 한도
    
    var label: String {
        switch self {
        case .session: return "Current Session"
        case .weekly: return "Weekly Limit"
        case .opus: return "Opus Limit"
        }
    }
}
