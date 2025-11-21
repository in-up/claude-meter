import SwiftUI

@main
struct ClaudeMeterApp: App {
    var body: some Scene {
        MenuBarExtra("ClaudeMeter", systemImage: "creditcard.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}
