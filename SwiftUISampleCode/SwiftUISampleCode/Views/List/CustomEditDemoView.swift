//
//  CustomEditDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct CustomEditDemo: View {
    @State private var items = ["A", "B", "C"]
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                HStack {
                    Text(item)
                    Spacer()
                    
                    // Chỉ hiện trong edit mode
                    if editMode?.wrappedValue == .active {
                        Button {
                            // Custom action
                        } label: {
                            Image(systemName: "pencil.circle")
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .onDelete { items.remove(atOffsets: $0) }
            .onMove { items.move(fromOffsets: $0, toOffset: $1) }
        }
        .toolbar { EditButton() }
    }
}
