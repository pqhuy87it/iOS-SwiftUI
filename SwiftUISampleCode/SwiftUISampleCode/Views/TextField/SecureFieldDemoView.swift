//
//  SecureFieldDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct SecureFieldDemo: View {
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    
    var body: some View {
        Form {
            // === 6a. SecureField cơ bản ===
            SecureField("Mật khẩu", text: $password)
                .textContentType(.password)
            // Hiển thị dots (•••), ẩn ký tự
            // iOS đề xuất strong password nếu .newPassword
            
            // === 6b. Toggle hiện/ẩn password ===
            HStack {
                Group {
                    if showPassword {
                        TextField("Mật khẩu", text: $password)
                    } else {
                        SecureField("Mật khẩu", text: $password)
                    }
                }
                .textContentType(.password)
                
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            // === 6c. Confirm password ===
            SecureField("Xác nhận mật khẩu", text: $confirmPassword)
                .textContentType(.newPassword)
            
            if !confirmPassword.isEmpty && password != confirmPassword {
                Text("Mật khẩu không khớp")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

