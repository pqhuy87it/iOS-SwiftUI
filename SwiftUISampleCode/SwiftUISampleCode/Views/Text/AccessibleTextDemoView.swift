//
//  AccessibleTextDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct AccessibleTextDemo: View {
    var body: some View {
        VStack(spacing: 12) {
            // Dynamic Type tự động scale với semantic fonts
            Text("Body text scales automatically")
                .font(.body)
                // User tăng text size trong Settings → text tự to lên
            
            // Cố định size: KHÔNG scale theo Dynamic Type
            Text("Fixed 14pt — không thay đổi")
                .font(.system(size: 14))
                // ⚠️ Tránh dùng fixed size cho content text
                // Chỉ dùng cho decorative hoặc constrained layouts
            
            // Custom accessibility label
            Text("$99.99")
                .accessibilityLabel("Chín mươi chín đô la chín mươi chín xu")
            
            // Combine nhiều Text thành 1 accessible element
            VStack {
                Text("Huy Nguyen").font(.headline)
                Text("iOS Developer").font(.subheadline)
            }
            .accessibilityElement(children: .combine)
            // VoiceOver đọc: "Huy Nguyen, iOS Developer"
            
            // Header trait (VoiceOver rotor navigation)
            Text("Phần Settings")
                .font(.title2)
                .accessibilityAddTraits(.isHeader)
        }
        .padding()
    }
}
#Preview {
    AccessibleTextDemo()
}
