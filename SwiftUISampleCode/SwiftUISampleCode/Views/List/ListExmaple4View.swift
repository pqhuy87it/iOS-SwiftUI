//
//  ListExmaple4View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ListExmaple4View: View {
    var body: some View {
        Group {
            RowStylingDemo()
            
            // === Apply row styling cho TẤT CẢ rows ===
            GlobalRowStyling()
        }
    }
}

#Preview {
    ListExmaple4View()
}
