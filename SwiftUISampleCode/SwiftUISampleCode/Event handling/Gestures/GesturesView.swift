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
                
                NavigationLink(destination: SpatialTapGestureView()) {
                    MenuRow(detailViewName: "Spatial TapGesture")
                }
                
                NavigationLink(destination: ComposingGesturesView()) {
                    MenuRow(detailViewName: "Composing SwiftUI gestures")
                }
                
            }
        }
        .navigationBarTitle("Gestures")
    }
}

#Preview {
    GesturesView()
}
