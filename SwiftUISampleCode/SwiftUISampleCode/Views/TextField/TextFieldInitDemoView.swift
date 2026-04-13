//
//  TextFieldInitDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI
import Combine

struct TextFieldInitDemo: View {
    @State private var name = ""
    @State private var bio = ""
    @State private var age = 0
    @State private var price = 0.0
    @State private var birthday = Date.now
    @State private var website: URL = URL(string: "https://apple.com")!
    
    var body: some View {
        Form {
            // === 1a. String label + Binding<String> ===
            TextField("Họ và tên", text: $name)
            
            // === 1b. Prompt (placeholder chi tiết hơn label) ===
            TextField("Họ và tên", text: $name, prompt: Text("Nhập họ tên đầy đủ"))
            // Label: cho accessibility / form context
            // Prompt: text mờ hiện trong field khi rỗng
            
            // === 1c. Custom label view (iOS 16+) ===
            TextField(text: $name) {
                Label("Tên hiển thị", systemImage: "person")
            }
            
            // === 1d. Format — Tự động parse number ===
            TextField("Tuổi", value: $age, format: .number)
            // User nhập "25" → age = 25 (Int)
            // User nhập "abc" → KHÔNG cập nhật (invalid)
            
            // === 1e. Format — Currency ===
            TextField("Giá", value: $price,
                      format: .currency(code: "VND"))
            // Hiển thị: "₫1,500,000"
            // Parse ngược: "1500000" → 1_500_000.0
            
            // === 1f. Format — Date ===
            TextField("Ngày sinh", value: $birthday,
                      format: .dateTime.day().month().year())
            
            // === 1g. Axis — Expandable text field (iOS 16+) ===
            TextField("Tiểu sử", text: $bio, axis: .vertical)
                .lineLimit(3...6)
            // Bắt đầu 3 dòng, mở rộng tối đa 6 dòng
            // Thay thế TextEditor cho nhiều trường hợp
            
            // === 1h. URL format ===
            TextField("Website", value: $website, format: .url)
        }
    }
}
