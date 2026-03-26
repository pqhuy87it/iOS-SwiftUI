# SwiftUI: `some View` & `@ViewBuilder`

## 1. `some View` — Opaque Return Type

### Vấn đề: View type thực sự rất phức tạp

Mỗi view trong SwiftUI có **concrete type cực kỳ dài** mà compiler tự suy ra:

```swift
// Viết đơn giản thế này:
VStack {
    Text("Hello")
    Image(systemName: "star")
    if showButton {
        Button("Tap") { }
    }
}

// Concrete type thực sự (compiler nhìn thấy):
// VStack<TupleView<(Text, Image, Optional<Button<Text>>)>>
```

Mỗi khi thêm/bớt view, nested thêm modifier, type thay đổi hoàn toàn:

```swift
Text("Hello")
// Type: Text

Text("Hello").bold()
// Type: ModifiedContent<Text, _BoldModifier>

Text("Hello").bold().padding()
// Type: ModifiedContent<ModifiedContent<Text, _BoldModifier>, _PaddingLayout>

Text("Hello").bold().padding().background(.red)
// Type: ModifiedContent<ModifiedContent<ModifiedContent<Text, _BoldModifier>,
//       _PaddingLayout>, _BackgroundModifier<Color>>
```

Nếu phải viết return type tường minh → **bất khả thi**.

### Giải pháp: `some View`

`some` là keyword của Swift (Opaque Return Type, SE-0244). Nó nói với compiler:

> "Tôi sẽ trả về **một kiểu cụ thể** conform protocol `View`, nhưng tôi **không muốn viết tên** kiểu đó ra. Compiler, hãy tự suy ra giúp tôi."

```swift
var body: some View {
    Text("Hello")
}
// Compiler hiểu: body trả về Text
// Nhưng bên ngoài chỉ thấy: "trả về some View"
```

### Quy tắc quan trọng: MỘT concrete type duy nhất

`some View` **không phải** "trả về bất kỳ View nào". Nó là **một type cố định** mà compiler suy ra — chỉ là giấu tên đi.

```swift
// ✅ Compiler suy ra: concrete type = Text (luôn là Text)
var body: some View {
    Text("Hello")
}

// ❌ Compile error: hai nhánh trả về TYPE KHÁC NHAU
var body: some View {
    if condition {
        Text("Hello")     // Type: Text
    } else {
        Image("photo")    // Type: Image ← KHÁC Text
    }
}
```

Tại sao lỗi? `some View` hứa trả về **một concrete type duy nhất**. Hai nhánh `if/else` trả về `Text` và `Image` — hai type khác nhau → vi phạm lời hứa.

### Cách giải quyết khi cần trả về type khác nhau

**Cách 1: `@ViewBuilder` (recommended)** — giải thích ở phần 2.

**Cách 2: `AnyView` (type erasure — tránh nếu có thể)**

```swift
var body: some View {
    if condition {
        AnyView(Text("Hello"))
    } else {
        AnyView(Image("photo"))
    }
}
// Cả hai nhánh đều trả về AnyView → cùng type → compile OK
// ⚠️ Nhưng mất type info → SwiftUI diff kém hiệu quả hơn
```

**Cách 3: `Group` hoặc container view**

```swift
var body: some View {
    Group {          // Group tự áp dụng @ViewBuilder bên trong
        if condition {
            Text("Hello")
        } else {
            Image("photo")
        }
    }
}
```

### `some View` vs `any View` (Swift 5.7+)

```swift
// some View — opaque type: MỘT concrete type cố định, compiler biết
var body: some View { Text("Hi") }
// Compiler biết bên trong là Text → tối ưu, static dispatch

// any View — existential type: BẤT KỲ type nào conform View
func randomView() -> any View {
    if Bool.random() {
        return Text("Hi")
    } else {
        return Image(systemName: "star")
    }
}
// Compiler KHÔNG biết concrete type → dynamic dispatch, boxing overhead
// ⚠️ Không dùng được cho body vì View protocol có associated type
```

---

## 2. `@ViewBuilder` — Result Builder cho View

### Bản chất

`@ViewBuilder` là một **result builder** (SE-0289) — cơ chế cho phép viết **nhiều statement** trong closure và Swift tự động gom chúng thành **một value duy nhất**.

Nói cách khác, `@ViewBuilder` biến cú pháp "liệt kê view" thành một `TupleView`, `ConditionalContent`, hoặc `EmptyView` tuỳ theo nội dung.

### Không có @ViewBuilder

```swift
// ❌ Swift thuần: closure phải return MỘT giá trị
func buildViews() -> some View {
    Text("Hello")      // ← expression 1
    Text("World")      // ← expression 2
    // Error: chỉ được return 1 expression
}
```

### Có @ViewBuilder

```swift
// ✅ @ViewBuilder cho phép liệt kê nhiều view
@ViewBuilder
func buildViews() -> some View {
    Text("Hello")      // ← view 1
    Text("World")      // ← view 2
    // @ViewBuilder tự gom thành TupleView<(Text, Text)>
}
```

### @ViewBuilder transform từng loại syntax

**Nhiều view liệt kê → `TupleView`**

```swift
@ViewBuilder
func content() -> some View {
    Text("A")
    Text("B")
    Text("C")
}
// Compiler tạo: TupleView<(Text, Text, Text)>
```

**`if/else` → `_ConditionalContent`**

```swift
@ViewBuilder
func content() -> some View {
    if isLoggedIn {
        HomeView()          // Type: HomeView
    } else {
        LoginView()         // Type: LoginView (KHÁC HomeView)
    }
}
// Compiler tạo: _ConditionalContent<HomeView, LoginView>
// ← MỘT concrete type duy nhất chứa cả hai khả năng
// ← Đây là lý do @ViewBuilder giải quyết được vấn đề "hai nhánh khác type"
```

**`if` không có `else` → `Optional`**

```swift
@ViewBuilder
func content() -> some View {
    Text("Always here")
    if showBadge {
        Badge()
    }
    // Compiler tạo: TupleView<(Text, Optional<Badge>)>
}
```

**`switch` → `_ConditionalContent` lồng nhau**

```swift
@ViewBuilder
func content() -> some View {
    switch status {
    case .loading:  ProgressView()
    case .success:  ContentView()
    case .error:    ErrorView()
    }
}
```

**Vòng `for...in` → `ForEach`**

```swift
@ViewBuilder
func content() -> some View {
    ForEach(items) { item in
        Text(item.name)
    }
}
```

### Giới hạn: tối đa 10 view con

`TupleView` hỗ trợ tối đa **10 phần tử** (Swift generic tuple limit):

```swift
@ViewBuilder
func content() -> some View {
    Text("1")
    Text("2")
    // ... 
    Text("10")    // ✅ OK
    Text("11")    // ❌ Compile error: quá 10 view
}

// Giải pháp: nhóm vào Group hoặc container
@ViewBuilder
func content() -> some View {
    Group {
        Text("1")
        // ...
        Text("10")
    }
    Group {
        Text("11")
        // ...
    }
}
```

---

## 3. `var body: some View` — Kết hợp cả hai

### Protocol View yêu cầu gì?

```swift
public protocol View {
    associatedtype Body: View
    
    @ViewBuilder @MainActor
    var body: Self.Body { get }
//  ↑            ↑        ↑
//  @ViewBuilder Self.Body computed property
//  tự áp dụng  = some View
```

**`body` đã có sẵn `@ViewBuilder`** — không cần viết thêm. Đó là lý do trong body có thể liệt kê nhiều view, dùng `if/else`, mà không cần return hay gom thủ công:

```swift
struct ProfileView: View {
    @State private var isEditing = false
    
    var body: some View {       // ← @ViewBuilder đã có sẵn từ protocol
        VStack {                // ← view 1
            Text("Profile")    // ← nhiều view trong VStack (VStack cũng là @ViewBuilder)
            
            if isEditing {     // ← if/else OK nhờ @ViewBuilder
                EditForm()
            } else {
                DisplayInfo()
            }
        }
        .padding()             // ← modifier
        // Không cần "return" — @ViewBuilder tự gom
    }
}
```

### Tại sao `VStack { }` cũng cho phép liệt kê nhiều view?

Vì init của `VStack` cũng đánh dấu closure là `@ViewBuilder`:

```swift
// Khai báo thực tế của VStack (đơn giản hoá):
struct VStack<Content: View>: View {
    init(
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content   // ← @ViewBuilder ở đây
    )
}
```

Tương tự cho `HStack`, `ZStack`, `List`, `Group`, `ScrollView`, `NavigationStack`... — hầu hết container đều dùng `@ViewBuilder` cho closure content.

---

## 4. `@ViewBuilder` trên function — Tách logic view

### Khi nào cần?

Khi `body` quá dài, tách thành **helper function**. Function bình thường **không có** `@ViewBuilder` → phải viết theo cách cũ. Thêm `@ViewBuilder` → được viết như trong `body`:

```swift
struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                headerSection          // computed property
                statsSection           // computed property
                buildActionButtons()   // function
            }
        }
    }
    
    // MARK: - Computed property (tự có @ViewBuilder vì return some View)
    
    private var headerSection: some View {
        // Computed property trả về some View:
        // KHÔNG tự có @ViewBuilder → chỉ return ĐƯỢC 1 root view
        VStack(alignment: .leading) {
            Text(vm.greeting)
                .font(.largeTitle)
            Text(vm.subtitle)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Computed property VỚI @ViewBuilder
    
    @ViewBuilder
    private var statsSection: some View {
        // Giờ có thể liệt kê nhiều view + dùng if/else
        if vm.isLoading {
            ProgressView()
        } else {
            StatsCard(data: vm.weeklyStats)
            StatsCard(data: vm.monthlyStats)
            // Hai StatsCard nằm cạnh nhau → @ViewBuilder gom thành TupleView
        }
    }
    
    // MARK: - Function VỚI @ViewBuilder
    
    @ViewBuilder
    private func buildActionButtons() -> some View {
        if vm.isAdmin {
            AdminPanel()
            DangerZone()
        } else {
            UserActions()
        }
    }
}
```

### So sánh: có vs không `@ViewBuilder`

```swift
// ❌ KHÔNG có @ViewBuilder — phải wrap trong container
private func buildContent() -> some View {
    VStack {                    // ← bắt buộc có root container
        if condition {
            Text("A")
            Text("B")
        } else {
            Text("C")
        }
    }
}

// ✅ CÓ @ViewBuilder — viết tự do như trong body
@ViewBuilder
private func buildContent() -> some View {
    if condition {
        Text("A")
        Text("B")            // ← nhiều view OK
    } else {
        Text("C")            // ← khác type cũng OK
    }
    // Không cần container bọc ngoài
}
```

### @ViewBuilder với parameter — Generic reusable component

```swift
struct Card<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    //           ↑ closure @ViewBuilder cho phép caller liệt kê nhiều view
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            Divider()
            
            content()   // gọi closure → render nội dung tuỳ ý
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// Sử dụng — caller viết tự do trong closure
Card(title: "Statistics") {
    Text("Users: 1,200")
    Text("Revenue: $50K")
    ProgressView(value: 0.7)
    // 3 view khác type → @ViewBuilder gom thành TupleView
}
```

### @ViewBuilder với `if #available`

```swift
@ViewBuilder
private func adaptiveList() -> some View {
    if #available(iOS 17, *) {
        List(items) { item in
            Text(item.name)
        }
        .listStyle(.insetGrouped)
        .scrollBounceBehavior(.basedOnSize)   // iOS 17+
    } else {
        List(items) { item in
            Text(item.name)
        }
        .listStyle(.insetGrouped)
    }
}
```

---

## 5. @ViewBuilder — Compiler transformation chi tiết

Để hiểu sâu, xem compiler biến đổi code như thế nào:

### Input (code ta viết)

```swift
@ViewBuilder
func content() -> some View {
    Text("Header")
    if isLoading {
        ProgressView()
    } else {
        DataView()
    }
    Text("Footer")
}
```

### Output (compiler tạo ra — đơn giản hoá)

```swift
func content() -> some View {
    // Bước 1: gom expression liền nhau
    let v0 = Text("Header")
    
    // Bước 2: if/else → buildEither
    let v1: _ConditionalContent<ProgressView, DataView>
    if isLoading {
        v1 = ViewBuilder.buildEither(first: ProgressView())
    } else {
        v1 = ViewBuilder.buildEither(second: DataView())
    }
    
    let v2 = Text("Footer")
    
    // Bước 3: gom tất cả → buildBlock
    return ViewBuilder.buildBlock(v0, v1, v2)
    // Return type: TupleView<(Text, _ConditionalContent<ProgressView, DataView>, Text)>
}
```

Các method của `ViewBuilder` result builder:

```
Code syntax           →    ViewBuilder method
───────────                ───────────────────
Nhiều expression      →    buildBlock(v1, v2, ...)        → TupleView
if condition { }      →    buildOptional(component)       → Optional<View>
if { } else { }       →    buildEither(first/second:)     → _ConditionalContent
for...in              →    (dùng ForEach)
if #available         →    buildLimitedAvailability(...)
```

---

## 6. Sai lầm thường gặp

### Sai lầm 1: Dùng `return` tường minh trong @ViewBuilder

```swift
// ❌ return khiến Swift thoát @ViewBuilder mode
@ViewBuilder
func content() -> some View {
    return Text("Hello")     // "return" → Swift coi đây là closure thường
    Text("World")            // ← unreachable code warning, không render
}

// ✅ Không dùng return trong @ViewBuilder
@ViewBuilder
func content() -> some View {
    Text("Hello")
    Text("World")
}
```

> **Lưu ý:** Nếu chỉ có **đúng 1 expression** thì `return` không gây lỗi (Swift tự suy), nhưng thêm expression thứ 2 sẽ gặp vấn đề. Tốt nhất: **không bao giờ viết `return` trong @ViewBuilder**.

### Sai lầm 2: Logic phức tạp trong @ViewBuilder

```swift
// ❌ @ViewBuilder không hỗ trợ mọi Swift syntax
@ViewBuilder
func content() -> some View {
    let filtered = items.filter { $0.isActive }  // ❌ let binding phức tạp
    for item in filtered {                        // ❌ for loop thường
        Text(item.name)
    }
}

// ✅ Dùng ForEach và tính toán trước
@ViewBuilder
func content() -> some View {
    ForEach(items.filter(\.isActive)) { item in
        Text(item.name)
    }
}
```

### Sai lầm 3: Quên @ViewBuilder khi cần conditional

```swift
// ❌ Computed property KHÔNG tự có @ViewBuilder
private var statusView: some View {
    if isOnline {
        Circle().fill(.green)    // Type: some Shape
    } else {
        Circle().fill(.red)      // Cùng type → OK trong trường hợp này
    }
    // NHƯNG nếu hai nhánh khác type → compile error
}

// ✅ Thêm @ViewBuilder cho an toàn
@ViewBuilder
private var statusView: some View {
    if isOnline {
        Label("Online", systemImage: "wifi")       // Type: Label
    } else {
        Image(systemName: "wifi.slash")             // Type: Image (khác!)
    }
    // @ViewBuilder → _ConditionalContent<Label, Image> → OK
}
```

---

## 7. Tóm tắt

| Concept | Ý nghĩa | Ghi nhớ |
|---|---|---|
| `some View` | Opaque return type — giấu concrete type, compiler tự suy | "Tôi trả về View cụ thể, nhưng không nói tên" |
| `@ViewBuilder` | Result builder — gom nhiều view thành một type | "Phép thuật cho phép liệt kê view tự do" |
| `var body` | Đã có sẵn `@ViewBuilder` từ protocol `View` | Không cần thêm `@ViewBuilder` |
| `func` / computed property | Mặc định KHÔNG có `@ViewBuilder` | Phải thêm thủ công khi cần conditional / nhiều view |
| `@ViewBuilder` closure | Container init (`VStack`, `HStack`...) đã đánh dấu | Đó là lý do viết tự do bên trong `VStack { }` |

-------

Hai concept này là nền tảng cú pháp của SwiftUI, Huy. Chúng giải quyết hai vấn đề khác nhau nhưng phối hợp chặt chẽ:

**`some View`** — giải quyết vấn đề concrete type quá phức tạp. `Text("Hello").bold().padding()` có type thực là `ModifiedContent<ModifiedContent<Text, _BoldModifier>, _PaddingLayout>` — không ai muốn viết ra. `some` nói compiler: "Anh tự suy type giúp tôi, tôi chỉ hứa nó conform `View`." Quy tắc quan trọng: **một concrete type duy nhất** — hai nhánh `if/else` trả về type khác nhau sẽ compile error.

**`@ViewBuilder`** — giải quyết chính vấn đề trên. Nó là result builder biến `if/else` thành `_ConditionalContent<A, B>` (một type duy nhất chứa cả hai khả năng), biến nhiều view liệt kê thành `TupleView`. Nhờ vậy mà viết được code "declarative" tự do trong body.

Điểm hay: `var body` **đã tự có `@ViewBuilder`** từ protocol `View`, nên không cần khai báo. Nhưng khi tách logic ra computed property hoặc function riêng, phải **thêm `@ViewBuilder` thủ công** nếu muốn dùng conditional hoặc liệt kê nhiều view.
