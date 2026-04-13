//
//  ImageSizingDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ImageSizingDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // ❌ KHÔNG resizable → hiện kích thước gốc, frame bị bỏ qua
            // Image("large-photo")
            //     .frame(width: 100, height: 100) // KHÔNG có tác dụng!
            
            // ✅ resizable() → image co dãn theo frame
            // Image("large-photo")
            //     .resizable()
            //     .frame(width: 100, height: 100)
            
            // === 3a. aspectRatio — Giữ tỉ lệ ===
            
            // .fit: toàn bộ ảnh HIỆN HẾT, có thể có khoảng trống
            Image(systemName: "photo.artframe")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 100)
                .border(.blue)
            // Ảnh nằm trọn trong frame, giữ nguyên tỉ lệ
            
            // .fill: ảnh PHỦM KÍN frame, có thể bị cắt
            Image(systemName: "photo.artframe")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 100)
                .clipped() // Cắt phần tràn ra ngoài
                .border(.red)
            // Ảnh phủ kín frame, phần thừa bị cắt
            
            // === 3b. scaledToFit / scaledToFill — Shorthand ===
            HStack(spacing: 12) {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()          // = aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .background(.gray.opacity(0.1))
                
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()         // = aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .background(.gray.opacity(0.1))
            }
            
            // === 3c. Custom aspect ratio ===
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(16/9, contentMode: .fit) // Force 16:9
                .frame(maxWidth: .infinity)
                .background(.gray.opacity(0.1))
            
            // === 3d. Chỉ set 1 chiều — chiều còn lại tự tính ===
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(height: 60) // Chỉ set height, width tự tính theo ratio
        }
        .padding()
    }
}

#Preview {
    ImageSizingDemo()
}
