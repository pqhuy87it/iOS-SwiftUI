//
//  VStackExample8View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct VStackExample8View: View {
    var body: some View {
        Form {
            // === VStack trong Form: KHÔNG tạo row riêng ===
            // Tất cả children nằm CÙNG 1 row
            VStack(alignment: .leading) {
                Text("Title").font(.headline)
                Text("Subtitle").font(.caption).foregroundStyle(.secondary)
            }
            // → 1 row duy nhất chứa cả Title + Subtitle
            
            // === Group: KHÔNG ảnh hưởng layout ===
            // Chỉ nhóm views logic, mỗi child là 1 row riêng
            Group {
                Text("Row A") // → Row riêng
                Text("Row B") // → Row riêng
                Text("Row C") // → Row riêng
            }
            .font(.subheadline) // Modifier apply cho TẤT CẢ children
            
            // === Section: Tạo group có header/footer ===
            Section("Mục 1") {
                Text("Item 1") // → Row riêng trong section
                Text("Item 2") // → Row riêng trong section
            }
            
            // === VStack trong Section: khi cần custom layout trong row ===
            Section("Mục 2") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Phức tạp").font(.headline)
                    Text("Layout custom trong 1 row")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        Image(systemName: "star.fill").foregroundStyle(.yellow)
                        Text("4.8")
                    }
                }
            }
        }
    }
}

#Preview {
    VStackExample8View()
}
