//
//  TextAnimationDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct TextAnimationDemo: View {
    @State private var count = 0
    @State private var status = "Đang chờ"
    @State private var emoji = "😀"
    
    var body: some View {
        VStack(spacing: 24) {
            
            // === 9a. .contentTransition(.numericText()) ===
            // Số chuyển đổi mượt (rolling digits effect)
            Text("\(count)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .contentTransition(.numericText(value: Double(count)))
            
            HStack(spacing: 16) {
                Button("-") { withAnimation(.spring) { count -= 1 } }
                Button("+") { withAnimation(.spring) { count += 1 } }
            }
            .font(.title)
            
            Divider()
            
            // === 9b. .contentTransition(.interpolate) ===
            // Morph mượt giữa 2 text bất kỳ
            Text(status)
                .font(.title2.bold())
                .foregroundStyle(status == "Thành công" ? .green : .orange)
                .contentTransition(.interpolate)
            
            Button("Toggle") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    status = status == "Đang chờ" ? "Thành công" : "Đang chờ"
                }
            }
            
            Divider()
            
            // === 9c. .contentTransition(.identity) ===
            // Không animation (snap ngay lập tức)
            Text(emoji)
                .font(.system(size: 60))
                .contentTransition(.identity)
            
            Button("Random Emoji") {
                emoji = ["😀", "🚀", "🎉", "💡", "🔥"].randomElement()!
            }
            
            Divider()
            
            // === 9d. Symbol effects (SF Symbols) ===
            HStack(spacing: 24) {
                // Bounce
                Image(systemName: "bell.fill")
                    .font(.title)
                    .symbolEffect(.bounce, value: count)
                
                // Pulse
                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundStyle(.red)
                    .symbolEffect(.pulse)
                
                // Variable color
                Image(systemName: "wifi")
                    .font(.title)
                    .symbolEffect(.variableColor.iterative)
            }
        }
        .padding()
    }
}

#Preview {
    TextAnimationDemo()
}
