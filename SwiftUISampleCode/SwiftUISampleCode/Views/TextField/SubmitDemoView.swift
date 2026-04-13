//
//  SubmitDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct SubmitDemo: View {
    @State private var searchQuery = ""
    @State private var results: [String] = []
    
    var body: some View {
        VStack(spacing: 16) {
            // === 5a. .onSubmit — Action khi nhấn Return ===
            TextField("Tìm kiếm...", text: $searchQuery)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    performSearch()
                }
            // User nhấn Return → gọi performSearch()
            
            // === 5b. .submitLabel — Đổi text nút Return ===
            // .done       → "Done"
            // .go         → "Go"
            // .send       → "Send"
            // .search     → "Search" (kính lúp)
            // .next       → "Next"
            // .continue   → "Continue"
            // .join       → "Join"
            // .return     → "Return" (default)
            // .route      → "Route"
            
            TextField("Tìm kiếm", text: $searchQuery)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
                .onSubmit { performSearch() }
            
            // Results
            ForEach(results, id: \.self) { item in
                Text(item)
            }
        }
        .padding()
    }
    
    func performSearch() {
        results = (1...5).map { "\(searchQuery) — kết quả \($0)" }
    }
}

