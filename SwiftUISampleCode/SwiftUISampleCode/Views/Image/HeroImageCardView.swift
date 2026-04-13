//
//  HeroImageCardView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct HeroImageCard: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        Image(systemName: "photo.artframe")
            .resizable()
            .scaledToFill()
            .frame(height: 250)
            .background(.blue.gradient)
            .clipShape(.rect(cornerRadius: 20))
            .overlay(alignment: .bottomLeading) {
                // Gradient overlay cho text readability
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.bold())
                    Text(subtitle)
                        .font(.subheadline)
                        .opacity(0.9)
                }
                .foregroundStyle(.white)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.7), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .clipShape(.rect(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
                )
            }
            .padding(.horizontal)
    }
}
