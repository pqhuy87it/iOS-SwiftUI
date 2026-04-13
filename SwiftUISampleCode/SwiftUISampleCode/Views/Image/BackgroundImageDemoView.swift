//
//  BackgroundImageDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct BackgroundImageDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            // Full-bleed background image
            Text("Hello World")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 200)
                .background {
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .scaledToFill()
                        .overlay(Color.black.opacity(0.4))
                }
                .clipShape(.rect(cornerRadius: 16))
            
            // Overlay icon badge
            Image(systemName: "photo")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .background(.gray.opacity(0.1))
                .clipShape(.rect(cornerRadius: 12))
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white, .green)
                        .offset(x: 6, y: -6)
                }
        }
        .padding()
    }
}

#Preview {
    BackgroundImageDemo()
}
