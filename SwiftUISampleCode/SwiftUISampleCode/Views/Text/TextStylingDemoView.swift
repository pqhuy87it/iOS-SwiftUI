//
//  TextStylingDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct TextStylingDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // === 3a. Màu sắc ===
                Text("Primary color (mặc định)")
                    .foregroundStyle(.primary)
                Text("Secondary color")
                    .foregroundStyle(.secondary)
                Text("Tertiary color")
                    .foregroundStyle(.tertiary)
                Text("Màu tuỳ chỉnh")
                    .foregroundStyle(.blue)
                Text("Gradient text")
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .font(.title.bold())
                
                Divider()
                
                // === 3b. Bold, Italic, Underline, Strikethrough ===
                Text("Bold text").bold()
                Text("Italic text").italic()
                Text("Underline").underline()
                Text("Underline styled").underline(true, color: .red)
                Text("Strikethrough").strikethrough()
                Text("Strikethrough styled").strikethrough(true, color: .orange)
                
                // Chain nhiều modifiers
                Text("Bold + Italic + Underline")
                    .bold()
                    .italic()
                    .underline()
                
                Divider()
                
                // === 3c. Letter spacing & Kerning ===
                Text("TRACKING +3").tracking(3)
                // tracking: khoảng cách đều giữa TẤT CẢ ký tự
                
                Text("KERNING +3").kerning(3)
                // kerning: khoảng cách giữa CẶP ký tự (font-aware)
                // Khác biệt: tracking thêm space AFTER mỗi glyph
                //            kerning chỉnh khoảng cách GIỮA cặp glyphs
                
                Divider()
                
                // === 3d. Baseline offset ===
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("H")
                        .font(.title)
                    Text("2")
                        .font(.caption)
                        .baselineOffset(-6) // Kéo XUỐNG → subscript
                    Text("O")
                        .font(.title)
                }
                
                HStack(spacing: 0) {
                    Text("E = mc")
                        .font(.title2)
                    Text("2")
                        .font(.caption)
                        .baselineOffset(10) // Kéo LÊN → superscript
                }
                
                Divider()
                
                // === 3e. Text case ===
                Text("hello world").textCase(.uppercase)     // "HELLO WORLD"
                Text("Hello World").textCase(.lowercase)     // "hello world"
                Text("hello world").textCase(nil)            // Giữ nguyên
                
                Divider()
                
                // === 3f. Monospaced digits ===
                Text("1234567890")
                    .monospacedDigit()
                // Mỗi SỐ có cùng width → cột số thẳng hàng
                // Rất quan trọng cho: giá, timer, bảng số liệu
            }
            .padding()
        }
    }
}

#Preview {
    TextStylingDemo()
}
