//
//  TabViews.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/09.
//

import SwiftUI

struct TabViews: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: TabViewExample1()) {
                    MenuRow(detailViewName: "Example 1")
                }
            }
        }
        .navigationBarTitle("TabView")
    }
}

#Preview {
    TabViews()
}
