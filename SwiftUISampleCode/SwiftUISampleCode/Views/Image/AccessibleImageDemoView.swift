//
//  AccessibleImageDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct AccessibleImageDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            // === Meaningful image: cần accessibility label ===
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
                .accessibilityLabel("Cảnh báo")
            // VoiceOver: "Cảnh báo, image"
            
            // === Decorative image: ẩn khỏi VoiceOver ===
            Image(decorative: "background-pattern")
            // VoiceOver bỏ qua hoàn toàn
            
            // Hoặc:
            Image(systemName: "circle.fill")
                .accessibilityHidden(true)
            
            // === Image button: accessibilityLabel BẮT BUỘC ===
            Button { } label: {
                Image(systemName: "gear")
                    .font(.title2)
            }
            .accessibilityLabel("Cài đặt")
            .accessibilityHint("Mở màn hình cài đặt")
            // ⚠️ Icon-only buttons PHẢI có label
            // Không có → VoiceOver đọc: "button" (vô nghĩa)
            
            // === Complex image: custom description ===
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .accessibilityLabel("Biểu đồ doanh thu")
                .accessibilityValue("Tháng 3 cao nhất với 1.2 tỷ đồng")
        }
    }
}

#Preview {
    AccessibleImageDemo()
}
