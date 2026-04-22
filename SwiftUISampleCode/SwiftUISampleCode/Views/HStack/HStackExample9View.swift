//
//  HStackExample9View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct CardView1: View {
    let index: Int
    let color: Color
    
    init(index: Int, color: Color) {
        self.index = index
        self.color = color
        // print("Init card \(index)") // Bỏ comment để thấy lazy behavior
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(color.gradient)
            .frame(width: 120, height: 80)
            .overlay(
                Text("\(index)")
                    .foregroundStyle(.white)
                    .font(.headline)
            )
    }
}

struct HStackExample9View: View {
    var body: some View {
        VStack(spacing: 24) {
            // === HStack: OK cho ít items (< 50) ===
            Text("HStack (eager)").font(.caption.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<20) { i in
                        CardView1(index: i, color: .blue)
                    }
                }
                .padding(.horizontal)
            }
            
            // === LazyHStack: cho nhiều items (100+) ===
            Text("LazyHStack (lazy)").font(.caption.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(0..<1000) { i in
                        CardView1(index: i, color: .green)
                        // Chỉ ~5-8 cards được init ban đầu
                        // Scroll → tạo thêm on-demand
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    HStackExample9View()
}
