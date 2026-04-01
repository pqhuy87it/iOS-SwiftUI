//
//  GesturesView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/01.
//

import SwiftUI

struct GesturesView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: GestureModifierView()) {
                    MenuRow(detailViewName: "Gesture modifiers")
                }
            }
        }
        .navigationBarTitle("Gestures")
    }
}

#Preview {
    GesturesView()
}
