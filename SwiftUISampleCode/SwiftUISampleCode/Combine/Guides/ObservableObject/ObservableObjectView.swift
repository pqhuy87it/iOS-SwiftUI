//
//  ObservableObjectView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/05.
//

import SwiftUI

struct ObservableObjectView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: ObjectWillChangeView()) {
                    VStack(alignment: .leading) {
                        Text("objectWillChange").font(.headline)
                        Text("Chỉ cần 1 object thay rồi re-render)").font(.caption).foregroundColor(.gray)
                    }
                }
                
                NavigationLink(destination: ObjectWillChange2View()) {
                    VStack(alignment: .leading) {
                        Text("objectWillChange").font(.headline)
                        Text("Setting thay đổi không re-render)").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("ObservableObject")
    }
}

#Preview {
    ObservableObjectView()
}
