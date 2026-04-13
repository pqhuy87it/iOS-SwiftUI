//
//  InlineImageDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct InlineImageDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // SF Symbol inline
            Text("Trạng thái: \(Image(systemName: "checkmark.circle.fill")) OK")
                .foregroundStyle(.green)
            
            // Nhiều icons inline
            Text("\(Image(systemName: "clock")) 5 phút  \(Image(systemName: "eye")) 1.2K")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    InlineImageDemo()
}
