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
        
        NavigationLink(destination: ZStackExampleView()) {
            MenuRow(detailViewName: "ZStack")
        }
        
        NavigationLink(destination: ButtonExampleView()) {
            MenuRow(detailViewName: "Button")
        }
        
        NavigationLink(destination: TextExampleView()) {
            MenuRow(detailViewName: "Text")
        }
        
        NavigationLink(destination: ImageExampleView()) {
            MenuRow(detailViewName: "Image")
        }
    }
}

#Preview {
    BasicView()
}
