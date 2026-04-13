//
//  ImageClippingDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ImageClippingDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 4a. clipShape — Cắt theo hình ===
            // Tròn
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .background(.blue.gradient)
                .clipShape(.circle)
            
            // Rounded Rectangle
            Image(systemName: "photo.artframe")
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 80)
                .background(.gray.opacity(0.2))
                .clipShape(.rect(cornerRadius: 16))
            
            // Capsule
            Image(systemName: "photo")
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 60)
                .background(.green.opacity(0.2))
                .clipShape(.capsule)
            
            // Custom shape
            Image(systemName: "photo")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .background(.orange.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // === 4b. overlay — Border / Badge ===
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .background(.blue.gradient)
                .clipShape(.circle)
                .overlay(
                    Circle()
                        .strokeBorder(.white, lineWidth: 3)
                )
                .overlay(alignment: .bottomTrailing) {
                    // Online badge
                    Circle()
                        .fill(.green)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                }
            
            // === 4c. shadow ===
            Image(systemName: "photo.artframe")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 80)
                .background(.gray.opacity(0.2))
                .clipShape(.rect(cornerRadius: 12))
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        }
        .padding()
    }
}

#Preview {
    ImageClippingDemo()
}
