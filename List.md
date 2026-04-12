```
// ============================================================
// LIST TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// List là scrollable container hiển thị rows theo chiều dọc,
// tương đương UITableView nhưng với API declarative.
//
// List khác ScrollView + LazyVStack ở nhiều điểm:
// - Cell REUSE thật sự (memory ổn định cho 100K+ items)
// - Built-in: swipe actions, selection, edit mode, separators
// - Section headers/footers native
// - Pull-to-refresh, searchable tích hợp
// - ListStyle thay đổi toàn bộ giao diện
//
// Đây là component dùng NHIỀU NHẤT cho Settings, Feeds,
// Master-Detail, Chat, Contacts, và hầu hết data lists.
// ============================================================
```

```Swift
import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÁC CÁCH KHỞI TẠO LIST                              ║
// ╚══════════════════════════════════════════════════════════╝

// === 1a. Static rows ===
struct StaticListDemo: View {
    var body: some View {
        List {
            Text("Dòng 1")
            Text("Dòng 2")
            Text("Dòng 3")
            // Mỗi child view tự động thành 1 row
        }
    }
}

// === 1b. Dynamic rows — ForEach + Identifiable ===
struct Task: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

struct DynamicListDemo: View {
    @State private var tasks = [
        Task(title: "Mua sữa", isCompleted: false),
        Task(title: "Code review", isCompleted: true),
        Task(title: "Tập gym", isCompleted: false),
    ]
    
    var body: some View {
        List {
            ForEach(tasks) { task in
                Text(task.title)
            }
        }
    }
}

// === 1c. Direct data binding — List(data) ===
struct DirectDataList: View {
    let items = ["Swift", "Kotlin", "Dart", "TypeScript"]
    
    var body: some View {
        // Shorthand: truyền data trực tiếp
        List(items, id: \.self) { item in
            Text(item)
        }
    }
}

// === 1d. Mixed static + dynamic ===
struct MixedListDemo: View {
    let recents = ["SwiftUI", "Combine"]
    let favorites = ["Swift", "Dart", "Rust"]
    
    var body: some View {
        List {
            // Static row
            Text("Tất cả ngôn ngữ")
                .font(.headline)
            
            // Dynamic section
            Section("Gần đây") {
                ForEach(recents, id: \.self) { item in
                    Text(item)
                }
            }
            
            Section("Yêu thích") {
                ForEach(favorites, id: \.self) { item in
                    Text(item)
                }
            }
        }
    }
}

// === 1e. Binding collection — Editable rows (iOS 15+) ===
struct EditableListDemo: View {
    @State private var tasks = [
        Task(title: "Mua sữa", isCompleted: false),
        Task(title: "Code review", isCompleted: true),
    ]
    
    var body: some View {
        List($tasks) { $task in
            // $tasks → ForEach cung cấp Binding<Task> cho mỗi row
            Toggle(task.title, isOn: $task.isCompleted)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. SECTIONS — NHÓM ROWS                                 ║
// ╚══════════════════════════════════════════════════════════╝

struct SectionDemo: View {
    var body: some View {
        List {
            // === 2a. Section với header text ===
            Section("Tài khoản") {
                Label("Hồ sơ", systemImage: "person")
                Label("Bảo mật", systemImage: "lock")
                Label("Thông báo", systemImage: "bell")
            }
            
            // === 2b. Header + Footer ===
            Section {
                Toggle("Wi-Fi", isOn: .constant(true))
                Toggle("Bluetooth", isOn: .constant(false))
            } header: {
                Text("Kết nối")
            } footer: {
                Text("Tắt Wi-Fi và Bluetooth để tiết kiệm pin.")
                    .font(.caption)
            }
            
            // === 2c. Custom header view ===
            Section {
                Text("Item 1")
                Text("Item 2")
            } header: {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Yêu thích")
                        .font(.headline)
                }
            }
            
            // === 2d. Collapsible Section (iOS 17+) ===
            Section("Nâng cao", isExpanded: .constant(true)) {
                Text("Option A")
                Text("Option B")
                Text("Option C")
            }
            
            // === 2e. Section visibility ===
            // Header mặc định UPPERCASE trên .insetGrouped
            // Muốn giữ nguyên case:
            Section {
                Text("Content")
            } header: {
                Text("Giữ nguyên chữ thường")
                    .textCase(nil) // Disable auto-uppercase
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3. LIST STYLES — CÁC KIỂU GIAO DIỆN                    ║
// ╚══════════════════════════════════════════════════════════╝

struct ListStyleDemo: View {
    var body: some View {
        // Thay .listStyle() để xem từng style:
        
        List {
            Section("Section 1") {
                Text("Row A")
                Text("Row B")
            }
            Section("Section 2") {
                Text("Row C")
                Text("Row D")
            }
        }
        .listStyle(.insetGrouped) // ← Thay đổi ở đây
    }
}

// ┌──────────────────────┬──────────┬──────────────────────────────┐
// │ Style                │ Min iOS  │ Mô tả                       │
// ├──────────────────────┼──────────┼──────────────────────────────┤
// │ .automatic           │ 13       │ Platform tự chọn (default)   │
// │ .insetGrouped        │ 14       │ Rounded cards, spaced groups │
// │                      │          │ → Giống Settings app         │
// │ .grouped             │ 13       │ Full-width groups, gray bg   │
// │ .inset               │ 14       │ Single group, inset margins  │
// │ .plain               │ 13       │ Không background, sát lề     │
// │                      │          │ → Giống Messages, Contacts   │
// │ .sidebar             │ 14       │ iPadOS/macOS sidebar style   │
// └──────────────────────┴──────────┴──────────────────────────────┘
//
// 📌 NGUYÊN TẮC CHỌN:
// Settings / Form-like      → .insetGrouped
// Feed / Chat / Messages    → .plain
// Master list / File browser → .sidebar (iPad)
// Simple data list          → .inset hoặc .plain


// ╔══════════════════════════════════════════════════════════╗
// ║  4. ROW STYLING — TUỲ CHỈNH TỪNG ROW                    ║
// ╚══════════════════════════════════════════════════════════╝

struct RowStylingDemo: View {
    var body: some View {
        List {
            // === 4a. listRowBackground — Background tuỳ chỉnh ===
            Text("Custom background")
                .listRowBackground(Color.blue.opacity(0.1))
            
            // === 4b. listRowSeparator — Ẩn/Hiện separator ===
            Text("Không có separator dưới")
                .listRowSeparator(.hidden)
            
            Text("Separator bình thường")
            
            // === 4c. listRowSeparatorTint ===
            Text("Separator màu đỏ")
                .listRowSeparatorTint(.red)
            
            // === 4d. listRowInsets — Custom padding ===
            Text("Insets tuỳ chỉnh")
                .listRowInsets(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 16))
            
            // === 4e. listItemTint — Tint cho row ===
            Label("Tinted row", systemImage: "star.fill")
                .listItemTint(.orange)
            
            // === 4f. Ẩn separator toàn bộ List ===
            // Đặt modifier trên List thay vì từng row:
        }
        .listSectionSeparator(.hidden) // Ẩn separator giữa sections
    }
}

// === Apply row styling cho TẤT CẢ rows ===
struct GlobalRowStyling: View {
    let items = (1...10).map { "Item \($0)" }
    
    var body: some View {
        List(items, id: \.self) { item in
            Text(item)
        }
        .listRowSpacing(8)                // iOS 17+: khoảng cách giữa rows
        .listSectionSpacing(16)           // iOS 17+: khoảng cách giữa sections
        .listRowSeparator(.hidden)        // Ẩn separator toàn bộ
        .scrollContentBackground(.hidden) // iOS 16+: xoá default background
        .background(Color.gray.opacity(0.05))
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. SWIPE ACTIONS                                        ║
// ╚══════════════════════════════════════════════════════════╝

struct SwipeActionsDemo: View {
    @State private var items = [
        Task(title: "Mua sữa", isCompleted: false),
        Task(title: "Code review", isCompleted: true),
        Task(title: "Tập gym", isCompleted: false),
        Task(title: "Đọc sách", isCompleted: false),
    ]
    
    @State private var pinnedIDs: Set<UUID> = []
    
    var body: some View {
        List {
            ForEach(items) { task in
                HStack {
                    if pinnedIDs.contains(task.id) {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                    Spacer()
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.green)
                    }
                }
                // === Trailing swipe (mặc định: phải → trái) ===
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    // Nút đầu tiên = full swipe action
                    Button(role: .destructive) {
                        withAnimation {
                            items.removeAll { $0.id == task.id }
                        }
                    } label: {
                        Label("Xoá", systemImage: "trash")
                    }
                    // role: .destructive → background đỏ tự động
                    
                    Button {
                        // Archive action
                    } label: {
                        Label("Lưu trữ", systemImage: "archivebox")
                    }
                    .tint(.blue)
                }
                // === Leading swipe (trái → phải) ===
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        if pinnedIDs.contains(task.id) {
                            pinnedIDs.remove(task.id)
                        } else {
                            pinnedIDs.insert(task.id)
                        }
                    } label: {
                        Label(
                            pinnedIDs.contains(task.id) ? "Bỏ ghim" : "Ghim",
                            systemImage: pinnedIDs.contains(task.id) ? "pin.slash" : "pin"
                        )
                    }
                    .tint(.orange)
                }
            }
        }
    }
}

// SWIPE ACTIONS RULES:
// - allowsFullSwipe: true → swipe hết → trigger nút ĐẦU TIÊN
// - Nút ĐẦU TIÊN trong .swipeActions = nút GẦN RÌA nhất
// - role: .destructive → background đỏ, animation remove
// - .tint() đổi background color cho từng button
// - Trailing: phải→trái (phổ biến: delete, archive)
// - Leading: trái→phải (phổ biến: pin, unread, flag)


// ╔══════════════════════════════════════════════════════════╗
// ║  6. SELECTION — CHỌN ROWS                                ║
// ╚══════════════════════════════════════════════════════════╝

struct SelectionDemo: View {
    let languages = ["Swift", "Kotlin", "Dart", "TypeScript", "Rust", "Go"]
    
    // === 6a. Single selection ===
    @State private var singleSelection: String?
    
    // === 6b. Multi selection ===
    @State private var multiSelection: Set<String> = []
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationStack {
            List(languages, id: \.self, selection: $multiSelection) { lang in
                Text(lang)
            }
            .navigationTitle("Ngôn ngữ (\(multiSelection.count))")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                    // Tap Edit → vào edit mode → checkmarks xuất hiện
                    // Tap row → toggle selection
                }
                
                if !multiSelection.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Xoá \(multiSelection.count) mục") {
                            // Xoá selected items
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
    }
}

// SELECTION RULES:
// - selection: Binding<V?> → single select (Optional)
// - selection: Binding<Set<V>> → multi select
// - Multi select CHỈ HOẠT ĐỘNG trong edit mode
// - Single select hoạt động cả ngoài edit mode (iOS 16+)
// - V phải Hashable
// - Checkmarks tự động hiện khi selection active


// ╔══════════════════════════════════════════════════════════╗
// ║  7. EDIT MODE — DELETE, MOVE, REORDER                    ║
// ╚══════════════════════════════════════════════════════════╝

struct EditModeDemo: View {
    @State private var items = ["Swift", "Kotlin", "Dart", "TypeScript", "Rust"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                // === 7a. Swipe-to-delete ===
                .onDelete(perform: deleteItems)
                
                // === 7b. Drag-to-reorder ===
                .onMove(perform: moveItems)
            }
            .navigationTitle("Ngôn ngữ")
            .toolbar {
                // EditButton toggle edit mode
                EditButton()
                // Edit mode: hiện delete buttons (−) và drag handles (≡)
            }
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}

// === 7c. Custom Edit Actions mỗi row ===
struct CustomEditDemo: View {
    @State private var items = ["A", "B", "C"]
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                        Spacer()
                        
                        // Chỉ hiện trong edit mode
                        if editMode?.wrappedValue == .active {
                            Button {
                                // Custom action
                            } label: {
                                Image(systemName: "pencil.circle")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                .onDelete { items.remove(atOffsets: $0) }
                .onMove { items.move(fromOffsets: $0, toOffset: $1) }
            }
            .toolbar { EditButton() }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. PULL-TO-REFRESH & SEARCHABLE                         ║
// ╚══════════════════════════════════════════════════════════╝

@Observable
final class ItemsViewModel {
    var items: [String] = (1...20).map { "Item \($0)" }
    var isLoading = false
    
    func refresh() async {
        isLoading = true
        try? await Task.sleep(for: .seconds(1.5))
        items.append("New Item \(items.count + 1)")
        isLoading = false
    }
    
    func filteredItems(query: String) -> [String] {
        guard !query.isEmpty else { return items }
        return items.filter { $0.localizedCaseInsensitiveContains(query) }
    }
}

struct RefreshSearchDemo: View {
    @State private var viewModel = ItemsViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredItems(query: searchText), id: \.self) { item in
                    Text(item)
                }
            }
            .navigationTitle("Items (\(viewModel.items.count))")
            
            // === 8a. Pull-to-Refresh ===
            .refreshable {
                // async context — List tự hiện spinner
                await viewModel.refresh()
                // Spinner tự ẩn khi async function return
            }
            
            // === 8b. Search Bar ===
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Tìm kiếm items..."
            )
            
            // === 8c. Search suggestions (iOS 16+) ===
            .searchSuggestions {
                if searchText.isEmpty {
                    Text("🔥 Item 1").searchCompletion("Item 1")
                    Text("⭐ Item 5").searchCompletion("Item 5")
                }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. LIST + NAVIGATION                                    ║
// ╚══════════════════════════════════════════════════════════╝

// === 9a. NavigationLink trong List ===
struct NavigationListDemo: View {
    let items = ["Swift", "Kotlin", "Dart", "Rust"]
    
    var body: some View {
        NavigationStack {
            List(items, id: \.self) { item in
                // NavigationLink tự thêm chevron ">"
                NavigationLink(item) {
                    DetailView(name: item)
                }
                
                // Hoặc custom label:
                // NavigationLink(value: item) {
                //     Label(item, systemImage: "chevron.left.forwardslash.chevron.right")
                // }
            }
            .navigationTitle("Ngôn ngữ")
            .navigationDestination(for: String.self) { item in
                DetailView(name: item)
            }
        }
    }
}

struct DetailView: View {
    let name: String
    var body: some View {
        Text("Chi tiết: \(name)")
            .navigationTitle(name)
    }
}

// === 9b. Master-Detail (iPad Split View) ===
struct MasterDetailDemo: View {
    let categories = ["Kết nối", "Âm thanh", "Màn hình", "Pin"]
    @State private var selected: String?
    
    var body: some View {
        NavigationSplitView {
            // Sidebar (Master)
            List(categories, id: \.self, selection: $selected) { cat in
                Label(cat, systemImage: "gear")
            }
            .navigationTitle("Cài đặt")
        } detail: {
            // Detail
            if let selected {
                Text("Chi tiết: \(selected)")
            } else {
                ContentUnavailableView(
                    "Chọn mục",
                    systemImage: "sidebar.left",
                    description: Text("Chọn 1 mục từ danh sách bên trái")
                )
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. LIST BACKGROUND & APPEARANCE CUSTOMIZATION          ║
// ╚══════════════════════════════════════════════════════════╝

struct ListAppearanceDemo: View {
    var body: some View {
        List {
            Section("Appearance Demo") {
                Text("Row 1")
                Text("Row 2")
                Text("Row 3")
            }
        }
        // === 10a. Xoá default background (iOS 16+) ===
        .scrollContentBackground(.hidden)
        // Mặc định: List có background xám (grouped) hoặc trắng
        // .hidden → trong suốt, hiện background custom phía sau
        
        // === 10b. Custom background ===
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .top, endPoint: .bottom
            )
        )
        
        // === 10c. Row spacing (iOS 17+) ===
        .listRowSpacing(8)
        
        // === 10d. Section spacing (iOS 17+) ===
        .listSectionSpacing(.compact) // .default, .compact, custom CGFloat
    }
}

// === Ẩn tất cả separators ===
struct NoSeparatorList: View {
    let items = (1...10).map { "Item \($0)" }
    
    var body: some View {
        List(items, id: \.self) { item in
            Text(item)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. EMPTY STATE & CONTENT UNAVAILABLE                   ║
// ╚══════════════════════════════════════════════════════════╝

struct EmptyStateListDemo: View {
    @State private var items: [String] = []
    @State private var searchText = ""
    
    var filteredItems: [String] {
        guard !searchText.isEmpty else { return items }
        return items.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    // === iOS 17+: ContentUnavailableView ===
                    ContentUnavailableView {
                        Label("Chưa có mục nào", systemImage: "tray")
                    } description: {
                        Text("Tap + để thêm mục mới")
                    } actions: {
                        Button("Thêm mục đầu tiên") {
                            items.append("Mục mới")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if filteredItems.isEmpty {
                    // Search không tìm thấy
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredItems, id: \.self) { item in
                            Text(item)
                        }
                        .onDelete { items.remove(atOffsets: $0) }
                    }
                }
            }
            .navigationTitle("Danh sách")
            .searchable(text: $searchText)
            .toolbar {
                Button { items.append("Item \(items.count + 1)") } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  12. SCROLL POSITION & PROGRAMMATIC SCROLLING            ║
// ╚══════════════════════════════════════════════════════════╝

struct ScrollPositionList: View {
    let items = (1...200).map { "Item \($0)" }
    @State private var scrollPosition: Int?
    
    var body: some View {
        VStack {
            // Header controls
            HStack {
                Button("Top") {
                    withAnimation { scrollPosition = 1 }
                }
                Button("Middle") {
                    withAnimation { scrollPosition = 100 }
                }
                Button("Bottom") {
                    withAnimation { scrollPosition = 200 }
                }
            }
            .buttonStyle(.bordered)
            
            // List với scroll position tracking
            List(items, id: \.self) { item in
                Text(item)
            }
            .scrollPosition(id: $scrollPosition, anchor: .top) // iOS 17+
        }
    }
}

// ScrollViewReader cho iOS 14-16:
struct ScrollViewReaderList: View {
    let items = (1...200).map { "Item \($0)" }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                Button("Go to Item 150") {
                    withAnimation {
                        proxy.scrollTo("Item 150", anchor: .center)
                    }
                }
                
                List(items, id: \.self) { item in
                    Text(item)
                        .id(item) // BẮT BUỘC .id() cho scrollTo
                }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  13. PAGINATION / INFINITE SCROLL VỚI LIST               ║
// ╚══════════════════════════════════════════════════════════╝

@Observable
final class PaginatedViewModel {
    var items: [String] = []
    var isLoading = false
    var hasMore = true
    private var page = 0
    
    func loadInitial() async {
        guard items.isEmpty else { return }
        await loadNext()
    }
    
    func loadNext() async {
        guard !isLoading, hasMore else { return }
        isLoading = true
        defer { isLoading = false }
        
        try? await Task.sleep(for: .seconds(0.5))
        let newItems = (1...20).map { "Page \(page + 1) - Item \($0)" }
        items.append(contentsOf: newItems)
        page += 1
        hasMore = page < 5
    }
    
    func shouldLoadMore(item: String) -> Bool {
        guard let index = items.firstIndex(of: item) else { return false }
        return index >= items.count - 5
    }
}

struct PaginatedListDemo: View {
    @State private var viewModel = PaginatedViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.items, id: \.self) { item in
                Text(item)
                    .onAppear {
                        if viewModel.shouldLoadMore(item: item) {
                            Task { await viewModel.loadNext() }
                        }
                    }
            }
            
            // Loading indicator
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            
            if !viewModel.hasMore {
                Text("— Hết danh sách —")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            }
        }
        .task { await viewModel.loadInitial() }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  14. PRODUCTION PATTERNS                                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 14a. iOS Settings-like Screen ===

struct SettingsScreen: View {
    @AppStorage("notifications") private var notifications = true
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("fontSize") private var fontSize = 16.0
    
    var body: some View {
        NavigationStack {
            List {
                // Profile section
                Section {
                    NavigationLink {
                        Text("Profile Detail")
                    } label: {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(.blue.gradient)
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Text("H").font(.title2.bold()).foregroundStyle(.white)
                                )
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Huy Nguyen").font(.headline)
                                Text("huy@example.com")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Toggles section
                Section("Cài đặt chung") {
                    SettingToggleRow(icon: "bell.fill", color: .red,
                                   title: "Thông báo", isOn: $notifications)
                    SettingToggleRow(icon: "moon.fill", color: .indigo,
                                   title: "Dark Mode", isOn: $darkMode)
                }
                
                // Slider section
                Section("Hiển thị") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            SettingIcon(icon: "textformat.size", color: .blue)
                            Text("Cỡ chữ")
                            Spacer()
                            Text("\(Int(fontSize))pt")
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $fontSize, in: 12...28, step: 1)
                    }
                }
                
                // Navigation rows
                Section("Khác") {
                    SettingNavRow(icon: "questionmark.circle", color: .purple,
                                title: "Trợ giúp", detail: nil)
                    SettingNavRow(icon: "info.circle", color: .gray,
                                title: "Phiên bản", detail: "2.1.0")
                }
                
                // Destructive section
                Section {
                    Button("Đăng xuất", role: .destructive) { }
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Cài đặt")
        }
    }
}

struct SettingToggleRow: View {
    let icon: String
    let color: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 14) {
                SettingIcon(icon: icon, color: color)
                Text(title)
            }
        }
    }
}

struct SettingNavRow: View {
    let icon: String
    let color: Color
    let title: String
    let detail: String?
    
    var body: some View {
        NavigationLink {
            Text(title)
        } label: {
            HStack(spacing: 14) {
                SettingIcon(icon: icon, color: color)
                Text(title)
                if let detail {
                    Spacer()
                    Text(detail)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct SettingIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 14))
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(color, in: .rect(cornerRadius: 6))
    }
}


// === 14b. Chat / Messages List ===

struct Message: Identifiable {
    let id = UUID()
    let sender: String
    let text: String
    let time: Date
    let isMe: Bool
}

struct ChatListDemo: View {
    let messages: [Message] = [
        Message(sender: "Huy", text: "Hello!", time: .now.addingTimeInterval(-300), isMe: false),
        Message(sender: "Me", text: "Hi Huy! Khỏe không?", time: .now.addingTimeInterval(-240), isMe: true),
        Message(sender: "Huy", text: "Khỏe, đang code SwiftUI", time: .now.addingTimeInterval(-180), isMe: false),
        Message(sender: "Me", text: "Nice! Mình cũng đang học", time: .now.addingTimeInterval(-60), isMe: true),
    ]
    
    var body: some View {
        List(messages) { msg in
            HStack {
                if msg.isMe { Spacer(minLength: 60) }
                
                VStack(alignment: msg.isMe ? .trailing : .leading, spacing: 4) {
                    Text(msg.text)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            msg.isMe ? Color.blue : Color.gray.opacity(0.2),
                            in: .rect(cornerRadius: 16)
                        )
                        .foregroundStyle(msg.isMe ? .white : .primary)
                    
                    Text(msg.time, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                if !msg.isMe { Spacer(minLength: 60) }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }
}
```

```
// ╔══════════════════════════════════════════════════════════╗
// ║  15. LIST vs LazyVStack vs FORM — KHI NÀO DÙNG?         ║
// ╚══════════════════════════════════════════════════════════╝

// ┌─────────────────┬──────────────────────────────────────────┐
// │ Component       │ Dùng khi                                 │
// ├─────────────────┼──────────────────────────────────────────┤
// │ List            │ Data lists cần: cell reuse, swipe,       │
// │                 │ selection, edit mode, separators, search  │
// │                 │ → Settings, Contacts, Messages, Feeds    │
// ├─────────────────┼──────────────────────────────────────────┤
// │ Form            │ Input forms: toggles, pickers, text fields│
// │                 │ Giống List nhưng optimize cho form input  │
// │                 │ → Settings form, Registration, Filters   │
// ├─────────────────┼──────────────────────────────────────────┤
// │ ScrollView +    │ Custom UI: cards, mixed content, no      │
// │ LazyVStack      │ reuse cần, full layout control           │
// │                 │ → Social feeds, Discovery, Dashboards    │
// ├─────────────────┼──────────────────────────────────────────┤
// │ ScrollView +    │ Rất ít items (< 30), cần exact sizing    │
// │ VStack          │ → About screen, static content           │
// └─────────────────┴──────────────────────────────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  16. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Nhiều buttons trong 1 row — chỉ 1 hoạt động
//    List { HStack { Button("A"); Button("B") } }
//    → Tap bất kỳ đâu → chỉ trigger button đầu tiên
//    ✅ FIX: .buttonStyle(.borderless) cho TỪNG button

// ❌ PITFALL 2: Custom background bị đè bởi List
//    List { Text("Row").background(.red) }
//    → Vẫn thấy default row background phía sau
//    ✅ FIX: .listRowBackground(Color.red) thay .background
//            + .scrollContentBackground(.hidden) nếu cần

// ❌ PITFALL 3: NavigationLink + onTapGesture conflict
//    NavigationLink { Detail() } label: { Text("Row") }
//        .onTapGesture { doSomething() } // Chặn navigation!
//    ✅ FIX: Bỏ onTapGesture, dùng .simultaneousGesture()
//            hoặc xử lý logic trong destination view

// ❌ PITFALL 4: ForEach bỏ quên → sai behavior
//    List { items.map { Text($0) } } // ❌ Không phải ForEach!
//    ✅ FIX: List { ForEach(items) { ... } }

// ❌ PITFALL 5: .onDelete không hoạt động
//    List(items) { item in Text(item) }
//        .onDelete { ... } // ❌ onDelete là modifier của ForEach, không phải List
//    ✅ FIX: List { ForEach(items) { ... }.onDelete { ... } }

// ❌ PITFALL 6: List scroll performance kém
//    Mỗi row chứa AsyncImage không cache → reload liên tục
//    ✅ FIX: Image caching library (Kingfisher, Nuke)
//            + tránh heavy computation trong row body

// ❌ PITFALL 7: editMode không hoạt động
//    List { ... }.toolbar { EditButton() }
//    → Phải trong NavigationStack/NavigationView
//    ✅ FIX: Wrap trong NavigationStack

// ✅ BEST PRACTICES:
// 1. .insetGrouped cho settings, .plain cho feeds/chat
// 2. ForEach TRONG List (không phải List trực tiếp) cho onDelete/onMove
// 3. .buttonStyle(.borderless) khi có nhiều buttons trong row
// 4. .listRowBackground thay .background cho row styling
// 5. .scrollContentBackground(.hidden) + .background cho custom bg
// 6. .refreshable cho async data loading (tự hiện spinner)
// 7. .searchable cho filter (tự hiện search bar)
// 8. ContentUnavailableView cho empty states (iOS 17+)
// 9. .swipeActions cho contextual actions (delete, pin, archive)
// 10. Identifiable models với stable ID (UUID, database ID)
// 11. .listRowSpacing + .listSectionSpacing cho fine-tune spacing (iOS 17+)
// 12. NavigationSplitView cho Master-Detail trên iPad
```

---

List là container phức tạp nhất trong SwiftUI — kết hợp lazy loading, cell reuse, swipe actions, selection, editing, sections, và rất nhiều built-in behaviors. Mình sẽ giải thích toàn bộ.Mình đã tổng hợp toàn bộ kiến thức List trong 16 phần. Đây là những điểm cốt lõi:

**List là component phức tạp nhất trong SwiftUI** vì nó kết hợp rất nhiều built-in behaviors: cell reuse, swipe actions, selection, edit mode (delete + reorder), pull-to-refresh, searchable, sections, và nhiều ListStyles. Hiểu đúng List giúp tránh phải tự build lại từ scratch.

**Năm phần giá trị nhất cho production:**

**Phần 5 — Swipe Actions**: Trailing (delete, archive) và leading (pin, unread) với `allowsFullSwipe` control. Rule quan trọng: nút **đầu tiên** trong `.swipeActions` là nút gần rìa nhất và cũng là nút trigger khi full swipe. `role: .destructive` tự động cho background đỏ + animation remove.

**Phần 7 — Edit Mode**: `.onDelete` và `.onMove` là modifiers của **ForEach**, không phải List — đây là pitfall #5 mà rất nhiều developer mắc. Pattern đúng: `List { ForEach(items) { ... }.onDelete { ... }.onMove { ... } }`.

**Phần 8 — Refreshable + Searchable**: Hai modifiers cực kỳ mạnh — `.refreshable` tự hiện pull-to-refresh spinner và chạy trong async context, `.searchable` tự thêm search bar vào navigation. Chỉ vài dòng code mà có feature hoàn chỉnh.

**Phần 10 — Background Customization**: Gotcha lớn nhất là **`.scrollContentBackground(.hidden)`** — không có modifier này thì List luôn có background mặc định đè lên custom background. Tương tự, row styling phải dùng **`.listRowBackground()`** thay vì `.background()`.

**Pitfall #1 ở Phần 16**: Nhiều buttons trong 1 List row — mặc định chỉ 1 button hoạt động. Fix bằng `.buttonStyle(.borderless)` cho từng button — đây là vấn đề gặp ở mọi project.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
