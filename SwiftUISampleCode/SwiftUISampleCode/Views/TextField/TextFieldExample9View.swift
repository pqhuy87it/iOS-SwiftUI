//
//  TextFieldExample9View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct TextFieldExample9View: View {
    var body: some View {
        List {
            // TextFieldStyle protocol:
            // func _body(configuration: TextField<Self._Label>) -> some View
            
            VStack(spacing: 24) {
                // Underline
                // === 9a. Underline Style ===
                TextField("Email", text: .constant(""))
                    .textFieldStyle(UnderlineTextFieldStyle(icon: "envelope"))
                
                // Filled
                // === 9b. Filled/Material Style ===
                TextField("Password", text: .constant(""))
                    .textFieldStyle(FilledTextFieldStyle())
                
                // Floating label
                // === 9c. Floating Label Style ===
                FloatingLabelTextField(title: "Username", text: .constant(""))
                
                FloatingLabelTextField(title: "Đã nhập", text: .constant("huy_dev"))
            }
            .padding(24)
        }
    }
}

#Preview {
    TextFieldExample9View()
}
