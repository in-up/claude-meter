import SwiftUI

@MainActor
class IconRenderer {
    static let shared = IconRenderer()
    
    func render(session: Double, weekly: Double, opus: Double) -> Image {
        let view = IconView(session: session, weekly: weekly, opus: opus)
        
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

fileprivate struct IconView: View {
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
        // 사용량 부분을 캡슐 모양과 동일하게 잘라내기 (모서리 곡률)
        .clipShape(Capsule())
        .frame(width: width, height: height)
    }
}
