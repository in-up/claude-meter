import Foundation

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case unauthorized // 세션 키 만료 등 비인가 처리
}

class APIService {
    static let shared = APIService()
    
    // User-Agent 정의
    private let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    
    private init() {}
    
    // [1] Organization ID 조회
    func fetchOrganizationID(sessionKey: String) async throws -> String {
        // 조직 조회 API에서 fetch
        let urlString = "https://claude.ai/api/organizations"
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("sessionKey=\(sessionKey)", forHTTPHeaderField: "Cookie")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.unauthorized
        }
        // 조직에 해당하는 UUID 정보 가져옴
        struct OrgItem: Codable {
            let uuid: String
        }
        
        let orgs = try JSONDecoder().decode([OrgItem].self, from: data)
        guard let firstOrg = orgs.first else { throw APIError.noData }
        
        return firstOrg.uuid
    }
    
    // [2] 사용량 정보 가져오기
    func fetchUsage(orgID: String, sessionKey: String) async throws -> UsageAPIResponse {
        let urlString = "https://claude.ai/api/organizations/\(orgID)/usage"
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("sessionKey=\(sessionKey)", forHTTPHeaderField: "Cookie")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.unauthorized
        }
        
        // DTO Parsing
        let usageResponse = try JSONDecoder().decode(UsageAPIResponse.self, from: data)
        return usageResponse
    }
}
