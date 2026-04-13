//
//  BasicZStackDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

// ZStack(
//     alignment: Alignment = .center,
//     @ViewBuilder content: () -> Content
// )

struct BasicZStackDemo: View {
    var body: some View {
        VStack(spacing: 30) {
            
            // === 1a. Cơ bản: layers từ sau ra trước ===
            ZStack {
                // Layer 1 (SAU CÙNG — khai báo đầu tiên)
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue)
                    .frame(width: 160, height: 100)
                
                // Layer 2 (GIỮA)
                RoundedRectangle(cornerRadius: 12)
                    .fill(.green)
                    .frame(width: 120, height: 80)
                
                // Layer 3 (TRƯỚC NHẤT — khai báo cuối cùng)
                RoundedRectangle(cornerRadius: 12)
                    .fill(.orange)
                    .frame(width: 80, height: 60)
            }
            
            // === 1b. Thứ tự khai báo = Thứ tự layer ===
            ZStack {
                Color.gray.opacity(0.1)     // Layer 0: background
                
                Text("Giữa")               // Layer 1: content
                    .font(.title2.bold())
                
                // Layer 2: badge góc trên phải
                VStack {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(.red)
                            .frame(width: 20, height: 20)
                            .overlay(Text("3").font(.caption2).foregroundStyle(.white))
                    }
                    Spacer()
                }
                .padding(8)
            }
            .frame(width: 150, height: 80)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
}
