//
//  ImageInitializersDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ImageInitializersDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 1a. Asset Catalog — Ảnh trong Assets.xcassets ===
            Image("hero-banner")
            // Tìm image set tên "hero-banner" trong Asset Catalog
            // Hỗ trợ @1x, @2x, @3x tự động theo device
            
            // === 1b. SF Symbols — System icons ===
            Image(systemName: "star.fill")
            // 5000+ icons, scale theo font, hỗ trợ weight + color
            
            // === 1c. UIImage → SwiftUI Image ===
            if let uiImage = UIImage(named: "photo") {
                Image(uiImage: uiImage)
            }
            
            // === 1d. CGImage ===
            // let cgImage: CGImage = ...
            // Image(cgImage, scale: 2.0, orientation: .up, label: Text("Photo"))
            
            // === 1e. Decorative — Ẩn khỏi Accessibility ===
            Image(decorative: "background-pattern")
            // VoiceOver BỎ QUA image này hoàn toàn
            // Dùng cho: background, decorative elements
            
            // === 1f. System image decorative ===
            Image(systemName: "circle.fill")
                .accessibilityHidden(true)
            // Tương đương decorative cho SF Symbols
        }
    }
}

#Preview {
    ImageInitializersDemo()
}
