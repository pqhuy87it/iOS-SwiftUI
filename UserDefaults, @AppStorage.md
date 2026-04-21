```Swift
// ============================================================
// USERDEFAULTS & @AppStorage TRONG SWIFTUI — CHI TIẾT
// ============================================================
//
// UserDefaults = hệ thống key-value storage NHẸ của Apple.
// Lưu user preferences, settings, small flags.
// Persist qua app launches, updates, reboots.
//
// @AppStorage = SwiftUI property wrapper BỌC UserDefaults.
// Tự động read/write + trigger view re-render khi value đổi.
//
// Kiến trúc:
// ┌───────────────────────────────────────────────────────┐
// │                     @AppStorage                       │
// │              (SwiftUI Property Wrapper)                │
// │      ┌─────────────────────────────────────────┐     │
// │      │           UserDefaults                   │     │
// │      │        (Foundation API)                   │     │
// │      │   ┌───────────────────────────────┐     │     │
// │      │   │     .plist file on disk       │     │     │
// │      │   │  ~/Library/Preferences/       │     │     │
// │      │   │  com.myapp.plist              │     │     │
// │      │   └───────────────────────────────┘     │     │
// │      └─────────────────────────────────────────┘     │
// └───────────────────────────────────────────────────────┘
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  PHẦN I — USERDEFAULTS (Foundation)                       ║
// ╚══════════════════════════════════════════════════════════╝


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CƠ BẢN — ĐỌC / GHI / XOÁ                           ║
// ╚══════════════════════════════════════════════════════════╝

struct UserDefaultsBasicDemo {
    
    static func demo() {
        let defaults = UserDefaults.standard
        
        // ============ GHI (SET) ============
        
        defaults.set("Huy Nguyen", forKey: "username")       // String
        defaults.set(25, forKey: "user_age")                  // Int
        defaults.set(1.75, forKey: "user_height")             // Double
        defaults.set(true, forKey: "is_premium")              // Bool
        defaults.set(Date.now, forKey: "last_login")          // Date
        defaults.set(["Swift", "Dart"], forKey: "languages")  // [String]
        defaults.set(
            ["name": "Huy", "role": "dev"],
            forKey: "user_info"
        ) // [String: Any]
        defaults.set(
            URL(string: "https://example.com"),
            forKey: "website"
        ) // URL
        
        // Data (small)
        let imageData = Data()
        defaults.set(imageData, forKey: "avatar_data")
        
        
        // ============ ĐỌC (GET) ============
        
        let name = defaults.string(forKey: "username")           // String?
        let age = defaults.integer(forKey: "user_age")           // Int (0 nếu nil)
        let height = defaults.double(forKey: "user_height")      // Double (0.0 nếu nil)
        let isPremium = defaults.bool(forKey: "is_premium")      // Bool (false nếu nil)
        let lastLogin = defaults.object(forKey: "last_login") as? Date  // Date?
        let langs = defaults.stringArray(forKey: "languages")    // [String]?
        let info = defaults.dictionary(forKey: "user_info")      // [String: Any]?
        let url = defaults.url(forKey: "website")                // URL?
        let data = defaults.data(forKey: "avatar_data")          // Data?
        
        _ = (name, age, height, isPremium, lastLogin, langs, info, url, data)
        
        // ⚠️ QUAN TRỌNG — Default values khi key chưa tồn tại:
        // .string(forKey:)      → nil
        // .integer(forKey:)     → 0        ← CÓ THỂ GÂY BUG!
        // .double(forKey:)      → 0.0      ← CÓ THỂ GÂY BUG!
        // .bool(forKey:)        → false    ← CÓ THỂ GÂY BUG!
        // .object(forKey:)      → nil
        // .stringArray(forKey:) → nil
        //
        // integer/double/bool trả về GIÁ TRỊ MẶC ĐỊNH thay nil
        // → Không phân biệt được "chưa set" vs "set bằng 0/false"
        
        
        // ============ XOÁ (REMOVE) ============
        
        defaults.removeObject(forKey: "username")
        // Key bị xoá hoàn toàn
        // Lần đọc tiếp: string → nil, integer → 0, bool → false
        
        
        // ============ KIỂM TRA KEY TỒN TẠI ============
        
        // Cách duy nhất chính xác:
        let exists = defaults.object(forKey: "username") != nil
        // .integer/.bool KHÔNG dùng được vì trả 0/false cho cả nil và giá trị thật
        _ = exists
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. REGISTER DEFAULTS — GIÁ TRỊ MẶC ĐỊNH AN TOÀN        ║
// ╚══════════════════════════════════════════════════════════╝

// register(defaults:) set giá trị MẶC ĐỊNH cho keys CHƯA có value.
// Giá trị này KHÔNG persist — chỉ tồn tại trong memory session.
// Gọi 1 lần khi app launch (AppDelegate / App init).

struct RegisterDefaultsDemo {
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            "theme": "system",          // String
            "font_size": 16,            // Int
            "notifications_enabled": true,  // Bool
            "max_cache_mb": 100.0,      // Double
            "onboarding_completed": false,
            "language": "vi",
        ])
        
        // Sau register:
        // defaults.string(forKey: "theme") → "system" (nếu chưa ai set)
        // defaults.integer(forKey: "font_size") → 16 (nếu chưa ai set)
        //
        // Nếu đã set trước đó:
        // defaults.string(forKey: "theme") → giá trị đã set (ưu tiên)
        
        // ⚠️ register KHÔNG ghi đè giá trị đã persist.
        // Chỉ cung cấp fallback cho keys chưa có value.
        // Phải gọi MỖI LẦN app launch (vì không persist).
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3. CODABLE VỚI USERDEFAULTS                             ║
// ╚══════════════════════════════════════════════════════════╝

// UserDefaults CHỈ hỗ trợ Property List types:
// String, Int, Double, Bool, Date, Data, Array, Dictionary
// Custom types → encode thành Data trước.

struct UserSettings: Codable, Equatable {
    var theme: String = "system"
    var fontSize: Int = 16
    var accentColor: String = "blue"
    var recentSearches: [String] = []
    var lastOpenedTab: Int = 0
}

// === Extension để save/load Codable ===

extension UserDefaults {
    func setCodable<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            set(data, forKey: key)
        }
    }
    
    func codable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

// Sử dụng:
struct CodableDefaultsDemo {
    static func demo() {
        let defaults = UserDefaults.standard
        
        // Save
        let settings = UserSettings(theme: "dark", fontSize: 18)
        defaults.setCodable(settings, forKey: "user_settings")
        
        // Load
        let loaded = defaults.codable(UserSettings.self, forKey: "user_settings")
        print(loaded?.theme ?? "nil") // "dark"
        
        // Save array of Codable
        let recentItems = ["item1", "item2", "item3"]
        defaults.setCodable(recentItems, forKey: "recent_items")
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. SUITENAME — APP GROUPS & SHARED DEFAULTS              ║
// ╚══════════════════════════════════════════════════════════╝

// .standard = app's default suite.
// suiteName = SHARED storage giữa app + extensions + widgets.

struct AppGroupDefaultsDemo {
    // App Group: "group.com.myapp.shared"
    // Enable: Xcode > Capabilities > App Groups
    
    static let sharedDefaults = UserDefaults(suiteName: "group.com.myapp.shared")
    
    static func saveForWidget() {
        // Main app ghi
        sharedDefaults?.set("Huy", forKey: "display_name")
        sharedDefaults?.set(42, forKey: "unread_count")
        
        // Widget đọc CÙNG suite → thấy data
    }
    
    static func readInWidget() {
        // Widget code:
        let name = sharedDefaults?.string(forKey: "display_name")
        let count = sharedDefaults?.integer(forKey: "unread_count")
        _ = (name, count)
    }
}

// App Group sharing:
// ┌──────────────────┐     ┌──────────────────┐
// │    Main App      │     │    Widget         │
// │   (Process 1)    │     │   (Process 2)     │
// │                  │     │                   │
// │  sharedDefaults  │     │  sharedDefaults   │
// │  .set("Huy")     │     │  .string() → "Huy"│
// └────────┬─────────┘     └────────┬──────────┘
//          │                        │
//          └──── SHARED .plist ─────┘
//            group.com.myapp.shared


// ╔══════════════════════════════════════════════════════════╗
// ║  5. KVO OBSERVATION — LẮNG NGHE THAY ĐỔI                 ║
// ╚══════════════════════════════════════════════════════════╝

// UserDefaults hỗ trợ KVO — observe key changes.
// Hữu ích khi cần react changes từ extension/widget.

@Observable
final class SettingsManager {
    var theme: String {
        didSet { UserDefaults.standard.set(theme, forKey: "theme") }
    }
    var fontSize: Int {
        didSet { UserDefaults.standard.set(fontSize, forKey: "font_size") }
    }
    
    private var observations: [NSKeyValueObservation] = []
    
    init() {
        let defaults = UserDefaults.standard
        theme = defaults.string(forKey: "theme") ?? "system"
        fontSize = defaults.integer(forKey: "font_size")
        if fontSize == 0 { fontSize = 16 } // Guard default
        
        // Observe changes (từ extension, widget, hoặc code khác)
        observations.append(
            defaults.observe(\.volatileDomainNames, options: [.new]) { _, _ in
                // Generic observation — cần manual key tracking
            }
        )
    }
    
    // Combine approach (nếu dùng Combine):
    // NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
    //     .sink { _ in self.reloadSettings() }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  PHẦN II — @AppStorage (SwiftUI)                          ║
// ╚══════════════════════════════════════════════════════════╝


// ╔══════════════════════════════════════════════════════════╗
// ║  6. @AppStorage CƠ BẢN                                    ║
// ╚══════════════════════════════════════════════════════════╝

// @AppStorage = @State + UserDefaults:
// - Đọc từ UserDefaults
// - Ghi vào UserDefaults khi value đổi
// - Trigger view RE-RENDER khi value đổi (như @State)

struct AppStorageBasicDemo: View {
    // === 6a. Primitive types ===
    @AppStorage("username") private var username = "Guest"
    // Key: "username" trong UserDefaults.standard
    // Default: "Guest" nếu key chưa tồn tại
    
    @AppStorage("is_premium") private var isPremium = false
    @AppStorage("font_size") private var fontSize: Double = 16
    @AppStorage("login_count") private var loginCount = 0
    
    // === 6b. Optional ===
    @AppStorage("last_search") private var lastSearch: String?
    // nil nếu key chưa tồn tại, nil khi removeObject
    
    // === 6c. URL ===
    @AppStorage("avatar_url") private var avatarURL: URL?
    
    // === 6d. Data ===
    @AppStorage("small_cache") private var cacheData: Data?
    
    var body: some View {
        Form {
            Section("Profile") {
                TextField("Username", text: $username)
                // Mỗi keystroke → GHI NGAY vào UserDefaults
                // Tất cả views KHÁC dùng cùng key → TỰ ĐỘNG cập nhật
                
                Toggle("Premium", isOn: $isPremium)
                // Toggle → true/false → UserDefaults cập nhật ngay
                
                Slider(value: $fontSize, in: 12...32, step: 1) {
                    Text("Font: \(Int(fontSize))pt")
                }
            }
            
            Section("Info") {
                Text("Logins: \(loginCount)")
                Text("Last search: \(lastSearch ?? "none")")
            }
        }
        .font(.system(size: fontSize))
        .onAppear {
            loginCount += 1
            // loginCount tăng + persist MỖI LẦN view appear
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. @AppStorage VỚI ENUM (RawRepresentable)               ║
// ╚══════════════════════════════════════════════════════════╝

// @AppStorage hỗ trợ enum conform RawRepresentable
// với RawValue là String hoặc Int.

enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var displayName: String {
        switch self {
        case .system: return "Hệ thống"
        case .light: return "Sáng"
        case .dark: return "Tối"
        }
    }
}

enum AppLanguage: String, CaseIterable {
    case vi = "vi"
    case en = "en"
    case ja = "ja"
}

enum SortOrder: Int, CaseIterable {
    case newest = 0
    case oldest = 1
    case alphabetical = 2
    case popular = 3
    
    var label: String {
        switch self {
        case .newest: return "Mới nhất"
        case .oldest: return "Cũ nhất"
        case .alphabetical: return "A → Z"
        case .popular: return "Phổ biến"
        }
    }
}

struct EnumAppStorageDemo: View {
    @AppStorage("app_theme") private var theme: AppTheme = .system
    @AppStorage("app_language") private var language: AppLanguage = .vi
    @AppStorage("sort_order") private var sortOrder: SortOrder = .newest
    
    var body: some View {
        Form {
            Picker("Theme", selection: $theme) {
                ForEach(AppTheme.allCases, id: \.self) { t in
                    Text(t.displayName).tag(t)
                }
            }
            
            Picker("Language", selection: $language) {
                ForEach(AppLanguage.allCases, id: \.self) { l in
                    Text(l.rawValue.uppercased()).tag(l)
                }
            }
            
            Picker("Sort", selection: $sortOrder) {
                ForEach(SortOrder.allCases, id: \.self) { s in
                    Text(s.label).tag(s)
                }
            }
        }
        .preferredColorScheme(theme.colorScheme)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. @AppStorage VỚI CODABLE (Custom RawRepresentable)     ║
// ╚══════════════════════════════════════════════════════════╝

// @AppStorage KHÔNG hỗ trợ Codable trực tiếp.
// Workaround: conform RawRepresentable với RawValue = String (JSON).

struct AppSettings: Codable, Equatable {
    var accentColor: String = "blue"
    var showBadges: Bool = true
    var maxItems: Int = 50
    var recentSearches: [String] = []
}

// Extension: Codable → RawRepresentable (String/JSON)
extension AppSettings: RawRepresentable {
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(AppSettings.self, from: data)
        else { return nil }
        self = decoded
    }
    
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8)
        else { return "{}" }
        return json
    }
}

struct CodableAppStorageDemo: View {
    @AppStorage("app_settings") private var settings = AppSettings()
    
    var body: some View {
        Form {
            Section("Appearance") {
                TextField("Accent Color", text: $settings.accentColor)
                Toggle("Show Badges", isOn: $settings.showBadges)
                Stepper("Max Items: \(settings.maxItems)",
                        value: $settings.maxItems, in: 10...200, step: 10)
            }
            
            Section("Recent (\(settings.recentSearches.count))") {
                ForEach(settings.recentSearches, id: \.self) { search in
                    Text(search)
                }
            }
            
            Button("Add Search") {
                settings.recentSearches.insert("Query \(Int.random(in: 1...99))", at: 0)
                if settings.recentSearches.count > 10 {
                    settings.recentSearches.removeLast()
                }
                // Toàn bộ struct → JSON → UserDefaults TỰ ĐỘNG
            }
        }
    }
}

// ⚠️ CẢNH BÁO VỀ RawRepresentable APPROACH:
// - Mỗi thay đổi NHỎ → TOÀN BỘ struct → JSON → UserDefaults
// - Struct lớn (nhiều fields, arrays dài) → CHẬM
// - Phù hợp cho: settings nhỏ (< 1KB JSON)
// - KHÔNG phù hợp cho: data lớn, frequent updates


// ╔══════════════════════════════════════════════════════════╗
// ║  9. @AppStorage VỚI APP GROUPS                            ║
// ╚══════════════════════════════════════════════════════════╝

struct AppGroupStorageDemo: View {
    // Shared giữa app + widget + extension
    @AppStorage("display_name", store: UserDefaults(suiteName: "group.com.myapp.shared"))
    private var displayName = "User"
    
    @AppStorage("unread_count", store: UserDefaults(suiteName: "group.com.myapp.shared"))
    private var unreadCount = 0
    
    // Standard (chỉ app chính)
    @AppStorage("internal_flag") private var internalFlag = false
    
    var body: some View {
        Form {
            Section("Shared (App + Widget)") {
                TextField("Display Name", text: $displayName)
                Stepper("Unread: \(unreadCount)", value: $unreadCount)
                Text("Widget cũng thấy data này")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section("App Only") {
                Toggle("Internal Flag", isOn: $internalFlag)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. @AppStorage — SHARING GIỮA NHIỀU VIEWS               ║
// ╚══════════════════════════════════════════════════════════╝

// @AppStorage cùng KEY trên nhiều views → TỰ ĐỘNG ĐỒNG BỘ.
// Thay đổi ở View A → View B re-render ngay.

struct SharedStorageDemo: View {
    var body: some View {
        TabView {
            SettingsTab()
                .tabItem { Label("Settings", systemImage: "gear") }
            
            PreviewTab()
                .tabItem { Label("Preview", systemImage: "eye") }
        }
    }
}

struct SettingsTab: View {
    @AppStorage("app_theme") private var theme: AppTheme = .system
    @AppStorage("font_size") private var fontSize: Double = 16
    @AppStorage("username") private var username = "Guest"
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $username)
                Picker("Theme", selection: $theme) {
                    ForEach(AppTheme.allCases, id: \.self) { Text($0.displayName) }
                }
                Slider(value: $fontSize, in: 12...32, step: 1) {
                    Text("Font: \(Int(fontSize))")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct PreviewTab: View {
    // CÙNG KEYS → tự động nhận giá trị từ SettingsTab
    @AppStorage("app_theme") private var theme: AppTheme = .system
    @AppStorage("font_size") private var fontSize: Double = 16
    @AppStorage("username") private var username = "Guest"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Xin chào, \(username)!")
                    .font(.system(size: fontSize, weight: .bold))
                
                Text("Theme: \(theme.displayName)")
                Text("Font: \(Int(fontSize))pt")
                
                Text("Thay đổi ở tab Settings → tự cập nhật ở đây")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Preview")
            .preferredColorScheme(theme.colorScheme)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. @AppStorage vs @SceneStorage vs @State               ║
// ╚══════════════════════════════════════════════════════════╝

// ┌──────────────────┬──────────────────┬──────────────────┬──────────────────┐
// │                  │ @State           │ @SceneStorage    │ @AppStorage      │
// ├──────────────────┼──────────────────┼──────────────────┼──────────────────┤
// │ Storage          │ Memory           │ Scene restore    │ UserDefaults     │
// │ Persist          │ ❌ Never         │ ✅ System kill   │ ✅ Always        │
// │                  │                  │ ❌ Force quit    │ (kể cả force quit)│
// │ Scope            │ View instance    │ Per scene/window │ TOÀN APP         │
// │ iPad multi-window│ Per view         │ Per window ✅    │ Shared ✅        │
// │ Share across     │ ❌              │ ❌ (per scene)   │ ✅ All views     │
// │ views            │                  │                  │ cùng key         │
// │ Dùng cho         │ Transient UI     │ UI state restore │ User preferences │
// │                  │ (animation,      │ (tab, scroll,    │ (theme, language │
// │                  │  toggle temp)    │  draft, position)│  settings)       │
// │ Widget/Extension │ ❌              │ ❌              │ ✅ (App Groups)  │
// │ iCloud sync      │ ❌              │ ❌              │ ✅ (NSUbiquitous)│
// │ Types            │ Any              │ Primitives       │ Primitives +     │
// │                  │                  │                  │ RawRepresentable │
// │ Performance      │ Fastest          │ Fast             │ I/O on write     │
// └──────────────────┴──────────────────┴──────────────────┴──────────────────┘
//
// 📌 DECISION:
// Animation state, temp toggles       → @State
// Current tab, scroll position, draft  → @SceneStorage
// Theme, language, settings, flags     → @AppStorage


// ╔══════════════════════════════════════════════════════════╗
// ║  12. PRODUCTION PATTERNS                                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 12a. Settings Manager — Centralized Access ===

@Observable
final class PreferencesManager {
    static let shared = PreferencesManager()
    
    private let defaults: UserDefaults
    
    // Keys enum — tránh typo, centralized
    enum Key: String {
        case theme = "pref_theme"
        case fontSize = "pref_font_size"
        case notificationsEnabled = "pref_notifications"
        case biometricEnabled = "pref_biometric"
        case onboardingComplete = "pref_onboarding_done"
        case lastSyncDate = "pref_last_sync"
        case apiEnvironment = "pref_api_env"
    }
    
    // Properties with UserDefaults backing
    var theme: AppTheme {
        get {
            AppTheme(rawValue: defaults.string(forKey: Key.theme.rawValue) ?? "") ?? .system
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.theme.rawValue)
        }
    }
    
    var fontSize: Double {
        get {
            let value = defaults.double(forKey: Key.fontSize.rawValue)
            return value > 0 ? value : 16 // Guard default
        }
        set {
            defaults.set(newValue, forKey: Key.fontSize.rawValue)
        }
    }
    
    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: Key.notificationsEnabled.rawValue) }
        set { defaults.set(newValue, forKey: Key.notificationsEnabled.rawValue) }
    }
    
    var onboardingComplete: Bool {
        get { defaults.bool(forKey: Key.onboardingComplete.rawValue) }
        set { defaults.set(newValue, forKey: Key.onboardingComplete.rawValue) }
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        // Register defaults
        defaults.register(defaults: [
            Key.theme.rawValue: AppTheme.system.rawValue,
            Key.fontSize.rawValue: 16.0,
            Key.notificationsEnabled.rawValue: true,
            Key.onboardingComplete.rawValue: false,
        ])
    }
    
    func resetAll() {
        Key.allCases.forEach { key in
            defaults.removeObject(forKey: key.rawValue)
        }
    }
}

extension PreferencesManager.Key: CaseIterable {}

// Sử dụng trong View:
struct SettingsWithManager: View {
    @State private var prefs = PreferencesManager.shared
    
    var body: some View {
        Form {
            Picker("Theme", selection: $prefs.theme) {
                ForEach(AppTheme.allCases, id: \.self) { Text($0.displayName) }
            }
            Toggle("Notifications", isOn: $prefs.notificationsEnabled)
            Slider(value: $prefs.fontSize, in: 12...32) {
                Text("Font: \(Int(prefs.fontSize))")
            }
            
            Section {
                Button("Reset All", role: .destructive) { prefs.resetAll() }
            }
        }
    }
}


// === 12b. Feature Flags ===

struct FeatureFlags {
    @AppStorage("ff_new_ui") static var newUIEnabled = false
    @AppStorage("ff_dark_mode_v2") static var darkModeV2 = false
    @AppStorage("ff_ai_assistant") static var aiAssistant = false
    @AppStorage("ff_analytics_v3") static var analyticsV3 = true
    
    // Remote config cập nhật flags:
    static func update(from remoteConfig: [String: Bool]) {
        if let value = remoteConfig["new_ui"] { newUIEnabled = value }
        if let value = remoteConfig["dark_mode_v2"] { darkModeV2 = value }
        if let value = remoteConfig["ai_assistant"] { aiAssistant = value }
    }
}

struct FeatureFlaggedView: View {
    @AppStorage("ff_new_ui") private var newUI = false
    
    var body: some View {
        if newUI {
            Text("New UI")
        } else {
            Text("Legacy UI")
        }
    }
}


// === 12c. Onboarding / First Launch ===

struct OnboardingGateView: View {
    @AppStorage("onboarding_completed") private var onboardingDone = false
    @AppStorage("app_version_at_onboarding") private var onboardingVersion = ""
    
    var body: some View {
        Group {
            if onboardingDone {
                MainTabView()
            } else {
                OnboardingFlow {
                    onboardingDone = true
                    onboardingVersion = appVersion
                }
            }
        }
        .animation(.easeInOut, value: onboardingDone)
    }
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

struct MainTabView: View { var body: some View { Text("Main App") } }
struct OnboardingFlow: View {
    let onComplete: () -> Void
    var body: some View {
        VStack {
            Text("Welcome!")
            Button("Get Started", action: onComplete)
        }
    }
}


// === 12d. Migration — Handle version updates ===

struct DefaultsMigration {
    static func migrateIfNeeded() {
        let defaults = UserDefaults.standard
        let currentVersion = 3
        let lastVersion = defaults.integer(forKey: "defaults_schema_version")
        
        guard lastVersion < currentVersion else { return }
        
        // Version 1 → 2: rename key
        if lastVersion < 2 {
            if let oldTheme = defaults.string(forKey: "theme") {
                defaults.set(oldTheme, forKey: "pref_theme")
                defaults.removeObject(forKey: "theme")
            }
        }
        
        // Version 2 → 3: change type
        if lastVersion < 3 {
            // fontSize changed from Int to Double
            let oldSize = defaults.integer(forKey: "pref_font_size")
            if oldSize > 0 {
                defaults.set(Double(oldSize), forKey: "pref_font_size")
            }
        }
        
        defaults.set(currentVersion, forKey: "defaults_schema_version")
    }
}


// === 12e. iCloud Sync (NSUbiquitousKeyValueStore) ===

struct CloudSyncDemo {
    static let cloud = NSUbiquitousKeyValueStore.default
    
    static func setup() {
        // Sync UserDefaults → iCloud
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloud,
            queue: .main
        ) { notification in
            // Data thay đổi từ DEVICE KHÁC
            guard let userInfo = notification.userInfo,
                  let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int
            else { return }
            
            if reason == NSUbiquitousKeyValueStoreServerChange {
                // Sync from cloud → local UserDefaults
                let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? []
                for key in changedKeys {
                    let value = cloud.object(forKey: key)
                    UserDefaults.standard.set(value, forKey: key)
                }
            }
        }
        
        cloud.synchronize() // Trigger sync
    }
    
    // ⚠️ NSUbiquitousKeyValueStore limits:
    // - Max 1MB total
    // - Max 1024 keys
    // - Chỉ property list types
    // - Sync KHÔNG real-time (có delay)
}


// === 12f. Testing with UserDefaults ===

struct TestableDefaults {
    // Tạo isolated UserDefaults cho testing
    static func makeTestDefaults() -> UserDefaults {
        let suiteName = "com.myapp.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        // Clean slate — không có data từ app chính
        return defaults
    }
    
    // Test example:
    static func testPreferencesManager() {
        let testDefaults = makeTestDefaults()
        let manager = PreferencesManager(defaults: testDefaults)
        
        // Assert defaults
        assert(manager.theme == .system)
        assert(manager.fontSize == 16)
        assert(manager.notificationsEnabled == true)
        
        // Modify
        manager.theme = .dark
        assert(manager.theme == .dark)
        
        // Reset
        manager.resetAll()
        assert(manager.theme == .system)
        
        // Cleanup
        testDefaults.removePersistentDomain(forName: testDefaults.description)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  13. GIỚI HẠN & KHI NÀO KHÔNG DÙNG                       ║
// ╚══════════════════════════════════════════════════════════╝

// UserDefaults / @AppStorage KHÔNG phù hợp cho:
//
// ❌ Data lớn (images, files, >1MB)
//    → Dùng: FileManager, Core Data, SwiftData
//
// ❌ Sensitive data (passwords, tokens, API keys)
//    → Dùng: Keychain (Security framework)
//
// ❌ Structured data (relational, queryable)
//    → Dùng: SwiftData, Core Data, SQLite
//
// ❌ Frequently changing data (every frame, timers)
//    → Dùng: @State (in-memory), save periodically
//
// ❌ Large collections (1000+ items)
//    → Dùng: Database, file storage
//
// ✅ PHÙ HỢP cho:
// ✅ User preferences (theme, language, font)
// ✅ Feature flags (bool toggles)
// ✅ Small state (onboarding done, last tab, sort order)
// ✅ Counters (login count, launch count)
// ✅ Simple cache (last search query, recent 5 items)


// ╔══════════════════════════════════════════════════════════╗
// ║  14. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: integer/bool trả 0/false cho key chưa tồn tại
//    let age = defaults.integer(forKey: "age") // 0 — chưa set HAY set = 0?
//    ✅ FIX: register(defaults:) cung cấp meaningful defaults
//            Hoặc dùng object(forKey:) rồi cast: defaults.object(forKey:) as? Int

// ❌ PITFALL 2: Lưu data lớn (images, files)
//    defaults.set(largeImageData, forKey: "avatar") // Vài MB → CHẬM
//    → UserDefaults load TẤT CẢ vào memory khi app launch!
//    ✅ FIX: Lưu FILE PATH trong UserDefaults, data vào FileManager

// ❌ PITFALL 3: Lưu passwords trong UserDefaults
//    defaults.set("secret123", forKey: "password") // ❌ KHÔNG MÃ HOÁ!
//    → .plist file đọc được bằng tool đơn giản
//    ✅ FIX: Keychain cho sensitive data

// ❌ PITFALL 4: Key typos
//    defaults.set(true, forKey: "is_premium")
//    defaults.bool(forKey: "isPremium") // ❌ Khác key → luôn false!
//    ✅ FIX: Enum keys hoặc static constants (Phần 12a)

// ❌ PITFALL 5: @AppStorage với Codable thay đổi schema
//    Thêm/xoá field trong Codable struct → JSON cũ decode FAIL
//    → @AppStorage trả về default value, MẤT data cũ
//    ✅ FIX: Codable với optional fields + default values
//            Hoặc migration logic (Phần 12d)

// ❌ PITFALL 6: @AppStorage trong View init
//    @AppStorage("count") var count = 0 // Default 0
//    // View A: @AppStorage("count") var count = 0
//    // View B: @AppStorage("count") var count = 99
//    // ⚠️ Default value KHÁC NHAU giữa 2 views!
//    // Giá trị thật: cái nào CHẠY TRƯỚC set default cho UserDefaults
//    ✅ FIX: Dùng CÙNG default value cho CÙNG key ở mọi nơi
//            Hoặc register(defaults:) 1 lần duy nhất

// ❌ PITFALL 7: synchronize() không cần nữa
//    defaults.synchronize() // ❌ DEPRECATED behavior
//    → iOS TỰ ĐỘNG sync. Gọi thủ công chỉ lãng phí.
//    ✅ FIX: Bỏ synchronize(). Chỉ cần set() là đủ.

// ❌ PITFALL 8: @AppStorage trên background thread
//    @AppStorage CHỈ update UI trên Main Thread
//    Background thread set UserDefaults → @AppStorage KHÔNG re-render
//    ✅ FIX: Set trên MainActor, hoặc dùng UserDefaults trực tiếp
//            + NotificationCenter observe cho manual refresh

// ✅ BEST PRACTICES:
// 1. Enum keys: tránh typo, centralized, autocomplete
// 2. register(defaults:) gọi 1 lần khi app launch
// 3. @AppStorage cho SwiftUI views, UserDefaults cho logic/services
// 4. App Groups cho widget/extension sharing
// 5. Keychain cho passwords/tokens, KHÔNG UserDefaults
// 6. Giữ data NHỎ: preferences, flags, small state only
// 7. Codable struct qua RawRepresentable cho complex settings
// 8. Migration logic cho schema changes giữa app versions
// 9. Isolated UserDefaults(suiteName:) cho unit testing
// 10. Cùng key → cùng default value ở MỌI nơi sử dụng
// 11. NSUbiquitousKeyValueStore cho iCloud sync (< 1MB)
// 12. KHÔNG synchronize() — iOS tự handle
```

---

UserDefaults và @AppStorage là cặp đôi persistence nhẹ nhất của Apple — hiểu đúng cơ chế, giới hạn, và best practices sẽ tránh được nhiều bugs phổ biến trong production. Mình sẽ giải thích toàn bộ.Mình đã tổng hợp toàn bộ kiến thức UserDefaults và @AppStorage trong 14 phần. Đây là những điểm cốt lõi:

**Quan hệ giữa hai API**: `@AppStorage` là SwiftUI wrapper bọc `UserDefaults` — tự động read/write + trigger view re-render. Dùng `@AppStorage` trong Views, `UserDefaults` trực tiếp trong Services/ViewModels/logic code.

**Ba điểm quan trọng nhất:**

**Phần 1 — Default values nguy hiểm**: `integer(forKey:)` trả `0`, `bool(forKey:)` trả `false` khi key **chưa tồn tại** — không phân biệt được "chưa set" vs "set bằng 0/false". Đây là nguồn bugs cực kỳ phổ biến. Fix bằng `register(defaults:)` ở Phần 2, hoặc dùng `object(forKey:) as? Int` để nhận `nil` rõ ràng.

**Phần 8 — Codable qua RawRepresentable**: `@AppStorage` không hỗ trợ Codable trực tiếp, nhưng conform struct với `RawRepresentable` (rawValue = JSON String) cho phép lưu **bất kỳ Codable struct** nào. Cảnh báo: mỗi thay đổi nhỏ → toàn bộ struct encode → write disk, nên chỉ dùng cho settings nhỏ < 1KB.

**Phần 11 — Decision table**: `@State` cho transient UI (animation, temp toggle), `@SceneStorage` cho UI state restore per-window (tab, scroll, draft), `@AppStorage` cho user preferences toàn app (theme, language, settings). Chọn sai wrapper → data mất khi không mong muốn hoặc persist khi không cần.

**Ba production patterns hay nhất:**

**Phần 12a — PreferencesManager**: Centralized access với enum keys (tránh typo), `register(defaults:)` có meaningful defaults, `resetAll()` cho testing/debug, inject `UserDefaults` instance cho unit test isolation.

**Phần 12d — Migration**: Khi thay đổi key names hoặc value types giữa app versions — check `defaults_schema_version`, migrate data step-by-step. Không migrate → data cũ bị mất hoặc decode fail.

**Phần 13 — Giới hạn**: UserDefaults load **toàn bộ** `.plist` vào memory khi app launch → data lớn (images, files) gây chậm startup. Passwords **không mã hoá** → dùng Keychain. Structured data → SwiftData/Core Data. UserDefaults chỉ cho **small preferences, flags, simple state**.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
