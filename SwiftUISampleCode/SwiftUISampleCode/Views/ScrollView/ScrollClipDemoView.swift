//
//  ScrollClipDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ScrollClipDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // === 9a. Mặc định: content bị clip tại ScrollView bounds ===
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(0..<10) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue.gradient)
                            .frame(width: 120, height: 80)
                            .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                        // ⚠️ Shadow bị CẮT ở mép ScrollView!
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 100)
            
            // === 9b. scrollClipDisabled: cho phép tràn (iOS 17+) ===
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(0..<10) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.green.gradient)
                            .frame(width: 120, height: 80)
                            .shadow(color: .green.opacity(0.3), radius: 10, y: 5)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16) // Extra padding cho shadow
            }
            .scrollClipDisabled()  // Shadow KHÔNG bị cắt
            .frame(height: 130)
        }
    }
}
