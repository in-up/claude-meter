import SwiftUI

struct AboutSettingsView: View {
    @StateObject private var updateManager = UpdateManager.shared
    
    var body: some View {
        Form {
            Section {
                HStack(spacing: 20) {
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ClaudeMeter")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("Version \(updateManager.currentVersion)")
                                .foregroundColor(.secondary)
                            
                            if updateManager.isUpdateAvailable {
                                Text("NEW \(updateManager.latestVersion)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Text("Designed for macOS")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 10)
            }
            
            Section {
                if updateManager.isUpdateAvailable {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("A new version is available!")
                            .font(.headline)
                        
                        if let url = updateManager.releaseURL {
                            Link("Download \(updateManager.latestVersion)", destination: url)
                                .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.vertical, 4)
                } else {
                    HStack {
                        Button("Check for Updates") {
                            Task { await updateManager.checkForUpdates() }
                        }
                        .disabled(updateManager.lastChecked == nil)
                        
                        if let lastChecked = updateManager.lastChecked {
                            Text("Last checked: \(lastChecked.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Link("Visit GitHub Repository", destination: URL(string: "https://github.com/in-up/claude-meter")!)
            }
        }
        .formStyle(.grouped)
        .onAppear {
            Task { await updateManager.checkForUpdates() }
        }
    }
}
