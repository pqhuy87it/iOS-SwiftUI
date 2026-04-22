//
//  HStackExample3View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct HStackExample3View: View {
    var body: some View {
        HStack(alignment: .iconCenter, spacing: 16) {
            // Icon — đánh dấu điểm căn chỉnh ở GIỮA icon
            Image(systemName: "bell.fill")
                .font(.title)
                .foregroundStyle(.blue)
                .alignmentGuide(.iconCenter) { d in
                    d[VerticalAlignment.center] // Giữa icon
                }
            
            // Text block — căn dòng ĐẦU TIÊN với giữa icon
            VStack(alignment: .leading, spacing: 4) {
                Text("Thông báo mới")
                    .font(.headline)
                    .alignmentGuide(.iconCenter) { d in
                        d[VerticalAlignment.center] // Giữa dòng này
                    }
                Text("Bạn có 3 tin nhắn chưa đọc")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("2 phút trước")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
    }
}

#Preview {
    HStackExample3View()
}
