//
//  TextFieldExample5View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct TextFieldExample5View: View {
    var body: some View {
        List {
            SubmitDemo()
            
            // === .onSubmit scope — apply cho nhiều fields cùng lúc ===
            OnSubmitScopeDemo()
        }
    }
}

#Preview {
    TextFieldExample5View()
}
