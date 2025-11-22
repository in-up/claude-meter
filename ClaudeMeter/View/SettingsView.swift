import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general

    enum SettingsTab: String, CaseIterable, Identifiable {
        case general = "General"
        case update = "Update"

        var id: String { rawValue }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(SettingsTab.general)

            UpdateSettingsView()
                .tabItem {
                    Label("Update", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(SettingsTab.update)
        }
        .frame(width: 460, height: 420)
        .padding()
        .background(DockIconToggler())
    }
}

// General Settings
struct GeneralSettingsView: View {
    @ObservedObject var prefs = PreferenceModel.shared
    @State private var launchAtLogin: Bool =
        SMAppService.mainApp.status == .enabled
    @State private var isSecure: Bool = true

    var body: some View {
        Form {
            // 1. Startup
            Section {
                Toggle(isOn: $launchAtLogin) {
                    VStack(alignment: .leading) {
                        Text("Start at Login")
                            .font(.headline)
                        Text(
                            "Automatically launch ClaudeMeter when you log in."
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(.switch)
                .onChange(of: launchAtLogin) { _, newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch { launchAtLogin = !newValue }
                }
            }

            // 2. Appearance
            Section(header: Text("Appearance")) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 16) {
                        ForEach(IconStyle.allCases, id: \.self) { style in
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            prefs.iconStyle == style
                                                ? Color.accentColor.opacity(0.1)
                                                : Color.clear
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    prefs.iconStyle == style
                                                        ? Color.accentColor
                                                        : Color.gray.opacity(
                                                            0.2
                                                        ),
                                                    lineWidth: 1
                                                )
                                        )

                                    IconPreview(style: style)
                                        .frame(width: 44, height: 32)
                                }
                                .frame(width: 80, height: 60)
                                .onTapGesture {
                                    withAnimation { prefs.iconStyle = style }
                                }
                                .contentShape(Rectangle())

                                Text(style.rawValue)
                                    .font(.caption)
                                    .fontWeight(
                                        prefs.iconStyle == style
                                            ? .bold : .regular
                                    )
                            }
                        }
                    }

                    Picker("Show on Menu Bar", selection: $prefs.displayTarget)
                    {
                        ForEach(UsageType.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // 3. Account
            Section(header: Text("Account")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        if isSecure {
                            SecureField(
                                "sk-ant-sid01...",
                                text: $prefs.sessionKey
                            )
                            .textFieldStyle(.roundedBorder)
                        } else {
                            TextField(
                                "sk-ant-sid01...",
                                text: $prefs.sessionKey
                            )
                            .textFieldStyle(.roundedBorder)
                        }

                        Button {
                            isSecure.toggle()
                        } label: {
                            Image(systemName: isSecure ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    Text("Your session key is stored securely on this Mac.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Link(
                        "How to get Session Key?",
                        destination: URL(
                            string:
                                "https://github.com/in-up/claude-meter"
                        )!
                    )
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear { launchAtLogin = SMAppService.mainApp.status == .enabled }
    }
}

// 2. Update Settings
struct UpdateSettingsView: View {
    var body: some View {
        Form {
            Section {
                HStack(spacing: 20) {
                    Image(systemName: "chart.bar.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.purple)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("ClaudeMeter")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Version 1.0.0 (Build 1)")
                            .font(.body)
                            .foregroundColor(.secondary)

                        Text("Designed for macOS")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 10)
            }

            Section {
                Button("Check for Updates...") {
                    // TODO: 업데이트 확인 로직
                }
                Link(
                    "Visit GitHub Repository",
                    destination: URL(
                        string: "https://github.com/in-up/claude-meter"
                    )!
                )
            }
        }
        .formStyle(.grouped)
    }
}

// Dock Icon Toggler
struct DockIconToggler: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                context.coordinator.setup(window: window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                context.coordinator.setup(window: window)
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator: NSObject, NSWindowDelegate {
        weak var window: NSWindow?

        func setup(window: NSWindow) {
            guard self.window != window else {
                if NSApp.activationPolicy() != .regular {
                    NSApp.setActivationPolicy(.regular)
                    NSApp.activate(ignoringOtherApps: true)
                }
                return
            }

            self.window = window
            window.delegate = self

            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
        }

        func windowWillClose(_ notification: Notification) {
            DispatchQueue.main.async {
                NSApp.setActivationPolicy(.accessory)
            }
        }

        func windowDidBecomeKey(_ notification: Notification) {
            if NSApp.activationPolicy() != .regular {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

struct IconPreview: View {
    var style: IconStyle
    let session = 0.5
    let weekly = 0.2
    let opus = 0.0
    var body: some View {
        IconRenderer.shared.render(
            session: session,
            weekly: weekly,
            opus: opus,
            style: style
        )
        .resizable().aspectRatio(contentMode: .fit).foregroundColor(.primary)
    }
}
