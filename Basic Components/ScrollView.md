```Swift
// ============================================================
// SCROLLVIEW TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// ScrollView là container cho phép nội dung SCROLL khi vượt
// quá kích thước hiển thị. Là nền tảng cho hầu hết screens:
// feeds, detail pages, forms, galleries, carousels...
//
// Khác UIScrollView: declarative, tự tính content size,
// tích hợp sâu với LazyVStack/LazyHStack.
//
// Apple bổ sung API mới MỖI NĂM cho ScrollView:
// iOS 14: LazyVStack/LazyHStack, ScrollViewReader
// iOS 15: .refreshable, .searchable
// iOS 16: (ít thay đổi)
// iOS 17: .scrollPosition, .scrollTargetBehavior, 
//         .scrollTransition, .scrollTargetLayout,
//         .scrollIndicators, .scrollClipDisabled,
//         .containerRelativeFrame
// iOS 18: .onScrollGeometryChange, .onScrollVisibilityChange
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÚ PHÁP & INITIALIZER                               ║
// ╚══════════════════════════════════════════════════════════╝

// ScrollView(
//     _ axes: Axis.Set = .vertical,
//     showsIndicators: Bool = true,  // Deprecated iOS 16+
//     @ViewBuilder content: () -> Content
// )

struct BasicScrollViewDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 1a. Vertical scroll (default) ===
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<30) { i in
                        Text("Row \(i)")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .frame(height: 200)
            
            // === 1b. Horizontal scroll ===
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(0..<20) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue.gradient)
                            .frame(width: 120, height: 80)
                            .overlay(Text("\(i)").foregroundStyle(.white))
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 100)
            
            // === 1c. Both axes (ít dùng) ===
            ScrollView([.horizontal, .vertical]) {
                VStack(spacing: 8) {
                    ForEach(0..<20) { row in
                        HStack(spacing: 8) {
                            ForEach(0..<20) { col in
                                Text("\(row),\(col)")
                                    .font(.caption2)
                                    .frame(width: 50, height: 30)
                                    .background(.gray.opacity(0.1))
                            }
                        }
                    }
                }
                .padding()
            }
            .frame(height: 150)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. SCROLL INDICATORS                                    ║
// ╚══════════════════════════════════════════════════════════╝

struct ScrollIndicatorsDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            // === 2a. Legacy: showsIndicators parameter ===
            ScrollView(showsIndicators: false) {
                content
            }
            .frame(height: 100)
            
            // === 2b. Modern: .scrollIndicators() (iOS 16+) ===
            ScrollView {
                content
            }
            .scrollIndicators(.hidden)     // Luôn ẩn
            // .scrollIndicators(.visible)  // Luôn hiện
            // .scrollIndicators(.automatic) // Hệ thống quyết định
            // .scrollIndicators(.never)     // Không bao giờ hiện
            .frame(height: 100)
            
            // === 2c. Ẩn chỉ 1 trục ===
            ScrollView([.horizontal, .vertical]) {
                content
            }
            .scrollIndicators(.hidden, axes: .horizontal)
            // Ẩn indicator ngang, giữ indicator dọc
            .frame(height: 100)
        }
    }
    
    private var content: some View {
        VStack(spacing: 8) {
            ForEach(0..<30) { i in
                Text("Row \(i)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3. ScrollView + VStack vs LazyVStack vs List            ║
// ╚══════════════════════════════════════════════════════════╝

// ScrollView CHỈ cung cấp SCROLLING.
// Content layout phụ thuộc vào children bên trong.

struct ContentComparisonDemo: View {
    let items = (0..<1000).map { "Item \($0)" }
    
    var body: some View {
        TabView {
            // === 3a. ScrollView + VStack: EAGER ===
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.gray.opacity(0.05))
                    }
                }
            }
            .tabItem { Text("VStack") }
            // TẤT CẢ 1000 views init NGAY → chậm, tốn memory
            // ✅ Dùng khi: < 30-50 items, cần exact total height
            
            // === 3b. ScrollView + LazyVStack: LAZY ===
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.gray.opacity(0.05))
                    }
                }
            }
            .tabItem { Text("LazyVStack") }
            // Chỉ init visible + buffer → nhanh, tiết kiệm memory
            // ⚠️ KHÔNG có cell reuse → memory tăng dần khi scroll
            // ✅ Dùng khi: 50-10K items, custom layout
            
            // === 3c. List: REUSE ===
            List(items, id: \.self) { item in
                Text(item)
            }
            .tabItem { Text("List") }
            // Cell reuse → memory ỔN ĐỊNH cho 100K+ items
            // ✅ Dùng khi: data lists, cần swipe/edit/selection
        }
    }
}

// ┌─────────────────────┬────────────┬────────────┬───────────┐
// │                     │  VStack    │ LazyVStack │  List     │
// ├─────────────────────┼────────────┼────────────┼───────────┤
// │ Init children       │ Tất cả    │ Khi cần    │ Khi cần   │
// │ Cell reuse          │ ❌        │ ❌         │ ✅        │
// │ Memory (scroll all) │ Cao nhất  │ Tăng dần   │ Ổn định   │
// │ Custom layout       │ ✅ 100%   │ ✅ 100%   │ Hạn chế   │
// │ Built-in features   │ ❌        │ pinnedViews│ Swipe/Edit│
// │ Scroll indicator    │ Chính xác │ Có thể nhảy│ Chính xác │
// │ Tốt cho             │ < 50 items│ 50-10K     │ 10K+      │
// └─────────────────────┴────────────┴────────────┴───────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  4. SCROLLVIEWREADER — PROGRAMMATIC SCROLLING (iOS 14+)  ║
// ╚══════════════════════════════════════════════════════════╝

struct ScrollViewReaderDemo: View {
    let items = (0..<100).map { "Item \($0)" }
    @State private var searchID: Int?
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                // Control bar
                HStack {
                    Button("⬆ Top") {
                        withAnimation(.spring) {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                    
                    Button("⬇ Bottom") {
                        withAnimation(.spring) {
                            proxy.scrollTo(99, anchor: .bottom)
                        }
                    }
                    
                    Button("→ #50") {
                        withAnimation(.spring) {
                            proxy.scrollTo(50, anchor: .center)
                        }
                    }
                }
                .buttonStyle(.bordered)
                .padding()
                
                // Scrollable content
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(0..<100) { i in
                            Text("Item \(i)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(
                                    i == searchID
                                        ? Color.yellow.opacity(0.3)
                                        : Color.gray.opacity(0.05),
                                    in: .rect(cornerRadius: 8)
                                )
                                .id(i) // ← BẮT BUỘC: scrollTo cần id
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// scrollTo() ANCHOR OPTIONS:
// .top       → item nằm ở TOP viewport
// .center    → item nằm GIỮA viewport
// .bottom    → item nằm ở BOTTOM viewport
// .leading   → cho horizontal scroll
// .trailing  → cho horizontal scroll
// nil        → SwiftUI tự chọn (scroll ít nhất có thể)


// ╔══════════════════════════════════════════════════════════╗
// ║  5. .scrollPosition — TRACKING & CONTROL (iOS 17+)       ║
// ╚══════════════════════════════════════════════════════════╝

// Thay thế ScrollViewReader với API sạch hơn, 2-way binding.

struct ScrollPositionDemo: View {
    @State private var position: Int?
    let items = Array(0..<200)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: hiển thị vị trí hiện tại
            HStack {
                Text("Đang xem: \(position.map { "#\($0)" } ?? "—")")
                    .font(.headline)
                
                Spacer()
                
                Button("Top") {
                    withAnimation { position = 0 }
                }
                Button("Middle") {
                    withAnimation { position = 100 }
                }
                Button("End") {
                    withAnimation { position = 199 }
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .padding()
            
            // ScrollView với position binding
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text("Item \(item)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                position == item
                                    ? Color.blue.opacity(0.15)
                                    : Color.gray.opacity(0.05),
                                in: .rect(cornerRadius: 8)
                            )
                    }
                }
                .scrollTargetLayout()  // ← BẮT BUỘC cho scrollPosition
                .padding(.horizontal)
            }
            .scrollPosition(id: $position) // ← 2-way binding
            // Scroll → position tự cập nhật
            // Set position → tự scroll đến item
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. SCROLL TARGET BEHAVIOR — PAGING & SNAPPING (iOS 17+) ║
// ╚══════════════════════════════════════════════════════════╝

struct ScrollTargetDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // === 6a. .paging — Full page snapping ===
            Text(".paging").font(.caption.bold())
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(0..<10) { i in
                        RoundedRectangle(cornerRadius: 20)
                            .fill([Color.blue, .green, .orange, .purple, .red][i % 5].gradient)
                            .containerRelativeFrame(.horizontal) // Full width mỗi page
                            .overlay(
                                Text("Page \(i + 1)")
                                    .font(.title.bold())
                                    .foregroundStyle(.white)
                            )
                            .padding(.horizontal, 16)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging) // Snap theo page
            .frame(height: 180)
            
            // === 6b. .viewAligned — Snap theo từng view ===
            Text(".viewAligned").font(.caption.bold())
            ScrollView(.horizontal) {
                LazyHStack(spacing: 12) {
                    ForEach(0..<20) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue.gradient)
                            .frame(width: 200, height: 120)
                            .overlay(Text("Card \(i + 1)").foregroundStyle(.white))
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal)
            }
            .scrollTargetBehavior(.viewAligned) // Snap theo card edge
            .frame(height: 140)
        }
    }
}

// .containerRelativeFrame() (iOS 17+):
// Size view TƯƠNG ĐỐI với scroll container
// .containerRelativeFrame(.horizontal)          → full width
// .containerRelativeFrame(.horizontal, count: 3) → 1/3 width
// Cực hữu ích cho carousel, paging layouts


// ╔══════════════════════════════════════════════════════════╗
// ║  7. SCROLL TRANSITIONS — HIỆU ỨNG KHI SCROLL (iOS 17+)  ║
// ╚══════════════════════════════════════════════════════════╝

struct ScrollTransitionDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            
            // === 7a. Fade + Scale khi scroll ===
            Text("scrollTransition").font(.caption.bold())
            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(0..<20) { i in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.blue.gradient)
                            .frame(width: 150, height: 100)
                            .overlay(Text("\(i)").foregroundStyle(.white).font(.title))
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.5)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                    .rotation3DEffect(
                                        .degrees(phase.value * 25),
                                        axis: (x: 0, y: 1, z: 0)
                                    )
                            }
                            // phase.isIdentity: view đang ở vùng hiển thị chính
                            // phase.value: -1 → 0 → 1 (trái → giữa → phải)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal)
            }
            .scrollTargetBehavior(.viewAligned)
            .frame(height: 120)
            
            // === 7b. Vertical fade-in effect ===
            Text("Vertical fade-in").font(.caption.bold())
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(0..<30) { i in
                        HStack {
                            Circle()
                                .fill(.blue.gradient)
                                .frame(width: 48, height: 48)
                            VStack(alignment: .leading) {
                                Text("Item \(i)").font(.headline)
                                Text("Description").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(.gray.opacity(0.05), in: .rect(cornerRadius: 12))
                        .scrollTransition(.animated(.spring)) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .offset(y: phase.isIdentity ? 0 : 30)
                                .scaleEffect(phase.isIdentity ? 1 : 0.95)
                        }
                    }
                }
                .padding()
            }
            .frame(height: 250)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. PULL-TO-REFRESH & SEARCHABLE                         ║
// ╚══════════════════════════════════════════════════════════╝

@Observable
final class FeedViewModel {
    var items: [String] = (1...20).map { "Post \($0)" }
    
    func refresh() async {
        try? await Task.sleep(for: .seconds(1))
        items.insert("New Post \(Int.random(in: 100...999))", at: 0)
    }
}

struct RefreshableScrollView: View {
    @State private var vm = FeedViewModel()
    @State private var searchText = ""
    
    var filtered: [String] {
        guard !searchText.isEmpty else { return vm.items }
        return vm.items.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filtered, id: \.self) { item in
                        Text(item)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.gray.opacity(0.05), in: .rect(cornerRadius: 10))
                    }
                }
                .padding()
            }
            .navigationTitle("Feed")
            
            // Pull-to-refresh: kéo xuống → spinner → async action
            .refreshable {
                await vm.refresh()
            }
            
            // Search bar tích hợp navigation
            .searchable(text: $searchText, prompt: "Tìm kiếm...")
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. SCROLL CLIP & OVERFLOW                               ║
// ╚══════════════════════════════════════════════════════════╝

struct ScrollClipDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // === 9a. Mặc định: content bị clip tại ScrollView bounds ===
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(0..<10) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue.gradient)
                            .frame(width: 120, height: 80)
                            .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                        // ⚠️ Shadow bị CẮT ở mép ScrollView!
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 100)
            
            // === 9b. scrollClipDisabled: cho phép tràn (iOS 17+) ===
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(0..<10) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.green.gradient)
                            .frame(width: 120, height: 80)
                            .shadow(color: .green.opacity(0.3), radius: 10, y: 5)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16) // Extra padding cho shadow
            }
            .scrollClipDisabled()  // Shadow KHÔNG bị cắt
            .frame(height: 130)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. onScrollGeometryChange & SCROLL EVENTS (iOS 18+)    ║
// ╚══════════════════════════════════════════════════════════╝

struct ScrollGeometryDemo: View {
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolling = false
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<50) { i in
                        Text("Row \(i)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.gray.opacity(0.05), in: .rect(cornerRadius: 8))
                    }
                }
                .padding()
            }
            // iOS 18+: Track scroll geometry changes
            // .onScrollGeometryChange(for: CGFloat.self) { geo in
            //     geo.contentOffset.y
            // } action: { oldValue, newValue in
            //     scrollOffset = newValue
            //     isScrolling = true
            // }
            
            // iOS 17 alternative: dùng GeometryReader trong background
            // hoặc PreferenceKey approach (xem bên dưới)
            
            // Floating header fade
            if scrollOffset > 50 {
                Text("Scrolled: \(Int(scrollOffset))pt")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: .capsule)
                    .transition(.opacity)
            }
        }
    }
}

// === iOS 14-16: Track scroll offset via PreferenceKey ===

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TrackableScrollView<Content: View>: View {
    @Binding var offset: CGFloat
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                // Invisible tracker
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ScrollOffsetKey.self,
                            value: -geo.frame(in: .named("scroll")).origin.y
                        )
                }
                .frame(height: 0)
                
                // Actual content
                content()
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            offset = value
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. PRODUCTION PATTERNS                                  ║
// ╚══════════════════════════════════════════════════════════╝

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


// ╔══════════════════════════════════════════════════════════╗
// ║  12. KEYBOARD AVOIDANCE & SAFE AREA                      ║
// ╚══════════════════════════════════════════════════════════╝

struct KeyboardAvoidanceDemo: View {
    @State private var text = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<10) { i in
                    Text("Row \(i)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.gray.opacity(0.05))
                }
                
                TextField("Nhập text...", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                // ScrollView TỰ ĐỘNG scroll lên khi keyboard xuất hiện
                // để TextField không bị che (iOS 14+)
            }
            .padding()
        }
        // Nếu cần disable keyboard avoidance:
        // .ignoresSafeArea(.keyboard)
        
        // Nếu cần scroll safe area:
        .safeAreaInset(edge: .bottom) {
            // View cố định ở bottom, content scroll phía trên
            HStack {
                TextField("Message...", text: $text)
                    .textFieldStyle(.roundedBorder)
                Button("Send") { }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}

// .safeAreaInset(edge:) (iOS 15+):
// Thêm view CỐ ĐỊNH ở edge, ScrollView content tự
// adjust insets để không bị che.
// Dùng cho: bottom bars, floating inputs, mini players


// ╔══════════════════════════════════════════════════════════╗
// ║  13. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Spacer trong ScrollView không hoạt động
//    ScrollView { VStack { Text("A"); Spacer(); Text("B") } }
//    → ScrollView cho VStack height VÔ HẠN → Spacer mở rộng vô tận
//    ✅ FIX: Dùng .frame(minHeight: geo.size.height) qua GeometryReader
//            hoặc bỏ Spacer, dùng padding/offset thay thế

// ❌ PITFALL 2: ScrollView không scroll
//    ScrollView { Text("Short") }
//    → Content nhỏ hơn viewport → không có gì để scroll
//    ✅ FIX: Đúng behavior. ScrollView chỉ scroll khi content > viewport

// ❌ PITFALL 3: VStack trong ScrollView — performance kém với nhiều items
//    ScrollView { VStack { ForEach(0..<10000) { ... } } }
//    → TẤT CẢ 10K views init ngay → lag, tốn memory
//    ✅ FIX: Dùng LazyVStack thay VStack cho > 50 items

// ❌ PITFALL 4: Shadow/overlay bị clip bởi ScrollView
//    ScrollView { Card().shadow(radius: 10) }
//    → Shadow bị cắt ở mép ScrollView
//    ✅ FIX: .scrollClipDisabled() (iOS 17+)
//            hoặc thêm padding cho shadow space

// ❌ PITFALL 5: .scrollTo không hoạt động
//    ScrollViewReader { proxy in proxy.scrollTo("id") }
//    → View chưa có .id() modifier
//    ✅ FIX: Thêm .id(value) cho target view
//            Đảm bảo id unique và type khớp

// ❌ PITFALL 6: .scrollPosition không tracking
//    ScrollView { LazyVStack { ... } }
//        .scrollPosition(id: $pos)
//    → Thiếu .scrollTargetLayout()
//    ✅ FIX: Thêm .scrollTargetLayout() vào LazyVStack

// ❌ PITFALL 7: Horizontal ScrollView chiều cao bất thường
//    ScrollView(.horizontal) { HStack { ForEach... } }
//    → ScrollView mở rộng full height
//    ✅ FIX: .frame(height: X) giới hạn chiều cao ScrollView

// ❌ PITFALL 8: Nested ScrollViews cùng trục
//    ScrollView { ScrollView { content } }
//    → Gesture conflict, scroll behavior không đoán trước
//    ✅ FIX: Nested scroll CHỈ KHI KHÁC TRỤC
//            (vertical chứa horizontal → OK, vertical chứa vertical → BAD)

// ✅ BEST PRACTICES:
// 1. LazyVStack/LazyHStack cho > 50 items trong ScrollView
// 2. .scrollTargetLayout + .scrollTargetBehavior cho carousel/paging
// 3. .scrollPosition cho tracking + programmatic scroll (iOS 17+)
// 4. ScrollViewReader cho iOS 14-16 programmatic scroll
// 5. .refreshable cho pull-to-refresh (async tự quản lý spinner)
// 6. .scrollIndicators(.hidden) cho horizontal carousels
// 7. .scrollClipDisabled() khi cards có shadows (iOS 17+)
// 8. .safeAreaInset cho fixed bottom/top bars
// 9. .containerRelativeFrame cho responsive item sizing (iOS 17+)
// 10. .scrollTransition cho scroll-driven animations (iOS 17+)
// 11. Nested scroll CHỈ khi khác trục (V→H ok, V→V avoid)
// 12. .coordinateSpace + PreferenceKey cho scroll offset (iOS 14-16)
```

---

ScrollView là container scroll nền tảng của SwiftUI — kết hợp với rất nhiều API mới qua các phiên bản iOS. Mình sẽ giải thích toàn bộ từ cơ chế hoạt động đến các API nâng cao như scroll position, paging, scroll transitions.Mình đã tổng hợp toàn bộ kiến thức ScrollView trong 13 phần. Đây là những điểm cốt lõi:

**ScrollView evolution** là điều nổi bật nhất — Apple bổ sung API mới mỗi năm, đặc biệt iOS 17 là bước nhảy lớn nhất với `.scrollPosition`, `.scrollTargetBehavior`, `.scrollTransition`, `.containerRelativeFrame`, `.scrollClipDisabled`. Hiểu theo version giúp chọn đúng API cho min deployment target.

**Năm phần giá trị nhất:**

**Phần 3 — ScrollView + VStack vs LazyVStack vs List**: Bảng so sánh quan trọng nhất. VStack tạo tất cả ngay (< 50 items), LazyVStack tạo on-demand nhưng không reuse (50-10K), List có cell reuse thật sự (10K+). Chọn sai → performance problem hoặc over-engineering.

**Phần 6 — Scroll Target Behavior**: `.paging` snap theo full page, `.viewAligned` snap theo card edge — kết hợp `.containerRelativeFrame(.horizontal)` để mỗi item tự tính size theo ScrollView width. Đây là cách build carousel/onboarding **không cần UIPageViewController** nữa.

**Phần 7 — Scroll Transitions**: `.scrollTransition` cho phép animate views based on scroll position — `phase.value` chạy từ -1→0→1 (trái→giữa→phải). Kết hợp opacity + scale + rotation3D tạo hiệu ứng carousel 3D cực premium chỉ với vài dòng code.

**Phần 11 — Production Patterns**: Carousel với paging dots, collapsible header (shrink on scroll), Netflix-style nested scroll (horizontal trong vertical), và chat view (auto scroll to bottom). Đặc biệt **collapsible header** dùng `TrackableScrollView` + PreferenceKey để track offset — pattern phổ biến mà SwiftUI chưa có built-in cho đến iOS 18.

**Pitfall #1 và #8**: Spacer trong ScrollView mở rộng vô tận (vì ScrollView cho content height vô hạn), và nested scroll cùng trục gây gesture conflict. Nested scroll **chỉ an toàn khi khác trục** (vertical chứa horizontal).

Huy muốn mình đi tiếp sang chủ đề nào khác không?
