//
//  SearchBarView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Tìm kiếm..."
    var onSubmit: (() -> Void)? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(10)
        .background(.gray.opacity(0.1), in: .capsule)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}

