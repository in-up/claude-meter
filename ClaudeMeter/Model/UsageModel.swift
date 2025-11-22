import Foundation

struct UsageItem: Codable {
    var type: UsageType
    var usedPercentage: Double // 0-1
    var resetDate: Date?
    
    // 추정 고갈 시간
    var estimatedDepletionDate: Date? = nil
    
    var percentageText: String {
        return String(format: "%.0f%%", usedPercentage * 100)
    }
    
    // 남은 시간 텍스트
    var remainingTimeText: String {
        // 고갈 추정 시간이 있고, 리셋보다 빠르다면 그걸 보여줌
        if let depletion = estimatedDepletionDate,
           let reset = resetDate,
           depletion < reset {
            let diff = depletion.timeIntervalSince(Date())
            if diff <= 0 { return "Depleted" }
            
            let hours = Int(diff) / 3600
            let minutes = (Int(diff) % 3600) / 60
            return "\(hours)h \(minutes)m left"
        }
        
        // 그렇지 않으면 리셋 시간까지 남은 시간 표시
        guard let resetDate = resetDate else { return "-" }
        let diff = resetDate.timeIntervalSince(Date())
        if diff <= 0 { return "Ready" }
        
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        return "\(hours)h \(minutes)m to reset"
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
