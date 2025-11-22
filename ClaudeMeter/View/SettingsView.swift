import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var prefs = PreferenceModel.shared
    @Environment(\.dismiss) var dismiss
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled
    
    var body: some View {
            Form {
                Section(header: Text("General")) {
                    Toggle("Start at Login", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { _, newValue in
                                                do {
                                                    if newValue {
                                                        try SMAppService.mainApp.register()
                                                    } else {
                                                        try SMAppService.mainApp.unregister()
                                                    }
                                                } catch {
                                                    print("Failed to update launch setting: \(error)")
                                                    launchAtLogin = !newValue
                                                }
                        }
                    
                    Link("How to get sessionKey?", destination: URL(string: "https://github.com/in-up/claude-meter#how-to-get-session-key")!)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Section(header: Text("Authentication")) {
                    SecureField("sessionKey (sk-ant-sid01...)", text: $prefs.sessionKey)
                }
                
                Section(header: Text("Appearance")) {
                    Picker("Show on Menu Bar", selection: $prefs.displayTarget) {
                        ForEach(UsageType.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Icon Style", selection: $prefs.iconStyle) {
                        ForEach(IconStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button("Quit App") {
                        NSApplication.shared.terminate(nil)
                    }
                    .foregroundColor(.red)
                }
            }
            .padding()
            .frame(width: 300, height: 350)
            .onAppear {
                launchAtLogin = SMAppService.mainApp.status == .enabled
            }
        }
    }
