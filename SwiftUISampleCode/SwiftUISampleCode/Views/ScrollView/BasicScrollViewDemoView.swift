//
//  BasicScrollViewDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct BasicScrollViewDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 1a. Vertical scroll (default) ===
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<30) { i in
                        Text("Row \(i)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .frame(height: 200)
            
            // === 1b. Horizontal scroll ===
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(0..<20) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue.gradient)
                            .frame(width: 120, height: 80)
                            .overlay(Text("\(i)").foregroundStyle(.white))
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 100)
            
            // === 1c. Both axes (ít dùng) ===
            ScrollView([.horizontal, .vertical]) {
                VStack(spacing: 8) {
                    ForEach(0..<20) { row in
                        HStack(spacing: 8) {
                            ForEach(0..<20) { col in
                                Text("\(row),\(col)")
                                    .font(.caption2)
                                    .frame(width: 50, height: 30)
                                    .background(.gray.opacity(0.1))
                            }
                        }
                    }
                }
                .padding()
            }
            .frame(height: 150)
        }
    }
}
