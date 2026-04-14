//
//  ListStyleDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ListStyleDemo: View {
    var body: some View {
        // Thay .listStyle() để xem từng style:
        
        List {
            Section("Section 1") {
                Text("Row A")
                Text("Row B")
            }
            Section("Section 2") {
                Text("Row C")
                Text("Row D")
            }
        }
        .listStyle(.insetGrouped) // ← Thay đổi ở đây
    }
}
