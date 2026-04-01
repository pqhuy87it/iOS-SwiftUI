//
//  ObservationView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/01.
//

import SwiftUI

struct ObservationView: View {
    var body: some View {
        NavigationLink(destination: ObservableExampleView()) {
            MenuRow(detailViewName: "Observable")
        }
        
        NavigationLink(destination: DataFlowExample()) {
            MenuRow(detailViewName: "Observable2")
        }
        
        NavigationLink(destination: ProfileView()) {
            MenuRow(detailViewName: "Observable3")
        }
    }
}

#Preview {
    ObservationView()
}
