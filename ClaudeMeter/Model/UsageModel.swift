import Foundation

struct UsageItem: Codable {
    var type: UsageType
    var usedPercentage: Double
    var resetDate: Date?
    var estimatedDepletionDate: Date?
    
    var percentageText: String {
        return String(format: "%.0f%%", usedPercentage * 100)
    }

    var shouldShowDepletionPrediction: Bool {
        guard let depletion = estimatedDepletionDate,
              let reset = resetDate else {
            return false
        }
        return depletion < reset
    }

    func resetDisplayText(referenceDate now: Date = Date()) -> String {
        guard let resetDate else { return "" }

        let diff = resetDate.timeIntervalSince(now)
        if diff <= 0 { return String(localized: "Ready") }

        if diff >= 3 * 3600 {
            let absoluteTime = formattedAbsoluteResetTime(for: resetDate, relativeTo: now)
            return String(format: String(localized: "Resets at %@"), absoluteTime)
        }

        let hours = Int64(Int(diff) / 3600)
        let minutes = Int64((Int(diff) % 3600) / 60)
        return String(format: String(localized: "%lldh %lldm to reset"), hours, minutes)
    }

    func depletionPredictionText(referenceDate now: Date = Date()) -> String? {
        guard shouldShowDepletionPrediction,
              let depletion = estimatedDepletionDate else {
            return nil
        }

        let diff = depletion.timeIntervalSince(now)
        guard diff > 0 else { return nil }

        let hours = Int64(Int(diff) / 3600)
        let minutes = Int64((Int(diff) % 3600) / 60)
        return String(format: String(localized: "(%lldh %lldm to depletion est.)"), hours, minutes)
    }

    private func formattedAbsoluteResetTime(for resetDate: Date, relativeTo now: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent

        if Calendar.autoupdatingCurrent.isDate(resetDate, inSameDayAs: now) {
            formatter.setLocalizedDateFormatFromTemplate("jm")
        } else {
            formatter.setLocalizedDateFormatFromTemplate("MEdjm")
        }

        return formatter.string(from: resetDate)
    }

    func displayText(for type: MenuBarTextType) -> String {
        switch type {
        case .time:
            return resetDisplayText()
        case .usage:
            return percentageText
        case .all:
            let resetText = resetDisplayText()
            guard !resetText.isEmpty else { return percentageText }
            return "\(percentageText) (\(resetText))"
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
