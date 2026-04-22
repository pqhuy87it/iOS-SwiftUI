//
//  HStackExample1View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct HStackExample1View: View {
    var body: some View {
        VStack(spacing: 30) {
            
            // === 1a. Mặc định: alignment .center, spacing hệ thống ===
            HStack {
                Text("A")
                Text("B")
                Text("C")
            }
            .border(.gray)
            // spacing mặc định ≈ 8pt (tuỳ platform, Apple không document chính xác)
            // alignment mặc định: .center (căn giữa theo chiều dọc)
            
            // === 1b. Custom spacing ===
            HStack(spacing: 20) {
                Text("Cách")
                Text("nhau")
                Text("20pt")
            }
            .border(.gray)
            
            // === 1c. Spacing = 0 ===
            HStack(spacing: 0) {
                Text("Không")
                    .padding(8).background(.blue.opacity(0.2))
                Text("có")
                    .padding(8).background(.green.opacity(0.2))
                Text("khoảng cách")
                    .padding(8).background(.orange.opacity(0.2))
            }
            
            // === 1d. Custom alignment ===
            HStack(alignment: .top) {
                Text("Ngắn")
                    .padding().background(.blue.opacity(0.2))
                Text("Dòng\nnày\ncao\nhơn")
                    .padding().background(.green.opacity(0.2))
                Text("Vừa")
                    .padding().background(.orange.opacity(0.2))
            }
        }
        .padding()
    }
}

#Preview {
    HStackExample1View()
}
