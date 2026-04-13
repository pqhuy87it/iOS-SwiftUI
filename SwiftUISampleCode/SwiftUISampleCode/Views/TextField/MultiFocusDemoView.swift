//
//  MultiFocusDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct MultiFocusDemo: View {
    enum Field: Hashable {
        case username, email, password
    }
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?
    
    var body: some View {
        Group {
            TextField("Username", text: $username)
                .focused($focusedField, equals: .username)
                .textContentType(.username)
                .submitLabel(.next) // Nút Return → "Next"
            
            TextField("Email", text: $email)
                .focused($focusedField, equals: .email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
            
            SecureField("Password", text: $password)
                .focused($focusedField, equals: .password)
                .textContentType(.newPassword)
                .submitLabel(.done) // Nút Return → "Done"
            
            Button("Đăng ký") {
                register()
            }
            .disabled(username.isEmpty || email.isEmpty || password.isEmpty)
        }
        // Navigate fields khi nhấn Return/Next
        .onSubmit {
            switch focusedField {
            case .username:
                focusedField = .email       // Username → Email
            case .email:
                focusedField = .password    // Email → Password
            case .password:
                focusedField = nil          // Password → Dismiss
                register()
            case nil:
                break
            }
        }
        // Toolbar dismiss button
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Xong") {
                    focusedField = nil
                }
            }
        }
    }
    
    func register() {
        focusedField = nil // Dismiss keyboard
        // Perform registration...
    }
}
