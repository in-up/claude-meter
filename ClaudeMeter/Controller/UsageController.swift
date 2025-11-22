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
    
    // 동적 폴링
    private var timer: Timer?
    private var currentInterval: TimeInterval = 60   // 초기 1분
    private let minInterval: TimeInterval = 60     // 최소 1분 (활성 시)
    private let maxInterval: TimeInterval = 600    // 최대 10분 (비활성 시)
    
    init() {
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
        
        // 세션 키 없을 시 중단
        guard !sessionKey.isEmpty else {
            self.errorMessage = "Session Key를 설정해주세요."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            // [2] APIService를 통해 데이터 가져오기
            // (1) 조직 ID 조회
            let orgID = try await APIService.shared.fetchOrganizationID(sessionKey: sessionKey)
            
            // (2) 사용량 조회
            let apiResponse = try await APIService.shared.fetchUsage(orgID: orgID, sessionKey: sessionKey)
            
            // (3) 모델 업데이트
            var newModel = UsageModel(from: apiResponse)
            
            // 동적 폴링 (사용량 변화 시 사용자가 클로드를 사용 중인 것으로 보고 실행 스케줄링 빠르게 조정)
            let hasChanged = (newModel.session.usedPercentage != self.model.session.usedPercentage) ||
                             (newModel.weekly.usedPercentage != self.model.weekly.usedPercentage)
            if hasChanged {
                // 변화 감지 시 최소 간격으로 초기화
                self.currentInterval = self.minInterval
            } else {
                // 변화 없으면 1.5배 씩 간격 증가
                self.currentInterval = min(self.currentInterval * 1.5, self.maxInterval)
            }
            
            // UsageEstimator로 예상 고갈 시간 계산
            newModel.session.estimatedDepletionDate = estimator.addDataAndEstimate(item: newModel.session)
            newModel.weekly.estimatedDepletionDate = estimator.addDataAndEstimate(item: newModel.weekly)
            newModel.opus.estimatedDepletionDate = estimator.addDataAndEstimate(item: newModel.opus)
            
            // (4) UI 업데이트
            withAnimation {
                self.model = newModel
            }
            
        } catch {
            print("Error: \(error)")
            if let apiError = error as? APIError, case .unauthorized = apiError {
                self.errorMessage = "세션 만료됨"
            }
            // 에러 발생 시 최소 간격으로 초기화
            self.currentInterval = self.minInterval
        }
        
        self.isLoading = false
        
        // 다음 타이머 예약
        scheduleNextFetch(interval: self.currentInterval)
    }
}
