//
//  ImageGalleryDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ImageGalleryDemo: View {
    let imageURLs = (1...12).map {
        URL(string: "https://picsum.photos/200/200?random=\($0)")!
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(imageURLs, id: \.absoluteString) { url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Color.gray.opacity(0.15)
                                .overlay(ProgressView().controlSize(.small))
                        }
                    }
                    .frame(minHeight: 120)
                    .clipShape(.rect(cornerRadius: 2))
                }
            }
        }
    }
}
