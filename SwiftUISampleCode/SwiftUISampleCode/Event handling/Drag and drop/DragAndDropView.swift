//
//  DragAndDropView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/01.
//

import SwiftUI

struct DragAndDropView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: DragDropInteractionsView()) {
                    MenuRow(detailViewName: "Drag Drop Interactions")
                }
                
            }
        }
        .navigationBarTitle("Drag and drop")
    }
}

#Preview {
    DragAndDropView()
}
