//
//  VStackExample6View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct VStackExample6View: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header banner
                RoundedRectangle(cornerRadius: 16)
                    .fill(.blue.gradient)
                    .frame(height: 200)
                    .overlay(Text("Banner").foregroundStyle(.white).font(.title))
                
                // Content sections
                ForEach(0..<20) { i in
                    HStack {
                        Circle()
                            .fill(.gray.opacity(0.2))
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text("Item \(i + 1)").font(.headline)
                            Text("Mô tả ngắn").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(.background, in: .rect(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                }
            }
            .padding()
        }
    }
}

#Preview {
    VStackExample6View()
}
