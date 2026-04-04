# SwiftUI: `@Published` vs `@State` vs `@Binding` — So sánh chi tiết

## 1. Một câu cho mỗi keyword

```
@State      → "Tôi TẠO và SỞ HỮU data này. Data sống trong View struct."
@Published  → "Tôi THÔNG BÁO khi data thay đổi. Data sống trong class (ViewModel)."
@Binding    → "Tôi MƯỢN data từ nơi khác. Tôi đọc/ghi nhưng KHÔNG sở hữu."
```

---

## 2. Mỗi keyword thuộc framework nào?

```
@State      → SwiftUI framework
@Binding    → SwiftUI framework
@Published  → Combine framework (dùng cùng ObservableObject trong SwiftUI)
```

`@Published` **không phải SwiftUI** — nó thuộc Combine. SwiftUI "hiểu" `@Published` thông qua protocol `ObservableObject`.

---

## 3. Data sống ở đâu?

```
@State:
  View struct (nhưng SwiftUI lưu NGOÀI struct trong storage riêng)
  ┌──────────────────┐       ┌──── SwiftUI Storage ────┐
  │ struct MyView {  │       │                          │
  │   @State var x ──────────│──▶ x = 42               │
  │ }                │       │   (managed by SwiftUI)   │
  └──────────────────┘       └──────────────────────────┘

@Published:
  Class instance (ObservableObject / ViewModel)
  ┌──────────────────────────┐
  │ class ViewModel {        │
  │   @Published var x = 42  │  ← sống trong class instance
  │ }                        │
  └──────────────────────────┘

@Binding:
  KHÔNG sống ở đâu cả — chỉ là REFERENCE đến data ở nơi khác
  ┌──────────────────┐       ┌──── Source of Truth ─────┐
  │ struct Child {   │       │ @State var x = 42        │
  │   @Binding var x ────────│──▶ (reference, không copy)│
  │ }                │       │ HOẶC @Published var x    │
  └──────────────────┘       └──────────────────────────┘
```

---

## 4. Ai SỞ HỮU data?

```
@State:      View SỞ HỮU ✅
             Tạo data, quản lý lifecycle
             Data chết khi View bị remove khỏi view tree

@Published:  Class (ViewModel) SỞ HỮU ✅
             Tạo data, quản lý lifecycle
             Data chết khi class instance dealloc

@Binding:    KHÔNG SỞ HỮU ❌
             Chỉ tham chiếu — đọc/ghi data của người khác
             Không kiểm soát lifecycle
```

---

## 5. Dùng trong type nào?

```swift
// @State → chỉ trong struct (View)
struct MyView: View {
    @State private var count = 0        // ✅
}

class MyClass {
    @State var count = 0                // ❌ vô nghĩa — @State cho View struct
}

// @Published → chỉ trong class
class ViewModel: ObservableObject {
    @Published var count = 0            // ✅
}

struct Settings {
    @Published var theme = "dark"       // ❌ compile error — cần class
}

// @Binding → chỉ trong struct (View), nhận từ bên ngoài
struct ChildView: View {
    @Binding var count: Int             // ✅ nhận từ parent
}
```

```
              struct (View)    class (ViewModel)
              ─────────────    ─────────────────
@State        ✅                ❌
@Published    ❌                ✅
@Binding      ✅                ❌
```

---

## 6. Projected Value (`$` prefix) — Khác nhau hoàn toàn

```swift
// @State
@State var name = ""
name           // String (giá trị)
$name          // Binding<String> → truyền cho child hoặc TextField

// @Published
@Published var name = ""
name           // String (giá trị)
$name          // Published<String>.Publisher → Combine stream
//                ↑ KHÁC! Không phải Binding mà là Combine Publisher

// @Binding
@Binding var name: String
name           // String (giá trị)
$name          // Binding<String> → truyền tiếp cho child
```

**Điểm khác biệt quan trọng nhất:**

```
$stateProperty     → Binding<T>                 (two-way UI binding)
$publishedProperty → Published<T>.Publisher      (Combine reactive stream)
$bindingProperty   → Binding<T>                 (two-way UI binding)
```

`$published` trả về **Combine Publisher**, KHÔNG phải Binding. Để có Binding từ `@Published`:

```swift
// Cần thông qua @StateObject / @ObservedObject
@StateObject var vm = ViewModel()
TextField("Name", text: $vm.name)
//                       ↑ $vm.name → Binding<String>
//                         (SwiftUI tạo Binding từ ObservableObject property)
//                         KHÁC với vm.$name → Published<String>.Publisher
```

```
$vm.name   → Binding<String>              ← cho UI (TextField, Toggle...)
vm.$name   → Published<String>.Publisher   ← cho Combine (.sink, .map, .debounce...)
```

---

## 7. Cơ chế trigger re-render

### @State: SwiftUI trực tiếp theo dõi

```swift
@State var count = 0
count = 1    // → SwiftUI BIẾT NGAY → re-render view
```

SwiftUI quản lý storage riêng, **biết chính xác khi nào giá trị thay đổi** → re-render view chứa `@State`.

### @Published: Thông qua objectWillChange publisher

```swift
class VM: ObservableObject {
    @Published var count = 0
}

// count thay đổi → @Published gửi willSet notification
// → objectWillChange.send() tự động
// → SwiftUI nhận signal → re-render TẤT CẢ views observe VM này
```

**Vấn đề:** `objectWillChange` là **1 publisher chung** cho TẤT CẢ `@Published` properties → thay đổi BẤT KỲ property → TẤT CẢ views observe VM đều re-render (dù không dùng property đó).

```
@Published var name = ""        ← thay đổi
@Published var email = ""       ← KHÔNG đổi
@Published var avatar: UIImage? ← KHÔNG đổi
→ objectWillChange.send()
→ TẤT CẢ views observe VM re-render (kể cả view chỉ dùng email)
```

### @Binding: Không trigger trực tiếp — delegate cho source

```swift
@Binding var count: Int
count = 1    // → ghi vào SOURCE OF TRUTH (@State hoặc @Published)
             // → SOURCE re-render → parent re-render → child (có @Binding) re-render
```

`@Binding` **không tự trigger** re-render — nó ghi vào source, source trigger, parent re-render, child cũng re-render.

```
                    trigger chain
@Binding ghi → @State thay đổi → parent re-render → child re-render
                  ↑ source of truth trigger
```

---

## 8. Có thể kết hợp với Combine?

```swift
// @State — KHÔNG có Combine publisher
@State var name = ""
// $name → Binding<String>, KHÔNG PHẢI Publisher
// Không .sink(), .debounce(), .map() được

// @Published — CÓ Combine publisher
@Published var name = ""
// $name → Published<String>.Publisher → Combine stream
vm.$name
    .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
    .removeDuplicates()
    .sink { print($0) }
    .store(in: &cancellables)
// ✅ Full Combine pipeline

// @Binding — KHÔNG có Combine publisher
@Binding var name: String
// $name → Binding<String>, KHÔNG PHẢI Publisher
```

```
              Combine Publisher?
              ──────────────────
@State        ❌ ($property = Binding)
@Published    ✅ ($property = Publisher)
@Binding      ❌ ($property = Binding)
```

---

## 9. Khởi tạo

```swift
// @State: CÓ initial value
@State private var count = 0           // ✅ initial value = 0
@State private var name = "Huy"        // ✅ initial value = "Huy"

// @Published: CÓ initial value
@Published var count = 0               // ✅ initial value = 0
@Published var items: [Item] = []      // ✅ initial value = []
@Published var user: User?             // ✅ initial value = nil (Optional)

// @Binding: KHÔNG CÓ initial value — nhận từ bên ngoài
@Binding var count: Int                // ✅ khai báo type, KHÔNG gán value
// ❌ @Binding var count: Int = 0      // KHÔNG có initial value
```

---

## 10. Visibility / Access Control

```swift
// @State: Convention là PRIVATE — chỉ view này dùng
@State private var isExpanded = false   // ✅ convention chuẩn
@State var isExpanded = false           // ⚠️ hoạt động nhưng vi phạm convention

// @Published: Có thể public, internal, hoặc private(set)
@Published var name = ""                // internal — đọc/ghi từ ngoài
@Published private(set) var isLoading = false  // đọc từ ngoài, chỉ class ghi
@Published private var cache = [:]      // private — chỉ class truy cập

// @Binding: KHÔNG có access control riêng — phụ thuộc vào View init
@Binding var name: String               // luôn là parameter nhận từ ngoài
```

---

## 11. Sử dụng cùng lúc — Pattern thực tế

### Pattern 1: @State → @Binding (View ↔ Child View)

```swift
// Parent SỞ HỮU
struct ParentView: View {
    @State private var isOn = false          // ← source of truth
    
    var body: some View {
        ChildView(isOn: $isOn)               // ← truyền Binding
        Text(isOn ? "ON" : "OFF")            // ← đọc state
    }
}

// Child MƯỢN
struct ChildView: View {
    @Binding var isOn: Bool                  // ← reference
    
    var body: some View {
        Toggle("Switch", isOn: $isOn)        // ← ghi → parent's @State đổi
    }
}
```

```
@State var isOn ←──── sở hữu
       │
       │ $isOn (Binding)
       ▼
@Binding var isOn ←── mượn, đọc/ghi ngược
       │
       │ $isOn (Binding)
       ▼
Toggle(isOn:) ←────── ghi khi user tap
```

### Pattern 2: @Published → $vm.property → Binding (ViewModel ↔ View)

```swift
// ViewModel SỞ HỮU
class FormVM: ObservableObject {
    @Published var email = ""                // ← source of truth
    @Published var password = ""
    @Published private(set) var isValid = false
    
    init() {
        // Combine pipeline dùng $email (Publisher)
        Publishers.CombineLatest($email, $password)
            .map { e, p in e.contains("@") && p.count >= 8 }
            .assign(to: &$isValid)
    }
}

// View QUAN SÁT + tạo Binding
struct FormView: View {
    @StateObject private var vm = FormVM()
    
    var body: some View {
        TextField("Email", text: $vm.email)
        //                       ↑ $vm.email → Binding<String>
        //                         (KHÁC vm.$email → Publisher)
        
        SecureField("Password", text: $vm.password)
        
        Button("Submit") { }
            .disabled(!vm.isValid)
    }
}
```

```
class ViewModel:
  @Published var email ←── sở hữu
          │
          ├── vm.$email → Publisher (Combine)
          │     dùng cho: .debounce, .sink, .combineLatest
          │
          └── $vm.email → Binding (SwiftUI)
                dùng cho: TextField, Toggle, Picker
```

### Pattern 3: @Published → @Binding (ViewModel → Child View)

```swift
struct ParentView: View {
    @StateObject var vm = SettingsVM()
    
    var body: some View {
        ThemeToggle(isDark: $vm.isDarkMode)
        //                  ↑ Binding từ @Published property
    }
}

struct ThemeToggle: View {
    @Binding var isDark: Bool
    // ↑ Nhận Binding — không biết source là @State hay @Published
    //   @Binding không quan tâm nguồn, chỉ cần Binding<Bool>
    
    var body: some View {
        Toggle("Dark Mode", isOn: $isDark)
    }
}
```

### Pattern 4: Cả 3 cùng lúc

```swift
// ViewModel
class ShopVM: ObservableObject {
    @Published var products: [Product] = []      // data từ API
    @Published var searchQuery = ""               // user input
    @Published private(set) var isLoading = false
}

// Parent View
struct ShopView: View {
    @StateObject private var vm = ShopVM()
    @State private var showFilter = false         // UI state thuần
    
    var body: some View {
        VStack {
            SearchBar(query: $vm.searchQuery)     // @Published → Binding
            //                ↑ Binding<String>
            
            FilterButton(isPresented: $showFilter) // @State → Binding
            //                         ↑ Binding<Bool>
            
            ProductList(products: vm.products)     // read-only, không cần Binding
            //                    ↑ [Product] value
        }
    }
}

// Child View
struct SearchBar: View {
    @Binding var query: String                     // @Binding mượn từ parent
    
    var body: some View {
        TextField("Search", text: $query)          // chain Binding tiếp
    }
}
```

```
ShopVM (@Published):
  products ──────── read-only ──────▶ ProductList (let)
  searchQuery ───── Binding ────────▶ SearchBar (@Binding)
  isLoading ─────── read-only ──────▶ ProgressView (let)

ShopView (@State):
  showFilter ────── Binding ────────▶ FilterButton (@Binding)
```

---

## 12. Bảng so sánh tổng hợp

```
                        @State              @Published           @Binding
                        ──────              ──────────           ────────
Framework               SwiftUI             Combine              SwiftUI
Dùng trong              struct (View)       class (ObsObject)    struct (View)
Sở hữu data?           ✅ Có               ✅ Có                ❌ Không (mượn)
Storage                 SwiftUI managed     Class instance       Reference đến source
Initial value?          ✅ Bắt buộc         ✅ Bắt buộc          ❌ Nhận từ ngoài
Access control          private (convention) public/private(set)  Từ parameter
$ prefix                Binding<T>          Publisher<T>         Binding<T>
Combine stream?         ❌                  ✅ ($prop = Publisher) ❌
Trigger re-render       Trực tiếp           objectWillChange     Gián tiếp (qua source)
Granularity             Per-property        Per-object (coarse)  Per-property (từ source)
Re-render scope         View chứa @State    TẤT CẢ views        View chứa @Binding
                                            observe object       + parent
Lifecycle               View identity       Class instance       Không quản lý
Dùng cho                UI state local:     Business state:      Child nhận data
                        toggle, text input, API data, user model,đọc/ghi: form field,
                        animation flag,     form validation,     reusable component,
                        sheet presented     computed logic       toggle, picker
```

---

## 13. Quy tắc quyết định — Flowchart

```
Data này thuộc về AI?
│
├── View (UI state: toggle, sheet, animation, text input tạm)
│   │
│   ├── View NÀY tạo và sở hữu data?
│   │   → @State ✅
│   │
│   └── View NÀY nhận data từ parent và cần GHI ngược?
│       → @Binding ✅
│
├── ViewModel / Business Logic (API data, validation, shared state)
│   → @Published (trong class ObservableObject) ✅
│   
│   View truy cập property ViewModel?
│   ├── Chỉ ĐỌC → vm.property (let)
│   └── Cần GHI (TextField, Toggle) → $vm.property (Binding)
│
└── Child chỉ cần ĐỌC, không ghi?
    → let property (không cần @State, @Binding, hay @Published)
```

---

## 14. iOS 17+ — @Observable thay đổi gì?

```swift
// CŨ: ObservableObject + @Published
class VM: ObservableObject {
    @Published var name = ""        // phải đánh dấu từng property
    @Published var email = ""
}
// Re-render: BẤT KỲ @Published đổi → TẤT CẢ views re-render

// MỚI: @Observable (iOS 17+)
@Observable class VM {
    var name = ""                   // tự động tracked
    var email = ""
}
// Re-render: CHỈ property mà body ĐỌC thay đổi → view đó re-render

// @State vẫn giữ nguyên vai trò — UI state local trong View
// @Binding vẫn giữ nguyên vai trò — two-way reference
// @Published bị thay thế bởi @Observable (không cần đánh dấu từng property)
```

```
              iOS 13–16                    iOS 17+
              ─────────                    ───────
UI state      @State                       @State (giữ nguyên)
Two-way ref   @Binding                     @Binding (giữ nguyên)
ViewModel     @Published + ObservableObject @Observable (thay thế)
View sở hữu   @StateObject                 @State (cho @Observable class)
View mượn     @ObservedObject              var (property thường)
Granularity   Per-object (coarse)          Per-property (fine) ✅
```

Ba keyword này phối hợp chặt chẽ nhưng vai trò hoàn toàn khác nhau, Huy. Tóm gọn điểm quan trọng nhất:

**Ai SỞ HỮU data?** `@State` sở hữu (trong View struct, SwiftUI quản lý storage). `@Published` sở hữu (trong class ViewModel). `@Binding` **không sở hữu** — chỉ mượn reference đọc/ghi data ở nơi khác. Đây là khác biệt nền tảng quyết định khi nào dùng cái nào.

**`$` prefix trả về type KHÁC NHAU — sai lầm hay nhầm nhất.** `$stateProperty` → `Binding<T>` (cho UI). `$bindingProperty` → `Binding<T>` (chain tiếp). Nhưng `$publishedProperty` → `Published<T>.Publisher` (Combine stream, KHÔNG phải Binding!). Muốn Binding từ `@Published` → phải qua `$vm.property` (SwiftUI tạo Binding từ ObservableObject). Tức `$vm.email` cho `Binding<String>`, còn `vm.$email` cho `Published<String>.Publisher` — thứ tự `$` khác nhau, kết quả khác nhau hoàn toàn.

**Re-render granularity khác nhau.** `@State` re-render chính xác view chứa nó. `@Published` trigger `objectWillChange` → **TẤT CẢ** views observe ViewModel đều re-render (dù chỉ 1 property đổi) — đây là lý do iOS 17 giới thiệu `@Observable` với per-property tracking. `@Binding` không tự trigger — delegate cho source, source trigger chain lên parent rồi xuống child.

**Pattern production:** `@State` cho UI state thuần (toggle, sheet, animation). `@Published` cho business logic trong ViewModel (API data, validation). `@Binding` khi child cần **ghi ngược** parent (form field, reusable component). Child chỉ đọc → dùng `let`, không cần `@Binding`.
