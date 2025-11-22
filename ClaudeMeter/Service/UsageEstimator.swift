import Foundation

class UsageEstimator {
    private var history: [UsageType: [(date: Date, usage: Double)]] = [:]
    
    // 데이터를 추가하고 추정 날짜를 반환
    func addDataAndEstimate(item: UsageItem) -> Date? {
        let now = Date()
        let type = item.type
        let usage = item.usedPercentage
        
        // utilization이 이전 값보다 작아지면 세션 리셋에 해당하므로 기록 초기화
        if let last = history[type]?.last, usage < last.usage {
            history[type] = []
        }
        
        // 데이터 저장
        if history[type] == nil { history[type] = [] }
        history[type]?.append((date: now, usage: usage))
        
        // 24시간 지나면 이전 데이터 삭제
        let oneDayAgo = now.addingTimeInterval(-86400)
        history[type] = history[type]?.filter { $0.date > oneDayAgo }
        
        // 데이터 포인트가 2개 미만이거나 사용량이 0이면 추정하지 않음
        guard let dataPoints = history[type], dataPoints.count >= 2, usage > 0 else {
            return nil
        }
        
        // 최근 10개 포인트로 선형 회귀 계산
        let recentPoints = Array(dataPoints.suffix(10))
        return calculateLinearRegression(history: recentPoints)
    }
    
    // Linear Regression
    private func calculateLinearRegression(history: [(date: Date, usage: Double)]) -> Date? {
        let n = Double(history.count)
        let baseDate = history.first!.date
        
        var sumX: Double = 0, sumY: Double = 0, sumXY: Double = 0, sumXX: Double = 0
        
        for point in history {
            let x = point.date.timeIntervalSince(baseDate)
            let y = point.usage
            sumX += x; sumY += y
            sumXY += (x * y); sumXX += (x * x)
        }
        
        let denominator = (n * sumXX) - (sumX * sumX)
        guard denominator != 0 else { return nil }
        
        let slope = ((n * sumXY) - (sumX * sumY)) / denominator
        
        // 기울기가 0이거나 음수면 추정 불가
        guard slope > 0 else { return nil }
        
        let intercept = (sumY - (slope * sumX)) / n
        
        // 사용량이 1.0이 되는 시점 계산
        let targetX = (1.0 - intercept) / slope
        
        return baseDate.addingTimeInterval(targetX)
    }
}
