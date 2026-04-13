//
//  OverlayVsZStackView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct OverlayVsZStack: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // === 4a. ZStack: size = child LỚN NHẤT ===
            ZStack {
                Rectangle().fill(.blue.opacity(0.2))
                    .frame(width: 200, height: 80)
                Text("ZStack")
            }
            .border(.red)
            // Kết quả: ZStack rộng 200x80 (theo Rectangle)
            
            // === 4b. .overlay: size = BASE VIEW ===
            Text("Base View")
                .padding()
                .background(.blue.opacity(0.2))
                .overlay(alignment: .topTrailing) {
                    Circle().fill(.red)
                        .frame(width: 20, height: 20)
                        .offset(x: 8, y: -8)
                }
            // Kết quả: size theo Text, Circle chồng lên nhưng
            // KHÔNG ảnh hưởng sizing → có thể tràn ra ngoài
            
            // === 4c. .background: size = BASE VIEW ===
            Text("Content")
                .padding(24)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green.opacity(0.2))
                    // Background tự co/dãn theo Text
                }
            // Kết quả: size theo Text, background co dãn theo
        }
    }
}
