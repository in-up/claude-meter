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
            .compositingGroup()
            
            BadgeView(usage: session).offset(x: style == .cShape ? 3 : 0, y: style == .cShape ? 1 : 0)
        }
        .frame(width: 23, height: 17)
    }
}

fileprivate struct BadgeView: View {
    var usage: Double
    
    var body: some View {
        let badgeConfig: (name: String, size: CGFloat)? = {
            if usage >= 1.0 {
                return ("lock.fill", 7)
            } else if usage >= 0.7 {
                return ("exclamationmark.triangle.fill", 8)
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

fileprivate struct LinesIconView: View {
    var session: Double
    var weekly: Double
    var opus: Double
    
    private let drawingColor = Color.black
    
    var body: some View {
        VStack(spacing: 1.5) {
            makeBar(usage: session)
            makeBar(usage: weekly)
            
            if opus > 0 {
                makeBar(usage: opus)
            } else {
                Capsule()
                    .fill(drawingColor.opacity(0.3))
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
            drawingColor.opacity(0.3)
            
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
            makeArc(usage: session, radius: 7, lineWidth: 2)
            makeArc(usage: weekly, radius: 4.5, lineWidth: 2)
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
                .stroke(color.opacity(0.3), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            
            Circle()
                .trim(from: trimTo * (1 - visualUsage), to: trimTo)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
        .frame(width: radius * 2, height: radius * 2)
        .rotationEffect(.degrees(135))
    }
}

// 내보내기용 고해상도 로고 뷰
struct ScalableLogoView: View {
    var layer: LogoLayer = .all
    let primaryColor: Color = .black
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            
            let baseSize: CGFloat = 22.0
            let scale = size / baseSize
            
            let outerRadius: CGFloat = 7.5 * scale
            let middleRadius: CGFloat = 4 * scale
            // let innerRadius: CGFloat = 2.5 * scale
            
            let thickLineWidth: CGFloat = 3.0
            // let thinLineWidth: CGFloat = 1.5
            
            ZStack {
                makeArc(
                    radius: outerRadius,
                    lineWidth: thickLineWidth,
                    usage: 0.6,
                    color: primaryColor
                )
                
                makeArc(
                    radius: middleRadius,
                    lineWidth: thickLineWidth,
                    usage: 0.45,
                    color: primaryColor
                )
            }
            .rotationEffect(.degrees(270))
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    
    func makeArc(radius: CGFloat, lineWidth: CGFloat, usage: Double, color: Color) -> some View {
        let trimTo: CGFloat = 0.75
        
        return ZStack {
            if layer == .all || layer == .background {
                Circle()
                    .trim(from: 0, to: trimTo)
                    .stroke(color.opacity(0.3), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            }
            
            if (layer == .all || layer == .foreground) && usage > 0 {
                Circle()
                    .trim(from: trimTo * (1 - usage), to: trimTo)
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            }
        }
        .frame(width: radius * 2, height: radius * 2)
        .rotationEffect(.degrees(135))
    }
}

// 미리보기
#Preview {
    ScalableLogoView()
        .frame(width: 512, height: 512)
        .padding()
}
