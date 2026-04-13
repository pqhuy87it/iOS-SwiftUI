//
//  OTPInputView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct OTPInputView: View {
    @State private var code = ""
    @FocusState private var isFocused: Bool
    let length: Int = 6
    var onComplete: ((String) -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Hidden TextField để nhận keyboard input
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0.01) // Gần như ẩn nhưng vẫn nhận input
                .onChange(of: code) { _, newValue in
                    code = String(newValue.filter(\.isNumber).prefix(length))
                    if code.count == length {
                        isFocused = false
                        onComplete?(code)
                    }
                }
            
            // Visual boxes
            HStack(spacing: 10) {
                ForEach(0..<length, id: \.self) { i in
                    let char = i < code.count
                        ? String(code[code.index(code.startIndex, offsetBy: i)])
                        : ""
                    
                    Text(char)
                        .font(.title.monospaced().bold())
                        .frame(width: 48, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.gray.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    i == code.count && isFocused
                                        ? .blue
                                        : .gray.opacity(0.2),
                                    lineWidth: i == code.count && isFocused ? 2 : 1
                                )
                        )
                }
            }
        }
        .onTapGesture { isFocused = true }
        .onAppear { isFocused = true }
    }
}
