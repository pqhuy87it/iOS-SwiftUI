//
//  SingleFocusDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct SingleFocusDemo: View {
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Nhập text", text: $text)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
            
            HStack {
                // Auto-focus
                Button("Focus") { isFocused = true }
                
                // Dismiss keyboard
                Button("Dismiss") { isFocused = false }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .onAppear {
            // Auto-focus khi view appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}
