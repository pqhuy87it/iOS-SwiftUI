//
//  TextProcessingDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct TextProcessingDemo: View {
    @State private var phone = ""
    @State private var cardNumber = ""
    @State private var username = ""
    @State private var charCount = 0
    
    var body: some View {
        Form {
            // === 8a. Auto-format phone number ===
            TextField("Số điện thoại", text: $phone)
                .keyboardType(.numberPad)
                .onChange(of: phone) { _, newValue in
                    // Chỉ giữ digits
                    let digits = newValue.filter(\.isNumber)
                    // Limit 10 digits
                    let limited = String(digits.prefix(10))
                    // Format: 0912 345 678
                    phone = formatPhone(limited)
                }
            
            // === 8b. Credit card formatting ===
            TextField("Số thẻ", text: $cardNumber)
                .keyboardType(.numberPad)
                .onChange(of: cardNumber) { _, newValue in
                    let digits = newValue.filter(\.isNumber)
                    let limited = String(digits.prefix(16))
                    // Format: 4242 4242 4242 4242
                    cardNumber = formatCardNumber(limited)
                }
            
            // === 8c. Character limit + counter ===
            VStack(alignment: .trailing, spacing: 4) {
                TextField("Username", text: $username)
                    .onChange(of: username) { _, newValue in
                        // Limit 20 characters, lowercase, no spaces
                        let processed = String(
                            newValue
                                .lowercased()
                                .filter { $0.isLetter || $0.isNumber || $0 == "_" }
                                .prefix(20)
                        )
                        if processed != newValue {
                            username = processed
                        }
                        charCount = username.count
                    }
                
                Text("\(charCount)/20")
                    .font(.caption)
                    .foregroundStyle(charCount >= 18 ? .orange : .secondary)
            }
        }
    }
    
    func formatPhone(_ digits: String) -> String {
        var result = ""
        for (i, ch) in digits.enumerated() {
            if i == 4 || i == 7 { result += " " }
            result.append(ch)
        }
        return result
    }
    
    func formatCardNumber(_ digits: String) -> String {
        var result = ""
        for (i, ch) in digits.enumerated() {
            if i > 0 && i % 4 == 0 { result += " " }
            result.append(ch)
        }
        return result
    }
}
