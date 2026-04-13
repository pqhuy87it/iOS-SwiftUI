//
//  RenderingModeDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct RenderingModeDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 5a. renderingMode — Template vs Original ===
            HStack(spacing: 20) {
                // .template: tint bằng foregroundStyle (như SF Symbol)
                Image(systemName: "heart.fill")
                    .renderingMode(.template)
                    .foregroundStyle(.red)
                    .font(.largeTitle)
                
                // .original: giữ màu gốc của asset
                Image(systemName: "heart.fill")
                    .renderingMode(.original)
                    .font(.largeTitle)
                // Multicolor symbol → hiện màu Apple thiết kế
            }
            
            // Với asset catalog images:
            // Image("logo")
            //     .renderingMode(.template)  // Tint theo foregroundStyle
            //     .foregroundStyle(.blue)
            //
            // Image("logo")
            //     .renderingMode(.original)  // Giữ màu gốc
            
            Divider()
            
            // === 5b. Color effects — Bộ lọc màu ===
            let sampleIcon = Image(systemName: "photo.artframe")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 60)
            
            HStack(spacing: 12) {
                // Gốc
                sampleIcon
                
                // Opacity
                sampleIcon.opacity(0.4)
                
                // Saturation
                sampleIcon.saturation(0)  // 0 = grayscale
                
                // Hue rotation
                sampleIcon.hueRotation(.degrees(120))
            }
            
            HStack(spacing: 12) {
                // Brightness
                sampleIcon.brightness(0.3)
                
                // Contrast
                sampleIcon.contrast(1.5)
                
                // Color multiply
                sampleIcon.colorMultiply(.blue)
                
                // Blur
                sampleIcon.blur(radius: 2)
            }
            
            Divider()
            
            // === 5c. Gradient foreground (SF Symbols) ===
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    .linearGradient(
                        colors: [.yellow, .orange, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .padding()
    }
}

#Preview {
    RenderingModeDemo()
}
