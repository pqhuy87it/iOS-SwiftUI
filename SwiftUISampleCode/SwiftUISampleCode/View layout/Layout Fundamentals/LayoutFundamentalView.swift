//
//  LayoutFundamentalView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/03/31.
//

import SwiftUI

struct LayoutFundamentalView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: LazyStackViews()) {
                    MenuRow(detailViewName: "Lazy stack views")
                }
            }
        }
        .navigationBarTitle("Layout fundamentals")
    }
}

#Preview {
    LayoutFundamentalView()
}
