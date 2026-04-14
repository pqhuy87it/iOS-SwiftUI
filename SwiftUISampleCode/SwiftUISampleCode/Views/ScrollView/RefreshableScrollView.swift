//
//  RefreshableScrollView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

@Observable
final class FeedViewModel {
    var items: [String] = (1...20).map { "Post \($0)" }
    
    func refresh() async {
        try? await Task.sleep(for: .seconds(1))
        items.insert("New Post \(Int.random(in: 100...999))", at: 0)
    }
}

struct RefreshableScrollView: View {
    @State private var vm = FeedViewModel()
    @State private var searchText = ""
    
    var filtered: [String] {
        guard !searchText.isEmpty else { return vm.items }
        return vm.items.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filtered, id: \.self) { item in
                    Text(item)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.gray.opacity(0.05), in: .rect(cornerRadius: 10))
                }
            }
            .padding()
        }
        .navigationTitle("Feed")
        
        // Pull-to-refresh: kéo xuống → spinner → async action
        .refreshable {
            await vm.refresh()
        }
        
        // Search bar tích hợp navigation
        .searchable(text: $searchText, prompt: "Tìm kiếm...")
    }
}
