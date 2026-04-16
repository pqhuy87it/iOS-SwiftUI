```Swift
// ============================================================
// TABVIEW TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// TabView hiển thị NHIỀU SCREENS, user chuyển đổi qua tab bar.
// Tương đương UITabBarController trong UIKit.
//
// Ngoài tab bar, TabView còn dùng cho:
// - Page-style swiping (onboarding, image carousel)
//
// API Evolution:
// iOS 13: TabView + .tabItem { }
// iOS 14: TabView + PageTabViewStyle
// iOS 15: .badge() trên tab items
// iOS 17: (minor improvements)
// iOS 18: TAB API MỚI — Tab struct, TabSection, .sidebarAdaptable,
//         search trong tab bar, customization
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÚ PHÁP CƠ BẢN — .tabItem (iOS 13+)                ║
// ╚══════════════════════════════════════════════════════════╝

struct BasicTabViewDemo: View {
    var body: some View {
        TabView {
            // Tab 1
            Text("Trang chủ")
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            // Tab 2
            Text("Tìm kiếm")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
            // Tab 3
            Text("Cá nhân")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                    // Label tự động tách icon + text cho tab bar
                }
        }
    }
}

// .tabItem RULES:
// - Chỉ hỗ trợ: Image, Text, Label (bên trong .tabItem { })
// - Views phức tạp khác (HStack, VStack...) sẽ bị BỎ QUA
// - Label tự tách thành Image + Text riêng
// - SF Symbols tự chuyển sang filled variant trong tab bar
// - Tối đa 5 tabs hiển thị (thêm → "More" tab tự động)


// ╔══════════════════════════════════════════════════════════╗
// ║  2. SELECTION — ĐIỀU KHIỂN TAB ĐANG CHỌN                 ║
// ╚══════════════════════════════════════════════════════════╝

// === 2a. selection + tag ===

struct SelectionDemo: View {
    @State private var selectedTab = 0
    // Hoặc dùng enum (khuyến khích)
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0) // ← Giá trị khớp type với selection
            
            SearchTab()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
            
            ProfileTab()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
        }
    }
}

struct HomeTab: View { var body: some View { Text("Home") } }
struct SearchTab: View { var body: some View { Text("Search") } }
struct ProfileTab: View { var body: some View { Text("Profile") } }

// === 2b. Enum-based selection (KHUYẾN KHÍCH) ===

enum AppTab: Int, Hashable, CaseIterable {
    case home, search, notifications, profile
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .search: return "Tìm kiếm"
        case .notifications: return "Thông báo"
        case .profile: return "Cá nhân"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .notifications: return "bell.fill"
        case .profile: return "person.fill"
        }
    }
}

struct EnumTabDemo: View {
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Text(tab.title)
                    .tabItem {
                        Image(systemName: tab.icon)
                        Text(tab.title)
                    }
                    .tag(tab)
            }
        }
    }
}


// === 2c. Programmatic tab switching ===

struct ProgrammaticSwitchDemo: View {
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab có button chuyển sang Profile
            VStack(spacing: 20) {
                Text("Home")
                    .font(.largeTitle)
                
                Button("Đi đến Profile") {
                    withAnimation { selectedTab = .profile }
                    // Set selectedTab → TabView TỰ ĐỘNG chuyển tab
                }
                .buttonStyle(.borderedProminent)
                
                Button("Xem Thông báo") {
                    selectedTab = .notifications
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(AppTab.home)
            
            Text("Search").tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }.tag(AppTab.search)
            
            Text("Notifications").tabItem {
                Image(systemName: "bell.fill")
                Text("Thông báo")
            }.tag(AppTab.notifications)
            
            Text("Profile").tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }.tag(AppTab.profile)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3. BADGES — NOTIFICATION INDICATORS (iOS 15+)           ║
// ╚══════════════════════════════════════════════════════════╝

struct BadgeDemo: View {
    @State private var unreadMessages = 5
    @State private var hasUpdate = true
    
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            Text("Chat")
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
                .badge(unreadMessages)
            // Badge số: hiện "5" badge đỏ trên icon
            // .badge(0) → KHÔNG hiện badge
            // .badge(99+) → hiện "99+"
            
            Text("Updates")
                .tabItem {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Updates")
                }
                .badge(hasUpdate ? "NEW" : nil)
            // Badge text: hiện "NEW"
            // .badge(nil) hoặc .badge("") → không hiện
            
            Text("Profile")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .badge(Text("!").foregroundStyle(.orange))
            // Badge với custom Text styling (iOS 17+)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. TINT & APPEARANCE CUSTOMIZATION                      ║
// ╚══════════════════════════════════════════════════════════╝

struct TabAppearanceDemo: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Home").tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }.tag(0)
            
            Text("Search").tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }.tag(1)
            
            Text("Profile").tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }.tag(2)
        }
        
        // === 4a. tint — Đổi màu icon/text đang chọn ===
        .tint(.purple) // Mặc định: .blue → đổi thành .purple
        
        // === 4b. Tab bar background (iOS 16+) ===
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        // .ultraThinMaterial, .thinMaterial, .regularMaterial
        // Color.blue.opacity(0.1)
        
        // === 4c. Tab bar visibility ===
        .toolbarBackground(.visible, for: .tabBar)
        // .visible: luôn hiện background
        // .hidden: ẩn background (transparent)
        // .automatic: hệ thống quyết định
        
        // === 4d. Ẩn hoàn toàn tab bar ===
        // Trên child view (navigation detail):
        // .toolbar(.hidden, for: .tabBar)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. iOS 18 TAB API MỚI — Tab STRUCT                      ║
// ╚══════════════════════════════════════════════════════════╝

// iOS 18 giới thiệu API mới hoàn toàn với Tab struct,
// thay thế .tabItem + .tag pattern.

struct iOS18TabDemo: View {
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        // === 5a. Tab struct — Cú pháp mới ===
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: .home) {
                // Content
                Text("Home Screen")
            }
            
            Tab("Search", systemImage: "magnifyingglass", value: .search) {
                Text("Search Screen")
            }
            
            Tab("Thông báo", systemImage: "bell.fill", value: .notifications) {
                Text("Notifications Screen")
            }
            .badge(3) // Badge trên Tab struct
            
            Tab("Profile", systemImage: "person.fill", value: .profile) {
                Text("Profile Screen")
            }
        }
    }
}

// === 5b. TabSection — Grouped tabs (iPad sidebar) ===

struct TabSectionDemo: View {
    @State private var selectedTab = "home"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Ungrouped tabs
            Tab("Home", systemImage: "house.fill", value: "home") {
                Text("Home")
            }
            
            Tab("Search", systemImage: "magnifyingglass", value: "search") {
                Text("Search")
            }
            
            // Grouped tabs → hiện như section trong sidebar
            TabSection("Library") {
                Tab("Playlists", systemImage: "music.note.list", value: "playlists") {
                    Text("Playlists")
                }
                Tab("Albums", systemImage: "square.stack", value: "albums") {
                    Text("Albums")
                }
                Tab("Artists", systemImage: "music.mic", value: "artists") {
                    Text("Artists")
                }
            }
            
            TabSection("Settings") {
                Tab("General", systemImage: "gear", value: "general") {
                    Text("General Settings")
                }
                Tab("Account", systemImage: "person.circle", value: "account") {
                    Text("Account Settings")
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        // iPhone: tab bar bình thường (top 4-5 tabs)
        // iPad: sidebar với sections
    }
}

// === 5c. Tab customization behavior (iOS 18+) ===

struct TabCustomizationDemo: View {
    @State private var selectedTab = "home"
    @State private var customization = TabViewCustomization()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: "home") {
                Text("Home")
            }
            .customizationID("home") // Enable drag reorder
            
            Tab("Search", systemImage: "magnifyingglass", value: "search") {
                Text("Search")
            }
            .customizationID("search")
            
            Tab("Profile", systemImage: "person.fill", value: "profile") {
                Text("Profile")
            }
            .customizationID("profile")
            .defaultVisibility(.hidden, for: .tabBar)
            // Mặc định ẩn khỏi tab bar, user có thể thêm lại
        }
        .tabViewCustomization($customization)
        // User có thể:
        // - Drag reorder tabs
        // - Ẩn/hiện tabs
        // - Customization persist qua sessions
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. .tabViewStyle(.page) — PAGE SWIPING                  ║
// ╚══════════════════════════════════════════════════════════╝

// TabView với PageTabViewStyle = horizontal paging (carousel/onboarding).
// KHÔNG có tab bar — chỉ swipe trái/phải.

struct PageStyleDemo: View {
    var body: some View {
        // === 6a. Basic page style ===
        TabView {
            ForEach(0..<5) { i in
                ZStack {
                    [Color.blue, .green, .orange, .purple, .red][i]
                        .ignoresSafeArea()
                    
                    VStack {
                        Text("Page \(i + 1)")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                        Text("Swipe trái/phải")
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
        }
        .tabViewStyle(.page)
        // Hiện page dots ở dưới
        
        // === 6b. Control page indicator ===
        // .tabViewStyle(.page(indexDisplayMode: .always))   // Luôn hiện dots
        // .tabViewStyle(.page(indexDisplayMode: .never))    // Ẩn dots
        // .tabViewStyle(.page(indexDisplayMode: .automatic)) // Hệ thống chọn
    }
}


// === 6c. Page indicator style ===

struct PageIndicatorDemo: View {
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<5) { i in
                RoundedRectangle(cornerRadius: 20)
                    .fill([Color.blue, .green, .orange, .purple, .red][i].gradient)
                    .padding()
                    .overlay(Text("Page \(i + 1)").font(.title).foregroundStyle(.white))
                    .tag(i)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // Ẩn built-in dots
        .frame(height: 250)
        
        // Custom page indicators
        HStack(spacing: 8) {
            ForEach(0..<5) { i in
                Capsule()
                    .fill(currentPage == i ? .blue : .gray.opacity(0.3))
                    .frame(width: currentPage == i ? 20 : 8, height: 8)
                    .animation(.spring(duration: 0.3), value: currentPage)
            }
        }
        .padding(.top, 8)
    }
}


// === 6d. Onboarding với Page Style ===

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void
    
    let pages = [
        OnboardingPage(icon: "sparkles", title: "Chào mừng",
                      description: "Khám phá trải nghiệm mới hoàn toàn.",
                      color: .blue),
        OnboardingPage(icon: "bell.badge", title: "Thông báo thông minh",
                      description: "Nhận thông báo đúng lúc, đúng nơi.",
                      color: .purple),
        OnboardingPage(icon: "lock.shield", title: "Bảo mật tuyệt đối",
                      description: "Dữ liệu được mã hoá đầu cuối.",
                      color: .green),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Pages
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: page.icon)
                            .font(.system(size: 72))
                            .foregroundStyle(page.color)
                        
                        Text(page.title)
                            .font(.title.bold())
                        
                        Text(page.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)
            
            // Controls
            VStack(spacing: 16) {
                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Circle()
                            .fill(currentPage == i ? pages[i].color : .gray.opacity(0.3))
                            .frame(width: currentPage == i ? 10 : 7,
                                   height: currentPage == i ? 10 : 7)
                    }
                }
                .animation(.spring(duration: 0.3), value: currentPage)
                
                // Next / Get Started button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Tiếp theo" : "Bắt đầu")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(pages[currentPage].color, in: .rect(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 24)
                
                // Skip button
                if currentPage < pages.count - 1 {
                    Button("Bỏ qua") { onComplete() }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 24)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. TABVIEW + NAVIGATION — KIẾN TRÚC CHUẨN              ║
// ╚══════════════════════════════════════════════════════════╝

// MỖI TAB có NavigationStack RIÊNG — không share navigation.
// Đây là kiến trúc chuẩn cho production apps.

struct TabNavigationDemo: View {
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Mỗi tab = 1 NavigationStack riêng biệt
            NavigationStack {
                HomeScreen(switchTab: { selectedTab = $0 })
                    .navigationTitle("Home")
                    .navigationDestination(for: String.self) { item in
                        DetailScreen(item: item)
                    }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(AppTab.home)
            
            NavigationStack {
                SearchScreen()
                    .navigationTitle("Search")
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(AppTab.search)
            
            NavigationStack {
                NotificationsScreen()
                    .navigationTitle("Notifications")
            }
            .tabItem {
                Image(systemName: "bell.fill")
                Text("Notifications")
            }
            .tag(AppTab.notifications)
            .badge(3)
            
            NavigationStack {
                ProfileScreen()
                    .navigationTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(AppTab.profile)
        }
    }
}

struct HomeScreen: View {
    let switchTab: (AppTab) -> Void
    let items = (1...20).map { "Item \($0)" }
    
    var body: some View {
        List(items, id: \.self) { item in
            NavigationLink(value: item) {
                Text(item)
            }
        }
    }
}

struct DetailScreen: View {
    let item: String
    var body: some View {
        Text("Detail: \(item)")
            .navigationTitle(item)
            .toolbar(.hidden, for: .tabBar)
            // ẨN tab bar khi push vào detail screen
    }
}

struct SearchScreen: View { var body: some View { Text("Search") } }
struct NotificationsScreen: View { var body: some View { Text("Notifications") } }
struct ProfileScreen: View { var body: some View { Text("Profile") } }


// ╔══════════════════════════════════════════════════════════╗
// ║  8. ẨN / HIỆN TAB BAR                                    ║
// ╚══════════════════════════════════════════════════════════╝

struct HideTabBarDemo: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                List(0..<20) { i in
                    NavigationLink("Item \(i)") {
                        Text("Detail \(i)")
                            .navigationTitle("Detail")
                        
                        // === Ẩn tab bar trong detail view ===
                            .toolbar(.hidden, for: .tabBar)
                        // Tab bar ẩn MỊN với animation
                        // Quay lại → tab bar hiện lại tự động
                    }
                }
                .navigationTitle("Items")
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Items")
            }
            .tag(0)
            
            Text("Tab 2")
                .tabItem {
                    Image(systemName: "star")
                    Text("Favorites")
                }
                .tag(1)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. CUSTOM TAB BAR — TỰ BUILD                            ║
// ╚══════════════════════════════════════════════════════════╝

// Khi cần: animated tabs, custom shapes, floating tab bar,
// middle FAB button, gradient backgrounds...

struct CustomTabBarDemo: View {
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case .home: Color.blue.opacity(0.05).overlay(Text("Home").font(.largeTitle))
                case .search: Color.green.opacity(0.05).overlay(Text("Search").font(.largeTitle))
                case .notifications: Color.orange.opacity(0.05).overlay(Text("Notifications").font(.largeTitle))
                case .profile: Color.purple.opacity(0.05).overlay(Text("Profile").font(.largeTitle))
                }
            }
            .ignoresSafeArea()
            
            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab)
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        // Icon with animation
                        ZStack {
                            if selectedTab == tab {
                                Capsule()
                                    .fill(.blue.opacity(0.15))
                                    .frame(width: 56, height: 32)
                                    .matchedGeometryEffect(id: "highlight", in: animation)
                            }
                            
                            Image(systemName: tab.icon)
                                .font(.system(size: 18, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundStyle(selectedTab == tab ? .blue : .gray)
                        }
                        .frame(height: 32)
                        
                        // Label
                        Text(tab.title)
                            .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundStyle(selectedTab == tab ? .blue : .gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: selectedTab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(.ultraThinMaterial)
    }
}


// === 9b. Floating Tab Bar (Capsule) ===

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: selectedTab == tab ? .bold : .regular))
                            .scaleEffect(selectedTab == tab ? 1.15 : 1.0)
                        
                        Circle()
                            .fill(selectedTab == tab ? .blue : .clear)
                            .frame(width: 4, height: 4)
                    }
                    .foregroundStyle(selectedTab == tab ? .blue : .gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: .capsule)
        .shadow(color: .black.opacity(0.12), radius: 15, y: 5)
        .padding(.bottom, 16)
    }
}

#Preview("Floating Tab") {
    @Previewable @State var tab: AppTab = .home
    
    ZStack(alignment: .bottom) {
        Color.gray.opacity(0.05).ignoresSafeArea()
            .overlay(Text(tab.title).font(.largeTitle))
        
        FloatingTabBar(selectedTab: $tab)
    }
}


// === 9c. Tab Bar with Center FAB Button ===

struct FABTabBar: View {
    @Binding var selectedTab: Int
    let onFABTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Left tabs
            tabButton(index: 0, icon: "house.fill", title: "Home")
            tabButton(index: 1, icon: "magnifyingglass", title: "Search")
            
            // Center FAB
            Button(action: onFABTap) {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.blue.gradient, in: .circle)
                    .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
            }
            .offset(y: -16)
            
            // Right tabs
            tabButton(index: 2, icon: "bell.fill", title: "Alerts")
            tabButton(index: 3, icon: "person.fill", title: "Profile")
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .background(.ultraThinMaterial)
    }
    
    func tabButton(index: Int, icon: String, title: String) -> some View {
        Button {
            withAnimation { selectedTab = index }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 10))
            }
            .foregroundStyle(selectedTab == index ? .blue : .gray)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. TABVIEW VỚI @Observable STATE                        ║
// ╚══════════════════════════════════════════════════════════╝

@Observable
final class TabRouter {
    var selectedTab: AppTab = .home
    var notificationBadge = 0
    var homePath = NavigationPath()
    var searchPath = NavigationPath()
    
    // Deep link handling
    func handleDeepLink(_ url: URL) {
        guard let host = url.host() else { return }
        switch host {
        case "home": selectedTab = .home
        case "notifications":
            selectedTab = .notifications
        case "profile":
            selectedTab = .profile
        default: break
        }
    }
    
    // Tap current tab → pop to root
    func tabTapped(_ tab: AppTab) {
        if selectedTab == tab {
            // Tap tab đang active → pop to root
            switch tab {
            case .home: homePath = NavigationPath()
            case .search: searchPath = NavigationPath()
            default: break
            }
        }
        selectedTab = tab
    }
}

struct RouterTabDemo: View {
    @State private var router = TabRouter()
    
    var body: some View {
        TabView(selection: Binding(
            get: { router.selectedTab },
            set: { router.tabTapped($0) }
            // Custom Binding: intercept tab selection
            // để implement "tap to pop to root"
        )) {
            NavigationStack(path: $router.homePath) {
                Text("Home")
                    .navigationTitle("Home")
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(AppTab.home)
            
            NavigationStack(path: $router.searchPath) {
                Text("Search")
                    .navigationTitle("Search")
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(AppTab.search)
            
            Text("Notifications")
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Notifications")
                }
                .tag(AppTab.notifications)
                .badge(router.notificationBadge)
            
            Text("Profile")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(AppTab.profile)
        }
        .environment(router)
        .onOpenURL { url in
            router.handleDeepLink(url)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. PAGE CAROUSEL PATTERNS                               ║
// ╚══════════════════════════════════════════════════════════╝

// === 11a. Image Carousel ===

struct ImageCarousel: View {
    @State private var currentIndex = 0
    let images: [Color] = [.blue, .green, .orange, .purple, .red]
    
    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, color in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.gradient)
                        .padding(.horizontal, 8)
                        .overlay(
                            Text("Image \(index + 1)")
                                .foregroundStyle(.white)
                                .font(.title2.bold())
                        )
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 200)
            
            // Custom dots
            HStack(spacing: 6) {
                ForEach(0..<images.count, id: \.self) { i in
                    Capsule()
                        .fill(currentIndex == i ? .primary : .gray.opacity(0.3))
                        .frame(width: currentIndex == i ? 18 : 6, height: 6)
                }
            }
            .animation(.spring(duration: 0.3), value: currentIndex)
        }
    }
}


// === 11b. Auto-scrolling Banner ===

struct AutoScrollBanner: View {
    @State private var currentPage = 0
    let pageCount = 4
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<pageCount, id: \.self) { i in
                RoundedRectangle(cornerRadius: 16)
                    .fill([Color.blue, .purple, .orange, .green][i].gradient)
                    .padding(.horizontal, 16)
                    .overlay(
                        Text("Banner \(i + 1)")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                    )
                    .tag(i)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 180)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPage = (currentPage + 1) % pageCount
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  12. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: NavigationStack BAO NGOÀI TabView
//    NavigationStack { TabView { ... } }
//    → Push navigation ẢNH HƯỞNG tất cả tabs, tab bar biến mất
//    ✅ FIX: NavigationStack BÊN TRONG mỗi tab
//            TabView { NavigationStack { Tab1() } }

// ❌ PITFALL 2: Tag type mismatch
//    @State var selected = 0
//    Tab().tag("home") // Tag String ≠ selection Int
//    → Tab không bao giờ được chọn
//    ✅ FIX: tag type PHẢI GIỐNG selection type

// ❌ PITFALL 3: .tabItem không hỗ trợ views phức tạp
//    .tabItem { HStack { Image(...); Text(...); Badge() } }
//    → Chỉ Image + Text được render, phần còn lại bị bỏ qua
//    ✅ FIX: Chỉ dùng Image, Text, Label trong .tabItem
//            Custom views → tự build tab bar (Phần 9)

// ❌ PITFALL 4: Tab content RE-INIT khi switch tabs
//    Mỗi lần chọn tab → content view CÓ THỂ bị re-init
//    → Mất scroll position, form state
//    ✅ FIX: @State ở TAB LEVEL hoặc parent
//            SwiftUI giữ state nếu view identity ổn định
//            Tránh dùng conditional content (if/else) cho tabs

// ❌ PITFALL 5: Page style + selection không đồng bộ
//    TabView(selection: $page) { }.tabViewStyle(.page)
//    → Swipe → selection cập nhật, nhưng set selection
//      programmatically đôi khi không animate
//    ✅ FIX: withAnimation { page = newPage }

// ❌ PITFALL 6: Badge không hiện
//    .badge(0) → không hiện (đúng behavior)
//    .badge("") → không hiện
//    ✅ FIX: .badge(count) khi count > 0
//            Hoặc .badge("text") khi text non-empty

// ❌ PITFALL 7: .toolbar(.hidden, for: .tabBar) không hoạt động
//    Đặt modifier SAI view → không ẩn được
//    ✅ FIX: Đặt trên view TRONG NavigationStack (destination)
//            KHÔNG phải trên NavigationStack hoặc TabView

// ❌ PITFALL 8: Environment không cascade qua tabs
//    TabView { Tab1(); Tab2() }.environment(obj)
//    → Thường hoạt động, nhưng nếu tab lazy load → có thể miss
//    ✅ FIX: Inject .environment() ở MỖI tab content nếu không chắc

// ✅ BEST PRACTICES:
// 1. NavigationStack BÊN TRONG mỗi tab, KHÔNG bao ngoài TabView
// 2. Enum cho tab selection (type-safe, scalable)
// 3. .badge() cho notification counts (0 = ẩn tự động)
// 4. .toolbar(.hidden, for: .tabBar) ẩn tab bar trong detail
// 5. Custom Binding intercepting tap → "tap to pop to root"
// 6. @Observable TabRouter cho deep linking + programmatic navigation
// 7. iOS 18 Tab struct cho sidebar-adaptable (iPad)
// 8. Page style cho onboarding, carousels (KHÔNG phải tab navigation)
// 9. Tối đa 5 tabs (HIG) — hơn → "More" tab hoặc sidebar
// 10. Custom tab bar khi cần: animation, FAB, gradient, floating
// 11. Mỗi tab giữ NavigationPath riêng cho independent navigation
// 12. .tint() + .toolbarBackground() cho tab bar appearance
```

---

TabView đã thay đổi lớn ở iOS 18 với Tab API mới, sideBar support, và search integration. Mình sẽ giải thích toàn bộ từ API cũ đến mới cùng các production patterns.Mình đã tổng hợp toàn bộ kiến thức TabView trong 12 phần. Đây là những điểm cốt lõi:

**TabView có 2 công dụng hoàn toàn khác nhau**: tab bar navigation (mặc định) và page-style swiping (`.tabViewStyle(.page)`). iOS 18 là bước nhảy lớn nhất với `Tab` struct, `TabSection`, `.sidebarAdaptable`, và tab customization.

**Năm phần giá trị nhất cho production:**

**Phần 7 — TabView + Navigation Architecture**: **Pitfall #1 lớn nhất** — NavigationStack phải nằm **BÊN TRONG** mỗi tab, không bao ngoài TabView. Sai → push navigation ảnh hưởng tất cả tabs và tab bar biến mất. Mỗi tab có NavigationStack riêng với NavigationPath riêng → independent navigation stacks.

**Phần 10 — TabRouter với @Observable**: Production pattern hoàn chỉnh — `TabRouter` class quản lý selected tab, navigation paths cho từng tab, badge counts, deep link handling. Trick hay nhất: **custom Binding intercept tab tap** — khi user tap tab đang active → pop to root bằng cách reset `NavigationPath()`. Đây là behavior chuẩn của mọi iOS app lớn.

**Phần 5 — iOS 18 Tab API**: API mới `Tab("Title", systemImage:, value:)` clean hơn `.tabItem` + `.tag` cũ. `TabSection` cho phép group tabs thành sections hiện trong sidebar trên iPad. `.tabViewStyle(.sidebarAdaptable)` tự động chuyển đổi tab bar (iPhone) ↔ sidebar (iPad).

**Phần 9 — Custom Tab Bar**: Ba variants production-ready: **Matched Geometry** tab bar (highlight capsule animate giữa tabs), **Floating Capsule** (Material background + shadow), và **FAB Center Button** (nút + tròn nhô lên giữa tab bar). Tất cả dùng ZStack overlay lên content thay vì TabView built-in.

**Phần 6d — Onboarding Page Style**: Component hoàn chỉnh với pages data model, custom page dots (capsule expanding), Next/Skip buttons, color-matched CTA — pattern dùng cho hầu hết mọi app's first-launch experience.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
