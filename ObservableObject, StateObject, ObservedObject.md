# SwiftUI: `ObservableObject`, `@StateObject`, `@ObservedObject`

## 1. Bức tranh tổng thể

Ba keyword này phối hợp theo mô hình **Source of Truth**:

```
ObservableObject (Protocol)
    "Tôi là object có state thay đổi được"
         │
         │  @Published property thay đổi
         │  → gửi objectWillChange
         ▼
┌─────────────────────────────────────┐
│         SwiftUI View Tree           │
│                                     │
│  @StateObject var vm = ViewModel()  │  ← View TẠO và SỞ HỮU object
│       │                             │
│       │  truyền xuống               │
│       ▼                             │
│  @ObservedObject var vm: ViewModel  │  ← View con MƯỢN, không sở hữu
│                                     │
└─────────────────────────────────────┘
```

---

## 2. `ObservableObject` — Protocol đánh dấu "object có state"

### Bản chất

`ObservableObject` là một **protocol** (không phải property wrapper). Nó nói với SwiftUI: "Object này có state thay đổi được, hãy lắng nghe tôi."

```swift
class ProfileViewModel: ObservableObject {
    @Published var name = "Huy"          // thay đổi → trigger view update
    @Published var avatarURL: URL?       // thay đổi → trigger view update
    var internalCache: [String] = []     // KHÔNG @Published → thay đổi im lặng
}
```

### Cơ chế hoạt động

`ObservableObject` cung cấp sẵn một publisher gọi là `objectWillChange`:

```swift
// Swift tự synthesize nếu không custom:
var objectWillChange: ObservableObjectPublisher
```

Mỗi khi bất kỳ `@Published` property nào **sắp thay đổi** (willSet), `objectWillChange` tự động `send()` → SwiftUI nhận signal → re-render view.

```
@Published var name = "Huy"
          │
          │ name = "John"  (willSet)
          ▼
objectWillChange.send()
          │
          ▼
SwiftUI invalidate view → body được gọi lại
```

### Custom objectWillChange (hiếm dùng)

```swift
class ManualViewModel: ObservableObject {
    // Tự quản lý khi nào notify
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    var score: Int = 0 {
        willSet { objectWillChange.send() }
    }
    
    // Chỉ notify khi score > 100
    func updateScore(_ value: Int) {
        guard value > 100 else {
            score = value  // thay đổi im lặng
            return
        }
        objectWillChange.send()  // thông báo thủ công
        score = value
    }
}
```

### Quy tắc: Dùng `class`, không dùng `struct`

```swift
// ✅ Class — reference type, identity ổn định
class ViewModel: ObservableObject { ... }

// ❌ Struct — KHÔNG conform được
// ObservableObject yêu cầu class (AnyObject constraint)
struct ViewModel: ObservableObject { ... } // Compile error
```

Lý do: SwiftUI cần **identity ổn định** (reference) để theo dõi object qua nhiều lần re-render. Struct bị copy mỗi lần mutate → mất identity.

---

## 3. `@StateObject` — View TẠO và SỞ HỮU object

### Bản chất

`@StateObject` là property wrapper nói với SwiftUI: **"Tôi tạo object này, hãy giữ nó sống suốt vòng đời của view, dù view re-render bao nhiêu lần."**

```swift
struct ProfileScreen: View {
    @StateObject private var viewModel = ProfileViewModel()
    //                                   ↑ chỉ chạy MỘT LẦN duy nhất
    
    var body: some View {
        Text(viewModel.name)
        // Khi parent re-render → ProfileScreen.init() chạy lại
        // NHƯNG viewModel KHÔNG bị tạo mới — SwiftUI giữ instance cũ
    }
}
```

### Vòng đời

```
Parent re-render lần 1:
  ProfileScreen.init()  → @StateObject tạo ProfileViewModel #1
  body gọi             → hiển thị với VM #1

Parent re-render lần 2:
  ProfileScreen.init()  → @StateObject KHÔNG tạo mới, giữ VM #1
  body gọi             → vẫn hiển thị với VM #1

ProfileScreen bị remove khỏi view tree:
  → VM #1 bị deallocate (deinit chạy)

ProfileScreen xuất hiện lại:
  → @StateObject tạo ProfileViewModel #2 (instance mới hoàn toàn)
```

### Quy tắc vàng

> **Dùng `@StateObject` ở view NÀO tạo object đó. Chỉ dùng MỘT LẦN cho mỗi object.**

```swift
// ✅ ĐÚNG: View tạo object → @StateObject
struct OrderListScreen: View {
    @StateObject private var viewModel = OrderListViewModel()
    
    var body: some View {
        List(viewModel.orders) { order in
            OrderRow(viewModel: viewModel, order: order)
            //       ↑ truyền xuống, KHÔNG tạo mới
        }
    }
}

// ❌ SAI: View nhận object từ bên ngoài → không dùng @StateObject
struct OrderRow: View {
    @StateObject var viewModel: OrderListViewModel  // ❌ 
    // ...
}
```

---

## 4. `@ObservedObject` — View MƯỢN object từ bên ngoài

### Bản chất

`@ObservedObject` nói với SwiftUI: **"Tôi không sở hữu object này. Ai đó ở trên truyền cho tôi. Nhưng hãy re-render tôi khi nó thay đổi."**

```swift
struct OrderRow: View {
    @ObservedObject var viewModel: OrderListViewModel
    //              ↑ nhận từ parent, KHÔNG tự tạo
    let order: Order
    
    var body: some View {
        Text(order.title)
        Button("Delete") { viewModel.delete(order) }
    }
}
```

### ⚠️ Khác biệt sống còn vs `@StateObject`: Không bảo vệ khỏi re-create

```swift
struct ParentView: View {
    @State private var counter = 0
    
    var body: some View {
        VStack {
            Button("Increment: \(counter)") { counter += 1 }
            
            // Mỗi khi counter thay đổi → body chạy lại
            // → ChildView.init() chạy lại
            ChildView()
        }
    }
}

struct ChildView: View {
    // ❌ @ObservedObject: Mỗi lần init() → tạo ViewModel MỚI → mất state!
    @ObservedObject var vm = SomeViewModel()
    
    // ✅ @StateObject: SwiftUI giữ instance cũ dù init() chạy lại
    // @StateObject var vm = SomeViewModel()
    
    var body: some View { Text(vm.text) }
}
```

**Minh hoạ:**

```
@ObservedObject var vm = ViewModel()         @StateObject var vm = ViewModel()
─────────────────────────────────            ─────────────────────────────────
Parent re-render #1: VM tạo mới (#1)        Parent re-render #1: VM tạo (#1)
Parent re-render #2: VM tạo mới (#2) ❌     Parent re-render #2: giữ VM #1 ✅
Parent re-render #3: VM tạo mới (#3) ❌     Parent re-render #3: giữ VM #1 ✅
→ State bị reset liên tục                   → State ổn định
```

### Khi nào dùng @ObservedObject?

**Khi view NHẬN object từ bên ngoài** — không tự khởi tạo:

```swift
struct ParentView: View {
    @StateObject private var settings = SettingsViewModel()  // ← sở hữu
    
    var body: some View {
        SettingsPanel(settings: settings)  // ← truyền xuống
    }
}

struct SettingsPanel: View {
    @ObservedObject var settings: SettingsViewModel  // ← mượn
    // KHÔNG có giá trị mặc định, KHÔNG tự khởi tạo
    
    var body: some View {
        Toggle("Dark Mode", isOn: $settings.isDarkMode)
        //                       ↑ Binding vẫn hoạt động
    }
}
```

---

## 5. So sánh tổng hợp

```
                    @StateObject              @ObservedObject
                    ────────────              ───────────────
Ai tạo object?     View này tạo              Nhận từ parent/DI
Giữ sống qua       ✅ Có                     ❌ Không
re-render?          (SwiftUI bảo vệ)         (bị tạo lại nếu init trong view)
Dùng ở đâu?        View SỞ HỮU object       View MƯỢN object
Init pattern?       = ViewModel()             Không init, nhận qua parameter
Khi view bị         Object bị dealloc        Không ảnh hưởng (không sở hữu)
remove?
Binding ($)?        ✅ Hỗ trợ                ✅ Hỗ trợ
```

---

## 6. Ví dụ thực tế hoàn chỉnh — MVVM Pattern

### ViewModel

```swift
class TodoListViewModel: ObservableObject {
    @Published private(set) var todos: [Todo] = []
    @Published var newTodoText = ""
    @Published private(set) var isLoading = false
    
    private let service: TodoService
    private var cancellables = Set<AnyCancellable>()
    
    init(service: TodoService = .shared) {
        self.service = service
    }
    
    func loadTodos() {
        isLoading = true
        service.fetchTodos()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] todos in
                    self?.todos = todos
                }
            )
            .store(in: &cancellables)
    }
    
    func addTodo() {
        guard !newTodoText.isEmpty else { return }
        todos.append(Todo(title: newTodoText))
        newTodoText = ""
    }
    
    func delete(_ todo: Todo) {
        todos.removeAll { $0.id == todo.id }
    }
}
```

### View sở hữu (Screen level)

```swift
struct TodoListScreen: View {
    @StateObject private var viewModel = TodoListViewModel()
    //           ↑ SỞ HỮU: tạo ở đây, giữ sống suốt vòng đời screen
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    todoList
                }
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItem { addButton }
            }
        }
        .onAppear { viewModel.loadTodos() }
    }
    
    private var todoList: some View {
        List(viewModel.todos) { todo in
            TodoRowView(viewModel: viewModel, todo: todo)
            //          ↑ TRUYỀN xuống, không tạo mới
        }
    }
    
    private var addButton: some View {
        HStack {
            TextField("New todo", text: $viewModel.newTodoText)
            Button("Add") { viewModel.addTodo() }
        }
    }
}
```

### View mượn (Component level)

```swift
struct TodoRowView: View {
    @ObservedObject var viewModel: TodoListViewModel
    //              ↑ MƯỢN: nhận từ parent, không tự tạo
    let todo: Todo
    
    var body: some View {
        HStack {
            Text(todo.title)
            Spacer()
            Button("Delete") {
                viewModel.delete(todo)
                // viewModel thay đổi todos → @Published trigger
                // → cả TodoListScreen VÀ TodoRowView đều re-render
            }
        }
    }
}
```

### Luồng data

```
TodoListScreen (@StateObject owns VM)
       │
       │ viewModel.todos thay đổi
       │ → objectWillChange.send()
       │ → SwiftUI re-render TodoListScreen
       │
       ├── TodoRowView #1 (@ObservedObject borrows VM)
       │      cũng re-render vì observe cùng VM
       │
       ├── TodoRowView #2 (@ObservedObject borrows VM)
       │      cũng re-render
       │
       └── TodoRowView #3 (@ObservedObject borrows VM)
              cũng re-render
```

---

## 7. `@StateObject` với dependency injection

Khi ViewModel cần parameter từ parent:

```swift
struct UserDetailScreen: View {
    let userID: String
    
    // ✅ Cách đúng: dùng closure để trì hoãn init
    @StateObject private var viewModel: UserDetailViewModel
    
    init(userID: String) {
        self.userID = userID
        // _viewModel truy cập wrapped value bên trong property wrapper
        _viewModel = StateObject(wrappedValue: UserDetailViewModel(userID: userID))
    }
    
    var body: some View {
        Text(viewModel.userName)
            .onAppear { viewModel.load() }
    }
}
```

**Lưu ý:** `StateObject(wrappedValue:)` closure chỉ chạy **một lần** — lần đầu SwiftUI render view. Các lần re-render sau, SwiftUI bỏ qua và dùng instance cũ.

---

## 8. Kết hợp với `@EnvironmentObject` — Chia sẻ global

```swift
// App level: tạo và inject
@main
struct MyApp: App {
    @StateObject private var authManager = AuthManager()
    //           ↑ App sở hữu
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                //                 ↑ inject vào environment
        }
    }
}

// Bất kỳ view con nào cũng truy cập được
struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    //                 ↑ Lấy từ environment, không cần truyền qua parameter
    
    var body: some View {
        if authManager.isLoggedIn {
            Text("Welcome, \(authManager.userName)")
        }
    }
}
```

```
@StateObject (tạo + sở hữu)
       │
       │ .environmentObject()
       ▼
@EnvironmentObject (truy cập global, không cần truyền tay)
       ≈
@ObservedObject (truy cập local, truyền qua parameter)
```

---

## 9. Sai lầm thường gặp

### Sai lầm 1: Dùng `@ObservedObject` để tạo object

```swift
// ❌ State bị reset mỗi khi parent re-render
struct ChatView: View {
    @ObservedObject var vm = ChatViewModel()  // NGUY HIỂM
}

// ✅ Dùng @StateObject khi view tạo object
struct ChatView: View {
    @StateObject var vm = ChatViewModel()
}
```

### Sai lầm 2: Dùng `@StateObject` cho object nhận từ bên ngoài

```swift
// ❌ Không nên: view không sở hữu, chỉ mượn
struct ChildView: View {
    @StateObject var vm: SharedViewModel  // ❌ ai truyền vào?
}

// ✅ Mượn = @ObservedObject
struct ChildView: View {
    @ObservedObject var vm: SharedViewModel
}
```

### Sai lầm 3: Quên `@Published`

```swift
class ViewModel: ObservableObject {
    var items: [Item] = []  // ❌ thiếu @Published → thay đổi không trigger UI
    @Published var items: [Item] = []  // ✅
}
```

---

## 10. Quy tắc quyết định nhanh

```
Hỏi: View này CÓ TẠO object không?
         │
    ┌────┴────┐
    Có        Không (nhận từ parameter / environment)
    │              │
    ▼              ▼
@StateObject    Truyền qua parameter?
                    │
               ┌────┴────┐
               Có        Không (global)
               │              │
               ▼              ▼
        @ObservedObject   @EnvironmentObject
```

------

Đây là bộ ba nền tảng của state management trong SwiftUI, Huy. Tóm gọn mối quan hệ:

**`ObservableObject`** là protocol đánh dấu class có state thay đổi được. Khi `@Published` property thay đổi → tự động gửi `objectWillChange.send()` → SwiftUI biết cần re-render. Bắt buộc dùng `class` vì SwiftUI cần reference type để giữ identity ổn định.

**`@StateObject`** — dùng ở view **tạo ra** object. Điểm then chốt: SwiftUI chỉ chạy initializer **một lần duy nhất**, dù parent re-render bao nhiêu lần view cũng giữ nguyên instance cũ. Object bị dealloc khi view bị remove khỏi tree.

**`@ObservedObject`** — dùng ở view **nhận** object từ bên ngoài (qua parameter). Nó **không bảo vệ** khỏi re-create — nếu lỡ viết `@ObservedObject var vm = ViewModel()`, mỗi lần parent re-render sẽ tạo instance mới → mất toàn bộ state. Đây là sai lầm cực kỳ phổ biến.

Quy tắc nhớ nhanh: **Ai tạo thì dùng `@StateObject`, ai mượn thì dùng `@ObservedObject`**. Mỗi object chỉ có đúng một nơi dùng `@StateObject` — đó là "source of truth".
