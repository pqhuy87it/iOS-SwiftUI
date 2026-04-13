//
//  KeyboardConfigDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct KeyboardConfigDemo: View {
    @State private var email = ""
    @State private var phone = ""
    @State private var amount = ""
    @State private var search = ""
    @State private var website = ""
    @State private var code = ""
    
    var body: some View {
        Form {
            // === 3a. keyboardType — Loại bàn phím ===
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
            // .default           → Bàn phím thường
            // .emailAddress      → Có @ và .
            // .numberPad         → Chỉ số (không return)
            // .decimalPad        → Số + dấu thập phân
            // .phonePad          → Số + * #
            // .URL               → Có / . .com
            // .asciiCapable      → Chỉ ASCII
            // .numbersAndPunctuation → Số + dấu câu
            // .twitter           → Có @ #
            // .webSearch         → Có Go button
            
            TextField("Số điện thoại", text: $phone)
                .keyboardType(.phonePad)
            
            TextField("Số tiền", text: $amount)
                .keyboardType(.decimalPad)
            
            // === 3b. textInputAutocapitalization ===
            TextField("Search", text: $search)
                .textInputAutocapitalization(.never)
            // .never             → không viết hoa
            // .words             → Viết hoa chữ cái đầu mỗi từ
            // .sentences         → Viết hoa đầu câu (default)
            // .characters        → VIẾT HOA TẤT CẢ
            
            // === 3c. autocorrectionDisabled ===
            TextField("Mã code", text: $code)
                .autocorrectionDisabled()
            // Tắt autocorrect — dùng cho: code, username, ID
            
            // === 3d. textContentType — Autofill hints ===
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
            // iOS Autofill biết đây là email → suggest từ Keychain
            
            // .name              → Tên
            // .namePrefix        → Mr/Mrs
            // .givenName         → Tên
            // .familyName        → Họ
            // .emailAddress      → Email
            // .telephoneNumber   → SĐT
            // .streetAddressLine1 → Địa chỉ
            // .postalCode        → Mã bưu điện
            // .creditCardNumber  → Số thẻ
            // .oneTimeCode       → OTP (auto-fill từ SMS!)
            // .password          → Password (Keychain)
            // .newPassword       → Strong Password suggestion
            // .username          → Username (Keychain)
            
            TextField("OTP", text: $code)
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)
            // iOS tự đọc SMS OTP → suggest autofill!
            
            // === 3e. Kết hợp nhiều modifiers ===
            TextField("Email đăng nhập", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            // Config hoàn chỉnh cho email input
        }
    }
}
