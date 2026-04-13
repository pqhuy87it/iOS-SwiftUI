//
//  ViewTransitionDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ViewTransitionDemo: View {
    @State private var showDetail = false
    
    var body: some View {
        ZStack {
            // Cả 2 views nằm trong ZStack
            // SwiftUI animate transition khi chuyển đổi
            
            if !showDetail {
                VStack {
                    Text("Master View")
                        .font(.title)
                    Button("Show Detail") {
                        withAnimation(.spring(duration: 0.5)) {
                            showDetail = true
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                VStack {
                    Text("Detail View")
                        .font(.title)
                    Button("Back") {
                        withAnimation(.spring(duration: 0.5)) {
                            showDetail = false
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
    }
}
