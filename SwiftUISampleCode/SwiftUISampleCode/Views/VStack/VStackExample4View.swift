//
//  VStackExample4View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct VStackExample4View: View {
    var body: some View {
        VStack(spacing: 0) {
            
            // Fixed: lấy đúng intrinsic height
            Text("Header cố định")
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.opacity(0.15))
            
            // Flexible: chiếm TẤT CẢ height còn lại
            Color.green.opacity(0.1)
                .overlay(Text("Body linh hoạt\n(chiếm phần còn lại)"))
            
            // Fixed
            Text("Footer cố định")
                .frame(maxWidth: .infinity)
                .padding()
                .background(.orange.opacity(0.15))
        }
        .frame(height: 350)
        .border(.gray)
    }
}

#Preview {
    VStackExample4View()
}
