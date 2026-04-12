//
//  LocalizationDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct LocalizationDemo: View {
    let itemCount = 5
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // === 11a. Auto localization ===
            // Text("Hello") tự động tìm key "Hello" trong Localizable.strings
            Text("Hello") // → "Xin chào" (nếu có localization)
            
            // === 11b. String interpolation → localized ===
            Text("Welcome, \("Huy")")
            // Tìm key "Welcome, %@" trong strings file
            
            // === 11c. Verbatim → KHÔNG localize ===
            Text(verbatim: "API_KEY_12345")
            // Hiện đúng chuỗi gốc, bỏ qua localization
            
            // === 11d. Pluralization (String Catalog) ===
            // Trong String Catalog (.xcstrings):
            // key: "%lld items"
            // one: "%lld item"
            // other: "%lld items"
            Text("\(itemCount) items")
            // → "5 items" (English) / "5 mục" (Vietnamese)
            
            // === 11e. LocalizedStringKey explicit ===
            let key: LocalizedStringKey = "greeting_\("Huy")"
            Text(key)
        }
        .padding()
    }
}

#Preview {
    LocalizationDemo()
}
