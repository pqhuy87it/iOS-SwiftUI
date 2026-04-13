//
//  ZStackExample9View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ZStackExample9View: View {
    var body: some View {
        List {
            // === 9a. View Transitions (if/else) ===
            ViewTransitionDemo()
            
            // === 9b. Expandable Card ===
            ExpandableCard()
        }
    }
}

#Preview {
    ZStackExample9View()
}
