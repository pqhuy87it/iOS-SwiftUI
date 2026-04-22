//
//  HStackExample4View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct HStackExample4View: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 4a. Fixed vs Fixed: chia đều khoảng trống ===
            HStack {
                Text("Fixed")
                    .padding(8).background(.blue.opacity(0.2))
                Text("Fixed")
                    .padding(8).background(.green.opacity(0.2))
            }
            .frame(maxWidth: .infinity)
            .border(.gray)
            
            // === 4b. Fixed + Spacer (flexible): Spacer chiếm hết ===
            HStack {
                Text("Trái")
                    .padding(8).background(.blue.opacity(0.2))
                Spacer() // ← Flexible: chiếm toàn bộ còn lại
                Text("Phải")
                    .padding(8).background(.green.opacity(0.2))
            }
            .border(.gray)
            
            // === 4c. Nhiều flexible children: chia ĐỀU ===
            HStack {
                Text("A")
                    .frame(maxWidth: .infinity) // Flexible
                    .padding(8).background(.blue.opacity(0.2))
                Text("B")
                    .frame(maxWidth: .infinity) // Flexible
                    .padding(8).background(.green.opacity(0.2))
                Text("CCCCC")
                    .frame(maxWidth: .infinity) // Flexible
                    .padding(8).background(.orange.opacity(0.2))
            }
            .border(.gray)
            // Mỗi child cùng maxWidth: .infinity → chia BẰNG NHAU
            
            // === 4d. Fixed width children ===
            HStack {
                Text("80pt")
                    .frame(width: 80)
                    .padding(8).background(.blue.opacity(0.2))
                Text("Còn lại")
                    .frame(maxWidth: .infinity)
                    .padding(8).background(.green.opacity(0.2))
                Text("60pt")
                    .frame(width: 60)
                    .padding(8).background(.orange.opacity(0.2))
            }
            .border(.gray)
        }
        .padding()
    }
}

#Preview {
    HStackExample4View()
}
