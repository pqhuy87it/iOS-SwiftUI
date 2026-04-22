//
//  HStackExample6View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct HStackExample6View: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // ❌ Không có priority: text dài bị cắt ngẫu nhiên
            HStack {
                Text("Tiêu đề rất dài có thể bị cắt")
                    .lineLimit(1)
                    .background(.blue.opacity(0.1))
                Text("Button")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.blue, in: .capsule)
                    .foregroundStyle(.white)
            }
            .padding()
            
            // ✅ Button có priority cao → KHÔNG bao giờ bị cắt
            HStack {
                Text("Tiêu đề rất dài sẽ bị truncate nếu không đủ chỗ")
                    .lineLimit(1)
                    .background(.blue.opacity(0.1))
                    .layoutPriority(0) // Mặc định, bị cắt trước
                
                Text("Button")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.blue, in: .capsule)
                    .foregroundStyle(.white)
                    .layoutPriority(1) // Cao hơn → được giữ nguyên
            }
            .padding()
            
            // Priority nhiều levels
            HStack {
                // Priority 0: bị cắt đầu tiên
                Text("Mô tả phụ dài dòng")
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .layoutPriority(0)
                
                // Priority 1: bị cắt thứ hai
                Text("Tiêu đề chính của item")
                    .lineLimit(1)
                    .layoutPriority(1)
                
                // Priority 2: KHÔNG BAO GIỜ bị cắt
                Image(systemName: "chevron.right")
                    .layoutPriority(2)
            }
            .padding()
        }
    }
}

#Preview {
    HStackExample6View()
}
