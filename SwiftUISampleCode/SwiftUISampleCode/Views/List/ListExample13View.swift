//
//  ListExample13View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ListExample13View: View {
    var body: some View {
        Group {
            PaginatedListDemo()
        }
    }
}

@Observable
final class PaginatedViewModel {
    var items: [String] = []
    var isLoading = false
    var hasMore = true
    private var page = 0
    
    func loadInitial() async {
        guard items.isEmpty else { return }
        await loadNext()
    }
    
    func loadNext() async {
        guard !isLoading, hasMore else { return }
        isLoading = true
        defer { isLoading = false }
        
        try? await Task.sleep(for: .seconds(0.5))
        let newItems = (1...20).map { "Page \(page + 1) - Item \($0)" }
        items.append(contentsOf: newItems)
        page += 1
        hasMore = page < 5
    }
    
    func shouldLoadMore(item: String) -> Bool {
        guard let index = items.firstIndex(of: item) else { return false }
        return index >= items.count - 5
    }
}

struct PaginatedListDemo: View {
    @State private var viewModel = PaginatedViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.items, id: \.self) { item in
                Text(item)
                    .onAppear {
                        if viewModel.shouldLoadMore(item: item) {
                            Task { await viewModel.loadNext() }
                        }
                    }
            }
            
            // Loading indicator
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            
            if !viewModel.hasMore {
                Text("— Hết danh sách —")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            }
        }
        .task { await viewModel.loadInitial() }
    }
}
