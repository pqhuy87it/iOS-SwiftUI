//
//  CombineView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/01.
//

import SwiftUI

struct CombineView: View {
    var body: some View {
        NavigationLink(destination: CombineGuideView()) {
            MenuRow(detailViewName: "Combine Guide")
        }
        
        NavigationLink(destination: StateObservedObjectView()) {
            MenuRow(detailViewName: "@StateObject & @ObservedObject")
        }
        
        NavigationLink(destination: KVOView()) {
            MenuRow(detailViewName: "Key-Value Observing (KVO)")
        }
        
        NavigationLink(destination: CombineAsyncView()) {
            MenuRow(detailViewName: "Using Combine for Asynchronous Code")
        }
    }
}

#Preview {
    CombineView()
}
