//
//  ValidationDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ValidationDemo: View {
    @State private var email = ""
    @State private var phone = ""
    @State private var age = ""
    
    @FocusState private var focusedField: FormField?
    
    enum FormField: Hashable {
        case email, phone, age
    }
    
    // Validation states
    private var emailError: String? {
        guard !email.isEmpty else { return nil }
        let regex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return email.wholeMatch(of: regex) == nil ? "Email không hợp lệ" : nil
    }
    
    private var phoneError: String? {
        guard !phone.isEmpty else { return nil }
        let digits = phone.filter(\.isNumber)
        return digits.count < 10 ? "SĐT phải có ít nhất 10 số" : nil
    }
    
    private var ageError: String? {
        guard !age.isEmpty else { return nil }
        guard let num = Int(age) else { return "Phải là số" }
        return (num < 1 || num > 150) ? "Tuổi không hợp lệ" : nil
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !phone.isEmpty && !age.isEmpty
        && emailError == nil && phoneError == nil && ageError == nil
    }
    
    var body: some View {
        Form {
            Section {
                ValidatedField(
                    title: "Email",
                    text: $email,
                    error: emailError,
                    icon: "envelope",
                    keyboard: .emailAddress,
                    contentType: .emailAddress,
                    isFocused: focusedField == .email
                )
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                
                ValidatedField(
                    title: "Số điện thoại",
                    text: $phone,
                    error: phoneError,
                    icon: "phone",
                    keyboard: .phonePad,
                    contentType: .telephoneNumber,
                    isFocused: focusedField == .phone
                )
                .focused($focusedField, equals: .phone)
                .submitLabel(.next)
                
                ValidatedField(
                    title: "Tuổi",
                    text: $age,
                    error: ageError,
                    icon: "number",
                    keyboard: .numberPad,
                    contentType: nil,
                    isFocused: focusedField == .age
                )
                .focused($focusedField, equals: .age)
                .submitLabel(.done)
            }
            
            Section {
                Button("Gửi") { }
                    .frame(maxWidth: .infinity)
                    .disabled(!isFormValid)
            }
        }
        .onSubmit {
            switch focusedField {
            case .email: focusedField = .phone
            case .phone: focusedField = .age
            case .age: focusedField = nil
            case nil: break
            }
        }
    }
}

// Reusable validated field component
struct ValidatedField: View {
    let title: String
    @Binding var text: String
    let error: String?
    var icon: String? = nil
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var isFocused: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(error != nil ? .red : (isFocused ? .blue : .secondary))
                        .frame(width: 20)
                }
                
                TextField(title, text: $text)
                    .keyboardType(keyboard)
                    .textContentType(contentType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                // Status icon
                if !text.isEmpty {
                    Image(systemName: error == nil ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundStyle(error == nil ? .green : .red)
                        .font(.subheadline)
                }
            }
            
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: error)
    }
}
