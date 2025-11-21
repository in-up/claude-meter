import Foundation
import Combine

class PreferenceModel: ObservableObject {
    static let shared = PreferenceModel()
    
    private let keySession = "claude_session_key"
    private let keyPlan = "claude_user_plan"
    private let keyDisplayTarget = "claude_display_target" // 추가된 키
    
    @Published var sessionKey: String {
        didSet { UserDefaults.standard.set(sessionKey, forKey: keySession) }
    }
    
    @Published var selectedPlan: UserPlan {
        didSet { UserDefaults.standard.set(selectedPlan.rawValue, forKey: keyPlan) }
    }
    
    // 메뉴 바에 표시할 항목
    @Published var displayTarget: UsageType {
        didSet { UserDefaults.standard.set(displayTarget.rawValue, forKey: keyDisplayTarget) }
    }
    
    private init() {
        self.sessionKey = UserDefaults.standard.string(forKey: keySession) ?? ""
        
        let savedPlan = UserDefaults.standard.string(forKey: keyPlan) ?? UserPlan.free.rawValue
        self.selectedPlan = UserPlan(rawValue: savedPlan) ?? .free
        
        let savedTarget = UserDefaults.standard.string(forKey: keyDisplayTarget) ?? UsageType.session.rawValue
        self.displayTarget = UsageType(rawValue: savedTarget) ?? .session
    }
}
