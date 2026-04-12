//
//  TextInteractionDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct TextInteractionDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // === 10a. textSelection — Copy text (iOS 15+) ===
            Text("Long press để copy đoạn text này")
                .textSelection(.enabled)
            // User long press → highlight → Copy menu xuất hiện
            
            // Disable selection
            Text("Không thể copy")
                .textSelection(.disabled) // Mặc định
            
            // Apply cho tất cả child texts
            VStack(alignment: .leading) {
                Text("Dòng 1: có thể copy")
                Text("Dòng 2: cũng copy được")
                Text("Dòng 3: tất cả đều selectable")
            }
            .textSelection(.enabled)
            // Tất cả 3 dòng đều selectable
            
            Divider()
            
            // === 10b. Link tappable (Markdown) ===
            Text("Truy cập [Apple Developer](https://developer.apple.com)")
                .tint(.purple) // Màu link
            // Tap → mở URL tự động
            
            // === 10c. Combine Text + tappable ===
            // Muốn tap vào phần text cụ thể → dùng AttributedString + link
            Text(tappableText())
        }
        .padding()
    }
    
    func tappableText() -> AttributedString {
        var text = AttributedString("Bấm vào ")
        text.font = .body
        
        var link = AttributedString("đây")
        link.font = .body.bold()
        link.foregroundColor = .blue
        link.link = URL(string: "https://example.com")
        
        var ending = AttributedString(" để xem thêm.")
        ending.font = .body
        
        return text + link + ending
    }
}


#Preview {
    TextInteractionDemo()
}
