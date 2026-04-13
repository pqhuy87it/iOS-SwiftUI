//
//  ImageExample10View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ImageExample10View: View {
    var body: some View {
        List {
            // === 10a. Avatar Component ===
            AvatarView(url: URL(string: "https://avatars.githubusercontent.com/u/5575899"),
                       name: "iOS Developer")
            
            // === 10b. Image Gallery / Grid ===
            ImageGalleryDemo()
            
            // === 10c. Hero Image with Parallax ===
            HeroImageCard(title: "Dota 2",
                          subtitle: "New version")
        }
    }
}

#Preview {
    ImageExample10View()
}
