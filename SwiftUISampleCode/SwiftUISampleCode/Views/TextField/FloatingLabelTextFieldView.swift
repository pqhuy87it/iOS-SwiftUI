//
//  FloatingLabelTextFieldView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct FloatingLabelTextField: View {
    let title: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    private var isFloating: Bool {
        isFocused || !text.isEmpty
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Floating label
            Text(title)
                .font(isFloating ? .caption : .body)
                .foregroundStyle(isFocused ? .blue : .secondary)
                .offset(y: isFloating ? -24 : 0)
                .animation(.easeInOut(duration: 0.2), value: isFloating)
            
            // TextField
            TextField("", text: $text)
                .focused($isFocused)
        }
        .padding(.top, 16) // Space cho floating label
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(isFocused ? .blue : .gray.opacity(0.3))
                .frame(height: isFocused ? 2 : 1)
        }
    }
}
