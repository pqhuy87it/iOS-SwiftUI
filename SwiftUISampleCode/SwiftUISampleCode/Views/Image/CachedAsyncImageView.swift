//
//  CachedAsyncImageView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct CachedAsyncImage: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    
    // Simple in-memory cache (production: dùng NSCache hoặc 3rd party)
    @State private var phase: AsyncImagePhase = .empty
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholder
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            case .failure:
                errorView
            @unknown default:
                placeholder
            }
        }
    }
    
    private var placeholder: some View {
        ZStack {
            Color.gray.opacity(0.1)
            ProgressView()
                .controlSize(.small)
        }
    }
    
    private var errorView: some View {
        ZStack {
            Color.gray.opacity(0.1)
            VStack(spacing: 6) {
                Image(systemName: "photo")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {
    CachedAsyncImage(url: URL(string: "https://zeerawireless.com/cdn/shop/articles/2026_wwdc_600x600_crop_center.jpg?v=1764351974"), contentMode: .fill)
}
