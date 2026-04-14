//
//  ScrollViewExample11View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ScrollViewExample11View: View {
    var body: some View {
        List {
            NavigationLink(destination: CarouselView()) {
                MenuRow(detailViewName: "11a. Carousel với Paging Dots")
            }
            
            NavigationLink(destination: CollapsibleHeaderView()) {
                MenuRow(detailViewName: "11b. Collapsible Header (Shrink on Scroll)")
            }
            
            NavigationLink(destination: CategoryTabsView()) {
                MenuRow(detailViewName: "11c. Horizontal Category Tabs + Vertical Content")
            }
            
            NavigationLink(destination: ChatScrollView()) {
                MenuRow(detailViewName: "11d. Chat / Messages (Scroll to bottom, reverse)")
            }
            
            NavigationLink(destination: NestedScrollDemo()) {
                MenuRow(detailViewName: "11e. Nested Scroll: Horizontal in Vertical (Netflix-style)")
            }
        }
    }
}

// === 11a. Carousel với Paging Dots ===

struct CarouselView: View {
    @State private var currentPage: Int?
    let pageCount = 5
    let colors: [Color] = [.blue, .green, .orange, .purple, .red]
    
    var body: some View {
        VStack(spacing: 12) {
            // Carousel
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(0..<pageCount, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colors[i].gradient)
                            .overlay(
                                VStack {
                                    Text("Page \(i + 1)")
                                        .font(.title.bold())
                                    Text("Swipe to navigate")
                                        .font(.subheadline)
                                }
                                .foregroundStyle(.white)
                            )
                            .containerRelativeFrame(.horizontal)
                            .padding(.horizontal, 16)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $currentPage)
            .scrollIndicators(.hidden)
            .frame(height: 200)
            
            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<pageCount, id: \.self) { i in
                    Circle()
                        .fill(currentPage == i ? Color.primary : Color.gray.opacity(0.3))
                        .frame(width: currentPage == i ? 8 : 6,
                               height: currentPage == i ? 8 : 6)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }
        }
        .onAppear { currentPage = 0 }
    }
}


// === 11b. Collapsible Header (Shrink on Scroll) ===

struct CollapsibleHeaderView: View {
    @State private var scrollOffset: CGFloat = 0
    
    private var headerHeight: CGFloat {
        max(60, 200 - scrollOffset)
    }
    
    private var headerOpacity: Double {
        max(0, 1 - scrollOffset / 150)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Content
            TrackableScrollView(offset: $scrollOffset) {
                LazyVStack(spacing: 12) {
                    // Spacer cho header
                    Color.clear.frame(height: 200)
                    
                    ForEach(0..<40) { i in
                        Text("Content Row \(i)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.gray.opacity(0.05), in: .rect(cornerRadius: 8))
                    }
                }
                .padding(.horizontal)
            }
            
            // Collapsible header
            VStack {
                Spacer()
                Text("Profile")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .opacity(headerOpacity)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity)
            .frame(height: headerHeight)
            .background(.blue.gradient)
            .clipShape(.rect(bottomLeadingRadius: scrollOffset > 100 ? 0 : 24,
                             bottomTrailingRadius: scrollOffset > 100 ? 0 : 24))
            .shadow(color: .black.opacity(0.1), radius: scrollOffset > 50 ? 5 : 0)
            .animation(.easeOut(duration: 0.15), value: scrollOffset)
        }
    }
}


// === 11c. Horizontal Category Tabs + Vertical Content ===

struct CategoryTabsView: View {
    let categories = ["Tất cả", "Công nghệ", "Thiết kế", "Kinh doanh", "Đời sống"]
    @State private var selected = "Tất cả"
    
    var body: some View {
        VStack(spacing: 0) {
            // Horizontal scrolling tabs
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selected = cat
                            }
                        } label: {
                            Text(cat)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selected == cat ? Color.blue : Color.gray.opacity(0.1),
                                    in: .capsule
                                )
                                .foregroundStyle(selected == cat ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .scrollIndicators(.hidden)
            
            Divider()
            
            // Vertical content
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<20) { i in
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.gray.opacity(0.1))
                                .frame(width: 80, height: 60)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(selected) — Bài \(i + 1)").font(.headline)
                                Text("Mô tả ngắn").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(.background, in: .rect(cornerRadius: 12))
                    }
                }
                .padding()
            }
        }
    }
}


// === 11d. Chat / Messages (Scroll to bottom, reverse) ===

struct ChatScrollView: View {
    @State private var messages = (1...20).map { "Message \($0)" }
    @State private var newMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { idx, msg in
                            let isMe = idx % 3 != 0
                            HStack {
                                if isMe { Spacer(minLength: 60) }
                                Text(msg)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        isMe ? Color.blue : Color.gray.opacity(0.2),
                                        in: .rect(cornerRadius: 16)
                                    )
                                    .foregroundStyle(isMe ? .white : .primary)
                                if !isMe { Spacer(minLength: 60) }
                            }
                            .id(idx)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo(messages.count - 1, anchor: .bottom)
                    }
                }
                .onAppear {
                    proxy.scrollTo(messages.count - 1, anchor: .bottom)
                }
            }
            
            Divider()
            
            // Input bar
            HStack(spacing: 8) {
                TextField("Nhắn tin...", text: $newMessage)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    guard !newMessage.isEmpty else { return }
                    messages.append(newMessage)
                    newMessage = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(newMessage.isEmpty)
            }
            .padding()
        }
    }
}


// === 11e. Nested Scroll: Horizontal in Vertical (Netflix-style) ===

struct NestedScrollDemo: View {
    let sections = [
        ("Xu hướng", Color.red),
        ("Phim mới", Color.blue),
        ("Hành động", Color.green),
        ("Hài hước", Color.orange),
        ("Kinh dị", Color.purple),
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(sections, id: \.0) { title, color in
                    VStack(alignment: .leading, spacing: 10) {
                        // Section header
                        Text(title)
                            .font(.title3.bold())
                            .padding(.horizontal)
                        
                        // Horizontal carousel
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 12) {
                                ForEach(0..<15) { i in
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(color.gradient)
                                        .frame(width: 130, height: 180)
                                        .overlay(
                                            Text("\(title) \(i+1)")
                                                .font(.caption)
                                                .foregroundStyle(.white)
                                        )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}
