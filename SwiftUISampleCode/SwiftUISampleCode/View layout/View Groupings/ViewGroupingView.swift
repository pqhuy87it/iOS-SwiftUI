//
//  ViewGroupingView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/03/31.
//

import SwiftUI

struct ViewGroupingView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: DisplayBoardContainerView()) {
                    MenuRow(detailViewName: "Display board container")
                }
                
                NavigationLink(destination: ContainerView()) {
                    MenuRow(detailViewName: "Container Views")
                }
            }
        }
        .navigationBarTitle("View Groupings")
    }
}

#Preview {
    ViewGroupingView()
}
