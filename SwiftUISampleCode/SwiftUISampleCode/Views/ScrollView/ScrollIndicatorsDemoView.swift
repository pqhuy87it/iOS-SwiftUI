//
//  ScrollIndicatorsDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ScrollIndicatorsDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            // === 2a. Legacy: showsIndicators parameter ===
            ScrollView(showsIndicators: false) {
                content
            }
            .frame(height: 100)
            
            // === 2b. Modern: .scrollIndicators() (iOS 16+) ===
            ScrollView {
                content
            }
            .scrollIndicators(.hidden)     // Luôn ẩn
            // .scrollIndicators(.visible)  // Luôn hiện
            // .scrollIndicators(.automatic) // Hệ thống quyết định
            // .scrollIndicators(.never)     // Không bao giờ hiện
            .frame(height: 100)
            
            // === 2c. Ẩn chỉ 1 trục ===
            ScrollView([.horizontal, .vertical]) {
                content
            }
            .scrollIndicators(.hidden, axes: .horizontal)
            // Ẩn indicator ngang, giữ indicator dọc
            .frame(height: 100)
        }
    }
    
    private var content: some View {
        VStack(spacing: 8) {
            ForEach(0..<30) { i in
                Text("Row \(i)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
        }
    }
}
