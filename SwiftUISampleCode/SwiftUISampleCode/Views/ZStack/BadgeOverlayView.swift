//
//  BadgeOverlayView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct BadgeOverlay: View {
    let count: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Base icon
            Image(systemName: "bell.fill")
                .font(.title2)
                .foregroundStyle(.primary)
            
            // Badge
            if count > 0 {
                Text(count > 99 ? "99+" : "\(count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(.red, in: .capsule)
                    .offset(x: 10, y: -8)
            }
        }
    }
}
