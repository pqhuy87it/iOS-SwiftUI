//
//  TextConcatenationDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct TextConcatenationDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // === 5a. Cơ bản: nối Text + Text ===
            Text(greetingText)
            
            // === 5b. Mix font sizes ===
            Text(pricingText)
            
            // === 5c. Inline icons (Dùng Cách 2 vì AttributedString không hỗ trợ Image) ===
            let statusPrefix = Text("Trạng thái: ").foregroundStyle(.secondary)
            let statusIcon = Text(Image(systemName: "checkmark.circle.fill")).foregroundStyle(.green)
            let statusText = Text(" Đã xác minh").bold().foregroundStyle(.green)
            Text("\(statusPrefix)\(statusIcon)\(statusText)")
            
            // === 5d. Required field indicator ===
            Text(requiredFieldText)
            
            // === 5e. Hashtags / Mentions ===
            Text(hashtagsText)
            
            // === 5f. Terms & Conditions ===
            Text(termsText)
                .tint(.blue) // Đổi màu link nếu muốn
        }
        .padding()
    }
    
    // MARK: - AttributedString Builders
    
    // 5a. Dùng thuộc tính range(of:) để tìm và đổi màu chữ "Huy"
    var greetingText: AttributedString {
        var str = AttributedString("Xin chào, Huy!")
        str.foregroundColor = .secondary // Cài đặt màu gốc cho toàn câu
        
        if let range = str.range(of: "Huy") {
            str[range].foregroundColor = .blue
            str[range].font = .body.bold()
        }
        return str
    }
    
    // 5b. Dùng phương thức .append() để nối từng mảnh với format riêng lẻ
    var pricingText: AttributedString {
        var result = AttributedString()
        
        var p1 = AttributedString("$")
        p1.font = .body
        p1.foregroundColor = .secondary
        result.append(p1)
        
        var p2 = AttributedString("99")
        p2.font = .system(size: 42, weight: .bold, design: .rounded)
        result.append(p2)
        
        var p3 = AttributedString(".99")
        p3.font = .title3
        p3.foregroundColor = .secondary
        result.append(p3)
        
        var p4 = AttributedString(" /tháng")
        p4.font = .caption
        p4.foregroundColor = .teal
        result.append(p4)
        
        return result
    }
    
    // 5d. Tìm dấu * và bôi đỏ
    var requiredFieldText: AttributedString {
        var str = AttributedString("Email *")
        str.font = .headline
        
        if let range = str.range(of: "*") {
            str[range].foregroundColor = .red
        }
        return str
    }
    
    // 5e. Tìm các Hashtag và in đậm + bôi xanh
    var hashtagsText: AttributedString {
        var str = AttributedString("Bài viết về #SwiftUI và #iOS development")
        
        if let r1 = str.range(of: "#SwiftUI") {
            str[r1].foregroundColor = .blue
            str[r1].font = .body.bold()
        }
        if let r2 = str.range(of: "#iOS") {
            str[r2].foregroundColor = .blue
            str[r2].font = .body.bold()
        }
        return str
    }
    
    // 5f. Tìm các cụm từ quan trọng để biến thành Link
    var termsText: AttributedString {
        var str = AttributedString("Bằng việc tiếp tục, bạn đồng ý với Điều khoản sử dụng và Chính sách bảo mật")
        str.font = .footnote
        str.foregroundColor = .secondary
        
        if let r1 = str.range(of: "Điều khoản sử dụng") {
            str[r1].link = URL(string: "https://example.com/terms")
        }
        if let r2 = str.range(of: "Chính sách bảo mật") {
            str[r2].link = URL(string: "https://example.com/privacy")
        }
        return str
    }
}

#Preview {
    TextConcatenationDemo()
}
