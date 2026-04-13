//
//  FilledTextFieldStyleView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct FilledTextFieldStyle: TextFieldStyle {
    @FocusState private var isFocused: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .focused($isFocused)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(isFocused ? 0.12 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isFocused ? .blue : .clear,
                        lineWidth: 1.5
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
