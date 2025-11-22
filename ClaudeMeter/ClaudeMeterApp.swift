import SwiftUI

@main
struct ClaudeMeterApp: App {
    @StateObject var controller = UsageController()
    @ObservedObject var prefs = PreferenceModel.shared
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(controller: controller)
        } label: {
            HStack(spacing: 4) {
                IconRenderer.shared.render(
                    session: controller.model.session.usedPercentage,
                    weekly: controller.model.weekly.usedPercentage,
                    opus: controller.model.opus.usedPercentage,
                    style: prefs.iconStyle
                )
                
                if prefs.showMenuBarText {
                    let item = controller.model.getItem(for: prefs.displayTarget)


                    Text(item.displayText(for: prefs.menuBarTextType))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                }
            }
        }
        .menuBarExtraStyle(.window)
        Settings {
            SettingsView()
        }
    }
}
