//
//  HStackExample10View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct SettingsRow1: View {
    let icon: String
    let iconColor: Color
    let title: String
    var detail: String? = nil
    var showChevron: Bool = true
    
    var body: some View {
        HStack(spacing: 14) {
            // Fixed: Icon box
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(iconColor, in: .rect(cornerRadius: 6))
            
            // Flexible: Title (được ưu tiên, co nếu cần)
            Text(title)
                .lineLimit(1)
                .layoutPriority(1)
            
            Spacer(minLength: 4)
            
            // Fixed: Detail text
            if let detail {
                Text(detail)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            
            // Fixed: Chevron
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct HStackExample10View: View {
    var body: some View {
        // === 10a. Navigation Bar Style ===
        
        HStack {
            Button { } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
            }
            
            Spacer()
            
            Text("Chi tiết")
                .font(.headline)
            
            Spacer()
            
            Button { } label: {
                Image(systemName: "ellipsis")
                    .font(.title3)
            }
        }
        .padding(.horizontal)
        .frame(height: 44) // Apple minimum tap target
        
        // === 10b. List Row — Icon + Text + Accessory ===
        VStack(spacing: 5) {
            SettingsRow1(icon: "wifi", iconColor: .blue, title: "Wi-Fi", detail: "Home Network")
            SettingsRow1(icon: "bluetooth", iconColor: .blue, title: "Bluetooth", detail: "On")
            SettingsRow1(icon: "bell.badge.fill", iconColor: .red, title: "Notifications")
            SettingsRow1(icon: "battery.100", iconColor: .green, title: "Battery", detail: "85%")
        }
        
        // === 10c. Price Display — Baseline Alignment ===
        
        PriceDisplay(currency: "$", amount: "9", decimal: ".99", period: "/mo")
            .padding()
        
        // === 10d. User Avatar + Info Row ===
        
        UserRow(name: "Huy", subtitle: "iOS Developer", isOnline: true)
        
        // === 10e. Stat Bar — Chia đều cột ===
        
        StatBar(stats: [
            ("Bài viết", "128"),
            ("Followers", "1.2K"),
            ("Following", "345"),
        ])
        .padding()
        
        // === 10f. Horizontal Scroll Cards (Carousel) ===
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Xu hướng")
                    .font(.title3.bold())
                Spacer()
                Button("Xem tất cả") { }
                    .font(.subheadline)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                // LazyHStack cho performance
                LazyHStack(spacing: 14) {
                    ForEach(0..<20) { i in
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue.gradient)
                                .frame(width: 200, height: 130)
                            
                            Text("Card \(i + 1)")
                                .font(.subheadline.weight(.medium))
                            Text("Mô tả ngắn")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 200)
                    }
                }
                .padding(.horizontal)
                .scrollTargetLayout() // iOS 17+: snap to card
            }
            .scrollTargetBehavior(.viewAligned) // iOS 17+: snap
        }
    }
}

#Preview {
    HStackExample10View()
}
