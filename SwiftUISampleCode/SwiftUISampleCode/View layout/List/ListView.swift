//
//  ListView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/03/30.
//

import SwiftUI

struct ListView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: SettingsView()) {
                    MenuRow(detailViewName: "Settings View")
                }
            }
        }
        .navigationBarTitle("List")
    }
}

#Preview {
    ListView()
}
