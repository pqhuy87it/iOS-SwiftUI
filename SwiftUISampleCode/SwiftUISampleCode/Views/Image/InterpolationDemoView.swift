//
//  InterpolationDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct InterpolationDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            // === 8a. interpolation — Chất lượng khi scale ===
            // Khi ảnh NHỎ bị phóng to, interpolation quyết định
            // cách tính pixel mới giữa các pixel gốc
            
            HStack(spacing: 12) {
                VStack {
                    Image(systemName: "square.fill")
                        .resizable()
                        .interpolation(.none)   // Pixel art: sharp edges
                        .frame(width: 60, height: 60)
                    Text(".none").font(.caption2)
                }
                
                VStack {
                    Image(systemName: "square.fill")
                        .resizable()
                        .interpolation(.low)    // Nhanh, chất lượng thấp
                        .frame(width: 60, height: 60)
                    Text(".low").font(.caption2)
                }
                
                VStack {
                    Image(systemName: "square.fill")
                        .resizable()
                        .interpolation(.medium) // Cân bằng
                        .frame(width: 60, height: 60)
                    Text(".medium").font(.caption2)
                }
                
                VStack {
                    Image(systemName: "square.fill")
                        .resizable()
                        .interpolation(.high)   // Mượt nhất, chậm nhất
                        .frame(width: 60, height: 60)
                    Text(".high").font(.caption2)
                }
            }
            
            // === 8b. antialiased — Khử răng cưa ===
            Image(systemName: "triangle.fill")
                .resizable()
                .antialiased(true)  // Mặc định: true. false cho pixel art
                .frame(width: 80, height: 80)
        }
        .padding()
    }
}

#Preview {
    InterpolationDemo()
}
