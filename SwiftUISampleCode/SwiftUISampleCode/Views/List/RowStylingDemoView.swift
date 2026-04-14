//
//  RowStylingDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct RowStylingDemo: View {
    var body: some View {
        List {
            // === 4a. listRowBackground — Background tuỳ chỉnh ===
            Text("Custom background")
                .listRowBackground(Color.blue.opacity(0.1))
            
            // === 4b. listRowSeparator — Ẩn/Hiện separator ===
            Text("Không có separator dưới")
                .listRowSeparator(.hidden)
            
            Text("Separator bình thường")
            
            // === 4c. listRowSeparatorTint ===
            Text("Separator màu đỏ")
                .listRowSeparatorTint(.red)
            
            // === 4d. listRowInsets — Custom padding ===
            Text("Insets tuỳ chỉnh")
                .listRowInsets(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 16))
            
            // === 4e. listItemTint — Tint cho row ===
            Label("Tinted row", systemImage: "star.fill")
                .listItemTint(.orange)
            
            // === 4f. Ẩn separator toàn bộ List ===
            // Đặt modifier trên List thay vì từng row:
        }
        .listSectionSeparator(.hidden) // Ẩn separator giữa sections
    }
}
