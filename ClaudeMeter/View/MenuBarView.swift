import SwiftUI

struct MenuBarView: View {
    @ObservedObject var controller: UsageController
    @ObservedObject var prefs = PreferenceModel.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // 헤더 영역
            HStack {
                TachometerIconView(
                    session: 1.0,
                    weekly: 1.0,
                    opus: 0.0,
                    color: colorScheme == .light ? .orange : Color(red: 0xDA/255, green: 0x6A/255, blue: 0x46/255)
                )
                .frame(width: 18, height: 18)
                Text("Claudemeter")
                    .font(.headline)
                
                Spacer()
                
                // Settings 버튼
                if #available(macOS 14.0, *) {
                    SettingsLink {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    // macOS 13 이하 호환성 설정
                    Button {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                        NSApp.activate(ignoringOtherApps: true)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
            
            // 2. 콘텐츠 영역
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
                VStack(spacing: 20) {
                    UsageRow(item: controller.model.session, prefs: prefs)
                    UsageRow(item: controller.model.weekly, prefs: prefs)
                    UsageRow(item: controller.model.opus, prefs: prefs)
                }
            }
            
            Divider()
            
            // 3. 푸터 영역
            HStack {
                // 마지막 업데이트 시간 표시
                Text("Updated \(controller.model.lastUpdated.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    Task { await controller.fetchData() }
                } label: {
                    RefreshIcon(isLoading: controller.isLoading)
                }
                .buttonStyle(.plain)
                .disabled(controller.isLoading)
            }
        }
        .padding()
        .frame(width: 280)
    }
}

struct UsageRow: View {
    var item: UsageItem
    @ObservedObject var prefs: PreferenceModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.type.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // 남은 사용량 퍼센트
                let remaining = 100 - (item.usedPercentage * 100)
                Text("\(Int(remaining))% remaining")
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
            
            Text(item.remainingTimeText)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // 사용량에 따라 아이콘 색상 변화
    func colorForUsage(_ usage: Double) -> Color {
        let threshold = prefs.notificationThreshold
        switch usage {
        case 0..<threshold: return .blue
        case threshold..<1.0: return .orange
        default: return .red
        }
    }
}

struct RefreshIcon: View {
    let isLoading: Bool
    @State private var rotation: Double = 0

    var body: some View {
        Image(systemName: "arrow.clockwise")
            .rotationEffect(.degrees(rotation))
            .onChange(of: isLoading) { _, newValue in
                if newValue {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                } else {
                    withAnimation(.default) {
                        rotation = 0
                    }
                }
            }
    }
}

