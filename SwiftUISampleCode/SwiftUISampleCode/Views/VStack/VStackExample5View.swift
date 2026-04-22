//
//  VStackExample5View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct VStackExample5View: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 5a. Spacer đẩy content lên trên ===
            VStack {
                Text("Nằm trên cùng")
                    .padding()
                    .background(.blue.opacity(0.2))
                Spacer() // Đẩy tất cả lên trên
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .border(.gray)
            
            // === 5b. Spacer kẹp giữa ===
            VStack {
                Text("Trên")
                Spacer()         // Đẩy "Trên" lên, "Dưới" xuống
                Text("Dưới")
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .border(.gray)
            
            // === 5c. Spacer căn giữa ===
            VStack {
                Spacer()
                Text("Giữa theo chiều dọc")
                Spacer()
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .border(.gray)
            
            // === 5d. layoutPriority ===
            VStack {
                // Priority 1: text này được giữ nguyên
                Text("Tiêu đề quan trọng")
                    .font(.headline)
                    .layoutPriority(1)
                
                // Priority 0 (default): bị truncate trước nếu thiếu chỗ
                Text("Mô tả dài có thể bị cắt khi không đủ chiều cao cho VStack, dòng này sẽ bị ảnh hưởng đầu tiên")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .border(.gray)
        }
        .padding()
    }
}

#Preview {
    VStackExample5View()
}
