//
//  HStackExample11View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct HStackExample11View: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        // === 11a. ViewThatFits — Tự chọn layout phù hợp (iOS 16+) ===
        
        ViewThatFits {
            // Thử HStack trước (nếu đủ chỗ)
            HStack(spacing: 16) {
                Image(systemName: "star.fill").font(.title)
                Text("Tiêu đề chính")
                    .font(.headline)
                Text("Mô tả dài cho phiên bản ngang khi màn hình đủ rộng")
                    .foregroundStyle(.secondary)
            }
            
            // Nếu HStack không vừa → fallback VStack
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "star.fill").font(.title)
                    Text("Tiêu đề chính").font(.headline)
                }
                Text("Mô tả dài cho phiên bản dọc khi màn hình hẹp")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        
        VStack(spacing: 5) {
            let layout = sizeClass == .compact
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(spacing: 20))
            
            layout {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nguyễn Văn Huy")
                        .font(.title2.bold())
                    Text("Senior iOS Developer")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button("Follow") { }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            // Compact (iPhone Portrait): VStack layout
            // Regular (iPad, Landscape): HStack layout
            // Transition animated tự động!
        }
        
        // === 11c. GeometryReader — Responsive breakpoint ===
    }
}

#Preview {
    HStackExample11View()
}
