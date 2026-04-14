//
//  RefreshSearchDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

@Observable
final class ItemsViewModel {
    var items: [String] = (1...20).map { "Item \($0)" }
    var isLoading = false
    
    func refresh() async {
        isLoading = true
        try? await Task.sleep(for: .seconds(1.5))
        items.append("New Item \(items.count + 1)")
        isLoading = false
    }
    
    func filteredItems(query: String) -> [String] {
        guard !query.isEmpty else { return items }
        return items.filter { $0.localizedCaseInsensitiveContains(query) }
    }
}

struct RefreshSearchDemo: View {
    @State private var viewModel = ItemsViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredItems(query: searchText), id: \.self) { item in
                    Text(item)
                }
            }
            .navigationTitle("Items (\(viewModel.items.count))")
            
            // === 8a. Pull-to-Refresh ===
            .refreshable {
                // async context — List tự hiện spinner
                await viewModel.refresh()
                // Spinner tự ẩn khi async function return
            }
            
            // === 8b. Search Bar ===
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Tìm kiếm items..."
            )
            
            // === 8c. Search suggestions (iOS 16+) ===
            .searchSuggestions {
                if searchText.isEmpty {
                    Text("🔥 Item 1").searchCompletion("Item 1")
                    Text("⭐ Item 5").searchCompletion("Item 5")
                }
            }
        }
    }
}
