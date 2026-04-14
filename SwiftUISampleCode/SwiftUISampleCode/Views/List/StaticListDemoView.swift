//
//  StaticListDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct StaticListDemo: View {
    var body: some View {
        List {
            Text("Dòng 1")
            Text("Dòng 2")
            Text("Dòng 3")
            // Mỗi child view tự động thành 1 row
        }
    }
}
