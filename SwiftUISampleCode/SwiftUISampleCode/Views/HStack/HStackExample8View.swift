//
//  HStackExample8View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct HStackExample8View: View {
    @State private var selectedTags: Set<String> = ["SwiftUI"]
    
    let tags = ["SwiftUI", "iOS", "Xcode", "WWDC", "Swift"]
    
    var body: some View {
        VStack(spacing: 24) {
            
            // === 8a. ForEach trong HStack ===
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    let isSelected = selectedTags.contains(tag)
                    Button {
                        if isSelected { selectedTags.remove(tag) }
                        else { selectedTags.insert(tag) }
                    } label: {
                        Text(tag)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isSelected ? .blue : .gray.opacity(0.15), in: .capsule)
                            .foregroundStyle(isSelected ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // === 8b. ForEach + Divider ===
            HStack {
                ForEach(Array(["🏠 Home", "🔍 Search", "👤 Profile"].enumerated()),
                        id: \.offset) { index, item in
                    if index > 0 {
                        Divider().frame(height: 20)
                    }
                    Text(item)
                        .font(.subheadline)
                }
            }
            .padding()
            .background(.gray.opacity(0.1), in: .rect(cornerRadius: 12))
            
            // === 8c. Conditional children ===
            HStack {
                Image(systemName: "person.circle")
                Text("Huy")
                
                if !selectedTags.isEmpty {
                    Spacer()
                    Text("\(selectedTags.count) tags")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    HStackExample8View()
}
