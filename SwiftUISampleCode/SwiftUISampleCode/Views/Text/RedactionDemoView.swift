//
//  RedactionDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct RedactionDemo: View {
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nguyễn Văn Huy")
                        .font(.headline)
                    Text("Senior iOS Developer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text("Đây là mô tả dài về profile, có thể nhiều dòng text hiển thị ở đây khi dữ liệu đã tải xong.")
                .font(.body)
            
            HStack {
                Text("128 bài viết").font(.caption)
                Text("1.2K followers").font(.caption)
            }
        }
        .redacted(reason: isLoading ? .placeholder : [])
        // .placeholder → tất cả Text hiện dạng skeleton blocks
        // Hình ảnh, shapes cũng bị redacted
        
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { isLoading = false }
            }
        }
    }
}

#Preview {
    RedactionDemo()
}
