//
//  LayoutAdjustmentsView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/03/30.
//

import SwiftUI

struct LayoutAdjustmentsView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: AligningViews()) {
                    MenuRow(detailViewName: "Aligning views across stacks")
                }
            }
        }
        .navigationBarTitle("Liquid Adjustments")
    }
}

#Preview {
    LayoutAdjustmentsView()
}
