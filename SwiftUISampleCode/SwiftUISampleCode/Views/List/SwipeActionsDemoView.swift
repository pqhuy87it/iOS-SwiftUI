//
//  SwipeActionsDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct SwipeActionsDemo: View {
    @State private var items = [
        Task1(title: "Mua sữa", isCompleted: false),
        Task1(title: "Code review", isCompleted: true),
        Task1(title: "Tập gym", isCompleted: false),
        Task1(title: "Đọc sách", isCompleted: false),
    ]
    
    @State private var pinnedIDs: Set<UUID> = []
    
    var body: some View {
        List {
            ForEach(items) { task in
                HStack {
                    if pinnedIDs.contains(task.id) {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                    Spacer()
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.green)
                    }
                }
                // === Trailing swipe (mặc định: phải → trái) ===
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    // Nút đầu tiên = full swipe action
                    Button(role: .destructive) {
                        withAnimation {
                            items.removeAll { $0.id == task.id }
                        }
                    } label: {
                        Label("Xoá", systemImage: "trash")
                    }
                    // role: .destructive → background đỏ tự động
                    
                    Button {
                        // Archive action
                    } label: {
                        Label("Lưu trữ", systemImage: "archivebox")
                    }
                    .tint(.blue)
                }
                // === Leading swipe (trái → phải) ===
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        if pinnedIDs.contains(task.id) {
                            pinnedIDs.remove(task.id)
                        } else {
                            pinnedIDs.insert(task.id)
                        }
                    } label: {
                        Label(
                            pinnedIDs.contains(task.id) ? "Bỏ ghim" : "Ghim",
                            systemImage: pinnedIDs.contains(task.id) ? "pin.slash" : "pin"
                        )
                    }
                    .tint(.orange)
                }
            }
        }
    }
}
