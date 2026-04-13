//
//  ImageExample9View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ImageExample9View: View {
    var body: some View {
        List {
            // === 9a. Label — Icon + Text ===
            LabelDemo()
            
            // === 9b. Inline trong Text ===
            InlineImageDemo()
            
            // === 9d. Background / Overlay Patterns ===
            BackgroundImageDemo()
        }
    }
}

#Preview {
    ImageExample9View()
}
