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
//                Section(header: Text("Operators")) {
//                    CombineOperatorsView()
//                }
                NavigationLink(destination: CombineOperatorsView()) {
                    MenuRow(detailViewName: "Operators")
                }
            }
        }
        .navigationBarTitle("Combine Tutorial")
    }
}

#Preview {
    CombineGuideView()
}
