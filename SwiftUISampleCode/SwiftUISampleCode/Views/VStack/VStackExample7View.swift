//
//  VStackExample7View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct VStackExample7View: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // Section 1: spacing NHỎ giữa các elements
            VStack(alignment: .leading, spacing: 8) {
                Text("Thông tin cá nhân")
                    .font(.title3.bold())
                Text("Cập nhật thông tin tài khoản của bạn")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Section 2
            VStack(spacing: 12) {
                InfoRow(label: "Họ tên", value: "Nguyễn Văn Huy")
                Divider()
                InfoRow(label: "Email", value: "huy@example.com")
                Divider()
                InfoRow(label: "SĐT", value: "0912 345 678")
            }
            .padding()
            .background(.gray.opacity(0.06), in: .rect(cornerRadius: 12))
            
            // Section 3
            VStack(spacing: 12) {
                InfoRow(label: "Vai trò", value: "Senior iOS Developer")
                Divider()
                InfoRow(label: "Team", value: "Mobile Engineering")
            }
            .padding()
            .background(.gray.opacity(0.06), in: .rect(cornerRadius: 12))
        }
        .padding()
    }
}

#Preview {
    VStackExample7View()
}
