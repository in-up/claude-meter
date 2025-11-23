import SwiftUI
import ServiceManagement

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
                Link("Get Session Key", destination: URL(string: "https://github.com/in-up/claude-meter")!)
                    .font(.caption).foregroundColor(.blue)
            }
        }
        .formStyle(.grouped)
        .onAppear { launchAtLogin = SMAppService.mainApp.status == .enabled }
    }
}
