//
//  AsyncImageDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct AsyncImageDemo: View {
    let url = URL(string: "https://picsum.photos/400/300")!
    
    var body: some View {
        VStack(spacing: 24) {
            
            // === 6a. Đơn giản nhất ===
            AsyncImage(url: url)
            // Tự hiện placeholder (gray) → load → hiện ảnh
            // ⚠️ Không resizable mặc định, hiện kích thước gốc
            
            // === 6b. Với scale ===
            AsyncImage(url: url, scale: 2.0)
            // Scale 2x → ảnh hiện nhỏ hơn (Retina)
            
            // === 6c. Custom placeholder + loaded + error ===
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    // Đang loading
                    ZStack {
                        Color.gray.opacity(0.1)
                        ProgressView()
                    }
                    
                case .success(let image):
                    // Load thành công
                    image
                        .resizable()
                        .scaledToFill()
                        .transition(.opacity.combined(with: .scale))
                    
                case .failure(let error):
                    // Lỗi
                    VStack(spacing: 8) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text("Không tải được ảnh")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 200, height: 150)
            .clipShape(.rect(cornerRadius: 12))
            
            // === 6d. Compact syntax với content + placeholder ===
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                // Skeleton loading
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.15))
                    .overlay(ProgressView())
            }
            .frame(width: 200, height: 150)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
}

#Preview {
    AsyncImageDemo()
}
