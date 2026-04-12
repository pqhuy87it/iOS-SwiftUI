//
//  BasicView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/11.
//

import SwiftUI

struct BasicView: View {
    var body: some View {
        NavigationLink(destination: HStackExampleView()) {
            MenuRow(detailViewName: "HStack")
        }
        
        NavigationLink(destination: VStackExampleView()) {
            MenuRow(detailViewName: "VStack")
        }
        
        NavigationLink(destination: ButtonExampleView()) {
            MenuRow(detailViewName: "Button")
        }
    }
}

#Preview {
    BasicView()
}
