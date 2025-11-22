import Foundation

struct UsageItem: Codable {
    var type: UsageType
    var usedPercentage: Double // 0-1
    var resetDate: Date?
    
    // 화면에 표시되는 사용량
    var percentageText: String {
        return String(format: "%.0f%%", usedPercentage * 100)
    }
    
    // 남은 시간 텍스트
    var remainingTimeText: String {
        guard let resetDate = resetDate else { return "세션이 시작되지 않음" }
        let diff = resetDate.timeIntervalSince(Date())
        if diff <= 0 { return "Ready" }
        
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        return "\(hours)h \(minutes)m"
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
        
        // 날짜 포맷 변환
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // 1. 현재 세션 (5시간)
        let sessionUtil = apiResponse.fiveHour?.utilization ?? 0
        let sessionDateStr = apiResponse.fiveHour?.resetsAt ?? ""
        self.session = UsageItem(
            type: .session,
            usedPercentage: sessionUtil / 100.0, // 2 -> 0.02 변환
            resetDate: formatter.date(from: sessionDateStr)
        )
        
        // 2. 주간 세션 (7일)
        let weeklyUtil = apiResponse.sevenDay?.utilization ?? 0
        let weeklyDateStr = apiResponse.sevenDay?.resetsAt ?? ""
        self.weekly = UsageItem(
            type: .weekly,
            usedPercentage: weeklyUtil / 100.0,
            resetDate: formatter.date(from: weeklyDateStr)
        )
        
        // 3. Opus 전용 세션
        let opusUtil = apiResponse.sevenDayOpus?.utilization ?? 0
        let opusDateStr = apiResponse.sevenDayOpus?.resetsAt ?? ""
        self.opus = UsageItem(
            type: .opus,
            usedPercentage: opusUtil / 100.0,
            resetDate: formatter.date(from: opusDateStr)
        )
    }
    
    // 타입으로 아이템 가져오기
    func getItem(for type: UsageType) -> UsageItem {
        switch type {
        case .session: return session
        case .weekly: return weekly
        case .opus: return opus
        }
    }
}
