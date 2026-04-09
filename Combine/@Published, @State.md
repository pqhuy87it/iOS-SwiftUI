# SwiftUI: `@Published` & `@State`

## 1. Bức tranh tổng thể — Hai thế giới State

```
┌──────────────────────────────────────────────────────────────┐
│                    SwiftUI State System                      │
│                                                              │
│   TRONG View (struct)              NGOÀI View (class)        │
│   ───────────────────              ──────────────────        │
│   @State                           @Published                │
│   - Value type (Int, String...)    - Property của class      │
│   - SwiftUI sở hữu & quản lý     - Combine publisher         │
│   - Private, local                - Kết hợp ObservableObject │
│   - Sống cùng view identity       - Nhiều view observe được  │
│                                                              │
│   struct CounterView: View {       class ViewModel: OO {     │
│     @State var count = 0             @Published var count = 0│
│   }                                }                         │
└──────────────────────────────────────────────────────────────┘
```

---

## 2. `@State` — Source of Truth bên trong View

### Bản chất

`@State` là property wrapper nói với SwiftUI: **"Giá trị này thuộc về view, hãy lưu trữ và quản lý giúp tôi. Khi nó thay đổi, re-render view."**

SwiftUI **không lưu** `@State` trong struct instance. Nó lưu ở **storage riêng bên ngoài struct**, được quản lý bởi framework. Đây là lý do giá trị không bị mất khi struct bị tạo lại.

```swift
struct CounterView: View {
    @State private var count = 0
    //      ↑ convention: luôn private vì chỉ view này sở hữu
    
    var body: some View {
        Button("Count: \(count)") {
            count += 1
            // Thay đổi count → SwiftUI re-render body
        }
    }
}
```

### Tại sao cần @State? Struct là immutable!

```swift
struct CounterView: View {
    var count = 0          // ❌ struct property
    
    var body: some View {
        Button("Count: \(count)") {
            count += 1     // ❌ Compile error: cannot mutate property of immutable struct
        }
    }
}
```

Vấn đề: View là `struct` → immutable. Không thể mutate property trực tiếp. `@State` giải quyết bằng cách lưu giá trị **bên ngoài struct**, cung cấp getter/setter qua property wrapper:

```
struct CounterView          SwiftUI Internal Storage
┌──────────────────┐       ┌───────────────────────┐
│ @State var count ─────── │ count = 0             │
│                  │       │ (managed by SwiftUI)  │
│ body {           │       └───────────────────────┘
│   count += 1 ────────── mutate storage, không mutate struct
│ }                │
└──────────────────┘
```

### Vòng đời @State

```
SwiftUI tạo CounterView lần đầu
    │
    ├── @State count = 0        → SwiftUI allocate storage, gán 0
    │
    ├── User tap → count = 1    → SwiftUI update storage
    │                            → body gọi lại (re-render)
    │
    ├── Parent re-render         → struct CounterView.init() chạy lại
    │   (counter = 0 trong init)   NHƯNG SwiftUI GIỮA storage cũ (count = 1)
    │                              body đọc count = 1 ✅ (không bị reset)
    │
    └── View bị remove khỏi tree → SwiftUI giải phóng storage
        (view identity thay đổi)    count mất
```

**Điểm mấu chốt:** `@State` initial value chỉ dùng **lần đầu tiên** view xuất hiện. Các lần struct init lại sau đó, SwiftUI bỏ qua initial value và dùng giá trị đang có trong storage.

### Binding: `$count` — Đọc/Ghi hai chiều

`@State` cung cấp **projected value** là `Binding<Value>`, truy cập qua prefix `$`:

```swift
struct ParentView: View {
    @State private var name = ""
    
    var body: some View {
        VStack {
            // $name = Binding<String> → TextField đọc VÀ ghi
            TextField("Enter name", text: $name)
            
            // name (không $) = String → chỉ đọc
            Text("Hello, \(name)")
            
            // Truyền Binding xuống view con
            ChildView(name: $name)
        }
    }
}

struct ChildView: View {
    @Binding var name: String    // nhận Binding, đọc/ghi ngược lên parent
    
    var body: some View {
        Button("Clear") { name = "" }  // ghi → parent's @State thay đổi
    }
}
```

```
@State var name                  ChildView
┌──────────────────┐           ┌───────────────────┐
│ wrappedValue:    │◄──────────│ @Binding var name │
│   get → "Huy"    │  Binding  │   get → đọc State │
│   set → update   │◄──────────│   set → ghi State │
│                  │           │                   │
│ projectedValue:  │           └───────────────────┘
│   $name (Binding)│
└──────────────────┘
```

### @State dùng cho kiểu dữ liệu nào?

```swift
// ✅ Value types — đúng mục đích thiết kế
@State private var count = 0                    // Int
@State private var name = ""                    // String
@State private var isPresented = false          // Bool
@State private var selectedTab = 0              // Int (enum tag)
@State private var items = ["A", "B", "C"]      // Array
@State private var offset: CGSize = .zero       // Struct

// ⚠️ Reference types (class) — CÓ THỂ nhưng KHÔNG NÊN
@State private var viewModel = ViewModel()
// @State theo dõi REFERENCE (con trỏ), không theo dõi PROPERTY bên trong
// vm.name = "new" → @State KHÔNG biết → KHÔNG re-render
// Dùng @StateObject thay thế cho class
```

### Ví dụ thực tế — Form state

```swift
struct RegistrationForm: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var agreedToTerms = false
    @State private var showingAlert = false
    @State private var selectedRole: Role = .user
    
    enum Role: String, CaseIterable {
        case user, admin, moderator
    }
    
    var isFormValid: Bool {
        !username.isEmpty && !email.isEmpty && password.count >= 8 && agreedToTerms
    }
    
    var body: some View {
        Form {
            Section("Account") {
                TextField("Username", text: $username)
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
            }
            
            Section("Role") {
                Picker("Role", selection: $selectedRole) {
                    ForEach(Role.allCases, id: \.self) { role in
                        Text(role.rawValue.capitalized)
                    }
                }
            }
            
            Section {
                Toggle("I agree to Terms", isOn: $agreedToTerms)
            }
            
            Button("Register") { showingAlert = true }
                .disabled(!isFormValid)
        }
        .alert("Success!", isPresented: $showingAlert) {
            Button("OK") { }
        }
    }
}
```

---

## 3. `@Published` — Combine Publisher bên trong Class

### Bản chất

`@Published` là property wrapper **từ Combine framework** (không phải SwiftUI). Nó biến một property thành **publisher** — mỗi khi giá trị **sắp thay đổi** (willSet), nó tự động gửi giá trị mới qua Combine pipeline.

```swift
class UserSettings: ObservableObject {
    @Published var username = "Huy"
    //         ↑ Mỗi khi username thay đổi:
    //           1. Phát value mới qua Combine publisher
    //           2. Trigger objectWillChange.send() → SwiftUI re-render
}
```

### Cơ chế hoạt động — Hai vai trò đồng thời

```
@Published var username = "Huy"
         │
         ├── Vai trò 1: Combine Publisher
         │   $username → Published<String>.Publisher
         │   Có thể .sink(), .map(), .debounce()...
         │
         └── Vai trò 2: ObservableObject integration
             username thay đổi → objectWillChange.send()
             → Mọi view đang observe object này → re-render
```

### Vai trò 1: Combine Publisher — `$username`

```swift
class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [Item] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // $query = Published<String>.Publisher
        // Đây là COMBINE publisher, dùng được mọi operator
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .flatMap { [weak self] query -> AnyPublisher<[Item], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                return self.search(query)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.results = items
            }
            .store(in: &cancellables)
    }
}
```

**Lưu ý quan trọng:** `$query` phát **giá trị mới trước khi property thay đổi** (willSet semantic):

```swift
@Published var name = "A"

$name.sink { newValue in
    print("Will change to: \(newValue)")
    print("Current value: \(self.name)")  // vẫn là giá trị CŨ
}

name = "B"
// Output:
// Will change to: B
// Current value: A     ← willSet, chưa thay đổi thực sự
```

### Vai trò 2: ObservableObject Integration

```swift
class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []      // thay đổi → trigger UI
    @Published var couponCode = ""              // thay đổi → trigger UI
    
    var totalPrice: Double {                    // computed → KHÔNG trigger UI trực tiếp
        items.reduce(0) { $0 + $1.price }      // nhưng re-render khi items thay đổi
    }                                           // vì body đọc lại totalPrice
    
    var internalLog: [String] = []              // KHÔNG @Published → thay đổi im lặng
}
```

```
@Published var items thay đổi
    │
    ▼
objectWillChange.send()       ← tự động, không cần code thêm
    │
    ▼
SwiftUI views đang observe    ← @StateObject / @ObservedObject / @EnvironmentObject
    │
    ▼
body gọi lại → đọc items mới → UI cập nhật
```

### @Published chỉ dùng trong class

```swift
// ✅ Class
class ViewModel: ObservableObject {
    @Published var count = 0
}

// ❌ Struct — compile error
struct Settings {
    @Published var theme = "dark"
    // Error: @Published requires class type
}
```

Lý do: `@Published` dùng `willSet` observer → cần reference semantics. Struct copy-on-write sẽ phá vỡ publish mechanism.

### Ví dụ thực tế — ViewModel hoàn chỉnh

```swift
class TodoViewModel: ObservableObject {
    // State cho UI — @Published
    @Published var todos: [Todo] = []
    @Published var newTodoText = ""
    @Published var filter: Filter = .all
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    // Computed — phụ thuộc vào @Published, tự cập nhật khi re-render
    var filteredTodos: [Todo] {
        switch filter {
        case .all:       return todos
        case .active:    return todos.filter { !$0.isDone }
        case .completed: return todos.filter { $0.isDone }
        }
    }
    
    var activeCount: Int {
        todos.filter { !$0.isDone }.count
    }
    
    // Internal state — không cần notify UI
    private var cancellables = Set<AnyCancellable>()
    private let service: TodoService
    
    init(service: TodoService = .shared) {
        self.service = service
        setupAutoSave()
    }
    
    // Combine pipeline lắng nghe @Published
    private func setupAutoSave() {
        $todos                                      // Publisher từ @Published
            .dropFirst()                            // bỏ giá trị khởi tạo
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] todos in
                self?.service.save(todos)
            }
            .store(in: &cancellables)
    }
    
    func addTodo() {
        guard !newTodoText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        todos.append(Todo(title: newTodoText))
        newTodoText = ""     // @Published → TextField clear, UI update
    }
    
    func loadTodos() {
        isLoading = true     // @Published → ProgressView hiện
        errorMessage = nil   // @Published → error label ẩn
        
        service.fetchTodos()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] todos in
                    self?.todos = todos
                }
            )
            .store(in: &cancellables)
    }
    
    enum Filter: String, CaseIterable {
        case all, active, completed
    }
}
```

```swift
struct TodoListView: View {
    @StateObject private var vm = TodoViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter", selection: $vm.filter) {
                    ForEach(TodoViewModel.Filter.allCases, id: \.self) { f in
                        Text(f.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
                
                if vm.isLoading {
                    ProgressView()
                } else if let error = vm.errorMessage {
                    Text(error).foregroundStyle(.red)
                } else {
                    List(vm.filteredTodos) { todo in
                        TodoRow(todo: todo)
                    }
                }
                
                HStack {
                    TextField("New todo", text: $vm.newTodoText)
                    Button("Add") { vm.addTodo() }
                }
                .padding()
            }
            .navigationTitle("Todos (\(vm.activeCount) left)")
            .onAppear { vm.loadTodos() }
        }
    }
}
```

---

## 4. So sánh chi tiết

```
                        @State                         @Published
                        ──────                         ──────────
Thuộc framework?        SwiftUI                        Combine
Dùng trong?             struct (View)                  class (ObservableObject)
Lưu trữ?               SwiftUI quản lý (ngoài struct) Trong class instance
Scope?                  Local — 1 view sở hữu         Shared — nhiều view observe
Binding ($)?            $count → Binding<Int>          $count → Published<Int>.Publisher
                        (two-way UI binding)           (Combine stream)
Khi nào re-render?      Value thay đổi                 objectWillChange.send()
Dùng cho?               UI state đơn giản:             Business state / logic:
                        toggle, text input,            network data, user model,
                        animation flag, selection      form validation, cart
Access control?         Luôn private (convention)      Có thể public, private(set)
Reference type?         ❌ Không nên                    ✅ Bắt buộc class
```

---

## 5. Khi nào dùng cái nào?

```
State chỉ liên quan đến 1 view?
(animation flag, sheet presented, text input tạm)
    │
    ├── Có  → @State ✅
    │
    └── Không → State cần chia sẻ hoặc có logic phức tạp?
                    │
                    ├── Có  → class ObservableObject + @Published ✅
                    │         (kết hợp @StateObject / @ObservedObject)
                    │
                    └── Truyền xuống 1 level? → @Binding ✅
                        (view con đọc/ghi state của parent)
```

### Ví dụ phân loại

```swift
struct ProductDetailView: View {
    // @State: UI state thuần tuý, local
    @State private var selectedTab = 0           // tab nào đang chọn
    @State private var isZoomed = false          // ảnh có zoom không
    @State private var showShareSheet = false    // sheet có hiện không
    @State private var quantity = 1              // số lượng chọn tạm
    
    // @StateObject → class có @Published: business logic
    @StateObject private var vm = ProductDetailViewModel()
    // Bên trong vm:
    //   @Published var product: Product?        // data từ API
    //   @Published var reviews: [Review] = []   // data từ API
    //   @Published var isInCart = false          // trạng thái cart
    //   @Published var isLoading = false         // loading state
    
    var body: some View {
        // ...
    }
}
```

---

## 6. Sai lầm thường gặp

### Sai lầm 1: @State cho shared state

```swift
// ❌ Hai view có @State riêng → KHÔNG đồng bộ
struct ViewA: View {
    @State var count = 0        // storage riêng
    var body: some View { Button("A: \(count)") { count += 1 } }
}
struct ViewB: View {
    @State var count = 0        // storage KHÁC, không liên quan ViewA
    var body: some View { Text("B: \(count)") }  // luôn = 0
}

// ✅ Dùng ObservableObject + @Published để chia sẻ
class SharedState: ObservableObject {
    @Published var count = 0
}
```

### Sai lầm 2: @Published trong struct

```swift
// ❌ Compile error
struct Settings {
    @Published var fontSize = 16.0
}

// ✅ Phải là class + ObservableObject
class Settings: ObservableObject {
    @Published var fontSize = 16.0
}
```

### Sai lầm 3: @State cho class object

```swift
// ❌ @State theo dõi REFERENCE, không theo dõi property
@State var user = User()  // User là class
// user.name = "New" → @State KHÔNG biết → UI KHÔNG update

// ✅ Dùng @StateObject
@StateObject var user = User()  // User: ObservableObject
```

### Sai lầm 4: Quên private cho @State

```swift
// ⚠️ Hoạt động nhưng vi phạm convention
@State var count = 0  // public → parent có thể init(count:) → confusing

// ✅ Luôn private
@State private var count = 0
// @State là source of truth LOCAL → không ai bên ngoài nên set
```

### Sai lầm 5: Init @State từ parameter

```swift
// ⚠️ Cẩn thận: initial value chỉ dùng LẦN ĐẦU
struct EditorView: View {
    @State private var text: String
    
    init(initialText: String) {
        _text = State(initialValue: initialText)
        // ← Chỉ có hiệu lực lần đầu view xuất hiện
        // Parent gửi initialText mới → @State giữ giá trị cũ!
    }
}

// Nếu cần đồng bộ với parent → dùng @Binding thay vì @State
struct EditorView: View {
    @Binding var text: String   // parent kiểm soát, không phải local state
}
```

---

## 7. Tổng kết — Mental Model

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  @State         "Tôi SỞ HỮU giá trị này.                         │
│                  Nó là local, private, chỉ view tôi dùng.        │
│                  SwiftUI giữ nó sống dù struct tạo lại."         │
│                                                                  │
│  @Published     "Tôi THÔNG BÁO khi giá trị thay đổi.             │
│                  Ai subscribe cũng nhận được.                    │
│                  SwiftUI views + Combine pipelines đều lắng nghe.│
│                  Tôi sống trong class ObservableObject."         │
│                                                                  │
│  Kết hợp:                                                        │
│  @State ──── view đơn giản, UI state thuần                       │
│  @Published ── business logic, shared state, API data            │
│               ↕ kết nối qua @StateObject / @ObservedObject       │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

------

Hai keyword này giải quyết cùng một bài toán — **reactive state** — nhưng ở hai ngữ cảnh hoàn toàn khác, Huy.

**`@State`** sống trong **struct View**, là state local mà chỉ view đó sở hữu. Điểm hay nhất: SwiftUI lưu giá trị **bên ngoài struct** trong storage riêng, nên dù parent re-render khiến struct init lại, giá trị vẫn được giữ nguyên. Initial value chỉ dùng đúng lần đầu tiên. Prefix `$` cho ra `Binding<T>` — dùng để truyền xuống view con cho two-way binding (TextField, Toggle, Picker...).

**`@Published`** sống trong **class ObservableObject**, phục vụ shared state và business logic. Nó có **hai vai trò đồng thời**: khi property thay đổi, vừa gửi `objectWillChange.send()` cho SwiftUI re-render, vừa phát giá trị mới qua Combine publisher (`$property`) để chain với `.debounce()`, `.map()`, `.sink()`... Lưu ý: `$` ở `@Published` cho ra `Published<T>.Publisher` (Combine stream), khác với `$` ở `@State` cho ra `Binding<T>`.

Quy tắc đơn giản: UI state thuần (toggle, sheet, animation flag) → `@State`. Business logic, data từ API, state chia sẻ giữa nhiều view → `@Published` trong `ObservableObject`.
