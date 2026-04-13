//
//  ExpandableCardView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ExpandableCard: View {
    @State private var isExpanded = false
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            if !isExpanded {
                // Compact state
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.blue.gradient)
                        .matchedGeometryEffect(id: "image", in: animation)
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading) {
                        Text("SwiftUI Guide")
                            .font(.headline)
                            .matchedGeometryEffect(id: "title", in: animation)
                        Text("Tap to expand")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(.background, in: .rect(cornerRadius: 16))
                .shadow(radius: 5)
                
            } else {
                // Expanded state
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.blue.gradient)
                        .matchedGeometryEffect(id: "image", in: animation)
                        .frame(height: 200)
                    
                    Text("SwiftUI Guide")
                        .font(.title.bold())
                        .matchedGeometryEffect(id: "title", in: animation)
                    
                    Text("ZStack cho phép chồng views lên nhau, tạo ra các layouts phức tạp, overlays, modals, và animated transitions.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding()
                .background(.background)
            }
        }
        .onTapGesture {
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                isExpanded.toggle()
            }
        }
        .padding()
    }
}
