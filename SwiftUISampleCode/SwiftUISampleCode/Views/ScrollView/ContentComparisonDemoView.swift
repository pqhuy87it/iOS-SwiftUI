//
//  ContentComparisonDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ContentComparisonDemo: View {
    let items = (0..<1000).map { "Item \($0)" }
    
    var body: some View {
        TabView {
            // === 3a. ScrollView + VStack: EAGER ===
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.gray.opacity(0.05))
                    }
                }
            }
            .tabItem { Text("VStack") }
            // TẤT CẢ 1000 views init NGAY → chậm, tốn memory
            // ✅ Dùng khi: < 30-50 items, cần exact total height
            
            // === 3b. ScrollView + LazyVStack: LAZY ===
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.gray.opacity(0.05))
                    }
                }
            }
            .tabItem { Text("LazyVStack") }
            // Chỉ init visible + buffer → nhanh, tiết kiệm memory
            // ⚠️ KHÔNG có cell reuse → memory tăng dần khi scroll
            // ✅ Dùng khi: 50-10K items, custom layout
            
            // === 3c. List: REUSE ===
            List(items, id: \.self) { item in
                Text(item)
            }
            .tabItem { Text("List") }
            // Cell reuse → memory ỔN ĐỊNH cho 100K+ items
            // ✅ Dùng khi: data lists, cần swipe/edit/selection
        }
    }
}
