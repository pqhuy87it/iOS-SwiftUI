//
//  ListExample10View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ListExample10View: View {
    var body: some View {
        Group {
            ListAppearanceDemo()
            
            NoSeparatorList()
        }
    }
}

struct ListAppearanceDemo: View {
    var body: some View {
        List {
            Section("Appearance Demo") {
                Text("Row 1")
                Text("Row 2")
                Text("Row 3")
            }
        }
        // === 10a. Xoá default background (iOS 16+) ===
        .scrollContentBackground(.hidden)
        // Mặc định: List có background xám (grouped) hoặc trắng
        // .hidden → trong suốt, hiện background custom phía sau
        
        // === 10b. Custom background ===
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .top, endPoint: .bottom
            )
        )
        
        // === 10c. Row spacing (iOS 17+) ===
        .listRowSpacing(8)
        
        // === 10d. Section spacing (iOS 17+) ===
        .listSectionSpacing(.compact) // .default, .compact, custom CGFloat
    }
}

// === Ẩn tất cả separators ===
struct NoSeparatorList: View {
    let items = (1...10).map { "Item \($0)" }
    
    var body: some View {
        List(items, id: \.self) { item in
            Text(item)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }
}
