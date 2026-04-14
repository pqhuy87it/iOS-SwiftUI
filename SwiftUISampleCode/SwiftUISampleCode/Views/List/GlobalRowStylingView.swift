//
//  GlobalRowStylingView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct GlobalRowStyling: View {
    let items = (1...10).map { "Item \($0)" }
    
    var body: some View {
        List(items, id: \.self) { item in
            Text(item)
        }
        .listRowSpacing(8)                // iOS 17+: khoảng cách giữa rows
        .listSectionSpacing(16)           // iOS 17+: khoảng cách giữa sections
        .listRowSeparator(.hidden)        // Ẩn separator toàn bộ
        .scrollContentBackground(.hidden) // iOS 16+: xoá default background
        .background(Color.gray.opacity(0.05))
    }
}
