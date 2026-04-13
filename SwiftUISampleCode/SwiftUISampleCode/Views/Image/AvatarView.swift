//
//  AvatarView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct AvatarView: View {
    let url: URL?
    let name: String
    var size: CGFloat = 48
    var showOnline: Bool = false
    
    private var initials: String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Avatar image hoặc initials fallback
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        initialsFallback
                    }
                }
                .frame(width: size, height: size)
                .clipShape(.circle)
            } else {
                initialsFallback
            }
            
            // Online indicator
            if showOnline {
                Circle()
                    .fill(.green)
                    .frame(width: size * 0.28, height: size * 0.28)
                    .overlay(
                        Circle().strokeBorder(.white, lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }
    
    private var initialsFallback: some View {
        Circle()
            .fill(.blue.gradient)
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .semibold))
                    .foregroundStyle(.white)
            )
    }
}
