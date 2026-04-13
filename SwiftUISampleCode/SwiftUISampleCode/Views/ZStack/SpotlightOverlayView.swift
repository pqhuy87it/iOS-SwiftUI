//
//  SpotlightOverlayView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct SpotlightOverlay: View {
    let targetFrame: CGRect
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Layer 0: Dark overlay với "lỗ" spotlight
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .mask {
                    // Dùng eoFill để tạo cutout
                    Rectangle()
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(
                                    width: targetFrame.width + 16,
                                    height: targetFrame.height + 16
                                )
                                .position(
                                    x: targetFrame.midX,
                                    y: targetFrame.midY
                                )
                                .blendMode(.destinationOut)
                        }
                }
                .compositingGroup()
            
            // Layer 1: Tooltip
            VStack(spacing: 12) {
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                
                Button("Hiểu rồi", action: onDismiss)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
            .padding()
            .frame(maxWidth: 250)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
            .position(
                x: targetFrame.midX,
                y: targetFrame.maxY + 80
            )
        }
    }
}
