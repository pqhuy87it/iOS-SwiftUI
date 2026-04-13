//
//  TabTransitionDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct TabContentView: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.largeTitle.bold())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color.opacity(0.1))
    }
}

struct TabTransitionDemo: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // Tab content
            ZStack {
                // Tất cả tab content nằm trong ZStack
                // Chỉ tab ĐƯỢC CHỌN mới hiện (opacity/transition)
                
                TabContentView(title: "Home", color: .blue)
                    .opacity(selectedTab == 0 ? 1 : 0)
                
                TabContentView(title: "Search", color: .green)
                    .opacity(selectedTab == 1 ? 1 : 0)
                
                TabContentView(title: "Profile", color: .orange)
                    .opacity(selectedTab == 2 ? 1 : 0)
            }
            .animation(.easeInOut(duration: 0.25), value: selectedTab)
            
            // Custom tab bar
            HStack(spacing: 0) {
                ForEach(0..<3) { i in
                    let icons = ["house.fill", "magnifyingglass", "person.fill"]
                    let labels = ["Home", "Search", "Profile"]
                    
                    Button {
                        selectedTab = i
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: icons[i])
                                .font(.title3)
                            Text(labels[i])
                                .font(.caption2)
                        }
                        .foregroundStyle(selectedTab == i ? .blue : .gray)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
    }
}
