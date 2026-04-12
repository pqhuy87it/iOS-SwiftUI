//
//  FontSystemDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct FontSystemDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                
                // === 2a. Semantic fonts (Dynamic Type tự động) ===
                // Apple khuyến khích dùng semantic → scale theo user settings
                Group {
                    Text("Large Title").font(.largeTitle)     // 34pt
                    Text("Title").font(.title)                // 28pt
                    Text("Title 2").font(.title2)             // 22pt
                    Text("Title 3").font(.title3)             // 20pt
                    Text("Headline").font(.headline)          // 17pt semi-bold
                    Text("Subheadline").font(.subheadline)    // 15pt
                    Text("Body").font(.body)                  // 17pt (default)
                    Text("Callout").font(.callout)            // 16pt
                    Text("Footnote").font(.footnote)          // 13pt
                    Text("Caption").font(.caption)            // 12pt
                }
                Text("Caption 2").font(.caption2)             // 11pt
                
                Divider()
                
                // === 2b. System font với tuỳ chỉnh ===
                Text("Size + Weight")
                    .font(.system(size: 24, weight: .bold))
                
                Text("Rounded Design")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                
                Text("Monospaced")
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                
                Text("Serif Design")
                    .font(.system(size: 18, weight: .light, design: .serif))
                
                Divider()
                
                // === 2c. Font weight modifiers ===
                Text("Ultra Light").fontWeight(.ultraLight)
                Text("Thin").fontWeight(.thin)
                Text("Light").fontWeight(.light)
                Text("Regular").fontWeight(.regular)
                Text("Medium").fontWeight(.medium)
                Text("Semibold").fontWeight(.semibold)
                Text("Bold").fontWeight(.bold)
                Text("Heavy").fontWeight(.heavy)
                Text("Black").fontWeight(.black)
                
                Divider()
                
                // === 2d. Font width (iOS 16+) ===
                Text("Condensed").fontWidth(.condensed)
                Text("Standard").fontWidth(.standard)
                Text("Expanded").fontWidth(.expanded)
                
                Divider()
                
                // === 2e. Custom fonts ===
                // Cần thêm font file vào project + Info.plist
                // Text("Custom Font")
                //     .font(.custom("Montserrat-Bold", size: 20))
                
                // Custom font với relative sizing (scale theo Dynamic Type)
                // Text("Relative Custom")
                //     .font(.custom("Montserrat", size: 17, relativeTo: .body))
                //     // size: base size, relativeTo: scale reference
            }
            .padding()
        }
    }
}

#Preview {
    FontSystemDemo()
}
