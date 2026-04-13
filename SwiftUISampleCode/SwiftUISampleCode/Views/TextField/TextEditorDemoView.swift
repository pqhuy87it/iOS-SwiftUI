//
//  TextEditorDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct TextEditorDemo: View {
    @State private var notes = ""
    @State private var bio = ""
    
    var body: some View {
        Form {
            // === 10a. TextEditor cơ bản ===
            Section("Ghi chú") {
                TextEditor(text: $notes)
                    .frame(minHeight: 100, maxHeight: 200)
            }
            
            // === 10b. TextEditor styled ===
            Section("Tiểu sử") {
                ZStack(alignment: .topLeading) {
                    // Placeholder (TextEditor không có built-in)
                    if bio.isEmpty {
                        Text("Viết vài dòng về bản thân...")
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                    
                    TextEditor(text: $bio)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                        // .hidden để custom background
                }
            }
            
            // === 10c. iOS 16+ Alternative: TextField with axis ===
            Section("Mô tả (TextField expandable)") {
                TextField("Nhập mô tả...", text: $notes, axis: .vertical)
                    .lineLimit(3...8) // Min 3, max 8 dòng
                // Ưu điểm hơn TextEditor:
                // ✅ Có placeholder built-in
                // ✅ Auto-expand theo content
                // ✅ onSubmit hoạt động
                // ✅ Giao diện nhất quán với TextField
            }
        }
    }
}
