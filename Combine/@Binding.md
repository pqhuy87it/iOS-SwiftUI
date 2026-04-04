# SwiftUI: `@Binding` — Giải thích chi tiết

## 1. Bản chất — Tham chiếu đọc/ghi ngược lên source of truth

`@Binding` là property wrapper tạo **two-way connection** đến một source of truth nằm ở **nơi khác** (parent view, ViewModel...). View có `@Binding` **không sở hữu** data — nó chỉ mượn quyền đọc VÀ ghi.

```
Parent (SỞ HỮU data):
  @State var isOn = false          ← source of truth

Child (MƯỢN qua Binding):
  @Binding var isOn: Bool          ← tham chiếu, không sở hữu
  isOn = true                      ← ghi → parent's @State thay đổi
                                     → CẢ parent VÀ child re-render
```

Hình dung: `@State` là **sổ gốc**, `@Binding` là **bản sao liên kết** — sửa bản sao thì sổ gốc cũng thay đổi và ngược lại.

---

## 2. Tại sao cần @Binding?

### View là struct → không thể mutate property của parent

```swift
// ❌ Không có Binding
struct ParentView: View {
    @State private var name = ""
    
    var body: some View {
        ChildInput(name: name)
        //              ↑ truyền VALUE (copy)
        //                child sửa → parent KHÔNG biết
    }
}

struct ChildInput: View {
    var name: String    // ← read-only copy
    
    var body: some View {
        TextField("Name", text: ???)
        // ❌ Không có cách ghi ngược lại parent
    }
}
```

### Binding giải quyết: truyền REFERENCE thay vì VALUE

```swift
// ✅ Có Binding
struct ParentView: View {
    @State private var name = ""
    
    var body: some View {
        ChildInput(name: $name)
        //              ↑ $name = Binding<String>
        //                truyền REFERENCE, không phải copy
    }
}

struct ChildInput: View {
    @Binding var name: String    // ← reference đến parent's @State
    
    var body: some View {
        TextField("Name", text: $name)
        //                       ↑ $name ở đây = Binding<String> (projected value)
        // User gõ → name thay đổi → parent's @State thay đổi → cả 2 re-render
    }
}
```

---

## 3. `$` Prefix — Projected Value

`@State`, `@Published`, `@Binding` đều có **projected value** truy cập qua prefix `$`:

```swift
@State var count = 0
// count     → Int (wrapped value) — đọc/ghi giá trị
// $count    → Binding<Int> (projected value) — reference truyền cho child

@Binding var isOn: Bool
// isOn      → Bool (wrapped value) — đọc/ghi giá trị
// $isOn     → Binding<Bool> (projected value) — truyền tiếp cho child khác
```

```
@State var name = "Huy"
         │
         ├── name  → "Huy" (String value)
         │
         └── $name → Binding<String>
                      │
                      ├── get: { return name }
                      └── set: { name = newValue }
```

### Chain Binding qua nhiều level

```swift
// Level 0: Source of truth
struct GrandParent: View {
    @State private var color = Color.blue
    var body: some View { Parent(color: $color) }
    //                           ↑ Binding<Color>
}

// Level 1: Pass-through
struct Parent: View {
    @Binding var color: Color
    var body: some View { Child(color: $color) }
    //                         ↑ Binding<Color> — truyền tiếp
}

// Level 2: Sử dụng
struct Child: View {
    @Binding var color: Color
    var body: some View {
        ColorPicker("Color", selection: $color)
        // Ghi ở đây → GrandParent's @State thay đổi
    }
}
```

```
GrandParent(@State color)
     │ $color (Binding)
     ▼
Parent(@Binding color)
     │ $color (Binding)
     ▼
Child(@Binding color)
     │ $color (Binding)
     ▼
ColorPicker
  user chọn .red → color = .red
  → Child re-render
  → Parent re-render
  → GrandParent re-render
  (tất cả hiện .red)
```

---

## 4. Nguồn tạo Binding

### 4.1 Từ `@State` → `$property`

```swift
@State private var text = ""
TextField("Input", text: $text)
//                        ↑ Binding<String> từ @State
```

### 4.2 Từ `@Binding` → `$property` (chain tiếp)

```swift
@Binding var isEnabled: Bool
Toggle("Enable", isOn: $isEnabled)
//                      ↑ Binding<Bool> từ @Binding → truyền tiếp
```

### 4.3 Từ `@StateObject` / `@ObservedObject` → `$vm.property`

```swift
@StateObject var vm = ViewModel()
TextField("Name", text: $vm.name)
//                       ↑ Binding<String> đến vm.name
Toggle("Dark", isOn: $vm.isDarkMode)
//                    ↑ Binding<Bool> đến vm.isDarkMode
```

### 4.4 Từ `@Observable` + `@State` / `@Bindable`

```swift
// iOS 17+ @Observable
@State var vm = ViewModel()     // @Observable class
TextField("Name", text: $vm.name)
//                       ↑ Binding<String>

// Hoặc dùng @Bindable cho object nhận từ ngoài
struct ChildView: View {
    @Bindable var vm: ViewModel    // @Observable, nhận từ parent
    var body: some View {
        TextField("Name", text: $vm.name)
    }
}
```

### 4.5 Từ `@AppStorage`

```swift
@AppStorage("username") var username = ""
TextField("Username", text: $username)
//                          ↑ Binding<String> → ghi vào UserDefaults
```

### 4.6 Từ `@Environment` + `@Bindable` (iOS 17+)

```swift
@Environment(Settings.self) var settings

var body: some View {
    @Bindable var settings = settings
    Toggle("Notifications", isOn: $settings.notificationsEnabled)
}
```

---

## 5. Binding với Views yêu cầu Binding

Rất nhiều SwiftUI views built-in **yêu cầu Binding** thay vì giá trị thường:

```swift
// TextField — text: Binding<String>
TextField("Name", text: $name)

// SecureField — text: Binding<String>
SecureField("Password", text: $password)

// TextEditor — text: Binding<String>
TextEditor(text: $bio)

// Toggle — isOn: Binding<Bool>
Toggle("WiFi", isOn: $wifiEnabled)

// Slider — value: Binding<Double>
Slider(value: $volume, in: 0...100)

// Stepper — value: Binding<Int>
Stepper("Quantity: \(qty)", value: $qty, in: 1...99)

// Picker — selection: Binding<T>
Picker("Theme", selection: $selectedTheme) { ... }

// DatePicker — selection: Binding<Date>
DatePicker("Birthday", selection: $date)

// ColorPicker — selection: Binding<Color>
ColorPicker("Color", selection: $color)

// Sheet — isPresented: Binding<Bool>
.sheet(isPresented: $showSheet) { ... }

// Alert — isPresented: Binding<Bool>
.alert("Error", isPresented: $showAlert) { ... }

// NavigationStack — path: Binding<NavigationPath>
NavigationStack(path: $path) { ... }

// @FocusState — focused: FocusState<T>.Binding
TextField("", text: $text).focused($isFocused)
```

---

## 6. Custom Binding — Tạo Binding thủ công

### 6.1 `Binding(get:set:)` — Hoàn toàn custom

```swift
struct TemperatureView: View {
    @State private var celsius: Double = 0
    
    // Computed Binding: hiển thị Fahrenheit nhưng lưu Celsius
    var fahrenheitBinding: Binding<Double> {
        Binding(
            get: { celsius * 9/5 + 32 },
            set: { celsius = ($0 - 32) * 5/9 }
        )
    }
    
    var body: some View {
        VStack {
            Text("Celsius: \(celsius, specifier: "%.1f")°C")
            Slider(value: fahrenheitBinding, in: 32...212)
            Text("Fahrenheit: \(fahrenheitBinding.wrappedValue, specifier: "%.1f")°F")
        }
    }
}
```

### 6.2 Binding với validation/transformation

```swift
struct AmountInput: View {
    @State private var amount: Double = 0
    
    // Binding giới hạn range
    var clampedBinding: Binding<Double> {
        Binding(
            get: { amount },
            set: { amount = min(max($0, 0), 10000) }
            //                    ↑ clamp 0...10000
        )
    }
    
    var body: some View {
        TextField("Amount", value: clampedBinding, format: .number)
    }
}
```

### 6.3 Binding chuyển đổi type

```swift
struct SearchView: View {
    @State private var query: String? = nil
    
    // Chuyển Optional<String> → String cho TextField
    var queryBinding: Binding<String> {
        Binding(
            get: { query ?? "" },
            set: { query = $0.isEmpty ? nil : $0 }
        )
    }
    
    var body: some View {
        TextField("Search", text: queryBinding)
    }
}
```

### 6.4 Binding với side effect (logging, analytics)

```swift
var loggedBinding: Binding<Bool> {
    Binding(
        get: { isEnabled },
        set: {
            print("Changed from \(isEnabled) to \($0)")
            analytics.track("toggle_changed", value: $0)
            isEnabled = $0
        }
    )
}

Toggle("Feature", isOn: loggedBinding)
```

---

## 7. `.constant()` — Binding cố định (read-only preview)

`Binding.constant()` tạo Binding **không bao giờ thay đổi** — dùng cho preview, test, hoặc khi cần truyền Binding nhưng không muốn ghi:

```swift
// Preview
#Preview {
    ToggleRow(isOn: .constant(true))
    //              ↑ luôn true, toggle không hoạt động
}

// Placeholder khi chưa có data thực
TextField("Name", text: .constant("Preview Name"))
//                       ↑ read-only, user gõ không thay đổi gì
```

### ⚠️ Không dùng `.constant()` trong production code

```swift
// ❌ Toggle không hoạt động — user tap nhưng không đổi
Toggle("WiFi", isOn: .constant(true))

// ✅ Dùng @State hoặc @Binding
@State private var wifiEnabled = true
Toggle("WiFi", isOn: $wifiEnabled)
```

---

## 8. Binding vào nested properties — KeyPath binding

### Binding vào property của object

```swift
struct User {
    var name: String
    var address: Address
    
    struct Address {
        var city: String
        var zipCode: String
    }
}

struct ProfileEditor: View {
    @Binding var user: User
    
    var body: some View {
        Form {
            TextField("Name", text: $user.name)
            //                       ↑ Binding<String> vào user.name
            
            TextField("City", text: $user.address.city)
            //                       ↑ Binding<String> vào user.address.city
            //                         nested property — hoạt động tự động
            
            TextField("Zip", text: $user.address.zipCode)
        }
    }
}
```

### Binding vào array element

```swift
struct TodoList: View {
    @State private var todos: [Todo] = []
    
    var body: some View {
        List($todos) { $todo in
            //        ↑ $todos = Binding<[Todo]>
            //              ↑ $todo = Binding<Todo> cho từng element
            
            HStack {
                Toggle("", isOn: $todo.isDone)
                    //            ↑ Binding<Bool> vào từng todo.isDone
                TextField("Title", text: $todo.title)
                    //                    ↑ Binding<String> vào từng todo.title
            }
        }
    }
}
```

### Binding vào dictionary value

```swift
@State private var settings: [String: Bool] = [
    "notifications": true,
    "darkMode": false,
    "autoSave": true
]

ForEach(Array(settings.keys.sorted()), id: \.self) { key in
    Toggle(key, isOn: Binding(
        get: { settings[key] ?? false },
        set: { settings[key] = $0 }
    ))
}
```

---

## 9. Ứng dụng thực tế

### 9.1 Reusable Form Field Component

```swift
struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let validation: (String) -> String?
    //                                ↑ nil = valid, String = error message
    
    @FocusState private var isFocused: Bool
    @State private var hasBeenEdited = false
    
    private var errorMessage: String? {
        guard hasBeenEdited, !isFocused else { return nil }
        return validation(text)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(errorMessage != nil ? .red : isFocused ? .blue : .gray.opacity(0.3))
                )
                .onChange(of: text) { _, _ in hasBeenEdited = true }
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}

// Sử dụng
struct SignUpForm: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 16) {
            FormField(
                title: "Email",
                placeholder: "you@example.com",
                text: $email,
                //    ↑ Binding — FormField đọc/ghi email
                validation: { $0.contains("@") ? nil : "Invalid email" }
            )
            
            FormField(
                title: "Password",
                placeholder: "8+ characters",
                text: $password,
                validation: { $0.count >= 8 ? nil : "Too short" }
            )
        }
        .padding()
    }
}
```

### 9.2 Rating Stars Component

```swift
struct RatingView: View {
    @Binding var rating: Int
    let maxRating: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundStyle(star <= rating ? .yellow : .gray)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            rating = star
                            // ↑ Ghi → parent's source of truth thay đổi
                        }
                    }
            }
        }
    }
}

// Sử dụng
struct ReviewForm: View {
    @State private var rating = 0
    
    var body: some View {
        VStack {
            RatingView(rating: $rating, maxRating: 5)
            //                 ↑ Binding — tap star → rating thay đổi ở đây
            
            Text("You rated: \(rating)/5")
        }
    }
}
```

### 9.3 Sheet với dismiss + data return

```swift
struct ContentView: View {
    @State private var selectedColor = Color.blue
    @State private var showPicker = false
    
    var body: some View {
        VStack {
            Circle().fill(selectedColor).frame(width: 100, height: 100)
            
            Button("Change Color") { showPicker = true }
        }
        .sheet(isPresented: $showPicker) {
            ColorPickerSheet(selectedColor: $selectedColor)
            //                              ↑ Sheet ghi → parent nhận
        }
    }
}

struct ColorPickerSheet: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ColorPicker("Pick a color", selection: $selectedColor)
            //                                     ↑ chain Binding tiếp
                .padding()
                .toolbar {
                    Button("Done") { dismiss() }
                }
        }
    }
}
```

### 9.4 Multi-step form — Binding qua nhiều screens

```swift
struct MultiStepForm: View {
    @State private var formData = FormData()
    @State private var step = 1
    
    var body: some View {
        switch step {
        case 1: Step1View(data: $formData, onNext: { step = 2 })
        case 2: Step2View(data: $formData, onNext: { step = 3 }, onBack: { step = 1 })
        case 3: Step3View(data: $formData, onSubmit: { submit() })
        default: EmptyView()
        }
    }
}

struct Step1View: View {
    @Binding var data: FormData
    let onNext: () -> Void
    
    var body: some View {
        VStack {
            TextField("First Name", text: $data.firstName)
            TextField("Last Name", text: $data.lastName)
            Button("Next") { onNext() }
        }
    }
}

struct Step2View: View {
    @Binding var data: FormData
    let onNext: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack {
            TextField("Email", text: $data.email)
            TextField("Phone", text: $data.phone)
            HStack {
                Button("Back") { onBack() }
                Button("Next") { onNext() }
            }
        }
    }
}
// Mỗi step sửa formData qua Binding → tất cả steps chia sẻ cùng data
```

### 9.5 Binding trong ForEach — Edit collection

```swift
struct ShoppingList: View {
    @State private var items: [ShoppingItem] = [
        ShoppingItem(name: "Milk", quantity: 1, isBought: false),
        ShoppingItem(name: "Eggs", quantity: 12, isBought: false),
    ]
    
    var body: some View {
        List {
            ForEach($items) { $item in
                //     ↑ $items: Binding<[ShoppingItem]>
                //               ↑ $item: Binding<ShoppingItem> cho từng phần tử
                HStack {
                    Toggle("", isOn: $item.isBought)
                        .labelsHidden()
                    
                    VStack(alignment: .leading) {
                        TextField("Item", text: $item.name)
                            .strikethrough(item.isBought)
                        
                        Stepper("Qty: \(item.quantity)", value: $item.quantity, in: 1...99)
                            .font(.caption)
                    }
                }
            }
            .onDelete { items.remove(atOffsets: $0) }
        }
    }
}
```

---

## 10. @Binding vs Alternatives — Khi nào dùng cái nào

```
Child cần ĐỌC data từ parent (read-only)?
  → Truyền value thường: let item: Item
  → KHÔNG cần @Binding

Child cần ĐỌC + GHI data ngược lại parent?
  → @Binding ✅

Child cần trigger action ở parent (không cần data)?
  → Closure: let onTap: () -> Void
  → KHÔNG cần @Binding

Data chia sẻ qua nhiều views không liên quan?
  → @EnvironmentObject / @Environment
  → KHÔNG cần @Binding qua từng level

Data từ ViewModel?
  → @StateObject / @ObservedObject + $vm.property
  → Hoặc @Observable + @Bindable
```

### So sánh

```
                @State          @Binding         Closure
                ──────          ────────         ───────
Sở hữu data    ✅ Có            ❌ Không          ❌ Không
Đọc data        ✅               ✅                ❌
Ghi data        ✅               ✅ (ngược parent) ❌
Truyền xuống    $property        $property         parameter
Dùng cho        Source of truth  Child cần ghi    Child trigger action
```

---

## 11. Sai lầm thường gặp

### ❌ Dùng @Binding khi chỉ cần đọc

```swift
// ❌ Child chỉ hiển thị, không sửa → @Binding thừa
struct DisplayView: View {
    @Binding var name: String    // ❌ không bao giờ ghi
    var body: some View { Text(name) }
}

// ✅ Dùng let (read-only)
struct DisplayView: View {
    let name: String             // ✅ đọc đủ rồi
    var body: some View { Text(name) }
}
```

### ❌ Tạo @State trong child cho data từ parent

```swift
// ❌ @State trong child = copy, KHÔNG đồng bộ ngược parent
struct ChildView: View {
    @State var name: String      // ❌ copy riêng, parent không biết khi sửa
    init(name: String) {
        _name = State(initialValue: name)
    }
}

// ✅ @Binding — đồng bộ hai chiều
struct ChildView: View {
    @Binding var name: String    // ✅ reference đến parent
}
```

### ❌ Quên $ khi truyền Binding

```swift
@State private var isOn = false

// ❌ Truyền VALUE (Bool), không phải Binding
ToggleRow(isOn: isOn)         // ❌ nếu ToggleRow cần @Binding

// ✅ Truyền BINDING
ToggleRow(isOn: $isOn)        // ✅ Binding<Bool>
```

### ❌ Modify @Binding trong init

```swift
// ❌ Sửa Binding trong init có thể gây vòng lặp re-render
struct BadView: View {
    @Binding var count: Int
    
    init(count: Binding<Int>) {
        _count = count
        _count.wrappedValue += 1    // ❌ sửa Binding trong init → re-render parent → init lại → +1 → ...
    }
}

// ✅ Sửa trong action hoặc onAppear
struct GoodView: View {
    @Binding var count: Int
    
    var body: some View {
        Button("Increment") { count += 1 }
        // Hoặc .onAppear { count += 1 } nếu cần 1 lần
    }
}
```

### ❌ @Binding cho @Observable object (iOS 17+)

```swift
// ❌ @Binding cho reference type @Observable
struct Child: View {
    @Binding var vm: ViewModel    // ❌ Binding cho reference type → confusing
}

// ✅ Truyền object trực tiếp (đã reference type)
struct Child: View {
    var vm: ViewModel             // ✅ @Observable tự track
    // Cần Binding cho PROPERTY: dùng @Bindable
    var body: some View {
        @Bindable var vm = vm
        TextField("", text: $vm.name)
    }
}
```

---

## 12. Tóm tắt

| Khía cạnh | Chi tiết |
|---|---|
| **Là gì?** | Property wrapper tạo two-way reference đến source of truth ở nơi khác |
| **Sở hữu data?** | ❌ Không — chỉ mượn quyền đọc/ghi |
| **Tạo từ đâu?** | `$stateProperty`, `$bindingProperty`, `$vm.property`, `Binding(get:set:)`, `.constant()` |
| **`$` prefix** | Lấy projected value = Binding — truyền cho child hoặc SwiftUI view cần Binding |
| **Nested** | `$user.address.city` — tự động tạo Binding đến nested property |
| **ForEach** | `ForEach($items) { $item in }` — Binding cho từng element |
| **Custom** | `Binding(get:set:)` — validation, transform, logging |
| **`.constant()`** | Binding cố định — chỉ dùng trong Preview/Test |
| **Dùng khi** | Child cần **GHI** data ngược parent (form input, toggle, picker, sheet) |
| **KHÔNG dùng khi** | Child chỉ đọc → let. Child trigger action → closure |

`@Binding` tạo **two-way connection** đến source of truth ở nơi khác — child đọc VÀ ghi ngược lại parent, Huy. Ba điểm cốt lõi:

**`@Binding` không sở hữu data, chỉ mượn.** `@State` là sổ gốc (source of truth), `@Binding` là tham chiếu liên kết. Ghi qua `@Binding` → `@State` ở parent thay đổi → cả parent lẫn child re-render. Prefix `$` lấy `Binding<T>` (projected value) để truyền xuống: `$name` từ `@State` hoặc `$name` từ `@Binding` đều cho ra `Binding<String>` — chain qua bao nhiêu level cũng được.

**Hầu hết built-in interactive views đều yêu cầu Binding:** `TextField(text: $name)`, `Toggle(isOn: $isEnabled)`, `Slider(value: $volume)`, `Picker(selection: $choice)`, `.sheet(isPresented: $show)`... Đây là lý do `@Binding` xuất hiện cực kỳ thường xuyên. Ngoài ra, `ForEach($items) { $item in }` cho Binding đến **từng element** trong array — edit trực tiếp collection.

**`Binding(get:set:)` cho custom logic** — validation (`clamp 0...10000`), transform (`Celsius ↔ Fahrenheit`), type conversion (`Optional<String> → String` cho TextField), side effect (logging, analytics). Đây là công cụ mạnh khi built-in Binding không đủ.

Quy tắc chọn: child cần **đọc + ghi** → `@Binding`. Child chỉ **đọc** → `let` (truyền value). Child chỉ **trigger action** → closure. Sai lầm phổ biến nhất: dùng `@Binding` khi chỉ cần đọc, hoặc tạo `@State` trong child cho data từ parent (copy riêng, không đồng bộ ngược).
