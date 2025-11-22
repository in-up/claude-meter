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
                    Text(
                        textForType(
                            item: controller.model.session,
                            type: prefs.menuBarTextType
                        )
                    ).font(.system(size: 12, weight: .medium, design: .monospaced))
                }
            }
        }
        .menuBarExtraStyle(.window)
        Settings {
            SettingsView()
        }
    }

    func textForType(item: UsageItem, type: MenuBarTextType) -> String {
            return item.displayText(for: type)
        }
}
