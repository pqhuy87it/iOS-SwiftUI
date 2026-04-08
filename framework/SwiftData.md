# SwiftUI: SwiftData — Giải thích chi tiết

## 1. Bản chất — Core Data thế hệ mới, Swift-native

SwiftData (iOS 17+) là framework **persistence** thay thế Core Data — lưu trữ data vào SQLite, tự động sync với iCloud, và tích hợp sâu với SwiftUI. Thay vì XML model editor + NSManagedObject + NSFetchRequest, SwiftData dùng **Swift macro + pure Swift classes**.

```
Core Data (cũ):
  .xcdatamodeld (XML editor) → NSManagedObjectModel
  NSManagedObject subclass   → entities
  NSFetchRequest             → queries
  NSManagedObjectContext     → write/read
  @FetchRequest              → SwiftUI integration

SwiftData (mới):
  @Model class               → model + schema (tất cả trong Swift code)
  ModelContainer             → database container
  ModelContext               → write/read
  @Query                     → SwiftUI integration
```

---

## 2. `@Model` — Định nghĩa Data Model

### Cơ bản

```swift
import SwiftData

@Model
class Todo {
    var title: String
    var isDone: Bool
    var createdAt: Date
    var priority: Int
    
    init(title: String, isDone: Bool = false, priority: Int = 0) {
        self.title = title
        self.isDone = isDone
        self.createdAt = Date()
        self.priority = priority
    }
}
```

`@Model` macro tự động:
- Conform `PersistentModel` + `Observable` (iOS 17 @Observable)
- Tạo schema cho database (bảng, cột)
- Tracking thay đổi (dirty tracking)
- Persist tất cả stored properties

### Supported Types

```swift
@Model
class Profile {
    // Primitives
    var name: String              // TEXT
    var age: Int                  // INTEGER
    var height: Double            // REAL
    var isActive: Bool            // INTEGER (0/1)
    
    // Foundation types
    var birthDate: Date           // REAL (timeInterval)
    var avatar: Data?             // BLOB
    var homepage: URL?            // TEXT
    var id: UUID                  // TEXT
    
    // Collections (stored as Transformable)
    var tags: [String]            // BLOB (encoded)
    var scores: [Int]             // BLOB (encoded)
    
    // Enums (with Codable conformance)
    var role: Role                // stored as raw value or encoded
    
    // Optional
    var bio: String?
    var deletedAt: Date?
    
    enum Role: String, Codable {
        case user, admin, moderator
    }
}
```

### `@Attribute` — Tuỳ chỉnh property

```swift
@Model
class User {
    // Unique constraint
    @Attribute(.unique)
    var email: String
    // ↑ email phải duy nhất — insert trùng → update (upsert)
    
    // External storage (file lớn lưu ngoài SQLite)
    @Attribute(.externalStorage)
    var profileImage: Data?
    // ↑ Data lớn (ảnh, video) lưu thành file riêng, SQLite chỉ giữ reference
    
    // Spotlight indexing
    @Attribute(.spotlight)
    var name: String
    // ↑ Index cho Spotlight search
    
    // Ephemeral (không persist)
    @Attribute(.ephemeral)
    var isSelected: Bool = false
    // ↑ Chỉ tồn tại trong memory, KHÔNG lưu vào database
    
    // Custom original name (schema migration)
    @Attribute(originalName: "user_name")
    var name: String
    // ↑ Database column tên "user_name", Swift property tên "name"
    //   Dùng khi rename property mà không muốn mất data
    
    var email: String
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
    }
}
```

### `@Relationship` — Quan hệ giữa models

```swift
@Model
class Author {
    var name: String
    
    // One-to-Many: 1 Author có nhiều Books
    @Relationship(deleteRule: .cascade)
    var books: [Book] = []
    // ↑ deleteRule: .cascade → xoá Author → xoá tất cả Books
    //              .nullify → xoá Author → books.author = nil
    //              .deny → không cho xoá Author nếu còn Books
    //              .noAction → xoá Author, Books giữ nguyên (orphan)
    
    init(name: String) {
        self.name = name
    }
}

@Model
class Book {
    var title: String
    var publishDate: Date
    
    // Many-to-One: inverse relationship
    var author: Author?
    // ↑ SwiftData tự detect inverse relationship
    //   Gán book.author = author → author.books tự thêm book
    
    // Many-to-Many
    @Relationship
    var categories: [Category] = []
    
    init(title: String, publishDate: Date = Date()) {
        self.title = title
        self.publishDate = publishDate
    }
}

@Model
class Category {
    var name: String
    var books: [Book] = []
    
    init(name: String) {
        self.name = name
    }
}
```

```
Author ──1:N──▶ [Book]     (cascade delete)
Book ──N:1──▶ Author?      (inverse, auto-detected)
Book ◀──N:M──▶ [Category]  (many-to-many)
```

### `@Transient` — Không persist

```swift
@Model
class Task {
    var title: String
    var isDone: Bool
    
    @Transient
    var isEditing: Bool = false
    // ↑ KHÔNG lưu vào database — chỉ tồn tại trong memory
    //   Giống @Attribute(.ephemeral)
    
    init(title: String) {
        self.title = title
        self.isDone = false
    }
}
```

---

## 3. `ModelContainer` — Database Container

### Tạo container

```swift
// Cách 1: Đơn giản — SwiftUI tự quản lý
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Todo.self)
        //                    ↑ Tạo container cho Todo model
        //                      SQLite file tạo tự động trong app sandbox
    }
}

// Nhiều models
.modelContainer(for: [Todo.self, Category.self, Tag.self])
```

### Cách 2: Custom configuration

```swift
@main
struct MyApp: App {
    let container: ModelContainer
    
    init() {
        let schema = Schema([Todo.self, Category.self])
        
        let config = ModelConfiguration(
            "MyDatabase",                    // tên database
            schema: schema,
            isStoredInMemoryOnly: false,     // true → in-memory (test)
            allowsSave: true,                // false → read-only
            groupContainer: .automatic       // App Group container
        )
        
        container = try! ModelContainer(
            for: schema,
            configurations: config
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
```

### In-memory container (cho testing / preview)

```swift
// Preview
#Preview {
    let container = try! ModelContainer(
        for: Todo.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    // Thêm sample data
    let context = container.mainContext
    context.insert(Todo(title: "Sample 1"))
    context.insert(Todo(title: "Sample 2"))
    
    return ContentView()
        .modelContainer(container)
}
```

---

## 4. `ModelContext` — CRUD Operations

### Lấy context trong SwiftUI

```swift
struct ContentView: View {
    @Environment(\.modelContext) private var context
    //                                      ↑ ModelContext từ environment
    //                                        inject bởi .modelContainer()
}
```

### CREATE — Insert

```swift
func addTodo(title: String) {
    let todo = Todo(title: title)
    context.insert(todo)
    // ↑ Thêm vào context → tự động save (autosave enabled mặc định)
    //   Không cần gọi context.save() thủ công (nhưng có thể nếu muốn)
}
```

### READ — Fetch

```swift
// FetchDescriptor — thay thế NSFetchRequest
func fetchTodos() throws -> [Todo] {
    let descriptor = FetchDescriptor<Todo>(
        predicate: #Predicate { $0.isDone == false },
        sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    return try context.fetch(descriptor)
}

// Với pagination
func fetchPage(offset: Int, limit: Int) throws -> [Todo] {
    var descriptor = FetchDescriptor<Todo>(
        sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    descriptor.fetchOffset = offset
    descriptor.fetchLimit = limit
    return try context.fetch(descriptor)
}

// Đếm
func countTodos() throws -> Int {
    let descriptor = FetchDescriptor<Todo>(
        predicate: #Predicate { $0.isDone == false }
    )
    return try context.fetchCount(descriptor)
}
```

### UPDATE — Modify properties trực tiếp

```swift
func toggleTodo(_ todo: Todo) {
    todo.isDone.toggle()
    // ↑ Chỉ cần modify property → SwiftData auto-detect dirty
    //   Auto-save sẽ persist thay đổi
    //   Không cần gọi context.save()
}

func updateTitle(_ todo: Todo, newTitle: String) {
    todo.title = newTitle
    // ← Trực tiếp thay đổi property. SwiftData tracks changes.
}
```

### DELETE

```swift
func deleteTodo(_ todo: Todo) {
    context.delete(todo)
    // ↑ Xoá khỏi context → auto-save → xoá khỏi database
}

// Batch delete
func deleteAllCompleted() throws {
    try context.delete(model: Todo.self, where: #Predicate {
        $0.isDone == true
    })
}
```

### Manual Save (khi cần)

```swift
func saveExplicitly() {
    do {
        try context.save()
    } catch {
        print("Save failed: \(error)")
    }
}
```

---

## 5. `#Predicate` — Type-safe Query

`#Predicate` là Swift macro tạo query **type-safe** — compiler kiểm tra property names và types tại compile-time:

```swift
// Cơ bản
#Predicate<Todo> { todo in
    todo.isDone == false
}

// So sánh string
#Predicate<Todo> { todo in
    todo.title.contains("important")
}

// Kết hợp điều kiện
#Predicate<Todo> { todo in
    todo.isDone == false && todo.priority > 2
}

// OR
#Predicate<Todo> { todo in
    todo.priority == 1 || todo.priority == 2
}

// Biến bên ngoài
let searchText = "buy"
let minPriority = 3
#Predicate<Todo> { todo in
    todo.title.localizedStandardContains(searchText) &&
    todo.priority >= minPriority
}

// Optional
#Predicate<Todo> { todo in
    todo.category?.name == "Work"
}

// Date comparison
let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
#Predicate<Todo> { todo in
    todo.createdAt > oneWeekAgo
}
```

### Predicate vs NSPredicate

```
NSPredicate (Core Data):
  NSPredicate(format: "isDone == %@ AND priority > %d", false, 2)
  ↑ String-based → runtime crash nếu typo
  
#Predicate (SwiftData):
  #Predicate<Todo> { $0.isDone == false && $0.priority > 2 }
  ↑ Swift macro → COMPILE-TIME check → typo = compile error ✅
```

---

## 6. `SortDescriptor` — Sắp xếp

```swift
// Ascending (mặc định)
SortDescriptor(\Todo.title)
SortDescriptor(\Todo.title, order: .forward)

// Descending
SortDescriptor(\Todo.createdAt, order: .reverse)

// Nhiều sort criteria
[
    SortDescriptor(\Todo.priority, order: .reverse),   // priority cao trước
    SortDescriptor(\Todo.createdAt, order: .reverse)    // cùng priority → mới nhất trước
]
```

---

## 7. `@Query` — SwiftUI Integration

`@Query` là property wrapper **tự động fetch data** và **re-render view** khi data thay đổi — thay thế `@FetchRequest` của Core Data.

### Cơ bản

```swift
struct TodoListView: View {
    @Query var todos: [Todo]
    // ↑ Tự động fetch TẤT CẢ Todo từ database
    //   Tự động re-render khi data thêm/xoá/sửa
    
    var body: some View {
        List(todos) { todo in
            Text(todo.title)
        }
    }
}
```

### Với Sort

```swift
@Query(sort: \Todo.createdAt, order: .reverse)
var todos: [Todo]
// ↑ Sắp xếp theo createdAt giảm dần

// Nhiều sort criteria
@Query(sort: [
    SortDescriptor(\Todo.priority, order: .reverse),
    SortDescriptor(\Todo.title)
])
var todos: [Todo]
```

### Với Filter (Predicate)

```swift
@Query(filter: #Predicate<Todo> { !$0.isDone })
var activeTodos: [Todo]
// ↑ Chỉ fetch todos chưa hoàn thành

@Query(
    filter: #Predicate<Todo> { $0.priority > 2 && !$0.isDone },
    sort: \Todo.createdAt,
    order: .reverse
)
var highPriorityTodos: [Todo]
```

### Với Animation

```swift
@Query(sort: \Todo.createdAt, animation: .spring)
var todos: [Todo]
// ↑ Thêm/xoá/sửa → animate thay đổi trong List
```

### Với FetchLimit

```swift
@Query(sort: \Todo.createdAt, order: .reverse)
var todos: [Todo]
// Hiện tại @Query không có fetchLimit trực tiếp
// Dùng .prefix() trên kết quả hoặc custom init
```

### Dynamic Query — Thay đổi filter/sort runtime

```swift
struct TodoListView: View {
    @State private var searchText = ""
    @State private var showCompleted = false
    
    // @Query không thể thay đổi predicate sau init
    // → Tách sang subview với init parameter
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
            Toggle("Show Completed", isOn: $showCompleted)
            
            FilteredTodoList(searchText: searchText, showCompleted: showCompleted)
            // ↑ Mỗi khi parameter đổi → subview re-create → @Query mới
        }
    }
}

struct FilteredTodoList: View {
    @Query var todos: [Todo]
    
    init(searchText: String, showCompleted: Bool) {
        let predicate = #Predicate<Todo> { todo in
            (searchText.isEmpty || todo.title.localizedStandardContains(searchText)) &&
            (showCompleted || !todo.isDone)
        }
        _todos = Query(
            filter: predicate,
            sort: [SortDescriptor(\Todo.createdAt, order: .reverse)],
            animation: .default
        )
    }
    
    var body: some View {
        List(todos) { todo in
            TodoRow(todo: todo)
        }
    }
}
```

---

## 8. Ví dụ hoàn chỉnh — Todo App

### Models

```swift
import SwiftData

@Model
class Todo {
    var title: String
    var isDone: Bool
    var priority: Priority
    var createdAt: Date
    var notes: String
    
    @Relationship(deleteRule: .nullify, inverse: \Category.todos)
    var category: Category?
    
    init(title: String, priority: Priority = .medium) {
        self.title = title
        self.isDone = false
        self.priority = priority
        self.createdAt = Date()
        self.notes = ""
    }
    
    enum Priority: Int, Codable, CaseIterable, Comparable {
        case low = 0, medium = 1, high = 2
        
        var label: String {
            switch self {
            case .low: "Low"
            case .medium: "Medium"
            case .high: "High"
            }
        }
        
        var color: Color {
            switch self {
            case .low: .gray
            case .medium: .blue
            case .high: .red
            }
        }
        
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

@Model
class Category {
    @Attribute(.unique)
    var name: String
    
    var todos: [Todo] = []
    
    init(name: String) {
        self.name = name
    }
}
```

### App Entry Point

```swift
@main
struct TodoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Todo.self, Category.self])
    }
}
```

### Views

```swift
struct ContentView: View {
    @State private var showAddSheet = false
    @State private var searchText = ""
    @State private var selectedFilter: TodoFilter = .all
    
    var body: some View {
        NavigationStack {
            TodoListView(searchText: searchText, filter: selectedFilter)
                .navigationTitle("Todos")
                .searchable(text: $searchText)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            ForEach(TodoFilter.allCases, id: \.self) { filter in
                                Button {
                                    selectedFilter = filter
                                } label: {
                                    Label(filter.label, systemImage: filter.icon)
                                    if selectedFilter == filter {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        } label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showAddSheet = true } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAddSheet) {
                    AddTodoView()
                }
        }
    }
}

enum TodoFilter: CaseIterable {
    case all, active, completed, highPriority
    
    var label: String {
        switch self {
        case .all: "All"
        case .active: "Active"
        case .completed: "Completed"
        case .highPriority: "High Priority"
        }
    }
    
    var icon: String {
        switch self {
        case .all: "tray.full"
        case .active: "circle"
        case .completed: "checkmark.circle"
        case .highPriority: "exclamationmark.triangle"
        }
    }
}

// Dynamic @Query subview
struct TodoListView: View {
    @Environment(\.modelContext) private var context
    @Query private var todos: [Todo]
    
    init(searchText: String, filter: TodoFilter) {
        let predicate: Predicate<Todo>? = {
            switch filter {
            case .all:
                if searchText.isEmpty { return nil }
                return #Predicate { $0.title.localizedStandardContains(searchText) }
            case .active:
                if searchText.isEmpty {
                    return #Predicate { !$0.isDone }
                }
                return #Predicate { !$0.isDone && $0.title.localizedStandardContains(searchText) }
            case .completed:
                if searchText.isEmpty {
                    return #Predicate { $0.isDone }
                }
                return #Predicate { $0.isDone && $0.title.localizedStandardContains(searchText) }
            case .highPriority:
                if searchText.isEmpty {
                    return #Predicate { $0.priority == .high }
                }
                return #Predicate { $0.priority == .high && $0.title.localizedStandardContains(searchText) }
            }
        }()
        
        if let predicate {
            _todos = Query(
                filter: predicate,
                sort: [SortDescriptor(\Todo.priority, order: .reverse),
                       SortDescriptor(\Todo.createdAt, order: .reverse)],
                animation: .default
            )
        } else {
            _todos = Query(
                sort: [SortDescriptor(\Todo.priority, order: .reverse),
                       SortDescriptor(\Todo.createdAt, order: .reverse)],
                animation: .default
            )
        }
    }
    
    var body: some View {
        if todos.isEmpty {
            ContentUnavailableView("No Todos", systemImage: "checklist",
                description: Text("Add a new todo to get started"))
        } else {
            List {
                ForEach(todos) { todo in
                    TodoRow(todo: todo)
                }
                .onDelete(perform: deleteTodos)
            }
        }
    }
    
    private func deleteTodos(at offsets: IndexSet) {
        for index in offsets {
            context.delete(todos[index])
        }
    }
}

struct TodoRow: View {
    let todo: Todo
    // ↑ @Model conform @Observable → SwiftUI tự track property changes
    //   todo.isDone thay đổi → row re-render
    
    var body: some View {
        HStack {
            Button {
                withAnimation { todo.isDone.toggle() }
                // ↑ Modify trực tiếp → SwiftData auto-save
            } label: {
                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.isDone ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .strikethrough(todo.isDone)
                    .foregroundStyle(todo.isDone ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    Text(todo.priority.label)
                        .font(.caption)
                        .foregroundStyle(todo.priority.color)
                    
                    if let category = todo.category {
                        Text(category.name)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    Text(todo.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

struct AddTodoView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var priority: Todo.Priority = .medium
    @State private var selectedCategory: Category?
    
    @Query(sort: \Category.name) var categories: [Category]
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                
                Picker("Priority", selection: $priority) {
                    ForEach(Todo.Priority.allCases, id: \.self) { p in
                        Text(p.label).tag(p)
                    }
                }
                
                Picker("Category", selection: $selectedCategory) {
                    Text("None").tag(nil as Category?)
                    ForEach(categories) { cat in
                        Text(cat.name).tag(cat as Category?)
                    }
                }
            }
            .navigationTitle("New Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let todo = Todo(title: title, priority: priority)
                        todo.category = selectedCategory
                        context.insert(todo)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
```

---

## 9. Schema Migration — Thay đổi model

### Lightweight migration (tự động)

SwiftData tự handle khi:
- Thêm property mới có default value
- Xoá property
- Rename property (dùng `originalName:`)

```swift
@Model
class Todo {
    var title: String
    var isDone: Bool
    var notes: String = ""        // ← THÊM MỚI với default → tự migrate
    
    @Attribute(originalName: "desc")
    var description: String       // ← RENAME từ "desc" → "description"
}
```

### Custom migration (VersionedSchema)

```swift
// Định nghĩa các phiên bản schema
enum TodoSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Todo.self] }
    
    @Model
    class Todo {
        var title: String
        var isDone: Bool
    }
}

enum TodoSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] { [Todo.self] }
    
    @Model
    class Todo {
        var title: String
        var isDone: Bool
        var priority: Int = 0    // ← property mới
    }
}

// Migration plan
enum TodoMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TodoSchemaV1.self, TodoSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: TodoSchemaV1.self,
        toVersion: TodoSchemaV2.self
    ) { context in
        // Custom migration logic
        let todos = try context.fetch(FetchDescriptor<TodoSchemaV2.Todo>())
        for todo in todos {
            todo.priority = 1    // default priority cho existing todos
        }
        try context.save()
    }
}

// Sử dụng
.modelContainer(
    for: Todo.self,
    migrationPlan: TodoMigrationPlan.self
)
```

---

## 10. ModelActor — Background Operations

```swift
// Heavy operations trên background thread
@ModelActor
actor DataImporter {
    // ↑ Tự động có modelContainer và modelExecutor
    
    func importTodos(from data: [ImportData]) throws {
        for item in data {
            let todo = Todo(title: item.title)
            modelContext.insert(todo)
        }
        try modelContext.save()
    }
    
    func deleteAllCompleted() throws {
        try modelContext.delete(model: Todo.self, where: #Predicate {
            $0.isDone == true
        })
        try modelContext.save()
    }
}

// Sử dụng
struct ImportButton: View {
    @Environment(\.modelContext) private var context
    
    var body: some View {
        Button("Import") {
            Task {
                let container = context.container
                let importer = DataImporter(modelContainer: container)
                try await importer.importTodos(from: importData)
            }
        }
    }
}
```

---

## 11. iCloud Sync

```swift
// Bật CloudKit sync — chỉ cần ModelConfiguration
let config = ModelConfiguration(
    cloudKitDatabase: .automatic
    // .automatic → sync với CloudKit container mặc định
    // .private("iCloud.com.myapp") → custom container
    // .none → không sync
)

let container = try ModelContainer(
    for: Todo.self,
    configurations: config
)
```

Yêu cầu:
- Enable CloudKit capability trong Xcode
- Enable Background Modes > Remote notifications
- iCloud account trên device

---

## 12. SwiftData vs Core Data

```
                        SwiftData              Core Data
                        ─────────              ─────────
Model definition        @Model (Swift code)    .xcdatamodeld (XML editor)
Query                   #Predicate (type-safe) NSPredicate (string-based)
SwiftUI integration     @Query                 @FetchRequest
Context                 ModelContext            NSManagedObjectContext
Container               ModelContainer         NSPersistentContainer
Migration               VersionedSchema        NSMappingModel
Background              @ModelActor            performBackgroundTask
Observable              Built-in (@Observable)  Manual (publisher)
Minimum iOS             17+                    11+ (with SwiftUI: 13+)
Maturity                Mới (iOS 17)           Rất mature (iOS 3)
```

---

## 13. Sai lầm thường gặp

### ❌ Quên .modelContainer ở App level

```swift
// ❌ @Query không hoạt động — không có container
struct MyView: View {
    @Query var todos: [Todo]    // crash: no ModelContext in environment
}

// ✅ Phải có .modelContainer ở ancestor
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: Todo.self)    // ← bắt buộc
    }
}
```

### ❌ #Predicate với operation không hỗ trợ

```swift
// ❌ Một số Swift operations không translate được sang SQL
#Predicate<Todo> { todo in
    todo.title.count > 5              // ⚠️ .count có thể không hoạt động
    todo.tags.contains("work")        // ⚠️ array operations hạn chế
}

// ✅ Dùng operations SwiftData hỗ trợ
#Predicate<Todo> { todo in
    todo.title.localizedStandardContains("search")
    todo.priority > 2
}
```

### ❌ Modify @Model object từ background thread không đúng cách

```swift
// ❌ Modify trên background thread trực tiếp
Task.detached {
    todo.title = "New"    // ❌ @Model object thuộc main context
}

// ✅ Dùng @ModelActor cho background work
```

---

## 14. Tóm tắt

| Concept | Vai trò |
|---|---|
| **@Model** | Macro biến class thành persistent model (tự tạo schema + Observable) |
| **ModelContainer** | Database container — tạo/quản lý SQLite file |
| **ModelContext** | Read/Write interface — insert, fetch, delete, save |
| **@Query** | SwiftUI property wrapper — auto-fetch + re-render khi data đổi |
| **#Predicate** | Type-safe query macro — compile-time check |
| **SortDescriptor** | Sắp xếp kết quả query |
| **@Attribute** | Tuỳ chỉnh property: .unique, .externalStorage, .spotlight |
| **@Relationship** | Quan hệ 1:N, N:M với delete rules |
| **@Transient** | Property không persist — chỉ memory |
| **@ModelActor** | Background operations an toàn |
| **VersionedSchema** | Schema migration giữa các phiên bản |

--- 

// ============================================================
// SWIFTDATA TRONG SWIFTUI - HƯỚNG DẪN CHI TIẾT (iOS 17+)
// ============================================================
// SwiftData là framework persistence declarative của Apple,
// ra mắt WWDC 2023, thay thế Core Data với API Swift-native.
// Tích hợp sâu với SwiftUI thông qua macro và property wrappers.
// ============================================================


// ╔══════════════════════════════════════════════════════════╗
// ║  1. ĐỊNH NGHĨA MODEL VỚI @Model MACRO                  ║
// ╚══════════════════════════════════════════════════════════╝

// @Model macro tự động:
// - Conform PersistentModel protocol
// - Thêm Observable conformance (thay @Published)
// - Generate schema từ stored properties
// - Tạo backing storage cho persistence

import SwiftData
import SwiftUI

@Model
final class Task {
    // --- Stored properties → tự động persist ---
    var title: String
    var note: String
    var isCompleted: Bool
    var createdAt: Date
    var priority: Priority
    
    // --- Enum cần Codable để SwiftData serialize ---
    enum Priority: Int, Codable, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
        
        var label: String {
            switch self {
            case .low: return "Thấp"
            case .medium: return "Trung bình"
            case .high: return "Cao"
            }
        }
    }
    
    // --- Computed properties KHÔNG persist (chỉ stored props) ---
    var isOverdue: Bool {
        !isCompleted && createdAt < Date.now
    }
    
    // --- Designated initializer (bắt buộc cho @Model) ---
    init(
        title: String,
        note: String = "",
        isCompleted: Bool = false,
        priority: Priority = .medium,
        createdAt: Date = .now
    ) {
        self.title = title
        self.note = note
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. PROPERTY WRAPPERS ĐIỀU KHIỂN SCHEMA                 ║
// ╚══════════════════════════════════════════════════════════╝

@Model
final class User {
    // @Attribute(.unique) → tạo UNIQUE constraint
    // Nếu insert trùng → upsert (update thay vì duplicate)
    @Attribute(.unique)
    var email: String
    
    var name: String
    
    // @Attribute(.externalStorage) → lưu data lớn ra file riêng
    // Phù hợp cho image, video, file attachment
    @Attribute(.externalStorage)
    var avatarData: Data?
    
    // @Attribute(.transformable(by:)) → custom ValueTransformer
    // Dùng khi cần serialize type phức tạp
    
    // @Attribute(.spotlight) → index cho Spotlight search (iOS 17+)
    @Attribute(.spotlight)
    var bio: String?
    
    // @Transient → KHÔNG persist, chỉ tồn tại in-memory
    // Hữu ích cho cache, computed state tạm
    @Transient
    var isOnline: Bool = false
    
    init(email: String, name: String, bio: String? = nil) {
        self.email = email
        self.name = name
        self.bio = bio
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3. RELATIONSHIPS (1-to-Many, Many-to-Many)             ║
// ╚══════════════════════════════════════════════════════════╝

// SwiftData tự động infer relationships từ type references.
// Dùng @Relationship để customize delete rule, inverse.

@Model
final class Category {
    var name: String
    var color: String
    
    // --- One-to-Many: 1 Category → nhiều Task ---
    // .cascade: xoá Category → xoá tất cả tasks liên quan
    // .nullify (default): xoá Category → tasks.category = nil
    // .deny: không cho xoá nếu còn tasks
    // .noAction: xoá nhưng không update tasks (cẩn thận!)
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.category)
    var tasks: [TaskItem] = []
    
    init(name: String, color: String = "#007AFF") {
        self.name = name
        self.color = color
    }
}

@Model
final class TaskItem {
    var title: String
    var isCompleted: Bool
    
    // --- Many-to-One: implicit inverse ---
    var category: Category?
    
    // --- Many-to-Many ---
    // Chỉ cần khai báo array ở cả 2 bên
    @Relationship(inverse: \Tag.tasks)
    var tags: [Tag] = []
    
    init(title: String, isCompleted: Bool = false, category: Category? = nil) {
        self.title = title
        self.isCompleted = isCompleted
        self.category = category
    }
}

@Model
final class Tag {
    @Attribute(.unique)
    var name: String
    
    var tasks: [TaskItem] = []
    
    init(name: String) {
        self.name = name
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. CẤU HÌNH ModelContainer & ModelContext               ║
// ╚══════════════════════════════════════════════════════════╝

// ModelContainer = database container (tương đương NSPersistentContainer)
// ModelContext   = workspace để CRUD (tương đương NSManagedObjectContext)

// --- 4a. Cách đơn giản nhất: .modelContainer modifier ---
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Tự động tạo container + inject vào Environment
        // Tất cả child views đều access được ModelContext
        .modelContainer(for: [TaskItem.self, Category.self, Tag.self])
    }
}

// --- 4b. Cấu hình nâng cao với ModelConfiguration ---
struct AppWithCustomConfig: App {
    let container: ModelContainer
    
    init() {
        let schema = Schema([TaskItem.self, Category.self, Tag.self])
        
        let config = ModelConfiguration(
            "MyAppStore",                    // tên file .store
            schema: schema,
            isStoredInMemoryOnly: false,     // true → in-memory (test/preview)
            allowsSave: true,                // false → read-only
            groupContainer: .automatic       // App Group sharing
            // cloudKitDatabase: .automatic  // iCloud sync
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}

// --- 4c. Multiple Configurations (tách database) ---
// Ví dụ: user data + cache data ở 2 file khác nhau
struct MultiStoreApp: App {
    let container: ModelContainer
    
    init() {
        let userConfig = ModelConfiguration(
            "UserData",
            schema: Schema([User.self]),
            url: URL.documentsDirectory.appending(path: "user.store")
        )
        let cacheConfig = ModelConfiguration(
            "CacheData",
            schema: Schema([TaskItem.self]),
            url: URL.cachesDirectory.appending(path: "cache.store")
        )
        
        do {
            container = try ModelContainer(
                for: User.self, TaskItem.self,
                configurations: [userConfig, cacheConfig]
            )
        } catch {
            fatalError("Container init failed: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(container)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. CRUD OPERATIONS VỚI ModelContext                     ║
// ╚══════════════════════════════════════════════════════════╝

struct TaskListView: View {
    // @Environment: lấy ModelContext từ container đã inject
    @Environment(\.modelContext) private var context
    
    // @Query: tự động fetch + observe changes (reactive)
    @Query(
        filter: #Predicate<TaskItem> { !$0.isCompleted },
        sort: \TaskItem.title,
        order: .forward,
        animation: .default
    )
    private var pendingTasks: [TaskItem]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(pendingTasks) { task in
                    TaskRow(task: task)
                }
                .onDelete(perform: deleteTasks)
            }
            .navigationTitle("Công việc")
            .toolbar {
                Button("Thêm", action: addTask)
            }
        }
    }
    
    // --- CREATE ---
    private func addTask() {
        let task = TaskItem(title: "Việc mới \(Date.now.formatted())")
        context.insert(task)
        // SwiftData tự động save khi cần (autosave)
        // Hoặc gọi thủ công: try? context.save()
    }
    
    // --- DELETE ---
    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            context.delete(pendingTasks[index])
        }
    }
}

struct TaskRow: View {
    // @Bindable: tạo Binding từ @Model object (iOS 17+)
    // Cho phép two-way binding trực tiếp vào model properties
    @Bindable var task: TaskItem
    
    var body: some View {
        HStack {
            // --- UPDATE: thay đổi trực tiếp → auto-persist ---
            Toggle(isOn: $task.isCompleted) {
                VStack(alignment: .leading) {
                    TextField("Tiêu đề", text: $task.title)
                    if let category = task.category {
                        Text(category.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. @Query - FETCHING DATA CHI TIẾT                     ║
// ╚══════════════════════════════════════════════════════════╝

// @Query là property wrapper thay thế @FetchRequest (Core Data).
// Tự động observe changes và refresh UI.

struct QueryExamplesView: View {
    
    // --- 6a. Basic: fetch tất cả, sort theo date ---
    @Query(sort: \TaskItem.title)
    private var allTasks: [TaskItem]
    
    // --- 6b. Filter với #Predicate macro ---
    // #Predicate compile-time check, type-safe hơn NSPredicate
    @Query(
        filter: #Predicate<TaskItem> { task in
            task.isCompleted == false && task.title.contains("quan trọng")
        },
        sort: [
            SortDescriptor(\TaskItem.isCompleted),   // chưa xong lên trước
            SortDescriptor(\TaskItem.title, order: .forward)
        ]
    )
    private var importantPending: [TaskItem]
    
    // --- 6c. Fetch limit (pagination) ---
    @Query(sort: \TaskItem.title, animation: .spring)
    private var tasks: [TaskItem]
    // Lưu ý: @Query chưa hỗ trợ fetchLimit trực tiếp
    // → Dùng FetchDescriptor nếu cần limit (xem phần 7)
    
    // --- 6d. Dynamic Query: thay đổi filter/sort tại runtime ---
    // Dùng init(_:) của @Query
    @Query private var filteredTasks: [TaskItem]
    
    init(showCompleted: Bool) {
        let predicate = #Predicate<TaskItem> { task in
            showCompleted || !task.isCompleted
        }
        _filteredTasks = Query(
            filter: predicate,
            sort: \TaskItem.title
        )
    }
    
    var body: some View {
        List(filteredTasks) { task in
            Text(task.title)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. FetchDescriptor - ADVANCED FETCHING                  ║
// ╚══════════════════════════════════════════════════════════╝

// Khi cần fetch thủ công ngoài SwiftUI view (ViewModel, Service)
// hoặc cần fetchLimit, fetchOffset...

struct FetchDescriptorExamples {
    let context: ModelContext
    
    // --- 7a. Basic fetch ---
    func fetchAllTasks() throws -> [TaskItem] {
        let descriptor = FetchDescriptor<TaskItem>(
            sortBy: [SortDescriptor(\.title)]
        )
        return try context.fetch(descriptor)
    }
    
    // --- 7b. Fetch với limit + offset (pagination) ---
    func fetchPage(page: Int, pageSize: Int) throws -> [TaskItem] {
        var descriptor = FetchDescriptor<TaskItem>(
            sortBy: [SortDescriptor(\.title)]
        )
        descriptor.fetchLimit = pageSize
        descriptor.fetchOffset = page * pageSize
        return try context.fetch(descriptor)
    }
    
    // --- 7c. Fetch count (không load objects) ---
    func countPendingTasks() throws -> Int {
        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate { !$0.isCompleted }
        )
        return try context.fetchCount(descriptor)
    }
    
    // --- 7d. Fetch identifiers only (lightweight) ---
    func fetchTaskIDs() throws -> [PersistentIdentifier] {
        let descriptor = FetchDescriptor<TaskItem>()
        return try context.fetchIdentifiers(descriptor)
    }
    
    // --- 7e. Complex predicate ---
    func searchTasks(keyword: String, minPriority: Int) throws -> [TaskItem] {
        let predicate = #Predicate<TaskItem> { task in
            task.title.localizedStandardContains(keyword) &&
            !task.isCompleted
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 50
        return try context.fetch(descriptor)
    }
    
    // --- 7f. Enumerate (memory-efficient batch processing) ---
    func processAllTasks() throws {
        let descriptor = FetchDescriptor<TaskItem>()
        try context.enumerate(descriptor, batchSize: 100) { task in
            // Process từng task, batchSize control memory footprint
            task.isCompleted = true
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. #Predicate MACRO CHI TIẾT                            ║
// ╚══════════════════════════════════════════════════════════╝

// #Predicate là macro thay thế NSPredicate, compile-time type-safe.
// Hỗ trợ: ==, !=, <, >, <=, >=, &&, ||, !
// String: .contains(), .localizedStandardContains(),
//         .hasPrefix(), .hasSuffix()
// Optional: != nil, == nil
// Collection: .contains(), .filter(), .isEmpty

struct PredicateExamples {
    // --- Combine nhiều conditions ---
    static let complexFilter = #Predicate<TaskItem> { task in
        !task.isCompleted &&
        task.title.localizedStandardContains("review") &&
        task.category != nil
    }
    
    // --- Variable capture (dynamic values) ---
    static func tasksAfter(date: Date) -> Predicate<TaskItem> {
        // Capture biến bên ngoài vào predicate
        return #Predicate<TaskItem> { task in
            task.isCompleted == false
        }
    }
    
    // --- Optional handling ---
    static let hasCategory = #Predicate<TaskItem> { task in
        task.category != nil
    }
    
    // --- Lưu ý quan trọng về #Predicate ---
    // 1. KHÔNG hỗ trợ: switch, if-else, guard, enum comparison trực tiếp
    // 2. KHÔNG dùng được: .map(), .compactMap(), custom methods
    // 3. Enum phải compare qua rawValue
    // 4. Relationship traversal hạn chế (chỉ 1 level)
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. MODELCONTEXT NÂNG CAO                                ║
// ╚══════════════════════════════════════════════════════════╝

struct ContextAdvancedUsage {
    
    // --- 9a. Undo/Redo support ---
    static func setupUndoManager(container: ModelContainer) {
        let context = container.mainContext
        context.undoManager = UndoManager()
        // Giờ mọi thay đổi đều có thể undo/redo
    }
    
    // --- 9b. Background context (heavy operations) ---
    @MainActor
    static func importData(container: ModelContainer, items: [String]) async {
        // Tạo background context → tránh block main thread
        let backgroundContext = ModelContext(container)
        backgroundContext.autosaveEnabled = false
        
        for title in items {
            let task = TaskItem(title: title)
            backgroundContext.insert(task)
        }
        
        do {
            try backgroundContext.save()
        } catch {
            print("Background save failed: \(error)")
        }
        // Main context sẽ tự động merge changes
    }
    
    // --- 9c. Rollback changes ---
    static func rollback(context: ModelContext) {
        context.rollback()
        // Huỷ tất cả unsaved changes
    }
    
    // --- 9d. Transaction-like batch operations ---
    static func batchUpdate(context: ModelContext) throws {
        context.autosaveEnabled = false
        defer { context.autosaveEnabled = true }
        
        // Thực hiện nhiều operations
        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate { $0.isCompleted }
        )
        let completedTasks = try context.fetch(descriptor)
        for task in completedTasks {
            context.delete(task)
        }
        
        // Commit tất cả cùng lúc
        try context.save()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. SCHEMA MIGRATION (VersionedSchema)                  ║
// ╚══════════════════════════════════════════════════════════╝

// Khi thay đổi model (thêm/xoá property, rename, đổi type)
// → cần Migration để không mất data người dùng.

// --- Bước 1: Định nghĩa Schema versions ---

enum TaskSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [TaskV1.self]
    }
    
    @Model
    final class TaskV1 {
        var title: String
        var isCompleted: Bool
        init(title: String, isCompleted: Bool = false) {
            self.title = title
            self.isCompleted = isCompleted
        }
    }
}

enum TaskSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [TaskV2.self]
    }
    
    @Model
    final class TaskV2 {
        var title: String
        var isCompleted: Bool
        var priority: Int  // ← property mới
        init(title: String, isCompleted: Bool = false, priority: Int = 0) {
            self.title = title
            self.isCompleted = isCompleted
            self.priority = priority
        }
    }
}

// --- Bước 2: Định nghĩa Migration Plan ---

enum TaskMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TaskSchemaV1.self, TaskSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    // Lightweight migration: SwiftData tự handle (thêm property với default)
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: TaskSchemaV1.self,
        toVersion: TaskSchemaV2.self
    )
    
    // Custom migration: khi cần transform data
    // static let customMigration = MigrationStage.custom(
    //     fromVersion: TaskSchemaV1.self,
    //     toVersion: TaskSchemaV2.self,
    //     willMigrate: { context in
    //         // Transform data trước khi schema change
    //     },
    //     didMigrate: { context in
    //         // Cleanup sau khi schema change
    //         let tasks = try context.fetch(FetchDescriptor<TaskSchemaV2.TaskV2>())
    //         for task in tasks {
    //             task.priority = task.isCompleted ? 0 : 1
    //         }
    //         try context.save()
    //     }
    // )
}

// --- Bước 3: Apply migration plan vào container ---
struct MigratingApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(
                for: TaskSchemaV2.TaskV2.self,
                migrationPlan: TaskMigrationPlan.self
            )
        } catch {
            fatalError("Migration failed: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(container)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. SWIFTDATA + CLOUDKIT (iCloud Sync)                  ║
// ╚══════════════════════════════════════════════════════════╝

// SwiftData hỗ trợ iCloud sync thông qua CloudKit.
// Yêu cầu:
// 1. Enable iCloud capability + CloudKit
// 2. Tạo CloudKit container
// 3. Tất cả properties phải có default value hoặc optional
// 4. Relationships phải optional
// 5. Không dùng @Attribute(.unique) (CloudKit không hỗ trợ)

struct CloudSyncApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: TaskItem.self)
            // CloudKit sync tự động nếu đã enable capability
            // Hoặc cấu hình explicit:
            // ModelConfiguration(cloudKitDatabase: .automatic)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  12. TESTING & PREVIEW VỚI IN-MEMORY STORE              ║
// ╚══════════════════════════════════════════════════════════╝

// --- Preview container ---
@MainActor
let previewContainer: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: TaskItem.self, Category.self, Tag.self,
        configurations: config
    )
    
    // Seed sample data
    let sampleCategory = Category(name: "Công việc", color: "#FF6B6B")
    container.mainContext.insert(sampleCategory)
    
    for i in 1...5 {
        let task = TaskItem(
            title: "Task mẫu \(i)",
            isCompleted: i % 2 == 0,
            category: sampleCategory
        )
        container.mainContext.insert(task)
    }
    
    return container
}()

// Sử dụng trong Preview:
#Preview {
    TaskListView()
        .modelContainer(previewContainer)
}

// --- Unit Test ---
// @Test hoặc XCTest
func testCreateTask() throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: TaskItem.self, configurations: config)
    let context = ModelContext(container)
    
    let task = TaskItem(title: "Test task")
    context.insert(task)
    try context.save()
    
    let fetched = try context.fetch(FetchDescriptor<TaskItem>())
    assert(fetched.count == 1)
    assert(fetched.first?.title == "Test task")
}


// ╔══════════════════════════════════════════════════════════╗
// ║  13. BEST PRACTICES & PRODUCTION TIPS                    ║
// ╚══════════════════════════════════════════════════════════╝

// 1. MODEL DESIGN
//    - Dùng value types (enum Codable, struct Codable) cho nested data
//    - @Transient cho computed/cache properties
//    - @Attribute(.externalStorage) cho data > 100KB
//    - Tránh deep relationship chains (performance)

// 2. PERFORMANCE
//    - Dùng fetchLimit + fetchOffset cho large datasets
//    - enumerate() cho batch processing (memory-efficient)
//    - fetchCount() / fetchIdentifiers() khi không cần full objects
//    - Background ModelContext cho heavy imports

// 3. THREADING
//    - mainContext → chỉ dùng trên Main thread (UI)
//    - ModelContext(container) → background work
//    - @Model objects KHÔNG thread-safe → pass PersistentIdentifier
//      giữa các context, rồi fetch lại trên context đích

// 4. ERROR HANDLING
//    - Wrap context.save() trong do-catch
//    - Handle merge conflicts khi multiple contexts
//    - Test migration trên real data trước khi ship

// 5. MIGRATION
//    - LUÔN dùng VersionedSchema từ đầu (dù chỉ v1)
//    - Lightweight migration cho thêm optional/default properties
//    - Custom migration cho rename, type change, data transform
//    - Test migration với production database copy

// 6. SWIFTDATA vs CORE DATA DECISION
//    - SwiftData: iOS 17+, new projects, SwiftUI-first
//    - Core Data: backward compatibility < iOS 17,
//      NSFetchedResultsController, complex NSPredicate,
//      advanced CloudKit customization
//    - Có thể coexist: SwiftData đọc Core Data .sqlite files

---

Huy, đây là một chủ đề rất hay! SwiftData là framework persistence hiện đại của Apple, thay thế Core Data với API declarative tích hợp sâu vào SwiftUI. Mình sẽ giải thích chi tiết toàn bộ.Mình đã tổng hợp toàn bộ kiến thức SwiftData theo 13 phần chính. Dưới đây là tóm tắt các điểm cốt lõi:

**Kiến trúc SwiftData** hoạt động trên 3 trụ cột: `@Model` macro định nghĩa schema từ Swift classes, `ModelContainer` quản lý database storage, và `ModelContext` là workspace cho mọi thao tác CRUD. Container được inject vào SwiftUI qua `.modelContainer()` modifier, còn context được lấy ra qua `@Environment(\.modelContext)`.

**Điểm khác biệt lớn so với Core Data** là tính declarative — thay vì `.xcdatamodeld` file và code generation, bạn chỉ cần đánh `@Model` lên class. Relationships tự động infer từ type references, và `@Query` property wrapper thay thế hoàn toàn `@FetchRequest` với type-safe `#Predicate` macro.

**Những phần đặc biệt quan trọng cho production** mà mình highlight trong guide:

- **Section 7 — FetchDescriptor**: Đây là API bạn sẽ dùng nhiều nhất ngoài View layer, hỗ trợ `fetchLimit`, `fetchOffset` (pagination), `fetchCount`, và `enumerate()` cho batch processing memory-efficient.

- **Section 9 — Background context**: `ModelContext(container)` tạo context mới cho heavy operations, tránh block main thread. Lưu ý `@Model` objects không thread-safe, cần pass `PersistentIdentifier` giữa các context.

- **Section 10 — Migration**: Nên dùng `VersionedSchema` ngay từ v1. Lightweight migration handle được thêm property với default value, còn custom migration cần cho rename/transform data.

Huy muốn mình đi sâu thêm vào phần nào không — ví dụ pattern kết hợp SwiftData với MVVM, hoặc so sánh chi tiết performance với Core Data?
