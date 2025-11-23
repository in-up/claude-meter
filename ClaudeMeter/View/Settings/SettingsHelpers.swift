import SwiftUI

// MARK: - Dock Icon Toggler
struct DockIconToggler: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window { context.coordinator.setup(window: window) }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window { context.coordinator.setup(window: window) }
        }
    }
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    class Coordinator: NSObject, NSWindowDelegate {
        weak var window: NSWindow?
        func setup(window: NSWindow) {
            guard self.window != window else {
                if NSApp.activationPolicy() != .regular {
                    NSApp.setActivationPolicy(.regular); NSApp.activate(ignoringOtherApps: true)
                }
                return
            }
            self.window = window; window.delegate = self
            NSApp.setActivationPolicy(.regular); NSApp.activate(ignoringOtherApps: true)
        }
        func windowWillClose(_ notification: Notification) {
            DispatchQueue.main.async { NSApp.setActivationPolicy(.accessory) }
        }
        func windowDidBecomeKey(_ notification: Notification) {
            if NSApp.activationPolicy() != .regular {
                NSApp.setActivationPolicy(.regular); NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

// MARK: - Icon Preview
struct IconPreview: View {
    var style: IconStyle
    let session = 0.5; let weekly = 0.2; let opus = 0.0
    var body: some View {
        IconRenderer.shared.render(session: session, weekly: weekly, opus: opus, style: style)
            .resizable().aspectRatio(contentMode: .fit).foregroundColor(.primary)
    }
}
