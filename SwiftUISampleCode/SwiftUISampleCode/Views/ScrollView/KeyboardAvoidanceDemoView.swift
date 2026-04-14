//
//  KeyboardAvoidanceDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct KeyboardAvoidanceDemo: View {
    @State private var text = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<10) { i in
                    Text("Row \(i)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.gray.opacity(0.05))
                }
                
                TextField("Nhập text...", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                // ScrollView TỰ ĐỘNG scroll lên khi keyboard xuất hiện
                // để TextField không bị che (iOS 14+)
            }
            .padding()
        }
        // Nếu cần disable keyboard avoidance:
        // .ignoresSafeArea(.keyboard)
        
        // Nếu cần scroll safe area:
        .safeAreaInset(edge: .bottom) {
            // View cố định ở bottom, content scroll phía trên
            HStack {
                TextField("Message...", text: $text)
                    .textFieldStyle(.roundedBorder)
                Button("Send") { }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}
