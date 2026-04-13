//
//  FullScreenZStackView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct FullScreenZStack: View {
    var body: some View {
        ZStack {
            // Layer 0: Full-screen background (kể cả safe area)
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()   // Phủ kín màn hình kể cả notch, home bar
            
            // Layer 1: Content (TÔN TRỌNG safe area)
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
                
                Text("Full Screen")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                Text("Background tràn safe area\nContent tôn trọng safe area")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))
                
                Spacer()
                Spacer()
            }
            // KHÔNG .ignoresSafeArea() → content nằm trong safe area
        }
    }
}
