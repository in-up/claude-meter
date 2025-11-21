import Foundation

// 1. 서버에서 받을 수 있는 JSON 구조와 매칭되는 모델 정의
struct UsageAPIResponse: Codable {
    let fiveHour: UsageDataDetail?      // five_hour
    let sevenDay: UsageDataDetail?      // seven_day
    let sevenDayOpus: UsageDataDetail?  // seven_day_opus
    
    // JSON 키값과 변수명 매칭
    enum CodingKeys: String, CodingKey {
        case fiveHour = "five_hour"
        case sevenDay = "seven_day"
        case sevenDayOpus = "seven_day_opus"
    }
}

// 2. 각 항목 안의 상세 데이터 모델 정의
struct UsageDataDetail: Codable {
    let utilization: Double
    let resetsAt: String?
    
    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }
}