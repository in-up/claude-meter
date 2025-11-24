import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var prefs = PreferenceModel.shared
    
    var body: some View {
        Form {
            Section {
                Toggle(String(localized: "Enable Notifications"), isOn: $prefs.enableNotifications)
                    .toggleStyle(.switch)
            }

            if prefs.enableNotifications {
                Section(header: Text(String(localized: "Usage Warning"))) {
                    Toggle(String(localized: "Warning Alert"), isOn: $prefs.enableWarningNoti)

                    if prefs.enableWarningNoti {
                        VStack(alignment: .leading) {
                            Text(String(localized: "Notify when usage exceeds:"))
                                .font(.caption).foregroundColor(.secondary)
                            HStack {
                                Slider(value: $prefs.notificationThreshold, in: 0.5...0.95, step: 0.05)
                                Text("\(Int(round(prefs.notificationThreshold * 20) * 5))%")
                                    .monospacedDigit()
                                    .frame(width: 40)
                            }
                        }
                    }
                }

                Section(header: Text(String(localized: "Events"))) {
                    Toggle(String(localized: "Refill Alert"), isOn: $prefs.enableRefillNoti)
                    Toggle(String(localized: "Depletion Alert (100%)"), isOn: $prefs.enableDepletionNoti)
                }
            }
        }
        .formStyle(.grouped)
    }
}
