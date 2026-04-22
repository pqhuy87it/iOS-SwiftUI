//
//  HStackExample7View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct HStackExample7View: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // ❌ Không fixedSize: text bị wrap/truncate
            HStack {
                Text("Username rất dài sẽ bị cắt ở đây")
                    .lineLimit(1)
                    .background(.blue.opacity(0.1))
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.blue)
            }
            .frame(width: 200)
            .border(.gray)
            
            // ✅ fixedSize(horizontal:vertical:)
            HStack {
                Text("Không bị cắt")
                    .fixedSize(horizontal: true, vertical: false)
                // horizontal: true → không bị co ngang (có thể tràn ra ngoài)
                // vertical: false → vẫn có thể co dọc bình thường
                    .background(.green.opacity(0.1))
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.blue)
            }
            .frame(width: 200)
            .border(.gray)
            
            // fixedSize trên TOÀN BỘ HStack
            HStack {
                Text("Fixed")
                Text("Size")
                Text("HStack")
            }
            .fixedSize() // Toàn bộ HStack không bị co
            .padding(8).background(.orange.opacity(0.1))
        }
        .padding()
    }
}

#Preview {
    HStackExample7View()
}
