//
//  MixedListDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct MixedListDemo: View {
    let recents = ["SwiftUI", "Combine"]
    let favorites = ["Swift", "Dart", "Rust"]
    
    var body: some View {
        List {
            // Static row
            Text("Tất cả ngôn ngữ")
                .font(.headline)
            
            // Dynamic section
            Section("Gần đây") {
                ForEach(recents, id: \.self) { item in
                    Text(item)
                }
            }
            
            Section("Yêu thích") {
                ForEach(favorites, id: \.self) { item in
                    Text(item)
                }
            }
        }
    }
}
