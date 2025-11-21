import Foundation
import SwiftUI
import Combine

@MainActor
class UsageController: ObservableObject {
    @Published var model: UsageModel = .empty
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    private var timer: Timer?
    
    init() {
        // 최초 실행 시 데이터 fetch
        Task {
            await fetchData()
        }
        
        // 5분 주기로 갱신
        startAutoRefresh()
    }
    
    func startAutoRefresh() {
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.fetchData()
            }
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
            withAnimation {
                self.model = UsageModel(from: apiResponse)
            }
            
        } catch {
            // 에러 발생 시 처리
            print("Fetch Error: \(error)")
            if let apiError = error as? APIError, case .unauthorized = apiError {
                self.errorMessage = "세션이 만료되었습니다. 키를 재설정해주세요."
            } else {
                self.errorMessage = "데이터를 가져오는데 실패했습니다."
            }
        }
        
        self.isLoading = false
    }
}
