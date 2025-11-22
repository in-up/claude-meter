import Foundation
import Combine

enum IconStyle: String, CaseIterable, Codable {
    case lines = "Lines (Default)"
    case cShape = "C-Shape"
}

class PreferenceModel: ObservableObject {
    static let shared = PreferenceModel()
    
    private let keySession = "claude_session_key"
    private let keyPlan = "claude_user_plan"
    private let keyDisplayTarget = "claude_display_target"
    private let keyIconStyle = "claude_icon_style"
    
    @Published var sessionKey: String {
        didSet { UserDefaults.standard.set(sessionKey, forKey: keySession) }
    }
    
    @Published var selectedPlan: UserPlan {
        didSet { UserDefaults.standard.set(selectedPlan.rawValue, forKey: keyPlan) }
    }
    
    @Published var displayTarget: UsageType {
        didSet { UserDefaults.standard.set(displayTarget.rawValue, forKey: keyDisplayTarget) }
    }
    
    @Published var iconStyle: IconStyle {
        didSet { UserDefaults.standard.set(iconStyle.rawValue, forKey: keyIconStyle) }
    }
    
    private init() {
        self.sessionKey = UserDefaults.standard.string(forKey: keySession) ?? ""
        
        let savedPlan = UserDefaults.standard.string(forKey: keyPlan) ?? UserPlan.free.rawValue
        self.selectedPlan = UserPlan(rawValue: savedPlan) ?? .free
        
        let savedTarget = UserDefaults.standard.string(forKey: keyDisplayTarget) ?? UsageType.session.rawValue
        self.displayTarget = UsageType(rawValue: savedTarget) ?? .session
        
        let savedStyle = UserDefaults.standard.string(forKey: keyIconStyle) ?? IconStyle.lines.rawValue
        self.iconStyle = IconStyle(rawValue: savedStyle) ?? .lines
    }
}
