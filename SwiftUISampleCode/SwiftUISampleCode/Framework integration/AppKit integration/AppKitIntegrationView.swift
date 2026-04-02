//
//  AppKitIntegrationView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/02.
//

import SwiftUI

struct AppKitIntegrationView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: UnifiedAnimationView()) {
                    MenuRow(detailViewName: "Unifying your app’s animations")
                }
            }
        }
        .navigationBarTitle("AppKit integration")
    }
}

#Preview {
    AppKitIntegrationView()
}
