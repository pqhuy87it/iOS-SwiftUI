//
//  TextFieldExample4View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct TextFieldExample4View: View {
    var body: some View {
        List {
            // === 4a. Boolean — Single field ===
            SingleFocusDemo()
            
            // === 4b. Enum — Multiple fields navigation ===
            MultiFocusDemo()
        }
    }
}

#Preview {
    TextFieldExample4View()
}
