//
//  ListExample12View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ListExample12View: View {
    var body: some View {
        List {
            NavigationLink(destination: ScrollPositionList()) {
                MenuRow(detailViewName: "Scroll position")
            }
            
            NavigationLink(destination: ScrollViewReaderList()) {
                MenuRow(detailViewName: "ScrollViewReader cho iOS 14-16")
            }
        }
    }
}


struct ScrollPositionList: View {
    let items = (1...200).map { "Item \($0)" }
    @State private var scrollPosition: Int?
    
    var body: some View {
        VStack {
            // Header controls
            HStack {
                Button("Top") {
                    withAnimation { scrollPosition = 1 }
                }
                Button("Middle") {
                    withAnimation { scrollPosition = 100 }
                }
                Button("Bottom") {
                    withAnimation { scrollPosition = 200 }
                }
            }
            .buttonStyle(.bordered)
            
            // List với scroll position tracking
            List(items, id: \.self) { item in
                Text(item)
            }
            .scrollPosition(id: $scrollPosition, anchor: .top) // iOS 17+
        }
    }
}

// ScrollViewReader cho iOS 14-16:
struct ScrollViewReaderList: View {
    let items = (1...200).map { "Item \($0)" }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                Button("Go to Item 150") {
                    withAnimation {
                        proxy.scrollTo("Item 150", anchor: .center)
                    }
                }
                
                List(items, id: \.self) { item in
                    Text(item)
                        .id(item) // BẮT BUỘC .id() cho scrollTo
                }
            }
        }
    }
}
