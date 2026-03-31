//
//  ViewlayoutView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/03/30.
//

import SwiftUI

struct ViewlayoutView: View {
    var body: some View {
        NavigationLink(destination: LayoutAdjustmentsView()) {
            MenuRow(detailViewName: "Liquid Adjustments")
        }
        
        NavigationLink(destination: ListView()) {
            MenuRow(detailViewName: "Lists")
        }
        
        NavigationLink(destination: CustomLayoutView()) {
            MenuRow(detailViewName: "Custom layout")
        }
    }
}

#Preview {
    ViewlayoutView()
}
