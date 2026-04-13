//
//  LoginFormView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct LoginForm: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showPassword = false
    @FocusState private var focus: Field?
    
    enum Field: Hashable { case email, password }
    
    var body: some View {
        VStack(spacing: 20) {
            // Email
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
            }
            .padding()
            .background(.gray.opacity(0.08), in: .rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(focus == .email ? .blue : .clear, lineWidth: 1.5)
            )
            
            // Password
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                
                Group {
                    if showPassword {
                        TextField("Mật khẩu", text: $password)
                    } else {
                        SecureField("Mật khẩu", text: $password)
                    }
                }
                .textContentType(.password)
                .focused($focus, equals: .password)
                .submitLabel(.go)
                
                Button { showPassword.toggle() } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(.gray.opacity(0.08), in: .rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(focus == .password ? .blue : .clear, lineWidth: 1.5)
            )
            
            // Login button
            Button {
                focus = nil
                isLoading = true
            } label: {
                HStack {
                    if isLoading { ProgressView().controlSize(.small) }
                    Text("Đăng nhập")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.blue, in: .rect(cornerRadius: 12))
                .foregroundStyle(.white)
            }
            .disabled(email.isEmpty || password.isEmpty || isLoading)
        }
        .padding(24)
        .onSubmit {
            switch focus {
            case .email: focus = .password
            case .password: focus = nil; isLoading = true
            case nil: break
            }
        }
    }
}
