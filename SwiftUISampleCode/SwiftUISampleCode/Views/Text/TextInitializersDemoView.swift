//
//  TextInitializersDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct TextInitializersDemo: View {
    let price = 1_250_000.5
    let ratio = 0.856
    let now = Date.now
    let range = Date.now...Date.now.addingTimeInterval(3600)
    let interval: TimeInterval = 3725 // 1h 2m 5s
    let distance = Measurement(value: 5.2, unit: UnitLength.kilometers)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // === 1a. String literal ===
            Text("Xin chào SwiftUI")
            
            // === 1b. String variable ===
            let name = "Huy"
            Text(name)
            
            // === 1c. Verbatim — KHÔNG localize ===
            Text(verbatim: "key_not_localized")
            // Bỏ qua Localizable.strings, hiện đúng chuỗi gốc
            
            // === 1d. Markdown (iOS 15+) ===
            Text("**Bold**, *italic*, ~~strike~~, `code`, [link](https://apple.com)")
            
            // === 1e. Date formatting ===
            Text(now, style: .date)        // "Apr 11, 2026"
            Text(now, style: .time)        // "2:30 PM"
            Text(now, style: .relative)    // "2 hours ago"
            Text(now, style: .offset)      // "+2 hours"
            Text(now, style: .timer)       // "2:15:30" (live đếm)
            Text(timerInterval: range)     // Countdown range
            
            // === 1f. Format — Số, tiền, phần trăm ===
            Text(price, format: .currency(code: "VND"))
            // → "₫1,250,000.50"
            
            Text(ratio, format: .percent)
            // → "85.6%"
            
            Text(42, format: .number.precision(.fractionLength(2)))
            // → "42.00"
            
            // === 1g. Measurement formatting ===
            Text(distance, format: .measurement(width: .abbreviated))
            // → "5.2 km"
            
            // === 1h. Image trong Text (inline icon) ===
            Text("Trạng thái: \(Image(systemName: "checkmark.circle.fill")) Hoàn thành")
            // Icon nằm INLINE với text, scale theo font size
        }
        .padding()
    }
}

#Preview {
    TextInitializersDemo()
}
