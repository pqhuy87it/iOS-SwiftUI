//
//  TextFieldStyleDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct TextFieldStyleDemo: View {
    @State private var text1 = ""
    @State private var text2 = ""
    @State private var text3 = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // === 2a. .automatic (Default) ===
            // Trong Form → rounded border
            // Ngoài Form → plain
            TextField("Automatic", text: $text1)
                .textFieldStyle(.automatic)
            
            // === 2b. .plain — Không border, không background ===
            TextField("Plain", text: $text2)
                .textFieldStyle(.plain)
            
            // === 2c. .roundedBorder — Border rounded ===
            TextField("Rounded Border", text: $text3)
                .textFieldStyle(.roundedBorder)
            
            // ⚠️ CHỈ CÓ 3 built-in styles trên iOS
            // macOS có thêm: .squareBorder
            // Custom style → tự build (Phần 9)
        }
        .padding()
    }
}
