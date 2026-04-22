//
//  VStackExample11View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct VStackExample11View: View {
    var body: some View {
        VStack(spacing: 16) {
            // === 11a. Section Card Container ===
            
            SectionCard(title: "Thông tin", subtitle: "Chi tiết tài khoản") {
                Text("Tên: Huy Nguyen")
                Text("Role: iOS Developer")
                Text("Team: Mobile")
            }
            
            SectionCard(title: "Kỹ năng") {
                HStack {
                    TagChip(text: "Swift")
                    TagChip(text: "SwiftUI")
                    TagChip(text: "Combine")
                }
            }
            
            // === 11b. Error Boundary Container ===
            
            ErrorBoundary(
                isError: true,
                errorMessage: "Không thể tải dữ liệu"
            ) { }
        }
        .padding()
    }
}

#Preview {
    VStackExample11View()
}
