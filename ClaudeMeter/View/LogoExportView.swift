import SwiftUI
import UniformTypeIdentifiers

// 내보내기
enum LogoLayer {
    case all
    case background
    case foreground
}

struct LogoExportView: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("Logo Asset Generator")
                .font(.largeTitle)
                .bold()
            
            // Preview
            ScalableLogoView(layer: .all)
                .frame(width: 200, height: 200)
                .border(Color.gray.opacity(0.3))
            
            Divider()
            
            HStack(spacing: 20) {
                // 1. 배경
                VStack {
                    Text("Background Layer").font(.caption)
                    Button("Save PNG") { exportPNG(layer: .background, name: "Logo_BG") }
                    Button("Save PDF") { exportPDF(layer: .background, name: "Logo_BG") }
                }
                
                // 2. 사용량
                VStack {
                    Text("Foreground Layer").font(.caption)
                    Button("Save PNG") { exportPNG(layer: .foreground, name: "Logo_FG") }
                    Button("Save PDF") { exportPDF(layer: .foreground, name: "Logo_FG") }
                }
            }
        }
        .padding()
        .frame(width: 500, height: 500)
    }
    
    // PNG 내보내기
    @MainActor
    func exportPNG(layer: LogoLayer, name: String) {
        let view = ScalableLogoView(layer: layer)
            .frame(width: 1024, height: 1024)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1.0
        renderer.isOpaque = false
        
        if let nsImage = renderer.nsImage,
           let tiffData = nsImage.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            
            saveWithPanel(data: pngData, fileExtension: "png", defaultName: name)
        }
    }
    
    // PDF 내보내기
    @MainActor
    func exportPDF(layer: LogoLayer, name: String) {
        let view = ScalableLogoView(layer: layer)
            .frame(width: 1024, height: 1024)
        
        let renderer = ImageRenderer(content: view)
        
        // 임시 경로에 먼저 저장
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).pdf")
        
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            guard let pdf = CGContext(tempURL as CFURL, mediaBox: &box, nil) else { return }
            
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }
        
        if let pdfData = try? Data(contentsOf: tempURL) {
            saveWithPanel(data: pdfData, fileExtension: "pdf", defaultName: name)
        }
    }
    
    func saveWithPanel(data: Data, fileExtension: String, defaultName: String) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType(filenameExtension: fileExtension)!]
        savePanel.nameFieldStringValue = defaultName
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save \(fileExtension.uppercased()) File"
        savePanel.message = "Choose a location to save the icon asset."
        
        savePanel.begin { result in
            if result == .OK, let url = savePanel.url {
                do {
                    try data.write(to: url)
                    print("✅ File saved successfully at: \(url.path)")
                    
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                } catch {
                    print("❌ Error saving file: \(error)")
                }
            } else {
                print("User canceled save.")
            }
        }
    }
}
