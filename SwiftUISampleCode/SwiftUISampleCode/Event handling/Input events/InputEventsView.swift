//
//  InputEventsView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/01.
//

import SwiftUI

struct InputEventsView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: AllowsTighteningView()) {
                    MenuRow(detailViewName: "allowsTightening")
                }
                
            }
        }
        .navigationBarTitle("Input events")
    }
}

#Preview {
    InputEventsView()
}
