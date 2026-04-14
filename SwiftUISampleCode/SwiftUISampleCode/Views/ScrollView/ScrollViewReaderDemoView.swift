//
//  ScrollViewReaderDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ScrollViewReaderDemo: View {
    let items = (0..<100).map { "Item \($0)" }
    @State private var searchID: Int?
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                // Control bar
                HStack {
                    Button("⬆ Top") {
                        withAnimation(.spring) {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                    
                    Button("⬇ Bottom") {
                        withAnimation(.spring) {
                            proxy.scrollTo(99, anchor: .bottom)
                        }
                    }
                    
                    Button("→ #50") {
                        withAnimation(.spring) {
                            proxy.scrollTo(50, anchor: .center)
                        }
                    }
                }
                .buttonStyle(.bordered)
                .padding()
                
                // Scrollable content
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(0..<100) { i in
                            Text("Item \(i)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    i == searchID
                                        ? Color.yellow.opacity(0.3)
                                        : Color.gray.opacity(0.05),
                                    in: .rect(cornerRadius: 8)
                                )
                                .id(i) // ← BẮT BUỘC: scrollTo cần id
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
