//
//  CombineGuideView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/02.
//

import SwiftUI

struct CombineGuideView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: CombineOperatorsView()) {
                    MenuRow(detailViewName: "Operators")
                }
                
                NavigationLink(destination: ObservableObjectView()) {
                    MenuRow(detailViewName: "ObservableObject")
                }
            }
        }
        .navigationBarTitle("Combine Tutorial")
    }
}

#Preview {
    CombineGuideView()
}
