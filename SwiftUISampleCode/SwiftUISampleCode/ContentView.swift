//
//  ContentView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/03/30.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Essentials")) {
                        EssentialListView()
                    }
                    Section(header: Text("Advanced")) {
                        AppStructureListView()
                    }
                    Section(header: Text("View layout")) {
                        ViewlayoutView()
                    }
                    Section(header: Text("Event handling")) {
                        EventHandlingView()
                    }
                    Section(header: Text("Observation")) {
                        ObservationView()
                    }
                    Section(header: Text("Combine")) {
                        CombineView()
                    }
                }
            }
            .navigationBarTitle("SwiftUI Sample Code")
        }
    }
}

#Preview {
    ContentView()
}
