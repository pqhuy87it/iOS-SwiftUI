//
//  ImageExample7View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ImageExample7View: View {
    var body: some View {
        VStack {
            // Wrapper giải quyết các hạn chế của AsyncImage
            CachedAsyncImage(url: URL(string: "https://zeerawireless.com/cdn/shop/articles/2026_wwdc_600x600_crop_center.jpg"),
                             contentMode: .fit)
        }
        .padding()
    }
}

#Preview {
    ImageExample7View()
}
