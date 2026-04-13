//
//  AccessibleTextFieldDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct AccessibleTextFieldDemo: View {
    @State private var name = ""
    @State private var amount = ""
    
    var body: some View {
        Form {
            // TextField tự động accessible (label = title string)
            TextField("Họ và tên", text: $name)
            // VoiceOver: "Họ và tên, text field, double tap to edit"
            
            // Custom accessibility
            TextField("Số tiền", text: $amount)
                .keyboardType(.decimalPad)
                .accessibilityLabel("Nhập số tiền thanh toán")
                .accessibilityHint("Nhập số tiền bằng VND, chỉ số")
                .accessibilityValue(amount.isEmpty ? "Trống" : "\(amount) đồng")
        }
    }
}
