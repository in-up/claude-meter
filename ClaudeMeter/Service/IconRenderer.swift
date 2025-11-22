import SwiftUI

@MainActor
class IconRenderer {
    static let shared = IconRenderer()
    
    func render(session: Double, weekly: Double, opus: Double, style: IconStyle) -> Image {
        let view = IconContainerView(
            style: style,
            session: session,
            weekly: weekly,
            opus: opus
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
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                switch style {
                case .lines:
                    LinesIconView(session: session, weekly: weekly, opus: opus)
                case .cShape:
                    CIconView(session: session, weekly: weekly, opus: opus)
                }
            }
            .padding(1)
            
            BadgeView(usage: session)
        }
        .frame(width: 22, height: 16)
    }
}

fileprivate struct BadgeView: View {
    var usage: Double
    
    var body: some View {
        if usage >= 1.0 {
            // 사용량 100% 도달 시 자물쇠 뱃지
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 8))
                .background(Circle().fill(Color.white).padding(1))
        } else if usage >= 0.7 {
            // 사용량 70% 이상 시 경고 뱃지
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 8))
                .background(Circle().fill(Color.white).padding(1))
        }
    }
}

fileprivate struct LinesIconView: View {
    var session: Double
    var weekly: Double
    var opus: Double
    
    private let drawingColor = Color.black
    
    var body: some View {
        VStack(spacing: 2) {
            makeBar(usage: session)
            makeBar(usage: weekly)
            
            if opus > 0 {
                makeBar(usage: opus)
            } else {
                // 미사용 시
                Capsule()
                    .fill(drawingColor.opacity(0.2))
                    .frame(width: 16, height: 3.5)
            }
        }
        .frame(width: 22, height: 15)
    }
    
    func makeBar(usage: Double) -> some View {
        let width: CGFloat = 16
        let height: CGFloat = 3.5
        
        var visualUsage = usage
        if usage > 0.0 && usage < 0.1 { visualUsage = 0.1 }
        else if usage > 0.9 && usage < 1.0 { visualUsage = 0.9 }
        
        let fillWidth = max(0, min(width * visualUsage, width))
        
        return ZStack(alignment: .leading) {
            drawingColor.opacity(0.2)
            
            if fillWidth > 0 {
                drawingColor
                    .frame(width: fillWidth)
            }
        }
        .clipShape(Capsule())
        .frame(width: width, height: height)
    }
}

fileprivate struct CIconView: View {
    var session: Double; var weekly: Double; var opus: Double
    private let color = Color.black
    
    var body: some View {
        ZStack {
            makeArc(usage: session, radius: 7, lineWidth: 2.5)
            makeArc(usage: weekly, radius: 4.5, lineWidth: 1.5)
            if opus > 0 {
                makeArc(usage: opus, radius: 2.5, lineWidth: 1.5)
            }
        }
        .rotationEffect(.degrees(270))
    }
    
    func makeArc(usage: Double, radius: CGFloat, lineWidth: CGFloat) -> some View {
        var visualUsage = usage
        if usage > 0.0 && usage < 0.1 { visualUsage = 0.1 }
        else if usage > 0.9 && usage < 1.0 { visualUsage = 0.9 }
        
        let trimTo = 0.75
        
        return ZStack {
            Circle()
                .trim(from: 0, to: trimTo)
                .stroke(color.opacity(0.2), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            
            Circle()
                .trim(from: trimTo * (1 - visualUsage), to: trimTo)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
        .frame(width: radius * 2, height: radius * 2)
        .rotationEffect(.degrees(135))
    }
}
