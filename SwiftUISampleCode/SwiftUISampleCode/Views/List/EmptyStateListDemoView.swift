//
//  EmptyStateListDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct EmptyStateListDemo: View {
    @State private var items: [String] = []
    @State private var searchText = ""
    
    var filteredItems: [String] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    // === iOS 17+: ContentUnavailableView ===
                    ContentUnavailableView {
                        Label("Chưa có mục nào", systemImage: "tray")
                    } description: {
                        Text("Tap + để thêm mục mới")
                    } actions: {
                        Button("Thêm mục đầu tiên") {
                            items.append("Mục mới")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if filteredItems.isEmpty {
                    // Search không tìm thấy
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredItems, id: \.self) { item in
                            Text(item)
                        }
                        .onDelete { items.remove(atOffsets: $0) }
                    }
                }
            }
            .navigationTitle("Danh sách")
            .searchable(text: $searchText)
            .toolbar {
                Button { items.append("Item \(items.count + 1)") } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
