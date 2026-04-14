//
//  ListExmaple7View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ListExmaple7View: View {
    var body: some View {
        Group {
            EditModeDemo()
            
            // === 7c. Custom Edit Actions mỗi row ===
            CustomEditDemo()
        }
    }
}

#Preview {
    ListExmaple7View()
}
