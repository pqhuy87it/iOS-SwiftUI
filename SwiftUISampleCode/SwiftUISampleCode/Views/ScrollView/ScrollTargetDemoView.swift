//
//  ScrollTargetDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ScrollTargetDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // === 6a. .paging — Full page snapping ===
            Text(".paging").font(.caption.bold())
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(0..<10) { i in
                        RoundedRectangle(cornerRadius: 20)
                            .fill([Color.blue, .green, .orange, .purple, .red][i % 5].gradient)
                            .containerRelativeFrame(.horizontal) // Full width mỗi page
                            .overlay(
                                Text("Page \(i + 1)")
                                    .font(.title.bold())
                                    .foregroundStyle(.white)
                            )
                            .padding(.horizontal, 16)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging) // Snap theo page
            .frame(height: 180)
            
            // === 6b. .viewAligned — Snap theo từng view ===
            Text(".viewAligned").font(.caption.bold())
            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(0..<20) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue.gradient)
                            .frame(width: 200, height: 120)
                            .overlay(Text("Card \(i + 1)").foregroundStyle(.white))
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal)
            }
            .scrollTargetBehavior(.viewAligned) // Snap theo card edge
            .frame(height: 140)
        }
    }
}
