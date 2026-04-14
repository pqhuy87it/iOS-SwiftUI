//
//  ScrollPositionDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ScrollPositionDemo: View {
    @State private var position: Int?
    let items = Array(0..<200)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: hiển thị vị trí hiện tại
            HStack {
                Text("Đang xem: \(position.map { "#\($0)" } ?? "—")")
                    .font(.headline)
                
                Spacer()
                
                Button("Top") {
                    withAnimation { position = 0 }
                }
                Button("Middle") {
                    withAnimation { position = 100 }
                }
                Button("End") {
                    withAnimation { position = 199 }
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .padding()
            
            // ScrollView với position binding
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text("Item \(item)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                position == item
                                    ? Color.blue.opacity(0.15)
                                    : Color.gray.opacity(0.05),
                                in: .rect(cornerRadius: 8)
                            )
                    }
                }
                .scrollTargetLayout()  // ← BẮT BUỘC cho scrollPosition
                .padding(.horizontal)
            }
            .scrollPosition(id: $position) // ← 2-way binding
            // Scroll → position tự cập nhật
            // Set position → tự scroll đến item
        }
    }
}
