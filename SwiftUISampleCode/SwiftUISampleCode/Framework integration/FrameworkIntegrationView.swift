//
//  FrameworkIntegrationView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/02.
//

import SwiftUI

struct FrameworkIntegrationView: View {
    var body: some View {
        NavigationLink(destination: AppKitIntegrationView()) {
            MenuRow(detailViewName: "AppKit integration")
        }
    }
}

#Preview {
    FrameworkIntegrationView()
}
