//
//  ScrollTransitionDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ScrollTransitionDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            
            // === 7a. Fade + Scale khi scroll ===
            Text("scrollTransition").font(.caption.bold())
            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(0..<20) { i in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.blue.gradient)
                            .frame(width: 150, height: 100)
                            .overlay(Text("\(i)").foregroundStyle(.white).font(.title))
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.5)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                    .rotation3DEffect(
                                        .degrees(phase.value * 25),
                                        axis: (x: 0, y: 1, z: 0)
                                    )
                            }
                            // phase.isIdentity: view đang ở vùng hiển thị chính
                            // phase.value: -1 → 0 → 1 (trái → giữa → phải)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal)
            }
            .scrollTargetBehavior(.viewAligned)
            .frame(height: 120)
            
            // === 7b. Vertical fade-in effect ===
            Text("Vertical fade-in").font(.caption.bold())
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(0..<30) { i in
                        HStack {
                            Circle()
                                .fill(.blue.gradient)
                                .frame(width: 48, height: 48)
                            VStack(alignment: .leading) {
                                Text("Item \(i)").font(.headline)
                                Text("Description").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(.gray.opacity(0.05), in: .rect(cornerRadius: 12))
                        .scrollTransition(.animated(.spring)) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .offset(y: phase.isIdentity ? 0 : 30)
                                .scaleEffect(phase.isIdentity ? 1 : 0.95)
                        }
                    }
                }
                .padding()
            }
            .frame(height: 250)
        }
    }
}
