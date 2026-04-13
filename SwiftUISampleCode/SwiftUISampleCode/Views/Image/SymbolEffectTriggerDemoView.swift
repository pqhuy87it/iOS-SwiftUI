//
//  SymbolEffectTriggerDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct SymbolEffectTriggerDemo: View {
    @State private var likeCount = 0
    @State private var isFavorite = false
    
    var body: some View {
        HStack(spacing: 24) {
            // Bounce khi trigger thay đổi
            Button {
                likeCount += 1
            } label: {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.title)
                    .symbolEffect(.bounce, value: likeCount)
            }
            
            // Replace: chuyển đổi mượt giữa 2 icons
            Button {
                isFavorite.toggle()
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title)
                    .foregroundStyle(isFavorite ? .red : .gray)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
    }
}

#Preview {
    SymbolEffectTriggerDemo()
}
