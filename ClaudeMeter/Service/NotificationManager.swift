import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification Permission Error: \(error.localizedDescription)")
            }
        }
    }
    
    func checkAndSendNotification(oldUsage: Double, newUsage: Double) {
        let prefs = PreferenceModel.shared
        guard prefs.enableNotifications else { return }
        let percentString = "\(Int(newUsage * 100))"

        // 1. 리필 알림 (50% 이상 -> 5% 미만)
        if prefs.enableRefillNoti, oldUsage > 0.5 && newUsage < 0.05 {
            sendNotification(
                title: String(localized: "New session started"),
                body: String(localized: "Current usage is \(percentString)%%.")
            )
        }

        // 2. 사용량 경고 (임계치 도달 시)
        let threshold = prefs.notificationThreshold
        if prefs.enableWarningNoti, oldUsage < threshold && newUsage >= threshold {
            sendNotification(
                title: String(localized: "Session running low"),
                body: String(localized: "Current usage is \(percentString)%%.")
            )
        }

        // 3. 완전 소진 시 (100%)
        if prefs.enableDepletionNoti, oldUsage < 1.0 && newUsage >= 1.0 {
            sendNotification(
                title: String(localized: "Session depleted"),
                body: String(localized: "Current usage is \(percentString)%%.")
            )
        }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
