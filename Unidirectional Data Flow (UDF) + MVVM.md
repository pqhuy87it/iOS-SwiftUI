```Swift
// ============================================================
// UNIDIRECTIONAL DATA FLOW (UDF) + MVVM TRONG SWIFTUI
// ============================================================
//
// Unidirectional Data Flow = DỮ LIỆU CHỈ CHẢY 1 CHIỀU:
//
//   ┌─────────────────────────────────────────────────────┐
//   │                                                     │
//   │   State ──────→ View ──────→ Action ──────→ ViewModel
//   │     ↑                                         │     │
//   │     └─────────── New State ◄──────────────────┘     │
//   │                                                     │
//   └─────────────────────────────────────────────────────┘
//
// - View ĐỌC state → render UI
// - User tương tác → View GỬI action
// - ViewModel NHẬN action → xử lý logic → CẬP NHẬT state
// - State thay đổi → View TỰ ĐỘNG re-render
//
// KHÔNG BAO GIỜ: View tự thay đổi state trực tiếp
// KHÔNG BAO GIỜ: Nhiều nguồn cùng thay đổi 1 state
// → SINGLE SOURCE OF TRUTH
//
// Tại sao cần UDF trong MVVM?
// - Debug dễ: mọi state change đều đi qua 1 đường duy nhất
// - Test dễ: send action → assert state (không cần mock UI)
// - Predictable: cùng state → cùng UI (deterministic)
// - Time-travel debugging: log actions → replay
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. VẤN ĐỀ CỦA MVVM TRUYỀN THỐNG (BIDIRECTIONAL)       ║
// ╚══════════════════════════════════════════════════════════╝

// === ❌ MVVM truyền thống: bidirectional, state phân tán ===

// Vấn đề: View có thể thay đổi state QUA NHIỀU ĐƯỜNG
// → Khó trace ai thay đổi gì, khi nào, tại sao

@Observable
final class TraditionalVM {
    // State phân tán — nhiều @Published properties
    var items: [String] = []
    var isLoading = false
    var error: String?
    var searchQuery = ""
    var selectedFilter = "all"
    var sortOrder = "newest"
    
    // Methods thay đổi state TRỰC TIẾP — không qua 1 entry point
    func loadItems() {
        isLoading = true
        // ... async work
        items = ["A", "B"]
        isLoading = false
    }
    
    func deleteItem(_ item: String) {
        items.removeAll { $0 == item }
    }
    
    func search(_ query: String) {
        searchQuery = query
        // ... filter logic
    }
    
    func toggleSort() {
        sortOrder = sortOrder == "newest" ? "oldest" : "newest"
        // ... re-sort
    }
}

// Vấn đề:
// 1. View gọi vm.loadItems(), vm.search(), vm.deleteItem()...
//    → NHIỀU ENTRY POINTS thay đổi state
// 2. Khó trace: items rỗng vì chưa load? Vì filter? Vì delete hết?
// 3. Khó test: phải mock nhiều scenarios
// 4. State inconsistency: isLoading = true nhưng items đã có data


// ╔══════════════════════════════════════════════════════════╗
// ║  2. UDF + MVVM — KIẾN TRÚC                               ║
// ╚══════════════════════════════════════════════════════════╝

// Core concepts:
//
// STATE: struct bất biến mô tả TOÀN BỘ UI tại 1 thời điểm
// ACTION: enum mô tả MỌI THỨ user/system có thể làm
// VIEWMODEL: nhận Action → xử lý → output State mới
// VIEW: render State, gửi Action — KHÔNG chứa logic
//
// ┌─────────────────────────────────────────────────────────┐
// │                    UDF + MVVM Flow                       │
// │                                                         │
// │  ┌───────┐  reads   ┌──────┐  sends   ┌────────────┐  │
// │  │ STATE │ ────────→ │ VIEW │ ────────→ │   ACTION   │  │
// │  └───┬───┘          └──────┘          └──────┬─────┘  │
// │      ↑                                        │        │
// │      │           ┌─────────────┐              │        │
// │      └───────────│  VIEWMODEL  │◄─────────────┘        │
// │    updates state │  (Reducer)  │  receives action       │
// │                  └──────┬──────┘                        │
// │                         │                               │
// │                  ┌──────▼──────┐                        │
// │                  │   EFFECTS   │ (API, DB, Analytics)   │
// │                  │  (Services) │                        │
// │                  └─────────────┘                        │
// └─────────────────────────────────────────────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  3. IMPLEMENTATION CƠ BẢN — TODO APP                     ║
// ╚══════════════════════════════════════════════════════════╝

// ============ STATE ============
// Struct bất biến chứa TOÀN BỘ data cần để render UI.
// Single source of truth cho 1 screen.

struct TodoState: Equatable {
    var items: [TodoItem] = []
    var isLoading = false
    var error: String?
    var filter: TodoFilter = .all
    var newItemTitle = ""
    var editingItemID: UUID?
    
    // Derived state: computed từ raw state → View dùng trực tiếp
    var filteredItems: [TodoItem] {
        switch filter {
        case .all: return items
        case .active: return items.filter { !$0.isCompleted }
        case .completed: return items.filter { $0.isCompleted }
        }
    }
    
    var activeCount: Int {
        items.filter { !$0.isCompleted }.count
    }
    
    var hasItems: Bool { !items.isEmpty }
    var canAddItem: Bool { !newItemTitle.trimmingCharacters(in: .whitespaces).isEmpty }
}

struct TodoItem: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var priority: Priority
    let createdAt: Date
    
    enum Priority: Int, CaseIterable, Comparable, Equatable, Hashable {
        case low = 0, medium = 1, high = 2
        
        static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

enum TodoFilter: String, CaseIterable, Hashable {
    case all = "Tất cả"
    case active = "Đang làm"
    case completed = "Xong"
}


// ============ ACTION ============
// Enum liệt kê MỌI THỨ có thể xảy ra trên screen.
// Mỗi case = 1 sự kiện cụ thể.

enum TodoAction {
    // User actions
    case addItem
    case deleteItem(id: UUID)
    case toggleItem(id: UUID)
    case updateTitle(id: UUID, newTitle: String)
    case setPriority(id: UUID, priority: TodoItem.Priority)
    case setFilter(TodoFilter)
    case setNewItemTitle(String)
    case startEditing(id: UUID)
    case cancelEditing
    
    // Async results (system actions)
    case loadItems
    case itemsLoaded([TodoItem])
    case loadFailed(String)
    case clearError
    case clearCompleted
}


// ============ VIEWMODEL ============
// Nhận Action → xử lý → cập nhật State.
// MỌI state change đều đi qua send(action:).

@Observable
final class TodoViewModel {
    // SINGLE source of truth
    private(set) var state: TodoState
    
    // Dependencies (inject cho testability)
    private let repository: TodoRepositoryProtocol
    
    init(
        initialState: TodoState = TodoState(),
        repository: TodoRepositoryProtocol = TodoRepository()
    ) {
        self.state = initialState
        self.repository = repository
    }
    
    // ============ SINGLE ENTRY POINT ============
    // MỌI tương tác từ View đều đi qua đây.
    // Không có method nào khác thay đổi state.
    
    @MainActor
    func send(_ action: TodoAction) {
        switch action {
            
        // ─── User Actions (synchronous state updates) ───
            
        case .addItem:
            guard state.canAddItem else { return }
            let item = TodoItem(
                id: UUID(),
                title: state.newItemTitle.trimmingCharacters(in: .whitespaces),
                isCompleted: false,
                priority: .medium,
                createdAt: .now
            )
            state.items.insert(item, at: 0)
            state.newItemTitle = "" // Reset input
            
            // Side effect: persist
            Task { await saveItems() }
            
        case .deleteItem(let id):
            state.items.removeAll { $0.id == id }
            Task { await saveItems() }
            
        case .toggleItem(let id):
            guard let index = state.items.firstIndex(where: { $0.id == id }) else { return }
            state.items[index].isCompleted.toggle()
            Task { await saveItems() }
            
        case .updateTitle(let id, let newTitle):
            guard let index = state.items.firstIndex(where: { $0.id == id }) else { return }
            state.items[index].title = newTitle
            state.editingItemID = nil
            Task { await saveItems() }
            
        case .setPriority(let id, let priority):
            guard let index = state.items.firstIndex(where: { $0.id == id }) else { return }
            state.items[index].priority = priority
            
        case .setFilter(let filter):
            state.filter = filter
            
        case .setNewItemTitle(let title):
            state.newItemTitle = title
            
        case .startEditing(let id):
            state.editingItemID = id
            
        case .cancelEditing:
            state.editingItemID = nil
            
        case .clearCompleted:
            state.items.removeAll { $0.isCompleted }
            Task { await saveItems() }
            
        // ─── Async Results (from side effects) ───
            
        case .loadItems:
            state.isLoading = true
            state.error = nil
            Task { await performLoadItems() }
            
        case .itemsLoaded(let items):
            state.items = items
            state.isLoading = false
            
        case .loadFailed(let message):
            state.error = message
            state.isLoading = false
            
        case .clearError:
            state.error = nil
        }
    }
    
    // ─── Side Effects (async operations) ───
    // Private — View KHÔNG gọi trực tiếp.
    // Kết quả quay lại qua send() → state update qua 1 đường duy nhất.
    
    private func performLoadItems() async {
        do {
            let items = try await repository.fetchAll()
            await MainActor.run { send(.itemsLoaded(items)) }
        } catch {
            await MainActor.run { send(.loadFailed(error.localizedDescription)) }
        }
    }
    
    private func saveItems() async {
        try? await repository.save(state.items)
    }
}


// ============ REPOSITORY (Dependencies) ============

protocol TodoRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [TodoItem]
    func save(_ items: [TodoItem]) async throws
}

final class TodoRepository: TodoRepositoryProtocol {
    func fetchAll() async throws -> [TodoItem] {
        try await Task.sleep(for: .seconds(0.5))
        return [
            TodoItem(id: UUID(), title: "Mua sữa", isCompleted: false,
                    priority: .medium, createdAt: .now),
            TodoItem(id: UUID(), title: "Code review", isCompleted: true,
                    priority: .high, createdAt: .now),
            TodoItem(id: UUID(), title: "Tập gym", isCompleted: false,
                    priority: .low, createdAt: .now),
        ]
    }
    
    func save(_ items: [TodoItem]) async throws {
        // Persist to UserDefaults, CoreData, API...
    }
}


// ============ VIEW ============
// View CHỈ LÀM 2 VIỆC:
// 1. Đọc state → render UI
// 2. User tương tác → gửi Action
// View KHÔNG chứa logic nghiệp vụ.

struct TodoListView: View {
    @State private var vm = TodoViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ─── Filter Picker ───
                filterPicker
                
                // ─── Add Item Bar ───
                addItemBar
                
                Divider()
                
                // ─── Content ───
                content
            }
            .navigationTitle("Tasks (\(vm.state.activeCount))")
            .toolbar { toolbarContent }
            .alert("Lỗi", isPresented: hasError) {
                Button("OK") { vm.send(.clearError) }
            } message: {
                Text(vm.state.error ?? "")
            }
        }
        .task {
            vm.send(.loadItems) // Entry point: load data khi appear
        }
    }
    
    // ─── Sub-views: CHỈ đọc state + gửi action ───
    
    private var filterPicker: some View {
        Picker("Filter", selection: Binding(
            get: { vm.state.filter },
            set: { vm.send(.setFilter($0)) } // Gửi action, KHÔNG set trực tiếp
        )) {
            ForEach(TodoFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    private var addItemBar: some View {
        HStack(spacing: 12) {
            TextField("Việc mới...", text: Binding(
                get: { vm.state.newItemTitle },
                set: { vm.send(.setNewItemTitle($0)) }
            ))
            .textFieldStyle(.roundedBorder)
            .onSubmit { vm.send(.addItem) }
            
            Button {
                vm.send(.addItem) // Action, không phải trực tiếp mutate
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .disabled(!vm.state.canAddItem)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var content: some View {
        if vm.state.isLoading && !vm.state.hasItems {
            ProgressView("Đang tải...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if vm.state.filteredItems.isEmpty {
            ContentUnavailableView(
                "Chưa có công việc",
                systemImage: "checklist",
                description: Text("Thêm công việc mới ở trên")
            )
        } else {
            itemList
        }
    }
    
    private var itemList: some View {
        List {
            ForEach(vm.state.filteredItems) { item in
                TodoRowView(
                    item: item,
                    isEditing: vm.state.editingItemID == item.id,
                    onToggle: { vm.send(.toggleItem(id: item.id)) },
                    onStartEdit: { vm.send(.startEditing(id: item.id)) },
                    onUpdateTitle: { vm.send(.updateTitle(id: item.id, newTitle: $0)) },
                    onCancelEdit: { vm.send(.cancelEditing) },
                    onSetPriority: { vm.send(.setPriority(id: item.id, priority: $0)) }
                )
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        vm.send(.deleteItem(id: item.id))
                    } label: {
                        Label("Xoá", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button("Xoá đã xong") { vm.send(.clearCompleted) }
                    .disabled(vm.state.items.filter(\.isCompleted).isEmpty)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    private var hasError: Binding<Bool> {
        Binding(
            get: { vm.state.error != nil },
            set: { if !$0 { vm.send(.clearError) } }
        )
    }
}

// ─── Row View: nhận data + callbacks, KHÔNG biết ViewModel ───

struct TodoRowView: View {
    let item: TodoItem
    let isEditing: Bool
    let onToggle: () -> Void
    let onStartEdit: () -> Void
    let onUpdateTitle: (String) -> Void
    let onCancelEdit: () -> Void
    let onSetPriority: (TodoItem.Priority) -> Void
    
    @State private var editText = ""
    
    var body: some View {
        HStack(spacing: 12) {
            // Toggle
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            // Title or Edit field
            if isEditing {
                TextField("Sửa tiêu đề", text: $editText)
                    .textFieldStyle(.roundedBorder)
                    .onAppear { editText = item.title }
                    .onSubmit { onUpdateTitle(editText) }
                
                Button("Huỷ") { onCancelEdit() }
                    .font(.caption)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .strikethrough(item.isCompleted)
                        .foregroundStyle(item.isCompleted ? .secondary : .primary)
                    
                    Text(item.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .onTapGesture { onStartEdit() }
                
                Spacer()
                
                // Priority indicator
                Menu {
                    ForEach(TodoItem.Priority.allCases, id: \.self) { p in
                        Button {
                            onSetPriority(p)
                        } label: {
                            Label(
                                "\(p)".capitalized,
                                systemImage: item.priority == p ? "checkmark" : ""
                            )
                        }
                    }
                } label: {
                    priorityBadge
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var priorityBadge: some View {
        Circle()
            .fill(priorityColor)
            .frame(width: 10, height: 10)
    }
    
    private var priorityColor: Color {
        switch item.priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. SIDE EFFECTS — XỬ LÝ ASYNC OPERATIONS                ║
// ╚══════════════════════════════════════════════════════════╝

// Side effects = operations NGOÀI state mutation:
// API calls, database, analytics, navigation, haptics...
//
// Trong UDF, side effects PHẢI:
// 1. Được trigger BỞI action (không tự phát)
// 2. Kết quả quay lại qua send(action) (không mutate trực tiếp)
// 3. Cancellable (tránh stale results)

// === Pattern: Action → Reduce State → Effect → Result Action ===

@Observable
final class ArticleListVM {
    private(set) var state = ArticleListState()
    private let api: ArticleAPIProtocol
    private var searchTask: Task<Void, Never>?
    
    init(api: ArticleAPIProtocol = ArticleAPI()) {
        self.api = api
    }
    
    @MainActor
    func send(_ action: ArticleAction) {
        switch action {
            
        // ─── Immediate state updates ───
        case .setSearchQuery(let query):
            state.searchQuery = query
            // Trigger debounced search EFFECT
            debouncedSearch(query)
            
        case .setCategory(let cat):
            state.selectedCategory = cat
            send(.loadArticles) // Chain action
            
        // ─── Async triggers ───
        case .loadArticles:
            state.isLoading = true
            state.error = nil
            Task { await performLoad() }
            
        case .loadNextPage:
            guard !state.isLoadingMore, state.hasNextPage else { return }
            state.isLoadingMore = true
            Task { await performLoadNextPage() }
            
        case .refresh:
            state.page = 1
            Task { await performLoad() }
            
        // ─── Async results ───
        case .articlesLoaded(let articles, let hasNext):
            state.articles = articles
            state.hasNextPage = hasNext
            state.isLoading = false
            
        case .nextPageLoaded(let articles, let hasNext):
            state.articles.append(contentsOf: articles)
            state.hasNextPage = hasNext
            state.page += 1
            state.isLoadingMore = false
            
        case .searchResultsLoaded(let results):
            state.searchResults = results
            state.isSearching = false
            
        case .failed(let error):
            state.error = error
            state.isLoading = false
            state.isLoadingMore = false
        }
    }
    
    // ─── Side Effects (private) ───
    
    private func performLoad() async {
        do {
            let result = try await api.fetchArticles(
                category: state.selectedCategory,
                page: 1
            )
            await MainActor.run {
                send(.articlesLoaded(result.articles, hasNext: result.hasNext))
            }
        } catch {
            await MainActor.run { send(.failed(error.localizedDescription)) }
        }
    }
    
    private func performLoadNextPage() async {
        do {
            let result = try await api.fetchArticles(
                category: state.selectedCategory,
                page: state.page + 1
            )
            await MainActor.run {
                send(.nextPageLoaded(result.articles, hasNext: result.hasNext))
            }
        } catch {
            await MainActor.run { send(.failed(error.localizedDescription)) }
        }
    }
    
    // Debounced search: cancel task cũ, delay, rồi search
    private func debouncedSearch(_ query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            state.searchResults = []
            return
        }
        
        state.isSearching = true
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            
            do {
                let results = try await api.search(query: query)
                await MainActor.run { send(.searchResultsLoaded(results)) }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run { send(.failed(error.localizedDescription)) }
            }
        }
    }
}

// Supporting types
struct ArticleListState: Equatable {
    var articles: [ArticleModel] = []
    var searchResults: [ArticleModel] = []
    var searchQuery = ""
    var selectedCategory = "all"
    var isLoading = false
    var isLoadingMore = false
    var isSearching = false
    var error: String?
    var page = 1
    var hasNextPage = true
}

struct ArticleModel: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let excerpt: String
}

enum ArticleAction {
    case setSearchQuery(String)
    case setCategory(String)
    case loadArticles
    case loadNextPage
    case refresh
    case articlesLoaded([ArticleModel], hasNext: Bool)
    case nextPageLoaded([ArticleModel], hasNext: Bool)
    case searchResultsLoaded([ArticleModel])
    case failed(String)
}

protocol ArticleAPIProtocol: Sendable {
    func fetchArticles(category: String, page: Int) async throws
        -> (articles: [ArticleModel], hasNext: Bool)
    func search(query: String) async throws -> [ArticleModel]
}

struct ArticleAPI: ArticleAPIProtocol {
    func fetchArticles(category: String, page: Int) async throws
        -> (articles: [ArticleModel], hasNext: Bool) {
        try await Task.sleep(for: .seconds(0.5))
        let articles = (1...10).map {
            ArticleModel(id: "\(page)-\($0)", title: "\(category) Article \($0)", excerpt: "...")
        }
        return (articles, page < 3)
    }
    func search(query: String) async throws -> [ArticleModel] {
        try await Task.sleep(for: .seconds(0.3))
        return (1...5).map { ArticleModel(id: "s\($0)", title: "\(query) result \($0)", excerpt: "...") }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. BINDING ADAPTER — KẾT NỐI UDF VỚI SwiftUI CONTROLS  ║
// ╚══════════════════════════════════════════════════════════╝

// SwiftUI controls (TextField, Picker, Toggle) cần @Binding.
// UDF không cho View mutate state trực tiếp.
// → Tạo Binding adapter: get từ state, set gửi action.

extension TodoViewModel {
    // Binding helpers — convert UDF → Binding cho SwiftUI controls
    
    var newItemTitleBinding: Binding<String> {
        Binding(
            get: { self.state.newItemTitle },
            set: { self.send(.setNewItemTitle($0)) }
        )
    }
    
    var filterBinding: Binding<TodoFilter> {
        Binding(
            get: { self.state.filter },
            set: { self.send(.setFilter($0)) }
        )
    }
}

// Hoặc generic helper:
extension Binding {
    /// Tạo Binding từ UDF: get state, set gửi action
    static func udf<VM>(
        state: @escaping () -> Value,
        send: @escaping (Value) -> Void
    ) -> Binding<Value> {
        Binding(
            get: state,
            set: send
        )
    }
}

// Sử dụng trong View:
struct CleanBindingDemo: View {
    @State private var vm = TodoViewModel()
    
    var body: some View {
        VStack {
            // Cách 1: dùng helper property
            TextField("New item", text: vm.newItemTitleBinding)
            Picker("Filter", selection: vm.filterBinding) {
                ForEach(TodoFilter.allCases, id: \.self) { Text($0.rawValue) }
            }
            
            // Cách 2: inline Binding
            Toggle("Show completed", isOn: Binding(
                get: { vm.state.filter == .completed },
                set: { vm.send(.setFilter($0 ? .completed : .all)) }
            ))
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. TESTING — LỢI ÍCH LỚN NHẤT CỦA UDF                 ║
// ╚══════════════════════════════════════════════════════════╝

// UDF cực kỳ dễ test: send(action) → assert state.
// Không cần mock UI, không cần render views.

// === Mock Repository ===

final class MockTodoRepository: TodoRepositoryProtocol {
    var mockItems: [TodoItem] = []
    var shouldThrow = false
    var saveCallCount = 0
    
    func fetchAll() async throws -> [TodoItem] {
        if shouldThrow { throw NSError(domain: "test", code: -1) }
        return mockItems
    }
    
    func save(_ items: [TodoItem]) async throws {
        saveCallCount += 1
    }
}

// === Unit Tests ===

struct TodoViewModelTests {
    
    // Test: add item
    static func testAddItem() async {
        let vm = TodoViewModel(repository: MockTodoRepository())
        
        // Send actions
        await vm.send(.setNewItemTitle("Buy milk"))
        await vm.send(.addItem)
        
        // Assert state
        assert(vm.state.items.count == 1)
        assert(vm.state.items.first?.title == "Buy milk")
        assert(vm.state.newItemTitle.isEmpty) // Input reset
    }
    
    // Test: toggle item
    static func testToggleItem() async {
        let item = TodoItem(id: UUID(), title: "Test", isCompleted: false,
                           priority: .medium, createdAt: .now)
        let vm = TodoViewModel(
            initialState: TodoState(items: [item]),
            repository: MockTodoRepository()
        )
        
        await vm.send(.toggleItem(id: item.id))
        
        assert(vm.state.items.first?.isCompleted == true)
    }
    
    // Test: filter
    static func testFilter() async {
        let items = [
            TodoItem(id: UUID(), title: "A", isCompleted: false,
                    priority: .high, createdAt: .now),
            TodoItem(id: UUID(), title: "B", isCompleted: true,
                    priority: .low, createdAt: .now),
        ]
        let vm = TodoViewModel(
            initialState: TodoState(items: items),
            repository: MockTodoRepository()
        )
        
        await vm.send(.setFilter(.active))
        assert(vm.state.filteredItems.count == 1)
        assert(vm.state.filteredItems.first?.title == "A")
        
        await vm.send(.setFilter(.completed))
        assert(vm.state.filteredItems.count == 1)
        assert(vm.state.filteredItems.first?.title == "B")
    }
    
    // Test: load failure
    static func testLoadFailure() async {
        let repo = MockTodoRepository()
        repo.shouldThrow = true
        let vm = TodoViewModel(repository: repo)
        
        await vm.send(.loadItems)
        
        // Wait for async effect
        try? await Task.sleep(for: .seconds(1))
        
        assert(vm.state.error != nil)
        assert(vm.state.isLoading == false)
    }
    
    // Test: cannot add empty item
    static func testCannotAddEmpty() async {
        let vm = TodoViewModel(repository: MockTodoRepository())
        
        await vm.send(.setNewItemTitle("   ")) // Whitespace only
        assert(vm.state.canAddItem == false)
        
        await vm.send(.addItem) // Should be no-op
        assert(vm.state.items.isEmpty)
    }
}

// Testing UDF vs Traditional:
// ┌──────────────────────┬──────────────────┬───────────────────┐
// │                      │ Traditional MVVM │ UDF + MVVM        │
// ├──────────────────────┼──────────────────┼───────────────────┤
// │ Test setup           │ Mock nhiều deps  │ Init state + mock │
// │ Test action          │ Gọi method, check│ send() → assert   │
// │                      │ nhiều properties │ state struct      │
// │ State assertion      │ Check từng field │ Equatable ==      │
// │ Async test           │ Complex mocking  │ Mock repo + wait  │
// │ Edge cases           │ Khó reproduce    │ Init specific     │
// │                      │                  │ state → send      │
// │ Snapshot test        │ Render view      │ Assert state only │
// └──────────────────────┴──────────────────┴───────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  7. MULTI-SCREEN — SHARED STATE & NAVIGATION              ║
// ╚══════════════════════════════════════════════════════════╝

// Mỗi screen có ViewModel riêng.
// Shared state qua: Environment object, parent coordinator, hoặc store.

// === App-level State ===

@Observable
final class AppStore {
    private(set) var authState = AuthState()
    private(set) var globalError: String?
    
    struct AuthState: Equatable {
        var isLoggedIn = false
        var currentUser: AppUser?
    }
    
    struct AppUser: Equatable {
        let id: String
        let name: String
    }
    
    enum AppAction {
        case login(user: AppUser)
        case logout
        case setGlobalError(String?)
    }
    
    @MainActor
    func send(_ action: AppAction) {
        switch action {
        case .login(let user):
            authState.isLoggedIn = true
            authState.currentUser = user
        case .logout:
            authState = AuthState()
        case .setGlobalError(let error):
            globalError = error
        }
    }
}

// === Screen-level VM nhận shared dependencies ===

@Observable
final class ProfileVM {
    private(set) var state = ProfileState()
    private let appStore: AppStore
    
    init(appStore: AppStore) {
        self.appStore = appStore
    }
    
    struct ProfileState: Equatable {
        var isEditing = false
        var editName = ""
    }
    
    enum ProfileAction {
        case startEdit
        case cancelEdit
        case saveProfile
        case logout
    }
    
    @MainActor
    func send(_ action: ProfileAction) {
        switch action {
        case .startEdit:
            state.isEditing = true
            state.editName = appStore.authState.currentUser?.name ?? ""
        case .cancelEdit:
            state.isEditing = false
        case .saveProfile:
            state.isEditing = false
            // Update via app store
        case .logout:
            appStore.send(.logout) // Delegate lên app-level
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. MIDDLEWARE / ACTION LOGGING — DEBUG UDF                ║
// ╚══════════════════════════════════════════════════════════╝

// Vì MỌI thay đổi đi qua send(), dễ dàng log TOÀN BỘ actions.

@Observable
final class LoggableTodoVM {
    private(set) var state = TodoState()
    private let repository: TodoRepositoryProtocol
    private let enableLogging: Bool
    
    init(repository: TodoRepositoryProtocol = TodoRepository(),
         enableLogging: Bool = false) {
        self.repository = repository
        self.enableLogging = enableLogging
    }
    
    @MainActor
    func send(_ action: TodoAction) {
        // ─── MIDDLEWARE: Pre-action logging ───
        #if DEBUG
        if enableLogging {
            let timestamp = Date.now.formatted(date: .omitted, time: .standard)
            print("[\(timestamp)] 📩 Action: \(action)")
            print("  State before: items=\(state.items.count), loading=\(state.isLoading)")
        }
        #endif
        
        // ─── REDUCE: process action ───
        reduce(action)
        
        // ─── MIDDLEWARE: Post-action logging ───
        #if DEBUG
        if enableLogging {
            print("  State after:  items=\(state.items.count), loading=\(state.isLoading)")
            print("")
        }
        #endif
    }
    
    private func reduce(_ action: TodoAction) {
        switch action {
        case .addItem:
            guard state.canAddItem else { return }
            let item = TodoItem(
                id: UUID(),
                title: state.newItemTitle.trimmingCharacters(in: .whitespaces),
                isCompleted: false,
                priority: .medium,
                createdAt: .now
            )
            state.items.insert(item, at: 0)
            state.newItemTitle = ""
        // ... other cases
        default: break
        }
    }
}

// Console output:
// [14:32:15] 📩 Action: setNewItemTitle("Buy milk")
//   State before: items=3, loading=false
//   State after:  items=3, loading=false
//
// [14:32:16] 📩 Action: addItem
//   State before: items=3, loading=false
//   State after:  items=4, loading=false
//
// → Trace CHÍNH XÁC mọi state change!
// → Time-travel: replay log → reproduce bugs


// ╔══════════════════════════════════════════════════════════╗
// ║  9. SO SÁNH CÁC ARCHITECTURE PATTERNS                    ║
// ╚══════════════════════════════════════════════════════════╝

// ┌────────────────────┬──────────────────────────────────────┐
// │ Architecture       │ Đặc điểm                             │
// ├────────────────────┼──────────────────────────────────────┤
// │ MVVM (truyền thống)│ Bidirectional, nhiều entry points    │
// │                    │ Đơn giản, nhanh build                │
// │                    │ Khó debug state phức tạp             │
// ├────────────────────┼──────────────────────────────────────┤
// │ UDF + MVVM         │ Unidirectional, single send()       │
// │ (bài này)          │ Dễ test, dễ debug, action logging   │
// │                    │ Hơi verbose hơn                      │
// │                    │ Không cần 3rd party library          │
// ├────────────────────┼──────────────────────────────────────┤
// │ TCA                │ Composable reducers, Effects system  │
// │ (Swift Composable  │ Full UDF, dependency injection       │
// │  Architecture)     │ Steep learning curve                 │
// │                    │ Rất strong testing support            │
// │                    │ Cần Point-Free library               │
// ├────────────────────┼──────────────────────────────────────┤
// │ Redux-like         │ Global store, reducers, middleware   │
// │ (ReSwift, etc.)    │ Single source of truth TOÀN APP     │
// │                    │ Có thể overkill cho small apps       │
// └────────────────────┴──────────────────────────────────────┘
//
// KHUYẾN KHÍCH:
// Small screens       → Traditional MVVM (đơn giản đủ dùng)
// Medium complexity   → UDF + MVVM (bài này) ← SWEET SPOT
// Large/complex apps  → TCA hoặc custom Redux
// Single feature team → UDF + MVVM
// Multiple teams      → TCA (enforced conventions)


// ╔══════════════════════════════════════════════════════════╗
// ║  10. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: View bypass send() — mutate state trực tiếp
//    vm.state.items.append(newItem) // ❌ PHẢI dùng vm.send(.addItem)
//    ✅ FIX: state LUÔN private(set) — View chỉ READ

// ❌ PITFALL 2: Action enum quá lớn (30+ cases)
//    → Khó maintain, switch statement dài
//    ✅ FIX: Tách Action theo nhóm: UserAction, SystemAction
//            Hoặc tách ViewModel theo feature/section

// ❌ PITFALL 3: Side effect không quay lại qua send()
//    Task { let data = await fetch(); vm.state.items = data }
//    → Bypass UDF flow → không log, không test được
//    ✅ FIX: Task { let data = await fetch(); vm.send(.loaded(data)) }

// ❌ PITFALL 4: State struct quá lớn → re-render toàn bộ
//    @Observable nhìn property level → OK
//    Nhưng nếu dùng Equatable check toàn state → compare chậm
//    ✅ FIX: @Observable đã handle fine-grained observation
//            Tách state nếu screen quá phức tạp

// ❌ PITFALL 5: Async action không cancel khi view disappear
//    send(.loadItems) → Task chạy → view disappear → Task chạy tiếp
//    ✅ FIX: Lưu Task reference, cancel trong deinit hoặc send(.cancel)
//            Hoặc dùng .task { vm.send(.load) } (task tự cancel)

// ❌ PITFALL 6: Binding boilerplate quá nhiều
//    Mỗi control cần Binding(get:set:) wrapper → verbose
//    ✅ FIX: Helper computed properties trên ViewModel (Phần 5)
//            Hoặc generic .udf() Binding factory

// ✅ BEST PRACTICES:
// 1. State: struct Equatable, private(set), computed derived state
// 2. Action: enum liệt kê TẤT CẢ events (user + system)
// 3. send(): SINGLE entry point, @MainActor
// 4. Side effects: private, kết quả quay lại qua send()
// 5. View: CHỈ đọc state + gửi action, KHÔNG chứa logic
// 6. Testing: send(action) → assert state (deterministic)
// 7. Logging: #if DEBUG middleware trong send() → trace mọi thứ
// 8. Dependencies: protocol + init injection cho testability
// 9. Derived state: computed properties trên State struct
// 10. Binding adapters: helper properties cho SwiftUI controls
// 11. Mỗi screen 1 ViewModel — shared state qua AppStore/Environment
// 12. Start simple: không phải MỌI screen đều cần full UDF
```

---

Đây là chủ đề kiến trúc nâng cao — kết hợp nguyên tắc luồng dữ liệu một chiều với MVVM giúp code dễ debug, dễ test, và đặc biệt tránh state inconsistency trong SwiftUI. Mình sẽ giải thích từ lý thuyết đến production implementation.Mình đã tổng hợp toàn bộ kiến thức UDF + MVVM trong 10 phần. Đây là những điểm cốt lõi:

**Bản chất UDF** cực kỳ đơn giản: **State → View → Action → ViewModel → New State** — dữ liệu chỉ chảy 1 chiều. View **chỉ đọc** state và **gửi** action, ViewModel **nhận** action và **cập nhật** state. Không bao giờ View tự mutate state trực tiếp. Mọi thay đổi đều đi qua `send()` — single entry point.

**Ba thành phần cốt lõi:**

- **State** (Phần 3): Struct `Equatable` chứa **toàn bộ** data render UI. `private(set)` — View chỉ read. Computed properties cho derived state (`filteredItems`, `activeCount`, `canAddItem`) → View dùng trực tiếp, không tính toán.

- **Action** (Phần 3): Enum liệt kê **mọi thứ** có thể xảy ra — user actions (`.addItem`, `.toggleItem`) và system results (`.itemsLoaded`, `.loadFailed`). Enum cung cấp exhaustive list → không bỏ sót case nào.

- **ViewModel** (Phần 3): `send(_ action:)` là **duy nhất** entry point. Switch trên action → update state. Side effects (API, DB) chạy private async, kết quả **quay lại** qua `send()` — không bypass.

**Bốn phần giá trị nhất cho production:**

**Phần 4 — Side Effects Pattern**: Async operations (API, database) là "effects" — trigger bởi action, kết quả quay lại qua `send(.loaded(data))` hoặc `send(.failed(error))`. Debounced search dùng cancellable Task — cancel task cũ khi query đổi.

**Phần 5 — Binding Adapter**: SwiftUI controls cần `@Binding` nhưng UDF không cho View mutate trực tiếp. Solution: `Binding(get: { vm.state.x }, set: { vm.send(.setX($0)) })`. Helper computed properties trên ViewModel giúp clean code.

**Phần 6 — Testing**: Đây là **lợi ích lớn nhất** của UDF. Test cực đơn giản: tạo ViewModel với initial state → `send(action)` → assert `state`. Không cần mock UI, không cần render views. Init specific state để test edge cases. Mock repository cho async tests.

**Phần 8 — Action Logging**: Vì mọi thứ đi qua `send()`, chỉ cần thêm `print()` trước/sau reduce → log **toàn bộ** state changes. Console hiện chính xác: action nào, state trước/sau ra sao. Time-travel debugging: replay log → reproduce bugs.

**So sánh ở Phần 9**: UDF + MVVM là **sweet spot** — đủ structure cho medium complexity apps mà không cần 3rd party library (như TCA). Với screens đơn giản → traditional MVVM đủ dùng. Với apps rất phức tạp → cân nhắc TCA.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
