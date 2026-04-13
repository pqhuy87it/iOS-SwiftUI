//
//  LabelDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct LabelDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Label kết hợp icon + text
            Label("Settings", systemImage: "gearshape.fill")
            Label("Downloads", systemImage: "arrow.down.circle")
            
            // Custom Label
            Label {
                Text("Custom Label")
            } icon: {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
            
            // Label styles
            Label("Compact", systemImage: "star")
                .labelStyle(.titleAndIcon)  // Icon + Text
            Label("Icon Only", systemImage: "star")
                .labelStyle(.iconOnly)      // Chỉ icon
            Label("Title Only", systemImage: "star")
                .labelStyle(.titleOnly)     // Chỉ text
        }
    }
}

#Preview {
    LabelDemo()
}
