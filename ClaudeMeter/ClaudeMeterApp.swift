import SwiftUI

@main
struct ClaudeMeterApp: App {
    @StateObject var controller = UsageController()
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(controller: controller)
        } label: {
            HStack(spacing: 4) {
                // 아이콘
                IconRenderer.shared.render(
                    session: controller.model.session.usedPercentage,
                    weekly: controller.model.weekly.usedPercentage,
                    opus: controller.model.opus.usedPercentage
                )
                
                // 텍스트
                let currentItem = controller.model.getItem(for: PreferenceModel.shared.displayTarget)
                Text(currentItem.remainingTimeText)
                    .font(.system(size: 12, weight: .medium, design: .monospaced)) // 가독성 좋은 폰트
            }
        }
        .menuBarExtraStyle(.window)
    }
}
