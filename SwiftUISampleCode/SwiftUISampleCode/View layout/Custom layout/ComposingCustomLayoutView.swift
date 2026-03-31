//
//  ComposingCustomLayoutView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/03/31.
//

import SwiftUI

struct ComposingCustomLayoutView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: EqualWidthExampleView()) {
                    MenuRow(detailViewName: "MyEqualWidthHStack layout")
                }
                
                NavigationLink(destination: EqualWidthVStackExampleView()) {
                    MenuRow(detailViewName: "MyEqualWidthVStack layout")
                }
                
                NavigationLink(destination: RadialLayoutExampleView()) {
                    MenuRow(detailViewName: "MyRadialLayout layout")
                }
            }
        }
        .navigationBarTitle("Composing layouts")
    }
}

#Preview {
    ComposingCustomLayoutView()
}
