//
//  ScrollViews.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/03/31.
//

import SwiftUI

struct ScrollViews: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: ScrollViewExample()) {
                    MenuRow(detailViewName: "Scroll View")
                }
                
                NavigationLink(destination: ScrollViewReaderView()) {
                    MenuRow(detailViewName: "Scroll Reader View")
                }
            }
        }
        .navigationBarTitle("Scroll Views")
    }
}

#Preview {
    ScrollViews()
}
