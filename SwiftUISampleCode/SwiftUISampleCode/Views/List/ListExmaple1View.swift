//
//  ListExmaple1View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ListExmaple1View: View {
    var body: some View {
        Group {
            // === 1a. Static rows ===
            StaticListDemo()
            
            // === 1b. Dynamic rows — ForEach + Identifiable ===
            DynamicListDemo()
            
            // === 1c. Direct data binding — List(data) ===
            DirectDataList()
            
            // === 1d. Mixed static + dynamic ===
            MixedListDemo()
            
            // === 1e. Binding collection — Editable rows (iOS 15+) ===
            EditableListDemo()
        }
    }
}

#Preview {
    ListExmaple1View()
}
