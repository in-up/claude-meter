import SwiftUI

@MainActor
class IconRenderer {
    static let shared = IconRenderer()

    func render(session: Double, weekly: Double, opus: Double, style: IconStyle) -> Image {
        let view = IconContainerView(
            style: style,
            session: session,
            weekly: weekly,
            opus: opus,
            prefs: PreferenceModel.shared
        )

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        renderer.isOpaque = false

        if let nsImage = renderer.nsImage {
            nsImage.isTemplate = true
            return Image(nsImage: nsImage)
        } else {
            return Image(systemName: "exclamationmark.triangle")
        }
    }
}

fileprivate struct IconContainerView: View {
    var style: IconStyle
    var session: Double
    var weekly: Double
    var opus: Double
    var prefs: PreferenceModel

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                switch style {
                case .lines:
                    LinesIconView(session: session, weekly: weekly, opus: opus)
                case .cShape:
                    TachometerIconView(session: session, weekly: weekly, opus: opus)
                }
            }
            .compositingGroup()

            BadgeView(usage: session, threshold: prefs.notificationThreshold)
        }
        .frame(width: 23, height: 17)
    }
}

fileprivate struct BadgeView: View {
    var usage: Double
    var threshold: Double

    var body: some View {
        let badgeConfig: (name: String, size: CGFloat)? = {
            if usage >= 1.0 {
                return ("lock.fill", 7)
            } else if usage >= threshold {
                return ("exclamationmark.triangle", 8)
            }
            return nil
        }()

        if let config = badgeConfig {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 9, height: 9)
                    .blendMode(.destinationOut)

                Image(systemName: config.name)
                    .font(.system(size: config.size, weight: .heavy))
                    .foregroundStyle(Color.black)
            }
            .compositingGroup()
        }
    }
}

struct LinesIconView: View {
    var session: Double
    var weekly: Double
    var opus: Double
    var color: Color = .primary

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let scale = size / 16.0
            let barWidth = 16 * scale
            let barHeight = 3.5 * scale
            let spacing = 1.5 * scale

            VStack(spacing: spacing) {
                makeBar(usage: session, width: barWidth, height: barHeight)
                makeBar(usage: weekly, width: barWidth, height: barHeight)

                if opus > 0 {
                    makeBar(usage: opus, width: barWidth, height: barHeight)
                } else {
                    Capsule()
                        .fill(color.opacity(0.3))
                        .frame(width: barWidth, height: barHeight)
                }
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    private func makeBar(usage: Double, width: CGFloat, height: CGFloat) -> some View {
        var visualUsage = usage
        if usage > 0.0 && usage < 0.1 { visualUsage = 0.1 }
        else if usage > 0.9 && usage < 1.0 { visualUsage = 0.9 }

        let fillWidth = max(0, min(width * visualUsage, width))

        return ZStack(alignment: .leading) {
            color.opacity(0.3)
            if fillWidth > 0 {
                color.frame(width: fillWidth)
            }
        }
        .clipShape(Capsule())
        .frame(width: width, height: height)
    }
}

struct TachometerIconView: View {
    var session: Double
    var weekly: Double
    var opus: Double
    var color: Color = .primary

    private static let baseSize: CGFloat = 18.0

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let scale = size / Self.baseSize

            ZStack {
                makeArc(usage: session, radius: 6.65 * scale, lineWidth: 2.25 * scale)
                makeArc(usage: weekly, radius: 3.75 * scale, lineWidth: 2.25 * scale)
                if opus > 0 {
                    makeArc(usage: opus, radius: 1.75 * scale, lineWidth: 1.5 * scale)
                }
            }
            .rotationEffect(.degrees(270))
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    private func makeArc(usage: Double, radius: CGFloat, lineWidth: CGFloat) -> some View {
        var visualUsage = usage
        if usage > 0.0 && usage < 0.1 { visualUsage = 0.1 }
        else if usage > 0.9 && usage < 1.0 { visualUsage = 0.9 }

        let trimTo: CGFloat = 0.75

        return ZStack {
            Circle()
                .trim(from: 0, to: trimTo)
                .stroke(color.opacity(0.3), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            Circle()
                .trim(from: trimTo * (1 - visualUsage), to: trimTo)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
        .frame(width: radius * 2 + lineWidth, height: radius * 2 + lineWidth)
        .rotationEffect(.degrees(135))
    }
}
