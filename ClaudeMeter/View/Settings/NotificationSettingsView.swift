import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var prefs = PreferenceModel.shared
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable Notifications", isOn: $prefs.enableNotifications)
                    .toggleStyle(.switch)
            }
            
            if prefs.enableNotifications {
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
                
                Section(header: Text("Events")) {
                    Toggle("Refill Alert", isOn: $prefs.enableRefillNoti)
                    Toggle("Depletion Alert (100%)", isOn: $prefs.enableDepletionNoti)
                }
            }
        }
        .formStyle(.grouped)
    }
}
