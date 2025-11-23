import Combine
import Foundation
import SwiftUI

@MainActor
class UpdateManager: ObservableObject {
    static let shared = UpdateManager()
    
    @Published var isUpdateAvailable: Bool = false
    @Published var latestVersion: String = ""
    @Published var releaseURL: URL?
    @Published var lastChecked: Date?
    @Published var checkError: String? = nil
    
    // 현재 앱 버전
    let currentVersion = "1.0.0"
    
    private let repoOwner = "in-up"
    private let repoName = "claude-meter"
    
    private init() {}
    
    func checkForUpdates() async {
        let urlString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest"
        guard let url = URL(string: urlString) else { return }
        
        self.checkError = nil
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                self.checkError = "No releases found."
                return
            }
            
            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
            
            // 서버, 로컬 버전 변수
            let serverVer = release.tagName.replacingOccurrences(of: "v", with: "")
            let localVer = currentVersion.replacingOccurrences(of: "v", with: "")
            
            // 서버의 버전과 비교해 더 작을경우 업데이트 존재
            if serverVer.compare(localVer, options: .numeric) == .orderedDescending {
                self.isUpdateAvailable = true
                self.latestVersion = release.tagName
                self.releaseURL = URL(string: release.htmlUrl)
            } else {
                self.isUpdateAvailable = false
            }
            
            self.lastChecked = Date()
            
        } catch {
            print("Update check failed: \(error)")
            self.checkError = "Failed to check for updates."
        }
    }
}

struct GitHubRelease: Codable {
    let tagName: String
    let htmlUrl: String
    let body: String? // 릴리즈 노트 내용
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlUrl = "html_url"
        case body
    }
}
