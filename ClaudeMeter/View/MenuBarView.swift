import SwiftUI

struct MenuBarView: View {
    @ObservedObject var controller: UsageController
    @ObservedObject var prefs = PreferenceModel.shared
    
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 헤더 영역
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.purple)
                Text("ClaudeMeter")
                    .font(.headline)
                
                Spacer()
                
                // Settings 버튼
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showSettings) {
                    SettingsView()
                }
            }
            
            Divider()
            
            // 예외.오류 처리
            if let errorMessage = controller.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 8)
            } else if controller.isLoading && controller.model.lastUpdated == Date.distantPast {
                ProgressView()
                    .scaleEffect(0.8)
                    .padding()
            } else {
                // 성공 시 사용량 표시
                usageContent
            }
            
            Divider()
            
            // 푸터 영역
            HStack {
                // 현재 보여주고 있는 항목의 남아있는 리셋 시간 표시
                let currentItem = controller.model.getItem(for: prefs.displayTarget)
                
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(currentItem.remainingTimeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 새로고침 버튼
                Button {
                    Task { await controller.fetchData() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .rotationEffect(.degrees(controller.isLoading ? 360 : 0))
                        .animation(controller.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: controller.isLoading)
                }
                .buttonStyle(.plain)
                .disabled(controller.isLoading)
            }
        }
        .padding()
        .frame(width: 260)
    }
    
    // 사용량 게이지 바 View
    var usageContent: some View {
        let item = controller.model.getItem(for: prefs.displayTarget)
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.type.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // 남은 사용량 퍼센트
                let remaining = 100 - (item.usedPercentage * 100)
                Text("\(Int(remaining))% 남음")
                    .font(.system(.body, design: .monospaced))
                    .bold()
            }
            
            // 게이지 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.1)
                        .foregroundColor(.primary)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .frame(width: min(geometry.size.width * item.usedPercentage, geometry.size.width), height: 8)
                        .foregroundColor(colorForUsage(item.usedPercentage))
                        .cornerRadius(4)
                        .animation(.spring(), value: item.usedPercentage)
                }
            }
            .frame(height: 8)
        }
    }
    
    // 사용량에 따라 아이콘 색상 변화
    func colorForUsage(_ usage: Double) -> Color {
        switch usage {
        case 0..<0.5: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }
}
