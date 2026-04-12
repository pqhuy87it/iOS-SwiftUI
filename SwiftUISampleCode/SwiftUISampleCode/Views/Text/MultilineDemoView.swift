//
//  MultilineDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct MultilineDemo: View {
    let longText = "SwiftUI cung cấp hệ thống Text rất mạnh mẽ cho phép hiển thị văn bản với nhiều tùy chỉnh phong phú từ font, color, spacing đến rich text và animations."
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // === 4a. lineLimit — Giới hạn số dòng ===
            Text(longText)
                .lineLimit(1) // Chỉ 1 dòng, còn lại bị cắt
            
            Text(longText)
                .lineLimit(2) // Tối đa 2 dòng
            
            Text(longText)
                .lineLimit(nil) // Không giới hạn (hiện TẤT CẢ)
            
            // iOS 16+: Range line limit
            Text(longText)
                .lineLimit(2...4)
            // Tối thiểu 2, tối đa 4 dòng
            // SwiftUI tự chọn trong khoảng phù hợp
            
            Divider()
            
            // === 4b. truncationMode — Vị trí dấu "..." ===
            Text(longText)
                .lineLimit(1)
                .truncationMode(.tail)    // "SwiftUI cung cấp hệ thống..."
            
            Text(longText)
                .lineLimit(1)
                .truncationMode(.middle)  // "SwiftUI cung...và animations."
            
            Text(longText)
                .lineLimit(1)
                .truncationMode(.head)    // "...rich text và animations."
            
            Divider()
            
            // === 4c. multilineTextAlignment ===
            Group {
                Text(longText)
                    .multilineTextAlignment(.leading)   // Căn trái (default)
                
                Text(longText)
                    .multilineTextAlignment(.center)    // Căn giữa
                
                Text(longText)
                    .multilineTextAlignment(.trailing)   // Căn phải
            }
            .lineLimit(3)
            .frame(width: 300)
            
            Divider()
            
            // === 4d. lineSpacing — Khoảng cách giữa các dòng ===
            Text(longText)
                .lineSpacing(8) // Thêm 8pt giữa mỗi dòng
                .lineLimit(3)
            
            // === 4e. minimumScaleFactor — Co text để vừa ===
            Text("Đoạn text dài sẽ tự thu nhỏ để vừa trong 1 dòng")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            // Scale xuống tối đa 50% kích thước gốc
            // Nếu vẫn không vừa → truncate
            // ⚠️ Dùng cẩn thận: text quá nhỏ → khó đọc
        }
        .padding()
    }
}

#Preview {
    MultilineDemo()
}
