# SwiftUI: `@ObservedObject` vs `ObservableObject` — So sánh chi tiết

## 1. Khác biệt nền tảng — Không cùng loại

Hai keyword này **không cùng loại** — một là **protocol**, một là **property wrapper**. Chúng hay bị nhầm vì tên gần giống nhau, nhưng vai trò hoàn toàn khác:

```
ObservableObject   → PROTOCOL trên CLASS
                     "Tôi là object CÓ THỂ được quan sát"
                     Định nghĩa KHẢ NĂNG

@ObservedObject    → PROPERTY WRAPPER trên PROPERTY trong View
                     "Tôi ĐANG quan sát object này"
                     Thực hiện hành động QUAN SÁT
```

Tương tự trong đời thực:

```
ObservableObject  = "Có thể được theo dõi"  (khả năng — giống "Trackable" package)
@ObservedObject   = "Đang theo dõi"          (hành động — giống scanner quét package)
```

---

## 2. `ObservableObject` — Protocol: Khai báo "tôi có thể được quan sát"

### Định nghĩa

```swift
// Apple's definition:
protocol ObservableObject: AnyObject {
    associatedtype ObjectWillChangePublisher: Publisher = ObservableObjectPublisher
        where ObjectWillChangePublisher.Failure == Never
    
    var objectWillChange: ObjectWillChangePublisher { get }
}
```

### Đặc điểm

```swift
// 1. Là PROTOCOL — conform trên CLASS (không phải struct)
class UserViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published private(set) var isLoading = false
}

// 2. Yêu cầu AnyObject → CHỈ class
struct BadVM: ObservableObject { }    // ❌ Compile error — struct không được

// 3. Cung cấp objectWillChange publisher (tự động synthesize)
let vm = UserViewModel()
vm.objectWillChange
    .sink { print("Something will change") }
// Mỗi khi BẤT KỲ @Published property thay đổi → objectWillChange.send()
```

### ObservableObject KHÔNG làm gì tự nó — cần "observer"

```swift
// Chỉ khai báo ObservableObject → chưa có gì xảy ra với SwiftUI
class VM: ObservableObject {
    @Published var count = 0
}

let vm = VM()
vm.count = 5
// ← SwiftUI KHÔNG BIẾT gì
// ← Chưa có View nào "observe" object này

// Cần @ObservedObject / @StateObject trong View để kết nối
struct MyView: View {
    @ObservedObject var vm: VM    // ← BÂY GIỜ SwiftUI mới lắng nghe
}
```

---

## 3. `@ObservedObject` — Property Wrapper: Thực hiện "tôi đang quan sát"

### Đặc điểm

```swift
// 1. Là PROPERTY WRAPPER — đặt trước property trong View struct
struct ProfileView: View {
    @ObservedObject var vm: UserViewModel
    //               ↑ property wrapper
    //                   ↑ property trong View
}

// 2. Chỉ dùng trong struct View
class NotAView {
    @ObservedObject var vm = VM()    // ⚠️ Không có ý nghĩa ngoài View
}

// 3. Object PHẢI conform ObservableObject
class NotObservable { var count = 0 }

struct MyView: View {
    @ObservedObject var vm: NotObservable
    // ❌ Compile error: NotObservable does not conform to ObservableObject
}
```

---

## 4. Mối quan hệ — Hai mảnh ghép bổ sung nhau

```
ObservableObject (protocol)     @ObservedObject (property wrapper)
─────────────────────────       ──────────────────────────────────
Khai báo trên CLASS              Khai báo trên PROPERTY trong View
"Tôi phát signal khi thay đổi"  "Tôi lắng nghe signal từ object"
        │                                 │
        │    objectWillChange.send()      │
        └─────────────────────────────────┘
              ↑ kết nối hai phía
```

```swift
// Bước 1: Class KHAI BÁO khả năng (ObservableObject)
class TimerVM: ObservableObject {
    @Published var seconds = 0          // thay đổi → objectWillChange.send()
}

// Bước 2: View ĐĂNG KÝ lắng nghe (@ObservedObject)
struct TimerView: View {
    @ObservedObject var timer: TimerVM  // lắng nghe objectWillChange
    
    var body: some View {
        Text("\(timer.seconds)s")
        // seconds thay đổi → objectWillChange → SwiftUI re-render body
    }
}
```

### Luồng hoạt động chi tiết

```
1. timer.seconds = 5
      │
2. @Published willSet → objectWillChange.send()
      │                  (ObservableObject cung cấp publisher)
      │
3. @ObservedObject đang subscribe objectWillChange
      │             (property wrapper tự subscribe)
      │
4. Nhận signal → SwiftUI invalidate TimerView
      │
5. TimerView.body chạy lại
      │
6. Text("\(timer.seconds)s") → hiển thị "5s"
```

---

## 5. Không thể dùng cái này mà thiếu cái kia

### ObservableObject mà KHÔNG có @ObservedObject/@StateObject

```swift
class VM: ObservableObject {
    @Published var count = 0
}

struct MyView: View {
    let vm = VM()          // ← KHÔNG có @ObservedObject/@StateObject
    
    var body: some View {
        Text("\(vm.count)")
        Button("+") { vm.count += 1 }
    }
}
// ❌ Button tap → count thay đổi → NHƯNG UI KHÔNG UPDATE
// Vì SwiftUI không biết cần lắng nghe VM này
// objectWillChange.send() phát nhưng KHÔNG AI NGHE
```

### @ObservedObject mà object KHÔNG conform ObservableObject

```swift
class PlainClass {
    var count = 0          // ← KHÔNG có @Published, KHÔNG conform ObservableObject
}

struct MyView: View {
    @ObservedObject var vm: PlainClass
    // ❌ Compile error: PlainClass does not conform to ObservableObject
}
```

### Kết luận: PHẢI có CẢ HAI

```
ObservableObject (trên class)  +  @ObservedObject (trong View)  =  Reactive UI ✅
ObservableObject (trên class)  +  không observer                =  Signal mất ❌
không ObservableObject         +  @ObservedObject                =  Compile error ❌
```

---

## 6. Một class → Nhiều observers

Một class conform `ObservableObject` có thể được observe bởi **nhiều Views cùng lúc**:

```swift
class SharedSettings: ObservableObject {
    @Published var fontSize: CGFloat = 16
    @Published var isDarkMode = false
}

// View 1 — observe
struct FontSizeView: View {
    @ObservedObject var settings: SharedSettings
    var body: some View { Text("Size: \(settings.fontSize)") }
}

// View 2 — observe cùng object
struct ThemeView: View {
    @ObservedObject var settings: SharedSettings
    var body: some View { Toggle("Dark", isOn: $settings.isDarkMode) }
}

// View 3 — observe cùng object
struct PreviewPanel: View {
    @ObservedObject var settings: SharedSettings
    var body: some View {
        Text("Preview")
            .font(.system(size: settings.fontSize))
            .colorScheme(settings.isDarkMode ? .dark : .light)
    }
}

// Parent — tạo 1 instance, chia sẻ cho cả 3
struct SettingsScreen: View {
    @StateObject var settings = SharedSettings()    // ← 1 instance
    
    var body: some View {
        VStack {
            FontSizeView(settings: settings)        // ← share
            ThemeView(settings: settings)            // ← share
            PreviewPanel(settings: settings)         // ← share
        }
    }
}
```

```
                   SharedSettings (ObservableObject)
                         │ objectWillChange
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼
     FontSizeView   ThemeView   PreviewPanel
   (@ObservedObject) (@ObservedObject) (@ObservedObject)
   
fontSize thay đổi → objectWillChange.send()
→ TẤT CẢ 3 views re-render (dù ThemeView không dùng fontSize)
```

---

## 7. Họ nhà "Observable" — Bản đồ đầy đủ

```
ObservableObject (PROTOCOL)
│
│ "Class conform protocol này"
│
├── @StateObject (PROPERTY WRAPPER)
│   "View TẠO và SỞ HỮU object"
│   Bảo vệ khỏi re-create khi parent re-render
│
├── @ObservedObject (PROPERTY WRAPPER)
│   "View MƯỢN object từ bên ngoài"
│   KHÔNG bảo vệ — phù hợp khi nhận qua parameter
│
└── @EnvironmentObject (PROPERTY WRAPPER)
    "View MƯỢN object từ environment"
    Giống @ObservedObject nhưng implicit injection

@Published (PROPERTY WRAPPER — Combine)
│ "Property phát signal khi thay đổi"
│ Dùng TRONG class conform ObservableObject
│ Trigger objectWillChange.send() tự động
```

### Bảng phân loại

```
                    Loại                 Dùng ở đâu            Vai trò
                    ────                 ──────────            ──────
ObservableObject    Protocol             class declaration     Khai báo khả năng
@Published          Property Wrapper     class property        Phát signal thay đổi
@StateObject        Property Wrapper     View property         Tạo + sở hữu + observe
@ObservedObject     Property Wrapper     View property         Mượn + observe
@EnvironmentObject  Property Wrapper     View property         Mượn từ env + observe
```

---

## 8. Tên gây nhầm — Phân tích ngữ pháp

```
Observable + Object   = "Object có thể quan sát được"
                        → Protocol TRÊN object

Observed + Object     = "Object đang ĐƯỢC quan sát"
                        → Property wrapper nói "tôi ĐANG observe object này"

Cách nhớ:
  ObservABLE  = "-able" = KHẢ NĂNG (protocol)
  ObservED    = "-ed"   = ĐANG LÀM (property wrapper)
```

```
"able" (có thể)  → ObservableObject  → Protocol
"ed" (đang)      → @ObservedObject   → Property Wrapper
"ing" (đang)     → @StateObject      → Property Wrapper (observe + own)
```

---

## 9. Ví dụ hoàn chỉnh — Thấy rõ cả hai cùng lúc

```swift
// ━━━━━ ObservableObject: PROTOCOL trên class ━━━━━
class ShoppingCart: ObservableObject {
    //                     ↑ PROTOCOL — khai báo "tôi observable"
    
    @Published var items: [CartItem] = []
    @Published private(set) var total: Double = 0
    
    func addItem(_ item: CartItem) {
        items.append(item)
        recalculateTotal()
    }
    
    func removeItem(at index: Int) {
        items.remove(at: index)
        recalculateTotal()
    }
    
    private func recalculateTotal() {
        total = items.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }
}

// ━━━━━ @StateObject: TẠO + observe ━━━━━
struct ShopScreen: View {
    @StateObject private var cart = ShoppingCart()
    //                              ↑ TẠO object (= init)
    
    var body: some View {
        NavigationStack {
            VStack {
                ProductGrid(cart: cart)
                CartSummary(cart: cart)
            }
        }
    }
}

// ━━━━━ @ObservedObject: MƯỢN + observe ━━━━━
struct ProductGrid: View {
    @ObservedObject var cart: ShoppingCart
    //                       ↑ MƯỢN object (nhận qua parameter, KHÔNG init)
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))]) {
            ForEach(products) { product in
                ProductCard(product: product) {
                    cart.addItem(CartItem(product: product, quantity: 1))
                    // ↑ Ghi vào cart → @Published items thay đổi
                    //   → objectWillChange.send()
                    //   → TẤT CẢ views có @ObservedObject/@StateObject re-render
                }
            }
        }
    }
}

// ━━━━━ @ObservedObject: MƯỢN + observe (view khác) ━━━━━
struct CartSummary: View {
    @ObservedObject var cart: ShoppingCart
    //                       ↑ MƯỢN cùng object
    
    var body: some View {
        HStack {
            Text("\(cart.items.count) items")
            Spacer()
            Text(cart.total, format: .currency(code: "USD"))
                .bold()
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
```

### Luồng khi user tap "Add to Cart"

```
1. User tap "Add to Cart" trong ProductGrid

2. cart.addItem(...)
   → items.append(newItem)
   → @Published items willSet
   → objectWillChange.send()        ← ObservableObject protocol

3. ShopScreen có @StateObject var cart
   → nhận objectWillChange signal
   → ShopScreen.body re-render       ← @StateObject observe

4. ProductGrid có @ObservedObject var cart
   → nhận objectWillChange signal
   → ProductGrid.body re-render      ← @ObservedObject observe

5. CartSummary có @ObservedObject var cart
   → nhận objectWillChange signal
   → CartSummary.body re-render      ← @ObservedObject observe
   → hiển thị items count mới + total mới
```

---

## 10. iOS 17+ — `@Observable` thay thế cả hai

```swift
// CŨ:
class Cart: ObservableObject {         // ← Protocol
    @Published var items: [Item] = []  // ← Phải đánh dấu từng property
}

struct ShopView: View {
    @StateObject var cart = Cart()     // ← TẠO
}

struct CartView: View {
    @ObservedObject var cart: Cart     // ← MƯỢN
}

// MỚI (iOS 17+):
@Observable                            // ← Macro thay ObservableObject + @Published
class Cart {
    var items: [Item] = []             // ← Tự động tracked
}

struct ShopView: View {
    @State var cart = Cart()           // ← TẠO (thay @StateObject)
}

struct CartView: View {
    var cart: Cart                     // ← MƯỢN (thay @ObservedObject)
    // Không cần property wrapper — SwiftUI tự detect @Observable
}
```

```
              ObservableObject era        @Observable era (iOS 17+)
              ─────────────────────       ──────────────────────────
Protocol      ObservableObject            @Observable (macro)
Signal        @Published (từng prop)      Tự động (tất cả var)
Tạo + own     @StateObject                @State
Mượn          @ObservedObject             var (thường)
Environment   @EnvironmentObject          @Environment(Type.self)
Granularity   Per-object (coarse)         Per-property (fine) ✅
```

---

## 11. Bảng so sánh tổng hợp

```
                    ObservableObject              @ObservedObject
                    ────────────────              ───────────────
Loại                Protocol                      Property Wrapper
Dùng trên           class declaration             View property
Khai báo            class VM: ObservableObject    @ObservedObject var vm: VM
Vai trò             "Tôi CÓ THỂ được observe"    "Tôi ĐANG observe object"
Thuộc framework     Combine                       SwiftUI
Cung cấp gì         objectWillChange publisher    Subscribe vào objectWillChange
Một mình đủ?        ❌ Cần observer trong View     ❌ Cần object conform protocol
Quan hệ             Được observe BỞI              Observe object
Số lượng            1 class conform               Nhiều Views observe cùng class
Tương tự            "Trackable" (khả năng)        "Tracking" (hành động)
Nhớ bằng            "-ABLE" = khả năng            "-ED" = đang thực hiện
iOS 17+ thay thế    @Observable macro             var thường (cho @Observable)
```

Hai keyword này hay bị nhầm vì tên gần giống, nhưng **không cùng loại**, Huy. Ba điểm cốt lõi:

**Khác nhau hoàn toàn về bản chất:** `ObservableObject` là **protocol** trên class — khai báo "class này CÓ THỂ được quan sát" (cung cấp `objectWillChange` publisher). `@ObservedObject` là **property wrapper** trên property trong View — thực hiện "tôi ĐANG quan sát object này" (subscribe vào `objectWillChange`). Cách nhớ: **"-ABLE"** = khả năng (protocol), **"-ED"** = đang thực hiện (property wrapper).

**Phải có CẢ HAI mới hoạt động.** Class conform `ObservableObject` mà không có `@ObservedObject`/`@StateObject` trong View → `objectWillChange` phát signal nhưng không ai nghe → UI không update. Ngược lại, `@ObservedObject` trên property mà class không conform `ObservableObject` → compile error. Chúng là **hai mảnh ghép bổ sung**: một bên phát signal, một bên lắng nghe.

**Luồng hoạt động:** `@Published` property thay đổi → trigger `objectWillChange.send()` (do `ObservableObject` protocol cung cấp) → `@ObservedObject` trong View đang subscribe publisher này → nhận signal → SwiftUI re-render View. Một class `ObservableObject` có thể được observe bởi **nhiều Views** cùng lúc qua `@ObservedObject` — tất cả đều re-render khi bất kỳ `@Published` property thay đổi.
