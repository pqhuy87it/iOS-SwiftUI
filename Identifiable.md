# SwiftUI: `Identifiable` — Giải thích chi tiết

## 1. Bản chất — Mỗi phần tử phải có "căn cước"

`Identifiable` là protocol yêu cầu type có **một property `id` duy nhất**, cho phép SwiftUI **phân biệt** từng phần tử trong collection. Nhờ `id`, SwiftUI biết phần tử nào được thêm, xóa, di chuyển, hay thay đổi — từ đó chỉ cập nhật đúng view cần thiết thay vì re-render toàn bộ list.

```swift
protocol Identifiable {
    associatedtype ID: Hashable
    var id: ID { get }
}
```

Chỉ yêu cầu **1 thứ**: property `id` có kiểu conform `Hashable`.

```swift
struct User: Identifiable {
    let id: UUID           // ← bắt buộc, duy nhất mỗi user
    var name: String
    var email: String
}
```

---

## 2. Tại sao SwiftUI cần Identifiable?

### Không có identity → SwiftUI không biết phần tử nào thay đổi

```swift
// Giả sử list users: ["Alice", "Bob", "Charlie"]
// Xóa "Bob" → list mới: ["Alice", "Charlie"]

// KHÔNG có identity:
// SwiftUI thấy: list từ 3 phần tử → 2 phần tử
// Không biết "Bob" bị xóa hay "Charlie" bị xóa
// → Phải DESTROY và REBUILD toàn bộ list ❌

// CÓ identity:
// SwiftUI thấy: id=2 ("Bob") biến mất, id=1 và id=3 vẫn còn
// → Chỉ remove row id=2, giữ nguyên row id=1 và id=3 ✅
// → Animation mượt, performance tốt
```

### Identity quyết định View lifecycle

```swift
ForEach(users) { user in
    UserRow(user: user)
    // SwiftUI map: user.id → UserRow instance
    // Cùng id → CÙNG view (update data, giữ state)
    // id mới → view MỚI (tạo mới, animation insert)
    // id biến mất → view BỊ XÓA (animation delete)
}
```

```
TRƯỚC: [Alice(id:1), Bob(id:2), Charlie(id:3)]
SAU:   [Alice(id:1), Charlie(id:3), Dave(id:4)]

SwiftUI diff:
  id:1 (Alice)   → VẪN CÒN → giữ view, update nếu data đổi
  id:2 (Bob)     → BIẾN MẤT → xóa view (animation slide out)
  id:3 (Charlie) → VẪN CÒN → giữ view
  id:4 (Dave)    → MỚI     → tạo view (animation slide in)
```

---

## 3. Cách conform Identifiable

### 3.1 Dùng UUID — Phổ biến nhất

```swift
struct Todo: Identifiable {
    let id = UUID()        // tự tạo UUID duy nhất mỗi instance
    var title: String
    var isDone: Bool
}

let todo1 = Todo(title: "Buy milk", isDone: false)
let todo2 = Todo(title: "Buy milk", isDone: false)
// todo1.id ≠ todo2.id (dù cùng title, cùng isDone)
```

### 3.2 Dùng ID từ server / database

```swift
struct Product: Identifiable {
    let id: Int            // ID từ API: 1001, 1002, ...
    var name: String
    var price: Double
}

// Decode từ JSON
struct Product: Identifiable, Codable {
    let id: Int
    let name: String
    let price: Double
}
// JSON: {"id": 1001, "name": "iPhone", "price": 999}
// → Product(id: 1001, ...) — id tự map
```

### 3.3 Dùng String làm ID

```swift
struct Country: Identifiable {
    let id: String         // country code: "VN", "US", "JP"
    var name: String
    var flag: String
}

let vietnam = Country(id: "VN", name: "Vietnam", flag: "🇻🇳")
```

### 3.4 Dùng property khác làm ID (custom keypath)

```swift
struct Email: Identifiable {
    var id: String { address }    // computed — dùng address làm id
    let address: String
    var subject: String
}
// Không cần property "id" riêng — address ĐÃ LÀ duy nhất
```

### 3.5 Enum conform Identifiable

```swift
enum Category: String, Identifiable, CaseIterable {
    case electronics, clothing, food, books
    
    var id: String { rawValue }
    // ↑ rawValue đã duy nhất cho mỗi case
}

// Dùng trong ForEach
ForEach(Category.allCases) { category in
    Text(category.rawValue.capitalized)
}
```

### 3.6 Struct đã có property tên `id` → tự động conform

```swift
// Nếu struct có property tên "id" với type Hashable
// → Swift tự synthesize Identifiable conformance

struct Message: Identifiable {
    let id: Int        // Swift tự hiểu: đây là Identifiable.id
    var text: String
    // Không cần viết thêm gì
}
```

---

## 4. Identifiable trong SwiftUI — Nơi bắt buộc

### 4.1 `ForEach`

```swift
// ✅ Model conform Identifiable → ForEach nhận trực tiếp
struct User: Identifiable {
    let id: UUID
    var name: String
}

ForEach(users) { user in
    Text(user.name)
}
// SwiftUI dùng user.id để track từng row
```

```swift
// ❌ Model KHÔNG conform Identifiable → compile error
struct Item {
    var name: String
}

ForEach(items) { item in    // ❌ Error: Item does not conform to Identifiable
    Text(item.name)
}
```

```swift
// Thay thế: chỉ định id thủ công qua keypath
ForEach(items, id: \.name) { item in
    Text(item.name)
}
// ⚠️ name phải duy nhất, nếu trùng → SwiftUI confused
```

### 4.2 `List`

```swift
// Identifiable
List(users) { user in
    Text(user.name)
}

// Hoặc ForEach bên trong List
List {
    ForEach(users) { user in
        UserRow(user: user)
    }
    .onDelete { indexSet in
        users.remove(atOffsets: indexSet)
    }
}
```

### 4.3 `.sheet(item:)` / `.alert(item:)` / `.fullScreenCover(item:)`

```swift
struct ErrorInfo: Identifiable {
    let id = UUID()
    let message: String
}

struct ContentView: View {
    @State private var currentError: ErrorInfo?
    //                                ↑ Optional Identifiable
    
    var body: some View {
        Button("Trigger Error") {
            currentError = ErrorInfo(message: "Something went wrong")
        }
        .sheet(item: $currentError) { error in
            // ↑ Hiện sheet khi currentError != nil
            // ↑ Dismiss khi currentError = nil
            // ↑ Cần Identifiable để SwiftUI phân biệt sheet instances
            ErrorView(message: error.message)
        }
    }
}
```

```swift
// .alert(item:)
.alert(item: $currentError) { error in
    // error: ErrorInfo — Identifiable
    Button("OK") { }
} message: { error in
    Text(error.message)
}
```

### 4.4 `NavigationLink` / `navigationDestination`

```swift
struct ProductList: View {
    @State private var selectedProduct: Product?
    //                                   ↑ Optional Identifiable
    let products: [Product]
    
    var body: some View {
        NavigationStack {
            List(products) { product in
                Button(product.name) {
                    selectedProduct = product
                }
            }
            .navigationDestination(item: $selectedProduct) { product in
                // ↑ item: yêu cầu Identifiable
                ProductDetailView(product: product)
            }
        }
    }
}
```

### 4.5 `onChange(of:)` / Animation identity

```swift
// SwiftUI dùng id để animate thay đổi
ForEach(items) { item in
    ItemRow(item: item)
        .transition(.slide)
}
// Thêm item mới (id mới) → animate slide in
// Xóa item (id biến mất) → animate slide out
// Update item (cùng id) → crossfade data mới
```

---

## 5. `id: \.self` — Khi type conform `Hashable`

Với primitive types (String, Int...) hoặc types đã Hashable, dùng `\.self` làm id:

```swift
// String array — mỗi string tự làm id cho chính nó
let fruits = ["Apple", "Banana", "Cherry"]
ForEach(fruits, id: \.self) { fruit in
    Text(fruit)
}

// Int array
ForEach([1, 2, 3, 4, 5], id: \.self) { number in
    Text("\(number)")
}

// Enum CaseIterable + Hashable
ForEach(Category.allCases, id: \.self) { category in
    Text(category.rawValue)
}
```

### ⚠️ Nguy hiểm khi dùng `\.self` với giá trị trùng

```swift
let names = ["Alice", "Bob", "Alice"]   // ← "Alice" xuất hiện 2 lần

ForEach(names, id: \.self) { name in
    Text(name)
}
// ⚠️ Hai "Alice" cùng id = "Alice"
// SwiftUI confused → behavior không xác định
// Có thể: render sai, animation lỗi, crash
```

```swift
// ✅ Giải pháp: wrap thành Identifiable
struct NameItem: Identifiable {
    let id = UUID()
    let name: String
}

let names = ["Alice", "Bob", "Alice"].map { NameItem(name: $0) }
ForEach(names) { item in
    Text(item.name)
}
// Mỗi NameItem có UUID riêng → không trùng
```

### `id: \.self` vs `Identifiable`

```
id: \.self:
  - Dùng chính GIÁ TRỊ làm identity
  - OK cho collection giá trị duy nhất
  - NGUY HIỂM khi có giá trị trùng
  - Không cần tạo struct/class riêng

Identifiable:
  - Dùng property `id` riêng biệt
  - AN TOÀN: id luôn duy nhất (UUID, server ID)
  - Chuẩn cho production code
  - Cần conform protocol
```

---

## 6. Stable Identity — id không nên thay đổi

### Quy tắc: `id` phải STABLE qua thời gian

```swift
// ❌ id thay đổi → SwiftUI nghĩ là PHẦN TỬ KHÁC
struct BadItem: Identifiable {
    var id = UUID()        // ← var, có thể thay đổi
    var name: String
    
    mutating func regenerateID() {
        id = UUID()        // ❌ SwiftUI: phần tử cũ bị xóa, phần tử mới xuất hiện
    }
}

// ✅ id cố định suốt đời
struct GoodItem: Identifiable {
    let id = UUID()        // ← let, không bao giờ thay đổi
    var name: String
}
```

### Hệ quả khi id thay đổi

```
item.id = UUID_A → SwiftUI tạo View_1 cho UUID_A
item.id = UUID_B → SwiftUI:
  - UUID_A biến mất → XÓA View_1 (mất hết state: scroll, text input, toggle...)
  - UUID_B là mới → TẠO View_2 (state reset về mặc định)
  → Trông như flicker/jump, mất user input
```

### id dùng array index — anti-pattern

```swift
// ❌ NGUY HIỂM: index thay đổi khi insert/delete
ForEach(Array(items.enumerated()), id: \.offset) { index, item in
    Text(item.name)
}
// Xóa item[0] → tất cả index dịch → SwiftUI confused
// item[1] giờ là index 0 → SwiftUI nghĩ nó là item CŨ ở index 0

// ✅ Dùng id thực sự
ForEach(items) { item in    // items: [Identifiable]
    Text(item.name)
}
```

---

## 7. Identifiable với Codable (API response)

```swift
// Typical API response
struct APIResponse: Codable {
    let results: [Movie]
}

struct Movie: Identifiable, Codable {
    let id: Int                // từ API: "id": 550
    let title: String
    let overview: String
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
    }
}

// Decode
let movies = try JSONDecoder().decode(APIResponse.self, from: data).results

// Dùng trong SwiftUI — id tự map
List(movies) { movie in
    MovieRow(movie: movie)
}
```

### API không có id → tự tạo

```swift
// API trả về item không có id
struct RawNotification: Codable {
    let title: String
    let body: String
    let timestamp: Date
}

// Wrap thành Identifiable
struct AppNotification: Identifiable {
    let id = UUID()                    // tự tạo
    let raw: RawNotification
    
    var title: String { raw.title }
    var body: String { raw.body }
}

// Hoặc dùng extension
extension RawNotification: Identifiable {
    var id: String { "\(title)-\(timestamp.timeIntervalSince1970)" }
    // ⚠️ Đảm bảo combo title+timestamp duy nhất
}
```

---

## 8. Identifiable vs Hashable vs Equatable

```
Equatable:    "Hai instance có GIỐNG NHAU không?"
              a == b → so sánh TẤT CẢ properties

Hashable:     "Cho tôi hash value để dùng trong Set/Dictionary"
              extends Equatable + hashValue

Identifiable: "Cho tôi ID để PHÂN BIỆT hai instance"
              Chỉ cần 1 property: id
              Hai instance có thể CÓ CÙNG DATA nhưng KHÁC id
```

```swift
struct Todo: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var isDone: Bool
}

let todo1 = Todo(id: UUID(), title: "Buy milk", isDone: false)
let todo2 = Todo(id: UUID(), title: "Buy milk", isDone: false)

// Identifiable: todo1.id ≠ todo2.id → KHÁC nhau (hai todo riêng biệt)
// Equatable:    todo1 ≠ todo2       → KHÁC nhau (vì id khác)
// Nếu so sánh chỉ title+isDone thì "giống", nhưng identity khác
```

### SwiftUI dùng cả ba

```swift
ForEach(items) { item in ... }
//              ↑ Identifiable — track phần tử nào
//              SwiftUI dùng Equatable bên trong để detect DATA thay đổi

// Flow:
// 1. Dùng id (Identifiable) → tìm view tương ứng
// 2. Dùng == (Equatable) → check data có thay đổi không
// 3. Data thay đổi → re-render view đó
// 4. Data giống → skip, giữ view cũ
```

---

## 9. `.id()` Modifier — Gán identity cho View

Khác với `Identifiable` (cho data), `.id()` modifier gán identity cho **View**:

```swift
// Force re-create view khi id thay đổi
ScrollView {
    ContentView()
        .id(refreshToken)
        // ↑ refreshToken thay đổi → SwiftUI DESTROY + RE-CREATE view
}

// Ứng dụng: scroll to top
ScrollViewReader { proxy in
    ScrollView {
        LazyVStack {
            Color.clear.frame(height: 0).id("top")    // anchor
            
            ForEach(items) { item in
                ItemRow(item: item)
            }
        }
    }
    
    Button("Scroll to Top") {
        withAnimation {
            proxy.scrollTo("top", anchor: .top)
            //              ↑ scroll đến view có .id("top")
        }
    }
}
```

### `.id()` vs `Identifiable`

```
Identifiable:
  → Protocol trên DATA model
  → Dùng trong ForEach, List, sheet(item:)
  → Track phần tử trong collection

.id() modifier:
  → Modifier trên VIEW
  → Gán identity cho view instance
  → Thay đổi → destroy + recreate view (reset tất cả state)
  → Dùng cho ScrollViewReader, force refresh
```

---

## 10. Ví dụ tổng hợp — Todo App

```swift
// Model — Identifiable
struct Todo: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isDone: Bool
    var priority: Priority
    let createdAt: Date
    
    init(title: String, priority: Priority = .medium) {
        self.id = UUID()
        self.title = title
        self.isDone = false
        self.priority = priority
        self.createdAt = Date()
    }
    
    enum Priority: String, Identifiable, CaseIterable {
        case low, medium, high
        var id: String { rawValue }
    }
}

// ViewModel
@Observable
class TodoViewModel {
    var todos: [Todo] = []
    var selectedFilter: Todo.Priority?
    
    var filteredTodos: [Todo] {
        guard let filter = selectedFilter else { return todos }
        return todos.filter { $0.priority == filter }
    }
    
    func add(title: String, priority: Todo.Priority) {
        todos.append(Todo(title: title, priority: priority))
    }
    
    func toggle(_ todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        //                                          ↑ tìm bằng id, không phải ==
        todos[index].isDone.toggle()
    }
    
    func delete(at offsets: IndexSet) {
        todos.remove(atOffsets: offsets)
    }
}

// Views
struct TodoListView: View {
    @State private var vm = TodoViewModel()
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Filter picker — Enum Identifiable
                Picker("Filter", selection: $vm.selectedFilter) {
                    Text("All").tag(nil as Todo.Priority?)
                    ForEach(Todo.Priority.allCases) { priority in
                        //                           ↑ Identifiable enum
                        Text(priority.rawValue.capitalized)
                            .tag(priority as Todo.Priority?)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // List — struct Identifiable
                List {
                    ForEach(vm.filteredTodos) { todo in
                        //                      ↑ Todo: Identifiable
                        // SwiftUI dùng todo.id để:
                        // - Track từng row
                        // - Animate insert/delete
                        // - Giữ row state (swipe, expand...)
                        TodoRow(todo: todo) {
                            vm.toggle(todo)
                        }
                    }
                    .onDelete { vm.delete(at: $0) }
                }
            }
            .navigationTitle("Todos")
            .toolbar {
                Button("Add") { showAddSheet = true }
            }
            .sheet(isPresented: $showAddSheet) {
                AddTodoView { title, priority in
                    vm.add(title: title, priority: priority)
                }
            }
        }
    }
}

struct TodoRow: View {
    let todo: Todo
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(todo.isDone ? .green : .gray)
                .onTapGesture { onToggle() }
            
            VStack(alignment: .leading) {
                Text(todo.title)
                    .strikethrough(todo.isDone)
                Text(todo.priority.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

---

## 11. Tóm tắt

| Khía cạnh | Chi tiết |
|---|---|
| **Là gì?** | Protocol yêu cầu property `id: Hashable` — identity duy nhất cho mỗi instance |
| **Tại sao cần?** | SwiftUI dùng `id` để diff collection → biết thêm/xóa/update → animate chính xác, performance tốt |
| **id type phổ biến** | `UUID` (local), `Int` / `String` (từ API) |
| **Bắt buộc ở đâu?** | `ForEach`, `List`, `.sheet(item:)`, `.alert(item:)`, `.navigationDestination(item:)` |
| **Thay thế** | `ForEach(items, id: \.keypath)` — nhưng phải đảm bảo duy nhất |
| **id: \.self** | Dùng chính giá trị làm id — OK cho primitives, nguy hiểm khi trùng |
| **Quy tắc** | `id` phải **stable** (dùng `let`, không thay đổi), **duy nhất** trong collection |
| **vs Equatable** | Identifiable: "ai là ai". Equatable: "giống nhau không" |
| **vs .id() modifier** | `.id()` gán identity cho **View**, không phải data |

---

`Identifiable` là protocol nền tảng cho mọi collection-based UI trong SwiftUI, Huy. Ba điểm cốt lõi:

**Tại sao cần:** SwiftUI dùng `id` để **diff** collection — biết chính xác phần tử nào thêm, xóa, di chuyển, thay đổi. Không có identity → SwiftUI phải destroy + rebuild toàn bộ list mỗi khi data đổi. Có identity → chỉ update đúng row cần thiết, animation mượt (slide in/out khi insert/delete), giữ được state của row (scroll position, text input, toggle...).

**Stable identity là bắt buộc:** `id` phải dùng `let` (không thay đổi suốt đời instance). Nếu id thay đổi, SwiftUI nghĩ phần tử cũ bị xóa và phần tử mới xuất hiện → destroy view + tạo mới → mất hết state, UI flicker. Anti-pattern phổ biến nhất: dùng array index làm id (`id: \.offset`) — insert/delete làm index dịch → SwiftUI confused hoàn toàn.

**`id: \.self` vs `Identifiable`:** `\.self` tiện cho primitive types (String, Int) nhưng **nguy hiểm khi có giá trị trùng** — hai "Alice" cùng id = "Alice" → behavior không xác định. Trong production code, luôn ưu tiên conform `Identifiable` với UUID hoặc server ID.
