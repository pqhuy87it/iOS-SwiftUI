//
//  AttributedStringDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct AttributedStringDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // === 7a. Build AttributedString thủ công ===
            Text(buildHighlightedText())
            
            // === 7b. Từng phần styling khác nhau ===
            Text(buildPriceText())
            
            // === 7c. Link trong AttributedString ===
            Text(buildLinkText())
            
            // === 7d. Combine attributes ===
            Text(buildComplexText())
            
            // === 7e. Search highlight ===
            Text(highlightSearch(
                in: "SwiftUI là framework UI hiện đại của Apple cho iOS",
                query: "SwiftUI"
            ))
        }
        .padding()
    }
    
    func buildHighlightedText() -> AttributedString {
        var text = AttributedString("Chào mừng đến với SwiftUI!")
        
        // Style toàn bộ
        text.font = .body
        text.foregroundColor = .primary
        
        // Tìm range và style riêng
        if let range = text.range(of: "SwiftUI") {
            text[range].font = .body.bold()
            text[range].foregroundColor = .blue
        }
        
        return text
    }
    
    func buildPriceText() -> AttributedString {
        var dollar = AttributedString("$")
        dollar.font = .body
        dollar.foregroundColor = .secondary
        
        var amount = AttributedString("49")
        amount.font = .system(size: 36, weight: .bold, design: .rounded)
        
        var cents = AttributedString(".99")
        cents.font = .title3
        cents.foregroundColor = .secondary
        
        var period = AttributedString(" /năm")
        period.font = .caption
        period.foregroundColor = .teal
        
        return dollar + amount + cents + period
    }
    
    func buildLinkText() -> AttributedString {
        var text = AttributedString("Xem chi tiết tại ")
        text.font = .footnote
        text.foregroundColor = .secondary
        
        var link = AttributedString("trang web")
        link.font = .footnote
        link.foregroundColor = .blue
        link.underlineStyle = .single
        link.link = URL(string: "https://apple.com")
        // link.link → Text tự động tappable!
        
        return text + link
    }
    
    func buildComplexText() -> AttributedString {
        var result = AttributedString()
        
        var warning = AttributedString("⚠️ Cảnh báo: ")
        warning.font = .headline
        warning.foregroundColor = .orange
        
        var message = AttributedString("Hành động này ")
        message.font = .body
        
        var emphasis = AttributedString("không thể hoàn tác")
        emphasis.font = .body.bold()
        emphasis.foregroundColor = .red
        emphasis.underlineStyle = .single
        emphasis.underlineColor = .red
        
        var ending = AttributedString(".")
        ending.font = .body
        
        result.append(warning)
        result.append(message)
        result.append(emphasis)
        result.append(ending)
        return result
    }
    
    func highlightSearch(in source: String, query: String) -> AttributedString {
        var attributed = AttributedString(source)
        attributed.font = .body
        attributed.foregroundColor = .primary
        
        // Highlight tất cả occurrences
        var searchRange = attributed.startIndex
        while let range = attributed[searchRange...].range(of: query,
                    options: .caseInsensitive) {
            attributed[range].backgroundColor = .yellow.opacity(0.3)
            attributed[range].font = .body.bold()
            searchRange = range.upperBound
        }
        
        return attributed
    }
}

#Preview {
    AttributedStringDemo()
}
