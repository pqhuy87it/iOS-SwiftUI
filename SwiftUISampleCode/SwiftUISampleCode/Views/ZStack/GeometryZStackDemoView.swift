//
//  GeometryZStackDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct GeometryZStackDemo: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background pattern
                Color.gray.opacity(0.05).ignoresSafeArea()
                
                // Positioned elements dựa trên container size
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: geo.size.width * 0.6)
                    .offset(
                        x: -geo.size.width * 0.2,
                        y: -geo.size.height * 0.15
                    )
                
                Circle()
                    .fill(.purple.opacity(0.1))
                    .frame(width: geo.size.width * 0.4)
                    .offset(
                        x: geo.size.width * 0.25,
                        y: geo.size.height * 0.2
                    )
                
                // Main content
                VStack(spacing: 16) {
                    Text("Responsive ZStack")
                        .font(.title.bold())
                    Text("Width: \(Int(geo.size.width)) × Height: \(Int(geo.size.height))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 250)
        .clipShape(.rect(cornerRadius: 20))
        .padding()
    }
}
