//
//  SelectionDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct SelectionDemo: View {
    let languages = ["Swift", "Kotlin", "Dart", "TypeScript", "Rust", "Go"]
    
    // === 6a. Single selection ===
    @State private var singleSelection: String?
    
    // === 6b. Multi selection ===
    @State private var multiSelection: Set<String> = []
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        List(languages, id: \.self, selection: $multiSelection) { lang in
            Text(lang)
        }
        .navigationTitle("Ngôn ngữ (\(multiSelection.count))")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
                // Tap Edit → vào edit mode → checkmarks xuất hiện
                // Tap row → toggle selection
            }
            
            if !multiSelection.isEmpty {
                ToolbarItem(placement: .bottomBar) {
                    Button("Xoá \(multiSelection.count) mục") {
                        // Xoá selected items
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .environment(\.editMode, $editMode)
    }
}
