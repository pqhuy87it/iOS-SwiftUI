//
//  HStackExample2View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct HStackExample2View: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // .top — căn theo cạnh TRÊN
            DemoRow(title: ".top", alignment: .top)
            
            // .center — căn GIỮA (default)
            DemoRow(title: ".center", alignment: .center)
            
            // .bottom — căn theo cạnh DƯỚI
            DemoRow(title: ".bottom", alignment: .bottom)
            
            // .firstTextBaseline — căn theo baseline dòng TEXT ĐẦU TIÊN
            // Quan trọng khi mix font sizes
            DemoRow(title: ".firstTextBaseline", alignment: .firstTextBaseline)
            
            // .lastTextBaseline — căn theo baseline dòng TEXT CUỐI
            DemoRow(title: ".lastTextBaseline", alignment: .lastTextBaseline)
        }
        .padding()
    }
}

#Preview {
    HStackExample2View()
}
