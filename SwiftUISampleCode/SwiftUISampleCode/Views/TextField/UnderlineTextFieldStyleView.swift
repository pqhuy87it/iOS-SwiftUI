//
//  UnderlineTextFieldStyleView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct UnderlineTextFieldStyle: TextFieldStyle {
    var icon: String? = nil
    var isValid: Bool = true
    @FocusState private var isFocused: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(isFocused ? .blue : .secondary)
                    .frame(width: 20)
            }
            
            configuration
                .focused($isFocused)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(isFocused ? .blue : (isValid ? .gray.opacity(0.3) : .red))
                .frame(height: isFocused ? 2 : 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}
