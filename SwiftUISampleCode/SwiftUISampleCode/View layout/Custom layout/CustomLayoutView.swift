//
//  CustomLayoutView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/03/31.
//

import SwiftUI

struct CustomLayoutView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: ComposingCustomLayoutView()) {
                    MenuRow(detailViewName: "Composing custom layouts")
                }
            }
        }
        .navigationBarTitle("Custom layout views")
    }
}

#Preview {
    CustomLayoutView()
}
