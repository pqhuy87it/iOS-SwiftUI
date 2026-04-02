//
//  CombineView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/01.
//

import SwiftUI

struct CombineView: View {
    var body: some View {
        NavigationLink(destination: StateObservedObjectView()) {
            MenuRow(detailViewName: "@StateObject & @ObservedObject")
        }
        
        NavigationLink(destination: KVOView()) {
            MenuRow(detailViewName: "Key-Value Observing (KVO)")
        }
    }
}

#Preview {
    CombineView()
}
