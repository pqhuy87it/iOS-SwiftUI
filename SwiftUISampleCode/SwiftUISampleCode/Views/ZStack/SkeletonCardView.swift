//
//  SkeletonCardView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct SkeletonCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Base skeleton shapes
            VStack(alignment: .leading, spacing: 12) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.15))
                    .frame(height: 160)
                
                // Title
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.15))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Subtitle
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.15))
                    .frame(width: 180, height: 12)
            }
            
            // Shimmer layer (gradient di chuyển)
            LinearGradient(
                colors: [.clear, .white.opacity(0.4), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: isAnimating ? 300 : -300)
            .mask(
                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 12).frame(height: 160)
                    RoundedRectangle(cornerRadius: 4).frame(height: 16)
                    RoundedRectangle(cornerRadius: 4).frame(width: 180, height: 12)
                }
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
        .padding()
    }
}
