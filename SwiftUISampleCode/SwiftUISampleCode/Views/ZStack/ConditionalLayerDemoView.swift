//
//  ConditionalLayerDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ConditionalLayerDemo: View {
    @State private var showOverlay = false
    @State private var showBanner = false
    
    var body: some View {
        ZStack {
            // === Layer 0: Main content ===
            VStack(spacing: 20) {
                Text("Nội dung chính")
                    .font(.title2)
                
                Button("Toggle Overlay") {
                    withAnimation(.spring) { showOverlay.toggle() }
                }
                
                Button("Toggle Banner") {
                    withAnimation(.easeInOut) { showBanner.toggle() }
                }
            }
            
            // === Layer 1: Dimming overlay (conditional) ===
            if showOverlay {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring) { showOverlay = false }
                    }
                    .transition(.opacity)
                
                // === Layer 2: Modal card ===
                VStack(spacing: 16) {
                    Text("Modal Content")
                        .font(.headline)
                    Text("Tap nền tối để đóng")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("Đóng") {
                        withAnimation(.spring) { showOverlay = false }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(24)
                .background(.background, in: .rect(cornerRadius: 20))
                .shadow(radius: 20)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                .padding(32)
            }
            
            // === Top banner (conditional) ===
            if showBanner {
                VStack {
                    Text("✅ Thao tác thành công!")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.green.gradient, in: .rect(cornerRadius: 12))
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
