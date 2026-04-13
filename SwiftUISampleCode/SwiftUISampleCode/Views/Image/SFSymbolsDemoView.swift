//
//  SFSymbolsDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct SFSymbolsDemo: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // === 2a. Cơ bản — scale theo .font() ===
                HStack(spacing: 20) {
                    Image(systemName: "heart.fill")
                        .font(.caption)    // nhỏ
                    Image(systemName: "heart.fill")
                        .font(.body)       // vừa
                    Image(systemName: "heart.fill")
                        .font(.title)      // lớn
                    Image(systemName: "heart.fill")
                        .font(.largeTitle) // rất lớn
                }
                
                // === 2b. imageScale — fine-tune size trong font ===
                HStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .imageScale(.small)
                    Image(systemName: "star.fill")
                        .imageScale(.medium) // default
                    Image(systemName: "star.fill")
                        .imageScale(.large)
                }
                .font(.title)
                
                // === 2c. Font weight — độ dày nét ===
                HStack(spacing: 16) {
                    Image(systemName: "bell")
                        .fontWeight(.ultraLight)
                    Image(systemName: "bell")
                        .fontWeight(.light)
                    Image(systemName: "bell")
                        .fontWeight(.regular)
                    Image(systemName: "bell")
                        .fontWeight(.semibold)
                    Image(systemName: "bell")
                        .fontWeight(.bold)
                    Image(systemName: "bell")
                        .fontWeight(.black)
                }
                .font(.title)
                
                Divider()
                
                // === 2d. Symbol Rendering Modes ===
                let iconName = "chart.bar.doc.horizontal.fill"
                
                VStack(alignment: .leading, spacing: 12) {
                    // Monochrome: 1 màu duy nhất
                    Label("Monochrome", systemImage: iconName)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.blue)
                    
                    // Hierarchical: 1 màu + opacity layers tự động
                    Label("Hierarchical", systemImage: iconName)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.blue)
                    
                    // Palette: 2-3 màu tuỳ chỉnh cho từng layer
                    Label("Palette", systemImage: iconName)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue, .orange, .green)
                    
                    // Multicolor: màu gốc do Apple thiết kế
                    Label("Multicolor", systemImage: "externaldrive.fill.badge.wifi")
                        .symbolRenderingMode(.multicolor)
                }
                .font(.title3)
                
                Divider()
                
                // === 2e. Variable Value (iOS 16+) ===
                // Một số symbols hỗ trợ giá trị 0.0 - 1.0
                HStack(spacing: 16) {
                    Image(systemName: "speaker.wave.3.fill", variableValue: 0.0)
                    Image(systemName: "speaker.wave.3.fill", variableValue: 0.33)
                    Image(systemName: "speaker.wave.3.fill", variableValue: 0.66)
                    Image(systemName: "speaker.wave.3.fill", variableValue: 1.0)
                }
                .font(.title)
                .foregroundStyle(.blue)
                
                HStack(spacing: 16) {
                    Image(systemName: "wifi", variableValue: 0.25)
                    Image(systemName: "wifi", variableValue: 0.5)
                    Image(systemName: "wifi", variableValue: 0.75)
                    Image(systemName: "wifi", variableValue: 1.0)
                }
                .font(.title)
                
                Divider()
                
                // === 2f. Symbol Effects (iOS 17+) ===
                VStack(spacing: 16) {
                    // Pulse liên tục
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.title)
                        .symbolEffect(.pulse)
                    
                    // Variable color liên tục
                    Image(systemName: "wifi")
                        .font(.title)
                        .symbolEffect(.variableColor.iterative)
                    
                    // Breathe (iOS 18+)
                    // Image(systemName: "heart.fill")
                    //     .symbolEffect(.breathe)
                }
                .foregroundStyle(.blue)
            }
            .padding()
        }
    }
}

#Preview {
    SFSymbolsDemo()
}
