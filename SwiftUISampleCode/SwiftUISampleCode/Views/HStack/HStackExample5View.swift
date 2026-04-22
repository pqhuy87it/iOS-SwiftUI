//
//  HStackExample5View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct HStackExample5View: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 5a. 1 Spacer: đẩy sang 2 bên ===
            HStack {
                Text("Trái")
                Spacer()
                Text("Phải")
            }
            .padding().background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
            
            // === 5b. 2 Spacers: căn giữa phần tử giữa ===
            HStack {
                Spacer()
                Text("Giữa")
                Spacer()
            }
            .padding().background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
            
            // === 5c. Spacers không đều ===
            HStack {
                Text("1/3")
                Spacer()
                Text("2/3")
                Spacer()
                Spacer() // 2 Spacers bên phải → phần tử giữa lệch trái
            }
            .padding().background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
            
            // === 5d. Spacer(minLength:) — khoảng cách tối thiểu ===
            HStack {
                Text("Text dài dài dài")
                Spacer(minLength: 20) // Tối thiểu 20pt, có thể co hơn
                Text("Phải")
            }
            .padding().background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
            
            // === 5e. Spacer(minLength: 0) — có thể co hoàn toàn ===
            HStack {
                Text("Có thể")
                Spacer(minLength: 0) // Cho phép co về 0pt
                Text("sát nhau")
            }
            .padding().background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
        }
        .padding()
    }
}

#Preview {
    HStackExample5View()
}
