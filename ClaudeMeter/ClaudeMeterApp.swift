// ClaudeMeterApp.swift

import SwiftUI

@main
struct ClaudeMeterApp: App {
    var body: some Scene {
        MenuBarExtra("ClaudeMeter", systemImage: "creditcard.fill") {
            // TODO: 실제 사용량 아이콘으로 변경
            Text("ClaudeMeter 준비 중...")
        }
        .menuBarExtraStyle(.window)
    }
}
