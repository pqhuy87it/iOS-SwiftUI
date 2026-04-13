//
//  FABLayoutView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct FABLayout: View {
    @State private var items = (1...20).map { "Item \($0)" }
    
    var body: some View {
        // ZStack đặt FAB TRÊN List
        ZStack(alignment: .bottomTrailing) {
            // Layer 0: Main content
            List(items, id: \.self) { item in
                Text(item)
            }
            
            // Layer 1: Floating button
            Button {
                items.append("Item \(items.count + 1)")
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.blue.gradient, in: .circle)
                    .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
            }
            .padding(20)
        }
    }
}
