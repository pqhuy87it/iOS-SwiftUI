//
//  ExamplesView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/05.
//

import SwiftUI

struct ExamplesView: View {
    var body: some View {
        NavigationLink(destination: Example1View()) {
            MenuRow(detailViewName: "Login View")
        }
    }
}

#Preview {
    ExamplesView()
}
