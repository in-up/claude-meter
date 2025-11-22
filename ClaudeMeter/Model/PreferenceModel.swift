import Foundation
import Combine
import Foundation

enum IconStyle: String, CaseIterable, Codable {
    case lines = "Lines"
    case cShape = "Tachometer"
}

enum MenuBarTextType: String, CaseIterable, Codable {
    case time = "Time Left"
    case usage = "Usage"
    case all = "Show All"
}

class PreferenceModel: ObservableObject {
    static let shared = PreferenceModel()
    
    private let keySession = "claude_session_key"
    private let keyPlan = "claude_user_plan"
    private let keyIconStyle = "claude_icon_style"

    private let keyShowText = "claude_show_text"
    private let keyTextType = "claude_text_type"
    
    private let keyEnableNoti = "claude_enable_notifications"
    private let keyNotiThreshold = "claude_notification_threshold"
    private let keyNotiRefill = "claude_noti_refill"
    private let keyNotiWarning = "claude_noti_warning"
    private let keyNotiDepletion = "claude_noti_depletion"
    
    @Published var sessionKey: String { didSet { UserDefaults.standard.set(sessionKey, forKey: keySession) } }
    @Published var selectedPlan: UserPlan { didSet { UserDefaults.standard.set(selectedPlan.rawValue, forKey: keyPlan) } }
    @Published var iconStyle: IconStyle { didSet { UserDefaults.standard.set(iconStyle.rawValue, forKey: keyIconStyle) } }
    @Published var showMenuBarText: Bool { didSet { UserDefaults.standard.set(showMenuBarText, forKey: keyShowText) } }
    @Published var menuBarTextType: MenuBarTextType { didSet { UserDefaults.standard.set(menuBarTextType.rawValue, forKey: keyTextType) } }
    
    @Published var enableNotifications: Bool { didSet { UserDefaults.standard.set(enableNotifications, forKey: keyEnableNoti) } }
    @Published var notificationThreshold: Double { didSet { UserDefaults.standard.set(notificationThreshold, forKey: keyNotiThreshold) } }
    @Published var enableRefillNoti: Bool { didSet { UserDefaults.standard.set(enableRefillNoti, forKey: keyNotiRefill) } }
    @Published var enableWarningNoti: Bool { didSet { UserDefaults.standard.set(enableWarningNoti, forKey: keyNotiWarning) } }
    @Published var enableDepletionNoti: Bool { didSet { UserDefaults.standard.set(enableDepletionNoti, forKey: keyNotiDepletion) } }
    
    private init() {
        self.sessionKey = UserDefaults.standard.string(forKey: keySession) ?? ""
        
        let savedPlan = UserDefaults.standard.string(forKey: keyPlan) ?? UserPlan.free.rawValue
        self.selectedPlan = UserPlan(rawValue: savedPlan) ?? .free
        
        let savedStyle = UserDefaults.standard.string(forKey: keyIconStyle) ?? IconStyle.lines.rawValue
        self.iconStyle = IconStyle(rawValue: savedStyle) ?? .lines
        
        self.showMenuBarText = UserDefaults.standard.object(forKey: keyShowText) as? Bool ?? true
        
        let savedTextType = UserDefaults.standard.string(forKey: keyTextType) ?? MenuBarTextType.time.rawValue
        self.menuBarTextType = MenuBarTextType(rawValue: savedTextType) ?? .time
        
        self.enableNotifications = UserDefaults.standard.object(forKey: keyEnableNoti) as? Bool ?? true
        
        let savedThreshold = UserDefaults.standard.double(forKey: keyNotiThreshold)
        self.notificationThreshold = savedThreshold == 0 ? 0.9 : savedThreshold
        self.enableRefillNoti = UserDefaults.standard.object(forKey: keyNotiRefill) as? Bool ?? true
        self.enableWarningNoti = UserDefaults.standard.object(forKey: keyNotiWarning) as? Bool ?? true
        self.enableDepletionNoti = UserDefaults.standard.object(forKey: keyNotiDepletion) as? Bool ?? true
    }
}
