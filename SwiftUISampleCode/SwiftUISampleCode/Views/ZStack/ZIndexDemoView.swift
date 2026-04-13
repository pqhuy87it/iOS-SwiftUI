//
//  ZIndexDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ZIndexDemo: View {
    @State private var frontCardIndex = 2
    let colors: [Color] = [.red, .green, .blue]
    
    var body: some View {
        VStack(spacing: 30) {
            // Cards chồng nhau, tap để đưa lên trước
            ZStack {
                ForEach(0..<3) { i in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colors[i].gradient)
                        .frame(width: 160, height: 100)
                        .offset(x: CGFloat(i - 1) * 30,
                                y: CGFloat(i - 1) * 20)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        .zIndex(i == frontCardIndex ? 10 : Double(i))
                        // Card được chọn → zIndex 10 → lên TRÊN CÙNG
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3)) {
                                frontCardIndex = i
                            }
                        }
                        .overlay {
                            Text("Card \(i + 1)")
                                .foregroundStyle(.white)
                                .font(.headline)
                        }
                }
            }
            .frame(height: 180)
            
            Text("Tap card để đưa lên trước")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
