//
//  SizingDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct SizingDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // === 3a. ZStack size = child lớn nhất ===
            ZStack {
                Color.red.opacity(0.2)          // Greedy: chiếm MỌI không gian
                    .frame(width: 200, height: 120)
                
                Text("Nhỏ hơn")                 // Nhỏ hơn
                    .padding()
                    .background(.blue.opacity(0.2))
            }
            .border(.gray)
            // ZStack rộng 200x120 (theo Color frame)
            
            // === 3b. Khi có greedy child (Color, Spacer...) ===
            ZStack {
                Color.green.opacity(0.1)
                // Color KHÔNG có intrinsic size → chiếm TOÀN BỘ available space
                // → ZStack mở rộng max
                
                Text("ZStack fills parent")
            }
            .frame(height: 60)
            .border(.gray)
            
            // === 3c. Giới hạn ZStack size ===
            ZStack {
                Color.orange.opacity(0.2)
                Text("Constrained")
            }
            .frame(width: 150, height: 80) // Giới hạn ZStack
            .clipShape(.rect(cornerRadius: 12))
            
            // === 3d. Khi TẤT CẢ children có fixed size ===
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.blue.opacity(0.2))
                    .frame(width: 120, height: 60)
                
                Text("OK")
                    .bold()
            }
            .border(.gray)
            // ZStack size = 120x60 (child lớn nhất)
        }
        .padding()
    }
}
