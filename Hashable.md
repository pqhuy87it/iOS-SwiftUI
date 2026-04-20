```Swift
// ============================================================
// HASHABLE TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// Hashable là protocol cho phép 1 giá trị tạo ra INTEGER HASH
// để dùng trong Set, Dictionary, và QUAN TRỌNG nhất — SwiftUI
// dùng Hashable ở KHẮP NƠI để IDENTIFY và DIFF views.
//
// Protocol hierarchy:
//   Equatable ← Hashable ← Identifiable
//                              ↑
//                        SwiftUI yêu cầu cho ForEach, List,
//                        NavigationPath, Picker, TabView...
//
// SwiftUI APIs yêu cầu Hashable:
// - ForEach(items, id: \.self)  → item phải Hashable
// - NavigationPath.append(item) → item phải Hashable
// - Picker selection            → selection type phải Hashable
// - TabView tag                 → tag type phải Hashable
// - List selection              → selection type phải Hashable
// - .navigationDestination(for:)→ data type phải Hashable
// - Set<T>, Dictionary<K, V>   → T, K phải Hashable
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. HASHABLE LÀ GÌ? — CƠ CHẾ HOẠT ĐỘNG                 ║
// ╚══════════════════════════════════════════════════════════╝

// Hashable = khả năng tạo ra 1 số nguyên (hash value)
// ĐẠI DIỆN cho giá trị đó. Dùng để:
// - Tra cứu O(1) trong Set/Dictionary (thay vì O(n))
// - SwiftUI diff: so sánh nhanh views cũ vs mới
// - Identity: phân biệt items trong collections

// === Protocol definition ===
// protocol Hashable: Equatable {
//     func hash(into hasher: inout Hasher)
// }
//
// Hashable KẾ THỪA Equatable:
// → Nếu conform Hashable → PHẢI có == operator
// → 2 giá trị equal (==) → PHẢI có CÙNG hash value
// → 2 giá trị CÙNG hash → KHÔNG nhất thiết equal (collision)

struct HashableExplanation {
    // Hash function example:
    static func demo() {
        var hasher = Hasher()
        hasher.combine("Hello")
        hasher.combine(42)
        let hashValue = hasher.finalize()
        print("Hash: \(hashValue)") // Số nguyên Int
        
        // Mỗi lần chạy app → hash value KHÁC NHAU
        // (Swift randomize seed mỗi launch vì bảo mật)
        
        // Built-in Hashable types:
        let _ = "Hello".hashValue    // String: Hashable ✅
        let _ = 42.hashValue         // Int: Hashable ✅
        let _ = 3.14.hashValue       // Double: Hashable ✅
        let _ = true.hashValue       // Bool: Hashable ✅
        let _ = UUID().hashValue     // UUID: Hashable ✅
        let _ = Date.now.hashValue   // Date: Hashable ✅
        let _ = URL(string: "https://apple.com")!.hashValue // URL: Hashable ✅
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. AUTO-SYNTHESIS — COMPILER TỰ GENERATE                ║
// ╚══════════════════════════════════════════════════════════╝

// Swift compiler TỰ ĐỘNG generate Hashable conformance khi:
// 1. Struct/Enum có TẤT CẢ stored properties/associated values là Hashable
// 2. Khai báo : Hashable (hoặc protocol kế thừa Hashable)

// === 2a. Struct — auto-synthesis ===

struct Product: Hashable {
    let id: UUID          // UUID: Hashable ✅
    let name: String      // String: Hashable ✅
    let price: Double     // Double: Hashable ✅
    let inStock: Bool     // Bool: Hashable ✅
    
    // Compiler TỰ GENERATE:
    // static func == (lhs: Product, rhs: Product) -> Bool { ... }
    // func hash(into hasher: inout Hasher) { ... }
    // Hash = combine(id, name, price, inStock)
}

// === 2b. Enum — auto-synthesis ===

enum Priority: Hashable {
    case low
    case medium
    case high
    case custom(level: Int) // Associated value Int: Hashable ✅
    
    // Auto-generated:
    // .low hash khác .medium khác .high
    // .custom(1) hash khác .custom(2)
}

// === 2c. Enum với RawValue — tự động Hashable ===

enum Category: String, Hashable, CaseIterable {
    case tech = "Công nghệ"
    case design = "Thiết kế"
    case business = "Kinh doanh"
    // RawRepresentable (String raw) → auto Hashable
}

enum StatusCode: Int, Hashable {
    case ok = 200
    case notFound = 404
    case serverError = 500
}

// === 2d. Khi auto-synthesis KHÔNG hoạt động ===

struct UserProfile {
    let id: UUID
    let name: String
    let avatar: UIImage   // ❌ UIImage KHÔNG Hashable!
    // → Compiler KHÔNG thể auto-synthesize Hashable
    // → Phải implement thủ công (Phần 3)
}

// RULE:
// TẤT CẢ stored properties phải Hashable → auto-synthesis ✅
// BẤT KỲ property nào KHÔNG Hashable     → phải implement thủ công


// ╔══════════════════════════════════════════════════════════╗
// ║  3. CUSTOM HASHABLE — IMPLEMENT THỦ CÔNG                 ║
// ╚══════════════════════════════════════════════════════════╝

// === 3a. Khi có property không Hashable ===

struct UserProfileHashable: Hashable {
    let id: UUID
    let name: String
    let avatar: UIImage   // UIImage KHÔNG Hashable
    
    // Equatable: so sánh bằng
    static func == (lhs: UserProfileHashable, rhs: UserProfileHashable) -> Bool {
        // Chỉ so sánh properties CẦN THIẾT cho identity
        lhs.id == rhs.id
    }
    
    // Hashable: tạo hash value
    func hash(into hasher: inout Hasher) {
        // Chỉ hash properties THAM GIA so sánh ==
        hasher.combine(id)
        // ⚠️ KHÔNG hash avatar (vì == cũng không so sánh avatar)
    }
    
    // QUY TẮC VÀNG:
    // Properties trong hash(into:) PHẢI LÀ SUBSET của properties trong ==
    // Nếu a == b → a.hashValue PHẢI == b.hashValue
}

// === 3b. Hash chỉ theo ID (phổ biến nhất) ===

struct Article: Hashable {
    let id: String
    let title: String
    let content: String       // Dài, tốn kém so sánh
    let tags: [String]        // Array<String> hashable nhưng chậm
    let createdAt: Date
    
    // Chỉ hash/compare theo id → NHANH HƠN nhiều
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // ⚠️ TRADE-OFF:
    // 2 Article cùng id nhưng khác title → == trả về TRUE
    // Đúng nếu id là unique identifier (database ID, UUID)
    // Sai nếu cần detect content changes → hash thêm fields
}

// === 3c. Hash nhiều fields (detect content changes) ===

struct TodoItem: Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var priority: Int
    
    // Hash TẤT CẢ fields → detect mọi thay đổi
    // SwiftUI diff sẽ re-render khi BẤT KỲ field nào đổi
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(isCompleted)
        hasher.combine(priority)
    }
    
    // == PHẢI nhất quán với hash
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.priority == rhs.priority
    }
}

// === 3d. Class conform Hashable ===

final class ViewModel: Hashable {
    let id = UUID()
    var title: String
    
    init(title: String) { self.title = title }
    
    // Class: PHẢI implement thủ công (không auto-synthesis)
    static func == (lhs: ViewModel, rhs: ViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    // Hoặc dùng ObjectIdentifier cho reference identity:
    // hasher.combine(ObjectIdentifier(self))
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. HASHABLE vs IDENTIFIABLE — KHÁC BIỆT & QUAN HỆ      ║
// ╚══════════════════════════════════════════════════════════╝

// Identifiable: có property `id` unique
// Hashable: TOÀN BỘ giá trị có thể hash
// Identifiable KHÔNG kế thừa Hashable (và ngược lại)
// Nhưng trong thực tế thường dùng CẢ HAI.

// === Identifiable ONLY — cho ForEach ===
struct TaskA: Identifiable {
    let id = UUID()
    var title: String
    // ForEach(tasks) { task in ... } ✅
    // NavigationPath.append(task) ❌ — cần Hashable
}

// === Hashable ONLY — cho NavigationPath, Picker ===
struct TaskB: Hashable {
    let id: UUID
    var title: String
    // ForEach(tasks, id: \.self) { task in ... } ✅ (id: \.self cần Hashable)
    // NavigationPath.append(task) ✅
    // Nhưng: ForEach(tasks) { task in ... } ❌ — cần Identifiable
}

// === CẢ HAI (KHUYẾN KHÍCH cho SwiftUI) ===
struct TaskC: Identifiable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    
    // ForEach(tasks) { task in ... } ✅ (Identifiable)
    // NavigationPath.append(task) ✅ (Hashable)
    // Picker selection ✅ (Hashable)
    // List selection ✅ (Hashable)
    // Set<TaskC> ✅ (Hashable)
}

// ┌────────────────────────┬──────────────┬──────────────┐
// │ SwiftUI API            │ Identifiable │ Hashable     │
// ├────────────────────────┼──────────────┼──────────────┤
// │ ForEach(data)          │ ✅ Required  │ ❌           │
// │ ForEach(data, id:\.self)│ ❌          │ ✅ Required  │
// │ List(data)             │ ✅ Required  │ ❌           │
// │ List selection         │              │ ✅ Required  │
// │ Picker .tag()          │              │ ✅ Required  │
// │ TabView .tag()         │              │ ✅ Required  │
// │ NavigationPath.append  │              │ ✅ Required  │
// │ .navigationDestination │              │ ✅ Required  │
// │ .sheet(item:)          │ ✅ Required  │              │
// │ .alert(item:)          │ ✅ Required  │              │
// │ Set<T>                 │              │ ✅ Required  │
// │ Dictionary<K,V>        │              │ ✅ (for K)   │
// └────────────────────────┴──────────────┴──────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  5. HASHABLE TRONG ForEach                                ║
// ╚══════════════════════════════════════════════════════════╝

struct ForEachHashableDemo: View {
    // === 5a. Identifiable → ForEach tự dùng .id ===
    struct Item: Identifiable {
        let id = UUID()
        let name: String
    }
    
    let identifiableItems = [Item(name: "A"), Item(name: "B")]
    
    // === 5b. Hashable → id: \.self ===
    let strings = ["Swift", "Kotlin", "Dart"]
    let numbers = [1, 2, 3, 4, 5]
    
    var body: some View {
        List {
            // Identifiable: không cần id parameter
            Section("Identifiable") {
                ForEach(identifiableItems) { item in
                    Text(item.name)
                }
            }
            
            // Hashable: dùng id: \.self
            Section("String (Hashable)") {
                ForEach(strings, id: \.self) { str in
                    Text(str)
                }
                // id: \.self → mỗi String LÀ ID của chính nó
                // ⚠️ Strings PHẢI UNIQUE! Duplicate → SwiftUI confused
            }
            
            // Int cũng Hashable
            Section("Int (Hashable)") {
                ForEach(numbers, id: \.self) { num in
                    Text("Number \(num)")
                }
            }
            
            // Enum CaseIterable + Hashable
            Section("Enum") {
                ForEach(Category.allCases, id: \.self) { cat in
                    Text(cat.rawValue)
                }
            }
        }
    }
}

// ⚠️ id: \.self PITFALL — DUPLICATE VALUES:
//
// let items = ["Apple", "Banana", "Apple"]  // "Apple" xuất hiện 2 lần!
// ForEach(items, id: \.self) { item in ... }
//
// → SwiftUI thấy 2 items cùng id "Apple"
// → Behavior UNDEFINED: có thể render sai, animation lỗi, crash
//
// ✅ FIX: Dùng model Identifiable với UUID
//         Hoặc đảm bảo data UNIQUE khi dùng id: \.self


// ╔══════════════════════════════════════════════════════════╗
// ║  6. HASHABLE TRONG NAVIGATION                             ║
// ╚══════════════════════════════════════════════════════════╝

// NavigationPath và .navigationDestination(for:) yêu cầu Hashable.

// === 6a. NavigationPath ===

struct NavigationHashableDemo: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 12) {
                // Append KHÁC TYPES vào cùng path — tất cả phải Hashable
                Button("Go to Article") {
                    let article = ArticleRoute(id: "a1", title: "SwiftUI")
                    path.append(article) // ArticleRoute: Hashable ✅
                }
                
                Button("Go to Profile") {
                    let profile = ProfileRoute(userID: "u1")
                    path.append(profile) // ProfileRoute: Hashable ✅
                }
                
                Button("Go to Settings") {
                    path.append("settings") // String: Hashable ✅
                }
            }
            .navigationTitle("Home")
            
            // Mỗi type cần 1 .navigationDestination
            .navigationDestination(for: ArticleRoute.self) { route in
                Text("Article: \(route.title)")
            }
            .navigationDestination(for: ProfileRoute.self) { route in
                Text("Profile: \(route.userID)")
            }
            .navigationDestination(for: String.self) { value in
                Text("Page: \(value)")
            }
        }
    }
}

struct ArticleRoute: Hashable {
    let id: String
    let title: String
}

struct ProfileRoute: Hashable {
    let userID: String
}

// === 6b. NavigationLink(value:) — value phải Hashable ===

struct NavLinkHashableDemo: View {
    let articles = [
        ArticleRoute(id: "1", title: "SwiftUI Layout"),
        ArticleRoute(id: "2", title: "Combine Framework"),
    ]
    
    var body: some View {
        NavigationStack {
            List(articles, id: \.id) { article in
                // value phải Hashable → ArticleRoute: Hashable ✅
                NavigationLink(value: article) {
                    Text(article.title)
                }
            }
            .navigationDestination(for: ArticleRoute.self) { route in
                Text("Detail: \(route.title)")
            }
        }
    }
}

// === 6c. Type-safe Route enum (Hashable) ===

enum AppRoute: Hashable {
    case articleDetail(id: String)    // String: Hashable
    case profile(userID: String)     // String: Hashable
    case settings
    case category(Category)          // Category: Hashable (enum)
    
    // Enum + associated values đều Hashable → auto-synthesis ✅
}

struct RouteEnumDemo: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Button("Article") { path.append(AppRoute.articleDetail(id: "a1")) }
                Button("Profile") { path.append(AppRoute.profile(userID: "u1")) }
                Button("Settings") { path.append(AppRoute.settings) }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .articleDetail(let id):
                    Text("Article: \(id)")
                case .profile(let userID):
                    Text("Profile: \(userID)")
                case .settings:
                    Text("Settings")
                case .category(let cat):
                    Text("Category: \(cat.rawValue)")
                }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. HASHABLE TRONG PICKER, TABVIEW, LIST SELECTION        ║
// ╚══════════════════════════════════════════════════════════╝

struct SelectionHashableDemo: View {
    // === 7a. Picker — selection + tag phải CÙNG Hashable type ===
    @State private var selectedCategory: Category = .tech
    @State private var selectedPriority: Priority = .medium
    
    // === 7b. TabView — tag phải Hashable ===
    @State private var selectedTab: AppTab = .home
    
    // === 7c. List — selection phải Hashable ===
    @State private var selectedItems: Set<String> = []
    // Set<String> → String phải Hashable ✅
    
    var body: some View {
        VStack {
            // Picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(Category.allCases, id: \.self) { cat in
                    Text(cat.rawValue).tag(cat) // tag type = Category: Hashable
                }
            }
            
            // TabView
            TabView(selection: $selectedTab) {
                Text("Home").tag(AppTab.home)       // tag type = AppTab: Hashable
                Text("Search").tag(AppTab.search)
            }
            
            // List multi-selection
            List(["A", "B", "C"], id: \.self, selection: $selectedItems) { item in
                Text(item)
            }
            // selection: Set<String> → String: Hashable ✅
        }
    }
}

enum AppTab: String, Hashable {
    case home, search, profile
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. HASHABLE TRONG SET & DICTIONARY                       ║
// ╚══════════════════════════════════════════════════════════╝

struct SetDictionaryDemo: View {
    // Set: element phải Hashable
    @State private var favoriteIDs: Set<String> = ["id1", "id3"]
    
    // Dictionary: KEY phải Hashable
    @State private var cache: [String: Data] = [:]  // String key: Hashable
    
    // Custom type trong Set
    @State private var selectedTags: Set<Tag> = []
    
    struct Tag: Hashable {
        let id: String
        let name: String
    }
    
    let allTags = [
        Tag(id: "1", name: "Swift"),
        Tag(id: "2", name: "iOS"),
        Tag(id: "3", name: "SwiftUI"),
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Toggle tags in/out of Set
            HStack {
                ForEach(allTags, id: \.id) { tag in
                    let isSelected = selectedTags.contains(tag)
                    // .contains() dùng HASH để tìm O(1) ← Hashable quan trọng!
                    
                    Button {
                        if isSelected { selectedTags.remove(tag) }
                        else { selectedTags.insert(tag) }
                    } label: {
                        Text(tag.name)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                isSelected ? .blue : .gray.opacity(0.15),
                                in: .capsule
                            )
                            .foregroundStyle(isSelected ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Text("Selected: \(selectedTags.map(\.name).joined(separator: ", "))")
                .font(.caption)
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. HASHABLE VỚI @Observable & SwiftData @Model           ║
// ╚══════════════════════════════════════════════════════════╝

// === 9a. @Observable class — phải implement thủ công ===

@Observable
final class TaskModel: Hashable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
    
    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
    
    // Class: KHÔNG auto-synthesis → implement thủ công
    static func == (lhs: TaskModel, rhs: TaskModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ObservableHashableDemo: View {
    @State private var tasks = [
        TaskModel(title: "Buy milk"),
        TaskModel(title: "Code review"),
    ]
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List(tasks, id: \.id) { task in
                NavigationLink(value: task) { // task: Hashable ✅
                    Text(task.title)
                }
            }
            .navigationDestination(for: TaskModel.self) { task in
                Text("Detail: \(task.title)")
            }
        }
    }
}

// === 9b. SwiftData @Model — tự conform Hashable ===

// @Model
// final class Item {
//     var title: String
//     var timestamp: Date
//     init(title: String, timestamp: Date = .now) {
//         self.title = title
//         self.timestamp = timestamp
//     }
// }
//
// @Model tự động conform:
// - PersistentModel
// - Observable
// - Hashable (hash theo persistentModelID)
// - Identifiable (id = persistentModelID)
//
// → Dùng trực tiếp trong ForEach, NavigationPath, Picker, Set


// ╔══════════════════════════════════════════════════════════╗
// ║  10. ADVANCED PATTERNS                                    ║
// ╚══════════════════════════════════════════════════════════╝

// === 10a. AnyHashable — Type Erasure ===

struct AnyHashableDemo: View {
    // AnyHashable cho phép trộn NHIỀU Hashable types trong 1 collection
    @State private var mixedItems: [AnyHashable] = [
        AnyHashable("String value"),
        AnyHashable(42),
        AnyHashable(ArticleRoute(id: "1", title: "Test")),
    ]
    
    var body: some View {
        List(mixedItems, id: \.self) { item in
            // Type check để render
            if let str = item as? String {
                Text("String: \(str)")
            } else if let num = item as? Int {
                Text("Int: \(num)")
            } else if let route = item as? ArticleRoute {
                Text("Route: \(route.title)")
            }
        }
    }
    // ⚠️ AnyHashable mất type safety → dùng cẩn thận
    // Prefer: enum với associated values thay AnyHashable
}


// === 10b. Hashable wrapper cho non-Hashable types ===

struct HashableImage: Hashable {
    let id: String        // Unique identifier
    let image: UIImage    // UIImage: NOT Hashable
    
    static func == (lhs: HashableImage, rhs: HashableImage) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Generic wrapper:
struct HashableWrapper<Value>: Hashable {
    let id: String
    let value: Value
    
    static func == (lhs: HashableWrapper, rhs: HashableWrapper) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


// === 10c. Hashable Codable model (API response) ===

struct APIUser: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let avatarURL: URL?
    
    // Tất cả properties (Int, String, URL?) đều Hashable
    // → Auto-synthesis hoạt động ✅
    // → Dùng được trong: ForEach, NavigationPath, Set, Picker
}

struct APIPost: Codable, Hashable, Identifiable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
    let tags: [String]  // [String]: Hashable ✅ (Array<Hashable>)
    
    // Auto-synthesis ✅ vì tất cả fields đều Hashable
}


// === 10d. Performance: hash chỉ theo ID ===

struct LargeModel: Hashable, Identifiable {
    let id: UUID
    let title: String
    let content: String         // Rất dài
    let metadata: [String: String]  // Nhiều entries
    let attachments: [Data]     // Nhiều data blobs
    
    // ❌ Auto-synthesis: hash TẤT CẢ fields → RẤT CHẬM
    // ✅ Custom: hash chỉ ID → O(1)
    
    static func == (lhs: LargeModel, rhs: LargeModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // ⚠️ Trade-off: content thay đổi nhưng id giữ nguyên
    //    → SwiftUI KHÔNG detect thay đổi (== vẫn true)
    //    → Nếu cần detect content changes: hash thêm relevant fields
    //    → Hoặc tách: Hashable cho navigation, Equatable cho diffing
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. PRODUCTION PATTERN — COMPLETE APP MODEL LAYER        ║
// ╚══════════════════════════════════════════════════════════╝

// Model layer chuẩn cho SwiftUI app:

// --- Domain Models ---

struct User: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let email: String
    let role: UserRole
}

enum UserRole: String, Codable, Hashable, CaseIterable {
    case admin, editor, viewer
    
    var displayName: String {
        switch self {
        case .admin: return "Quản trị"
        case .editor: return "Biên tập"
        case .viewer: return "Người xem"
        }
    }
}

struct Post: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let excerpt: String
    let authorID: String
    let category: PostCategory
    let tags: [String]
    let publishedAt: Date
}

enum PostCategory: String, Codable, Hashable, CaseIterable {
    case tech, design, business, lifestyle
}

// --- Route Models (Navigation) ---

enum Route: Hashable {
    case postDetail(Post)
    case userProfile(User)
    case category(PostCategory)
    case settings
    case editPost(id: String)
}

// --- Usage trong View ---

struct ProductionApp: View {
    @State private var path = NavigationPath()
    @State private var selectedTab: AppTab = .home
    @State private var selectedCategory: PostCategory = .tech
    @State private var selectedPosts: Set<String> = []  // Set<String>: Hashable
    
    let posts: [Post] = []
    
    var body: some View {
        TabView(selection: $selectedTab) {  // AppTab: Hashable
            NavigationStack(path: $path) {  // NavigationPath: type-erased Hashable
                List(posts, selection: $selectedPosts) { post in  // Identifiable + Hashable
                    NavigationLink(value: Route.postDetail(post)) {  // Route: Hashable
                        Text(post.title)
                    }
                }
                .navigationDestination(for: Route.self) { route in  // Route: Hashable
                    switch route {
                    case .postDetail(let post): Text(post.title)
                    case .userProfile(let user): Text(user.name)
                    case .category(let cat): Text(cat.rawValue)
                    case .settings: Text("Settings")
                    case .editPost(let id): Text("Edit \(id)")
                    }
                }
            }
            .tabItem { Text("Home") }
            .tag(AppTab.home)  // AppTab: Hashable
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  12. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Duplicate values với id: \.self
//    ForEach(["A", "B", "A"], id: \.self) // 2 items cùng hash "A"
//    → SwiftUI confused, animation sai, possible crash
//    ✅ FIX: Đảm bảo data UNIQUE, hoặc dùng Identifiable model

// ❌ PITFALL 2: hash(into:) không nhất quán với ==
//    a == b trả về true NHƯNG a.hashValue ≠ b.hashValue
//    → Vi phạm Hashable contract → crash Set/Dictionary
//    ✅ FIX: Properties trong hash() PHẢI là SUBSET của ==
//            Nếu a == b → PHẢI có hash(a) == hash(b)

// ❌ PITFALL 3: Hash TẤT CẢ fields cho model lớn → chậm
//    struct BigModel: Hashable { /* 20 fields, auto-synthesis */ }
//    → hash() combine 20 fields mỗi lần → performance kém
//    ✅ FIX: Custom hash chỉ theo id (hoặc vài key fields)

// ❌ PITFALL 4: Class quên implement Hashable
//    class MyModel: Hashable { } // ❌ Compile error
//    → Class KHÔNG auto-synthesis — phải viết == và hash(into:)
//    ✅ FIX: Implement thủ công hoặc dùng struct

// ❌ PITFALL 5: Picker tag type mismatch
//    @State var selected: Category = .tech
//    Text("Tech").tag("tech") // tag String ≠ selection Category
//    → Picker không hoạt động, KHÔNG báo lỗi compile!
//    ✅ FIX: .tag(Category.tech) — cùng type với selection

// ❌ PITFALL 6: Array là Hashable (khi Element: Hashable)
//    let tags: [String] // [String]: Hashable ✅
//    → Auto-synthesis hoạt động
//    ⚠️ NHƯNG: hash array DÀI → chậm, cân nhắc exclude khỏi hash

// ❌ PITFALL 7: Optional<Hashable> là Hashable
//    let url: URL?  // URL?: Hashable ✅
//    nil.hashValue khác "some".hashValue ✅

// ✅ BEST PRACTICES:
// 1. Conform CÙNG LÚC Identifiable + Hashable cho SwiftUI models
// 2. Enum + CaseIterable + Hashable cho selection types (Picker, Tab)
// 3. Codable + Hashable cho API response models
// 4. Custom hash(into:) cho models lớn — chỉ hash id
// 5. Route enum: Hashable cho type-safe NavigationPath
// 6. Auto-synthesis khi TẤT CẢ fields Hashable + model nhỏ
// 7. Manual hash khi: có non-Hashable field, model lớn, class
// 8. NEVER: hash(a) ≠ hash(b) khi a == b (vi phạm contract)
// 9. String/Int/enum id: \.self CHỈ khi data GUARANTEED unique
// 10. @Model (SwiftData) tự conform Hashable — không cần làm gì
```

---

`Hashable` là protocol nền tảng mà SwiftUI phụ thuộc ở khắp nơi — từ `ForEach`, `NavigationPath`, `Picker` selection đến `Set`, `Dictionary`, và diffing algorithm. Mình sẽ giải thích toàn bộ từ cơ chế hash đến cách SwiftUI dùng nó.Mình đã tổng hợp toàn bộ kiến thức Hashable trong 12 phần. Đây là những điểm cốt lõi:

**Hashable là "invisible glue"** mà SwiftUI dùng ở khắp nơi — ForEach diffing, NavigationPath routing, Picker/TabView selection, List selection, Set/Dictionary operations. Không hiểu Hashable → không hiểu tại sao SwiftUI hoạt động (hoặc không hoạt động).

**Năm phần giá trị nhất:**

**Phần 2 — Auto-synthesis**: Swift compiler tự generate `hash(into:)` và `==` khi **tất cả stored properties đều Hashable**. Struct tự động, enum tự động (kể cả associated values). Class **không bao giờ** auto-synthesis — phải viết tay. Biết rule này giúp quyết định nhanh: auto hay manual.

**Phần 3 — Custom hash chỉ theo ID**: Production pattern quan trọng nhất. Model lớn (20 fields) mà auto-synthesis hash tất cả → chậm. Custom `hash(into:)` chỉ combine `id` → O(1). Trade-off: content thay đổi mà id giữ nguyên thì SwiftUI không detect → nếu cần detect content changes thì hash thêm relevant fields.

**Phần 4 — Hashable vs Identifiable**: Bảng tra quan trọng — `ForEach(data)` cần Identifiable, `NavigationPath.append()` cần Hashable, `Picker .tag()` cần Hashable, `.sheet(item:)` cần Identifiable. Best practice: conform **cả hai** (`Identifiable, Hashable`) cho mọi SwiftUI model.

**Phần 6 — Navigation với Hashable**: `NavigationPath` là type-erased Hashable container — append bất kỳ Hashable type nào. Pattern `enum Route: Hashable` với associated values cho type-safe routing: `.articleDetail(Post)`, `.profile(User)`, `.settings` — tất cả auto-synthesis Hashable vì associated values đều Hashable.

**Phần 3 — Quy tắc vàng**: Properties trong `hash(into:)` **phải là subset** của properties trong `==`. Nếu `a == b` trả về `true` thì `hash(a)` **bắt buộc** bằng `hash(b)`. Vi phạm → Set/Dictionary crash hoặc behavior undefined. Ngược lại không bắt buộc: hash bằng nhau không nhất thiết equal (hash collision là bình thường).

Huy muốn mình đi tiếp sang chủ đề nào khác không?
