//
//  VStackExample2View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct AlignmentColumn: View {
    let title: String
    let alignment: HorizontalAlignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            
            VStack(alignment: alignment, spacing: 6) {
                Text("Ngắn")
                    .padding(6).background(.blue.opacity(0.2), in: .rect(cornerRadius: 4))
                Text("Dài hơn nhiều")
                    .padding(6).background(.green.opacity(0.2), in: .rect(cornerRadius: 4))
                Text("Vừa")
                    .padding(6).background(.orange.opacity(0.2), in: .rect(cornerRadius: 4))
            }
            .frame(width: 110)
            .padding(8)
            .background(.gray.opacity(0.08), in: .rect(cornerRadius: 8))
        }
    }
}


struct VStackExample2View: View {
    var body: some View {
        HStack(spacing: 10) {
            
            // .leading — căn TRÁI
            AlignmentColumn(title: ".leading", alignment: .leading)
            
            // .center — căn GIỮA (default)
            AlignmentColumn(title: ".center", alignment: .center)
            
            // .trailing — căn PHẢI
            AlignmentColumn(title: ".trailing", alignment: .trailing)
        }
        .padding(5)
    }
}

#Preview {
    VStackExample2View()
}
