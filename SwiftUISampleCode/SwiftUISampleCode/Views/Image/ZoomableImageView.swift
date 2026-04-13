//
//  ZoomableImageView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ZoomableImage: View {
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        Image(systemName: "map.fill")
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        scale = lastScale * value.magnification
                    }
                    .onEnded { value in
                        lastScale = scale
                        // Clamp scale
                        withAnimation(.spring) {
                            scale = min(max(scale, 1.0), 5.0)
                            lastScale = scale
                        }
                    }
            )
            .gesture(
                TapGesture(count: 2)
                    .onEnded {
                        withAnimation(.spring) {
                            if scale > 1.0 {
                                scale = 1.0
                                lastScale = 1.0
                            } else {
                                scale = 2.5
                                lastScale = 2.5
                            }
                        }
                    }
            )
    }
}

#Preview {
    ZoomableImage()
}
