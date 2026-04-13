//
//  OnSubmitScopeDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

// === .onSubmit scope — apply cho nhiều fields cùng lúc ===
struct OnSubmitScopeDemo: View {
    @State private var field1 = ""
    @State private var field2 = ""
    
    var body: some View {
        VStack {
            TextField("Field 1", text: $field1)
            TextField("Field 2", text: $field2)
        }
        .onSubmit {
            // Trigger cho CẢ HAI fields khi nhấn Return
            print("Submitted from either field")
        }
    }
}
