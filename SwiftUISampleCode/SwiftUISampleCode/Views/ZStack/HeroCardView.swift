//
//  HeroCardView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct HeroCard: View {
    let title: String
    let subtitle: String
    let category: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Layer 0: Background image
            Image(systemName: "photo.artframe")
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .background(.blue.gradient)
            
            // Layer 1: Gradient scrim cho text readability
            LinearGradient(
                colors: [.black.opacity(0.7), .clear],
                startPoint: .bottom,
                endPoint: .center
            )
            
            // Layer 2: Content
            VStack(alignment: .leading, spacing: 6) {
                Text(category.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(20)
        }
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
    }
}
