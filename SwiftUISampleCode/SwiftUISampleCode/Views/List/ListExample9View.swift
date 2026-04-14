//
//  ListExample9View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ListExample9View: View {
    var body: some View {
        Group {
            NavigationListDemo()
            
            MasterDetailDemo()
        }
    }
}

// === 9a. NavigationLink trong List ===
struct NavigationListDemo: View {
    let items = ["Swift", "Kotlin", "Dart", "Rust"]
    
    var body: some View {
        NavigationStack {
            List(items, id: \.self) { item in
                // NavigationLink tự thêm chevron ">"
                NavigationLink(item) {
                    DetailView(name: item)
                }
                
                // Hoặc custom label:
                // NavigationLink(value: item) {
                //     Label(item, systemImage: "chevron.left.forwardslash.chevron.right")
                // }
            }
            .navigationTitle("Ngôn ngữ")
            .navigationDestination(for: String.self) { item in
                DetailView(name: item)
            }
        }
    }
}

struct DetailView: View {
    let name: String
    var body: some View {
        Text("Chi tiết: \(name)")
            .navigationTitle(name)
    }
}

// === 9b. Master-Detail (iPad Split View) ===
struct MasterDetailDemo: View {
    let categories = ["Kết nối", "Âm thanh", "Màn hình", "Pin"]
    @State private var selected: String?
    
    var body: some View {
        NavigationSplitView {
            // Sidebar (Master)
            List(categories, id: \.self, selection: $selected) { cat in
                Label(cat, systemImage: "gear")
            }
            .navigationTitle("Cài đặt")
        } detail: {
            // Detail
            if let selected {
                Text("Chi tiết: \(selected)")
            } else {
                ContentUnavailableView(
                    "Chọn mục",
                    systemImage: "sidebar.left",
                    description: Text("Chọn 1 mục từ danh sách bên trái")
                )
            }
        }
    }
}
