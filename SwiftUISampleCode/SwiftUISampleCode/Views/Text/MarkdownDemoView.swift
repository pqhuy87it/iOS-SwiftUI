//
//  MarkdownDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct MarkdownDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // === 6a. Inline Markdown ===
            Text("**Bold** and *italic* text")
            Text("~~Strikethrough~~ text")
            Text("`inline code` block")
            Text("Visit [Apple](https://apple.com)")  // Tappable link!
            Text("**Bold *and italic* combined**")
            
            Divider()
            
            // === 6b. Markdown từ variable ===
            // ⚠️ String variable KHÔNG auto-parse Markdown!
            let raw = "**This won't be bold**"
            Text(raw) // → Hiện đúng "**This won't be bold**"
            
            // ✅ Phải dùng LocalizedStringKey hoặc AttributedString
            Text(LocalizedStringKey(raw)) // → This won't be bold (bold)
            
            // Hoặc init từ AttributedString
            if let md = try? AttributedString(markdown: raw) {
                Text(md) // → Bold!
            }
            
            Divider()
            
            // === 6c. Markdown link styling ===
            Text("Xem [tài liệu](https://docs.swift.org) để biết thêm.")
                .tint(.purple) // Đổi màu link
            
            // === 6d. Complex markdown ===
            let complex = """
            **SwiftUI** hỗ trợ *Markdown* trong `Text` view:
            - ~~Gạch ngang~~
            - **Bold *nested italic***
            - [Links](https://apple.com) tự động tappable
            """
            if let attr = try? AttributedString(markdown: complex) {
                Text(attr)
            }
        }
        .padding()
    }
}

#Preview {
    MarkdownDemo()
}
