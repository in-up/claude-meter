import Foundation
import SwiftUI
import Combine

@MainActor
class UsageController: ObservableObject {
    @Published var model: UsageModel = .empty
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    // 예상 고갈 시간
    private let estimator = UsageEstimator()
    
    // 동적 폴링 타이머
    private var timer: Timer?
    private var currentInterval: TimeInterval = 60   // 초기 1분
    private let minInterval: TimeInterval = 60     // 최소 1분 (활성 시)
    private let maxInterval: TimeInterval = 600    // 최대 10분 (비활성 시)
    
    init() {
        NotificationManager.shared.requestAuthorization()
        
        Task { await fetchData() }
    }
    
    // 다음 실행 스케줄링
    private func scheduleNextFetch(interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { [weak self] in await self?.fetchData() }
        }
    }

    // 데이터를 새로고침하는 메인 함수
    func fetchData() async {
        // [1] 저장된 세션 키 가져오기
        let sessionKey = PreferenceModel.shared.sessionKey
        guard !sessionKey.isEmpty else {
            self.errorMessage = "Session Key를 설정해주세요."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            // [2] APIService를 통해 데이터 가져오기
            let orgID = try await APIService.shared.fetchOrganizationID(sessionKey: sessionKey)
            let apiResponse = try await APIService.shared.fetchUsage(orgID: orgID, sessionKey: sessionKey)
            
            let oldSessionUsage = self.model.session.usedPercentage
            // [3] 모델 업데이트 준비
            var newModel = UsageModel(from: apiResponse)
            
            // 동적 폴링 로직
            let hasChanged = (newModel.session.usedPercentage != self.model.session.usedPercentage) ||
                             (newModel.weekly.usedPercentage != self.model.weekly.usedPercentage)

            if hasChanged {
                self.currentInterval = self.minInterval
            } else {
                self.currentInterval = min(self.currentInterval * 1.5, self.maxInterval)
            }
            
            // UsageEstimator로 예상 고갈 시간 계산
            newModel.session.estimatedDepletionDate = estimator.addDataAndEstimate(item: newModel.session)
            newModel.weekly.estimatedDepletionDate = estimator.addDataAndEstimate(item: newModel.weekly)
            newModel.opus.estimatedDepletionDate = estimator.addDataAndEstimate(item: newModel.opus)
            
            // 알림 조건 확인 및 전송
            NotificationManager.shared.checkAndSendNotification(
                oldUsage: oldSessionUsage,
                newUsage: newModel.session.usedPercentage
            )
            
            // (4) UI 업데이트
            withAnimation {
                self.model = newModel
            }
            
        } catch {
            print("Error: \(error)")
            if let apiError = error as? APIError, case .unauthorized = apiError {
                self.errorMessage = "세션 만료됨"
            }
            self.currentInterval = self.minInterval
        }
        
        self.isLoading = false
        
        // 다음 타이머 예약
        scheduleNextFetch(interval: self.currentInterval)
    }
}
