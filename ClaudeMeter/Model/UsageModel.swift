import Foundation

struct UsageItem: Codable {
    var type: UsageType
    var usedPercentage: Double
    var resetDate: Date?
    var estimatedDepletionDate: Date?
    
    var percentageText: String {
        return String(format: "%.0f%%", usedPercentage * 100)
    }
    
    // 기존 로직 유지: 리셋 시간 vs 고갈 추정 시간 중 더 짧은 것 반환
    var remainingTimeText: String {
        // 고갈 추정 시간이 있고, 리셋보다 빠르다면 그걸 보여줌
        if let depletion = estimatedDepletionDate,
           let reset = resetDate,
           depletion < reset {
            let diff = depletion.timeIntervalSince(Date())
            if diff <= 0 { return String(localized: "Depleted") }

            let hours = Int(diff) / 3600
            let minutes = (Int(diff) % 3600) / 60
            return String(localized: "\(hours)h \(minutes)m left")
        }

        // 그렇지 않으면 리셋 시간까지 남은 시간 표시
        guard let resetDate = resetDate else { return "" }
        let diff = resetDate.timeIntervalSince(Date())
        if diff <= 0 { return String(localized: "Ready") }

        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        return String(localized: "\(hours)h \(minutes)m to reset")
    }
    
    // textType에 따라 시간, 사용량, 또는 모두를 문자열로 반환
    func displayText(for type: MenuBarTextType) -> String {
        switch type {
        case .time:
            return remainingTimeText
        case .usage:
            return percentageText
        case .all:
            // 예: "25% (3h 43m left)"
            return "\(percentageText) (\(remainingTimeText))"
        }
    }
}

struct UsageModel: Codable {
    var session: UsageItem
    var weekly: UsageItem
    var opus: UsageItem
    var lastUpdated: Date
    
    init(session: UsageItem, weekly: UsageItem, opus: UsageItem, lastUpdated: Date) {
        self.session = session
        self.weekly = weekly
        self.opus = opus
        self.lastUpdated = lastUpdated
    }
    
    static let empty = UsageModel(
        session: UsageItem(type: .session, usedPercentage: 0, resetDate: nil),
        weekly: UsageItem(type: .weekly, usedPercentage: 0, resetDate: nil),
        opus: UsageItem(type: .opus, usedPercentage: 0, resetDate: nil),
        lastUpdated: Date()
    )

        // UsageAPIResponse을 UsageModel로 변환
    init(from apiResponse: UsageAPIResponse) {
        self.lastUpdated = Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let sessionUtil = (apiResponse.fiveHour?.utilization ?? 0) / 100.0
        let sessionDate = formatter.date(from: apiResponse.fiveHour?.resetsAt ?? "")
        self.session = UsageItem(type: .session, usedPercentage: sessionUtil, resetDate: sessionDate)
        
        let weeklyUtil = (apiResponse.sevenDay?.utilization ?? 0) / 100.0
        let weeklyDate = formatter.date(from: apiResponse.sevenDay?.resetsAt ?? "")
        self.weekly = UsageItem(type: .weekly, usedPercentage: weeklyUtil, resetDate: weeklyDate)
        
        let opusUtil = (apiResponse.sevenDayOpus?.utilization ?? 0) / 100.0
        let opusDate = formatter.date(from: apiResponse.sevenDayOpus?.resetsAt ?? "")
        self.opus = UsageItem(type: .opus, usedPercentage: opusUtil, resetDate: opusDate)
    }
    
    func getItem(for type: UsageType) -> UsageItem {
        switch type {
        case .session: return session
        case .weekly: return weekly
        case .opus: return opus
        }
    }
}
