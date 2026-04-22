//
//  VStackExample10View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct VStackExample10View: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var isVertical = true
    
    let items = ["SwiftUI", "Combine", "Swift Data", "Swift Testing"]
    
    var body: some View {
        // === 10a. ViewThatFits (iOS 16+) ===
        ViewThatFits {
            // Thử HStack trước
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    TagChip(text: item)
                }
            }
            
            // Không vừa → VStack
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    TagChip(text: item)
                }
            }
        }
        .padding()
        
        // === 10b. AnyLayout — Animated transition (iOS 16+) ===
        VStack(spacing: 24) {
            // Toggle layout
            Toggle("Vertical Layout", isOn: $isVertical.animation(.spring))
            
            let layout = isVertical
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
            
            layout {
                ForEach(0..<3) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .fill([Color.blue, .green, .orange][i].gradient)
                        .frame(width: isVertical ? nil : 80,
                               height: isVertical ? 60 : 80)
                        .frame(maxWidth: isVertical ? .infinity : nil)
                        .overlay(Text("\(i + 1)").foregroundStyle(.white).font(.headline))
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding()
        
        // === 10c. Dynamic Type / Size Class Adaptation ===
        // Compact + large text → VStack
        // Regular hoặc normal text → HStack
        let useVertical = hSizeClass == .compact || typeSize >= .accessibility1
        
        let layout = useVertical
        ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
        : AnyLayout(HStackLayout(spacing: 20))
        
        layout {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Nguyễn Văn Huy").font(.headline)
                Text("Senior iOS Developer").foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    VStackExample10View()
}
