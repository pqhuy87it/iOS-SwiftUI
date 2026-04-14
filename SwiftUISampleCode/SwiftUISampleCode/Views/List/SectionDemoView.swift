//
//  SectionDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct SectionDemo: View {
    var body: some View {
        List {
            // === 2a. Section với header text ===
            Section("Tài khoản") {
                Label("Hồ sơ", systemImage: "person")
                Label("Bảo mật", systemImage: "lock")
                Label("Thông báo", systemImage: "bell")
            }
            
            // === 2b. Header + Footer ===
            Section {
                Toggle("Wi-Fi", isOn: .constant(true))
                Toggle("Bluetooth", isOn: .constant(false))
            } header: {
                Text("Kết nối")
            } footer: {
                Text("Tắt Wi-Fi và Bluetooth để tiết kiệm pin.")
                    .font(.caption)
            }
            
            // === 2c. Custom header view ===
            Section {
                Text("Item 1")
                Text("Item 2")
            } header: {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Yêu thích")
                        .font(.headline)
                }
            }
            
            // === 2d. Collapsible Section (iOS 17+) ===
            Section("Nâng cao", isExpanded: .constant(true)) {
                Text("Option A")
                Text("Option B")
                Text("Option C")
            }
            
            // === 2e. Section visibility ===
            // Header mặc định UPPERCASE trên .insetGrouped
            // Muốn giữ nguyên case:
            Section {
                Text("Content")
            } header: {
                Text("Giữ nguyên chữ thường")
                    .textCase(nil) // Disable auto-uppercase
            }
        }
    }
}
