import SwiftUI

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general
    
    enum SettingsTab: String, CaseIterable, Identifiable {
        case general = "General"
        case notifications = "Notifications"
        case about = "About"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem { Label(String(localized: "General"), systemImage: "gear") }
                .tag(SettingsTab.general)

            NotificationSettingsView()
                .tabItem { Label(String(localized: "Notifications"), systemImage: "bell.badge") }
                .tag(SettingsTab.notifications)

            AboutSettingsView()
                .tabItem { Label(String(localized: "About"), systemImage: "info.circle") }
                .tag(SettingsTab.about)
        }
        .frame(width: 450, height: 420)
        .padding()
        .background(DockIconToggler())
    }
}
