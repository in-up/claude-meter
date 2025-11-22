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
        // 50% 이상 -> 5% 미만으로 사용량 감소
        if oldUsage > 0.5 && newUsage < 0.05 {
            sendNotification(title: "새로운 세션이 시작되었습니다.", body: "현재 사용량은 \(newUsage)%입니다.")
        }
        
        // 90% 이상 도달
        if oldUsage < 0.9 && newUsage >= 0.9 {
            sendNotification(title: "세션이 곧 소진됩니다.", body: "현재 사용량은 \(newUsage)%입니다.")
        }
        
        // 100% 도달
        if oldUsage < 1.0 && newUsage >= 1.0 {
            sendNotification(title: "세션이 모두 소진되었습니다.", body: "현재 사용량은 \(newUsage)%입니다.")
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
