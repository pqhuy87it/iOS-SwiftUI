//
//  TextFieldExample11View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct TextFieldExample11View: View {
    @State var searchStr = "iOS"
    
    var body: some View {
        List {
            // === 11a. Login Form ===
            LoginForm()
            
            // === 11b. Search Bar Component ===
            SearchBar(text: $searchStr)
            
            VStack(spacing: 24) {
                Text("Nhập mã OTP").font(.title2.bold())
                Text("Chúng tôi đã gửi mã 6 số qua SMS")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                OTPInputView { code in
                    print("OTP: \(code)")
                }
            }
            .padding()
        }
    }
}

#Preview {
    TextFieldExample11View()
}
