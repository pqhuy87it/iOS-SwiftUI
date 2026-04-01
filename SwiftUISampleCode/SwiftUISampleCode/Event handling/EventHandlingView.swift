//
//  EventHandlingView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/01.
//

import SwiftUI

struct EventHandlingView: View {
    var body: some View {
        NavigationLink(destination: GesturesView()) {
            MenuRow(detailViewName: "Gestures")
        }
        
        NavigationLink(destination: InputEventsView()) {
            MenuRow(detailViewName: "Input events")
        }
        
        NavigationLink(destination: DragAndDropView()) {
            MenuRow(detailViewName: "Drag and drop")
        }
    }
}

#Preview {
    EventHandlingView()
}
