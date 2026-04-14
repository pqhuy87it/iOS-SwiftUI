//
//  DirectDataListView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct DirectDataList: View {
    let items = ["Swift", "Kotlin", "Dart", "TypeScript"]
    
    var body: some View {
        // Shorthand: truyền data trực tiếp
        List(items, id: \.self) { item in
            Text(item)
        }
    }
}
