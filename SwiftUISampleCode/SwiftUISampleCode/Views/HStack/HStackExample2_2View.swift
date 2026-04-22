//
//  HStackExample2_2View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct HStackExample2_2View: View {
    var body: some View {
        VStack(spacing: 32) {
            // ❌ .center: text lệch, đọc khó
            HStack(alignment: .center, spacing: 4) {
                Text("$")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Text("99")
                    .font(.system(size: 48, weight: .bold))
                Text(".99")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("/tháng")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.gray.opacity(0.1), in: .rect(cornerRadius: 12))
            
            // ✅ .firstTextBaseline: text thẳng hàng hoàn hảo
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Text("99")
                    .font(.system(size: 48, weight: .bold))
                Text(".99")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("/tháng")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.gray.opacity(0.1), in: .rect(cornerRadius: 12))
        }
    }
}

#Preview {
    HStackExample2_2View()
}
