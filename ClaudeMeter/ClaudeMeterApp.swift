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
        // 로고 내보내기를 위해 설정 버튼을 로고 내보내기 뷰로 연결
        Settings { LogoExportView() }
    }

    func textForType(item: UsageItem, type: MenuBarTextType) -> String {
            return item.displayText(for: type)
        }
}
