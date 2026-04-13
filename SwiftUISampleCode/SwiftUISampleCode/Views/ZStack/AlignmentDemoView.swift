//
//  AlignmentDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct AlignmentDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            let alignments: [(String, Alignment)] = [
                ("topLeading", .topLeading),
                ("top", .top),
                ("topTrailing", .topTrailing),
                ("leading", .leading),
                ("center", .center),
                ("trailing", .trailing),
                ("bottomLeading", .bottomLeading),
                ("bottom", .bottom),
                ("bottomTrailing", .bottomTrailing),
            ]
            
            // Grid 3x3 hiển thị tất cả alignments
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3),
                      spacing: 8) {
                ForEach(alignments, id: \.0) { name, alignment in
                    ZStack(alignment: alignment) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.gray.opacity(0.1))
                            .frame(width: 100, height: 70)
                        
                        // Content: nhỏ hơn background → thấy rõ alignment
                        Circle()
                            .fill(.blue)
                            .frame(width: 20, height: 20)
                    }
                    .overlay(alignment: .bottom) {
                        Text(name)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .offset(y: 12)
                    }
                }
            }
            .padding()
        }
    }
}
