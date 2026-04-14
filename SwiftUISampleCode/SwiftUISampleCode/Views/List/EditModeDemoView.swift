//
//  EditModeDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct EditModeDemo: View {
    @State private var items = ["Swift", "Kotlin", "Dart", "TypeScript", "Rust"]
    
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
            }
            // === 7a. Swipe-to-delete ===
            .onDelete(perform: deleteItems)
            
            // === 7b. Drag-to-reorder ===
            .onMove(perform: moveItems)
        }
        .navigationTitle("Ngôn ngữ")
        .toolbar {
            // EditButton toggle edit mode
            EditButton()
            // Edit mode: hiện delete buttons (−) và drag handles (≡)
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}
