import SwiftUI

struct SettingsView: View {
    @ObservedObject var prefs = PreferenceModel.shared
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Authentication")) {
                SecureField("sessionKey (sk-ant-sid01...)", text: $prefs.sessionKey)
                
                Link("How to get sessionKey?", destination: URL(string: "https://github.com/in-up/claude-meter#how-to-get-session-key")!)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Section(header: Text("Display Option")) {
                // 메뉴 바에 무엇을 띄울지 선택
                Picker("Show on Menu Bar", selection: $prefs.displayTarget) {
                    ForEach(UsageType.allCases, id: \.self) { type in
                        Text(type.label).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // 아이콘 스타일 선택
            Section(header: Text("Appearance")) {
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
        .frame(width: 300, height: 250)
    }
}
