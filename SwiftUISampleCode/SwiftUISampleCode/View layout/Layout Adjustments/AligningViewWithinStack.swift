//
//  AligningViewWithinStack.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/03/30.
//

import SwiftUI

struct AligningViewWithinStack: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image("microphone")
                .alignmentGuide(.firstTextBaseline) { context in
                    context[.bottom] - 0.12 * context.height
                }
            Text("Connecting")
                .font(.caption)
            Text("Bryan")
                .font(.title)
        }
        .padding()
        .border(Color.blue, width: 1)
    }
}

#Preview {
    AligningViewWithinStack()
}
