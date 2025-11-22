import SwiftUI
import ServiceManagement

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
                .tabItem { Label("General", systemImage: "gear") }
                .tag(SettingsTab.general)
            
            NotificationSettingsView()
                .tabItem { Label("Notifications", systemImage: "bell.badge") }
                .tag(SettingsTab.notifications)
            
            AboutSettingsView()
                .tabItem { Label("About", systemImage: "info.circle") }
                .tag(SettingsTab.about)
        }
        .frame(width: 450, height: 420)
        .padding()
        .background(DockIconToggler())
    }
}

// General
struct GeneralSettingsView: View {
    @ObservedObject var prefs = PreferenceModel.shared
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    @State private var isSecure: Bool = true
    
    var body: some View {
        Form {
            // 1. Startup
            Section {
                Toggle("Start at Login", isOn: $launchAtLogin)
                    .toggleStyle(.switch)
                    .onChange(of: launchAtLogin) { _, newValue in
                        do {
                            if newValue { try SMAppService.mainApp.register() }
                            else { try SMAppService.mainApp.unregister() }
                        } catch { launchAtLogin = !newValue }
                    }
            }
            
            // 2. Appearance
            Section(header: Text("Appearance")) {
                // 아이콘 스타일
                HStack(spacing: 16) {
                    ForEach(IconStyle.allCases, id: \.self) { style in
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(prefs.iconStyle == style ? Color.accentColor.opacity(0.1) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(prefs.iconStyle == style ? Color.accentColor : Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                
                                IconPreview(style: style)
                                    .frame(width: 44, height: 32)
                            }
                            .frame(width: 80, height: 60)
                            .onTapGesture { withAnimation { prefs.iconStyle = style } }
                            .contentShape(Rectangle())
                            
                            Text(style.rawValue).font(.caption)
                        }
                    }
                }
                
                Divider().padding(.vertical, 4)
                
                // 메뉴바 텍스트 설정
                Toggle("Show Text in Menu Bar", isOn: $prefs.showMenuBarText)
                
                if prefs.showMenuBarText {
                    Picker("Text Format", selection: $prefs.menuBarTextType) {
                        ForEach(MenuBarTextType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
            }
            
            // 3. Account
            Section(header: Text("Account")) {
                HStack {
                    if isSecure {
                        SecureField("sk-ant-sid01...", text: $prefs.sessionKey).textFieldStyle(.roundedBorder)
                    } else {
                        TextField("sk-ant-sid01...", text: $prefs.sessionKey).textFieldStyle(.roundedBorder)
                    }
                    Button { isSecure.toggle() } label: {
                        Image(systemName: isSecure ? "eye.slash" : "eye").foregroundColor(.secondary)
                    }.buttonStyle(.plain)
                }
                Link("Get Session Key", destination: URL(string: "https://github.com/wooseok-dev/claude-meter")!)
                    .font(.caption).foregroundColor(.blue)
            }
        }
        .formStyle(.grouped)
        .onAppear { launchAtLogin = SMAppService.mainApp.status == .enabled }
    }
}

// Notifications
struct NotificationSettingsView: View {
    @ObservedObject var prefs = PreferenceModel.shared
    
    var body: some View {
        Form {
            // 알림 전체 활성화
            Section {
                Toggle("Enable Notifications", isOn: $prefs.enableNotifications)
                    .toggleStyle(.switch)
            }
            
            if prefs.enableNotifications {
                // 1. 사용량 경고 설정
                Section(header: Text("Usage Warning")) {
                    Toggle("Warning Alert", isOn: $prefs.enableWarningNoti)
                    
                    if prefs.enableWarningNoti {
                        VStack(alignment: .leading) {
                            Text("Notify when usage exceeds:")
                                .font(.caption).foregroundColor(.secondary)
                            HStack {
                                Slider(value: $prefs.notificationThreshold, in: 0.5...0.95, step: 0.05)
                                Text("\(Int(prefs.notificationThreshold * 100))%")
                                    .monospacedDigit()
                                    .frame(width: 40)
                            }
                        }
                    }
                }
                
                // 2. 기타 알림 설정
                Section(header: Text("Events")) {
                    Toggle("Refill Alert", isOn: $prefs.enableRefillNoti)
                    Toggle("Depletion Alert (100%)", isOn: $prefs.enableDepletionNoti)
                }
            }
        }
        .formStyle(.grouped)
    }
}
// About
struct AboutSettingsView: View {
    var body: some View {
        Form {
            Section {
                HStack(spacing: 20) {
                    Image(systemName: "chart.bar.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.purple)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ClaudeMeter")
                            .font(.title2).fontWeight(.bold)
                        Text("Version 1.0.0")
                            .font(.body).foregroundColor(.secondary)
                        Text("Designed for macOS")
                            .font(.caption).foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 10)
            }
            
            Section {
                Link("Visit GitHub Repository", destination: URL(string: "https://github.com/wooseok-dev/claude-meter")!)
            }
        }
        .formStyle(.grouped)
    }
}

//  Dock Icon Toggler
struct DockIconToggler: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window { context.coordinator.setup(window: window) }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window { context.coordinator.setup(window: window) }
        }
    }
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    class Coordinator: NSObject, NSWindowDelegate {
        weak var window: NSWindow?
        func setup(window: NSWindow) {
            guard self.window != window else {
                if NSApp.activationPolicy() != .regular {
                    NSApp.setActivationPolicy(.regular); NSApp.activate(ignoringOtherApps: true)
                }
                return
            }
            self.window = window; window.delegate = self
            NSApp.setActivationPolicy(.regular); NSApp.activate(ignoringOtherApps: true)
        }
        func windowWillClose(_ notification: Notification) {
            DispatchQueue.main.async { NSApp.setActivationPolicy(.accessory) }
        }
        func windowDidBecomeKey(_ notification: Notification) {
            if NSApp.activationPolicy() != .regular {
                NSApp.setActivationPolicy(.regular); NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

struct IconPreview: View {
    var style: IconStyle
    let session = 0.5; let weekly = 0.2; let opus = 0.0
    var body: some View {
        IconRenderer.shared.render(session: session, weekly: weekly, opus: opus, style: style)
            .resizable().aspectRatio(contentMode: .fit).foregroundColor(.primary)
    }
}
