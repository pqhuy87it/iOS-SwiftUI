# SwiftUI: `@StateObject` vs `@ObservedObject` — So sánh chi tiết

## 1. Một câu cho mỗi keyword

```
@StateObject     → "Tôi TẠO object này. SwiftUI giữ nó sống dù view re-render bao nhiêu lần."
@ObservedObject  → "Tôi MƯỢN object này từ bên ngoài. Tôi không kiểm soát lifecycle."
```

---

## 2. Giống nhau — Rất nhiều

Cả hai đều:

```
✅ Dùng với class conform ObservableObject
✅ Lắng nghe objectWillChange → re-render view khi @Published thay đổi
✅ Cung cấp Binding qua $vm.property
✅ Dùng trong struct View
✅ Khai báo cùng syntax: var vm: SomeViewModel
```

```swift
// Cả hai dùng ĐỐI TƯỢNG GIỐNG NHAU
class CounterVM: ObservableObject {
    @Published var count = 0
}

// @StateObject
struct ViewA: View {
    @StateObject var vm = CounterVM()
    var body: some View {
        Text("\(vm.count)")
        Button("+") { vm.count += 1 }
    }
}

// @ObservedObject — body code GIỐNG HỆT
struct ViewB: View {
    @ObservedObject var vm: CounterVM
    var body: some View {
        Text("\(vm.count)")
        Button("+") { vm.count += 1 }
    }
}
```

**Về mặt sử dụng hàng ngày (đọc property, gọi method, tạo Binding), hai keyword HOÀN TOÀN GIỐNG NHAU.** Khác biệt nằm ở **lifecycle management**.

---

## 3. Khác nhau — Lifecycle quyết định tất cả

### Vấn đề cốt lõi: View struct bị RE-CREATE liên tục

SwiftUI **tạo lại struct View** mỗi khi parent re-render. Đây là behavior bình thường, không phải bug:

```swift
struct ParentView: View {
    @State private var counter = 0
    
    var body: some View {
        VStack {
            Text("Parent: \(counter)")
            Button("Increment") { counter += 1 }
            
            ChildView()
            // ↑ Mỗi khi counter thay đổi:
            //   1. ParentView.body chạy lại
            //   2. ChildView.init() chạy lại ← QUAN TRỌNG
            //   3. ChildView.body chạy lại
        }
    }
}
```

**Câu hỏi then chốt:** Khi `ChildView.init()` chạy lại, object bên trong có bị **tạo mới** không?

---

## 4. `@StateObject` — BẢO VỆ khỏi re-create

```swift
struct ChildView: View {
    @StateObject var vm = CounterVM()
    //                    ↑ init closure
    
    var body: some View {
        Text("Count: \(vm.count)")
        Button("+") { vm.count += 1 }
    }
}
```

### Lần render đầu tiên

```
ParentView.body → ChildView.init()
  @StateObject: "Lần đầu tiên → tạo CounterVM #1, lưu vào SwiftUI storage"
  ChildView.body → hiển thị với VM #1
  vm.count = 0
```

### Parent re-render (counter thay đổi)

```
ParentView.body → ChildView.init()
  @StateObject: "ĐÃ có VM trong storage → BỎ QUA init closure, dùng VM #1 CŨ"
  ChildView.body → hiển thị với VM #1 (GIỮ NGUYÊN)
  vm.count = 5  ← giá trị từ lần tap trước, KHÔNG reset
```

### ChildView bị remove rồi appear lại

```
ChildView bị remove (if condition = false)
  → VM #1 bị dealloc (deinit chạy)

ChildView appear lại (if condition = true)
  → @StateObject tạo CounterVM #2 (instance MỚI)
  → vm.count = 0 (reset)
```

### Timeline

```
Parent render #1: @StateObject tạo VM #1      count=0
Parent render #2: @StateObject giữ VM #1       count=5 ✅ (giữ nguyên)
Parent render #3: @StateObject giữ VM #1       count=12 ✅ (giữ nguyên)
  ...
Parent render #N: @StateObject giữ VM #1       count=42 ✅ (giữ nguyên)
ChildView remove: VM #1 dealloc
ChildView appear: @StateObject tạo VM #2       count=0 (mới hoàn toàn)
```

---

## 5. `@ObservedObject` — KHÔNG BẢO VỆ

```swift
struct ChildView: View {
    @ObservedObject var vm = CounterVM()
    //                       ↑ init expression
    
    var body: some View {
        Text("Count: \(vm.count)")
        Button("+") { vm.count += 1 }
    }
}
```

### Lần render đầu tiên

```
ParentView.body → ChildView.init()
  @ObservedObject: tạo CounterVM #1
  ChildView.body → hiển thị với VM #1
  vm.count = 0
```

### Parent re-render ← KHÁC BIỆT SỐNG CÒN

```
ParentView.body → ChildView.init()
  @ObservedObject: tạo CounterVM #2 (MỚI!) ← VM #1 bị thay thế
  ChildView.body → hiển thị với VM #2
  vm.count = 0  ← STATE BỊ RESET! ❌
```

### Timeline — Thảm hoạ

```
Parent render #1: @ObservedObject tạo VM #1     count=0
  user tap +5 lần → count=5
Parent render #2: @ObservedObject tạo VM #2     count=0 ❌ RESET!
  user tap +3 lần → count=3
Parent render #3: @ObservedObject tạo VM #3     count=0 ❌ RESET!
  ...
```

**User tap → count tăng → parent re-render vì bất kỳ lý do nào → count reset về 0.** Bug cực kỳ khó debug vì không phải lúc nào cũng xảy ra — chỉ khi parent re-render.

---

## 6. Minh hoạ trực quan — Cùng scenario

```swift
struct ParentView: View {
    @State private var parentCounter = 0
    
    var body: some View {
        VStack {
            Text("Parent: \(parentCounter)")
            Button("Parent +1") { parentCounter += 1 }
            // ↑ Tap → parentCounter đổi → body chạy lại
            //   → ChildA và ChildB init() chạy lại
            
            ChildA()    // @StateObject
            ChildB()    // @ObservedObject
        }
    }
}

struct ChildA: View {
    @StateObject var vm = CounterVM()    // ← BẢO VỆ
    var body: some View {
        HStack {
            Text("A: \(vm.count)")
            Button("+") { vm.count += 1 }
        }
    }
}

struct ChildB: View {
    @ObservedObject var vm = CounterVM() // ← KHÔNG BẢO VỆ
    var body: some View {
        HStack {
            Text("B: \(vm.count)")
            Button("+") { vm.count += 1 }
        }
    }
}
```

```
Bước 1: Mở app
  ChildA: A: 0      ChildB: B: 0

Bước 2: Tap "A +" 3 lần, "B +" 3 lần
  ChildA: A: 3      ChildB: B: 3

Bước 3: Tap "Parent +1" ← parent re-render
  ChildA: A: 3 ✅    ChildB: B: 0 ❌  ← RESET!
                      ↑ @ObservedObject tạo VM MỚI

Bước 4: Tap "B +" 2 lần
  ChildA: A: 3       ChildB: B: 2

Bước 5: Tap "Parent +1" lần nữa
  ChildA: A: 3 ✅    ChildB: B: 0 ❌  ← RESET LẦN NỮA!
```

---

## 7. Cách dùng ĐÚNG từng keyword

### @StateObject: View TẠO object

```swift
// ✅ View tạo và sở hữu ViewModel
struct ProductListScreen: View {
    @StateObject private var vm = ProductListVM()
    //          ↑ private — view này sở hữu
    //                        ↑ init tại chỗ
    
    var body: some View {
        List(vm.products) { product in
            ProductRow(vm: vm, product: product)
            //         ↑ truyền xuống child
        }
        .task { await vm.loadProducts() }
    }
}
```

### @ObservedObject: View NHẬN object từ bên ngoài

```swift
// ✅ View nhận ViewModel từ parent — KHÔNG tự tạo
struct ProductRow: View {
    @ObservedObject var vm: ProductListVM
    //                      ↑ KHÔNG có = init
    //                        nhận từ parameter
    let product: Product
    
    var body: some View {
        HStack {
            Text(product.name)
            Button("Add to Cart") { vm.addToCart(product) }
        }
    }
}
```

### Luồng data

```
ProductListScreen
  @StateObject var vm = ProductListVM()     ← TẠO VÀ SỞ HỮU
       │
       │ truyền vm xuống
       ▼
ProductRow
  @ObservedObject var vm: ProductListVM     ← MƯỢN, KHÔNG TẠO
       │
       │ vm.addToCart(product)
       ▼
  vm.products thay đổi → objectWillChange
       │
       ▼
  CẢ ProductListScreen VÀ ProductRow re-render
```

---

## 8. Quy tắc vàng — 1 câu duy nhất

> **View nào TẠO object → `@StateObject`. View nào NHẬN object → `@ObservedObject`.**

```
Hỏi: View này có gọi init() để tạo object không?

Có (= ClassName())  → @StateObject ✅
Không (nhận qua parameter) → @ObservedObject ✅
```

```swift
// TẠO: có dấu = và init
@StateObject var vm = ProductListVM()         // ✅
@StateObject var vm = ProductListVM(api: api) // ✅

// NHẬN: không có dấu =, nhận qua init parameter
@ObservedObject var vm: ProductListVM         // ✅
```

### Mỗi object chỉ có ĐÚNG MỘT @StateObject

```
@StateObject (1 nơi) ←── source of truth
       │
       ├── @ObservedObject (child 1) ←── mượn
       ├── @ObservedObject (child 2) ←── mượn
       └── @ObservedObject (child 3) ←── mượn
```

---

## 9. @StateObject với Dependency Injection

Khi ViewModel cần parameter → dùng `_stateObject = StateObject(wrappedValue:)` trong init:

```swift
struct UserDetailScreen: View {
    @StateObject private var vm: UserDetailVM
    
    init(userID: String) {
        _vm = StateObject(wrappedValue: UserDetailVM(userID: userID))
        // ↑ _vm truy cập property wrapper bên trong
        //   wrappedValue closure chỉ chạy LẦN ĐẦU SwiftUI render
        //   Parent re-render → closure KHÔNG chạy lại → VM giữ nguyên
    }
    
    var body: some View {
        Text(vm.userName)
            .task { await vm.load() }
    }
}
```

**⚠️ Lưu ý:** Nếu parent thay đổi `userID` và truyền lại → `StateObject` **KHÔNG tạo VM mới** (vì chỉ chạy lần đầu). Cần `.onChange(of: userID)` hoặc `.id(userID)` để force recreate nếu muốn.

---

## 10. @ObservedObject KHÔNG BẢO VỆ — Tại sao vẫn tồn tại?

### Lý do: @ObservedObject ra đời TRƯỚC @StateObject

```
iOS 13 (2019): Chỉ có @ObservedObject — dùng cho mọi trường hợp
iOS 14 (2020): Apple thêm @StateObject — fix vấn đề re-create
```

`@ObservedObject` vẫn tồn tại vì:

```
1. Backward compatibility — code cũ vẫn compile
2. Vai trò "MƯỢN" vẫn đúng — khi nhận object từ parent
3. @StateObject KHÔNG phù hợp cho object nhận từ ngoài
```

### @ObservedObject an toàn KHI nhận từ parent

```swift
// ✅ AN TOÀN: object sống ở parent (@StateObject)
// @ObservedObject chỉ observe, không quản lý lifecycle
struct ChildView: View {
    @ObservedObject var vm: SharedVM    // ← nhận từ parent, KHÔNG init
    // Parent giữ VM bằng @StateObject → VM không bị re-create
    // ChildView re-create → @ObservedObject nhận lại CÙNG VM instance
}

// ❌ NGUY HIỂM: object tạo tại chỗ trong @ObservedObject
struct ChildView: View {
    @ObservedObject var vm = SharedVM() // ← tạo tại chỗ → RE-CREATE mỗi lần
}
```

---

## 11. Edge case: @ObservedObject tạo tại chỗ — Khi nào "tình cờ" hoạt động?

```swift
struct ChildView: View {
    @ObservedObject var vm = CounterVM()
    // ❌ anti-pattern nhưng "tình cờ" hoạt động nếu:
    //   1. Parent KHÔNG BAO GIỜ re-render
    //   2. Hoặc ChildView là ROOT view (không có parent)
    //   3. Hoặc parent re-render nhưng ChildView có .id() cố định
}
```

Đây là lý do bug **khó tìm**: app chạy đúng trong test đơn giản, nhưng fail trong production khi parent re-render do state khác thay đổi.

---

## 12. Kết hợp với @EnvironmentObject

```swift
// @EnvironmentObject hoạt động giống @ObservedObject
// nhưng nhận object từ ENVIRONMENT thay vì PARAMETER

@main
struct MyApp: App {
    @StateObject private var authManager = AuthManager()
    //           ↑ App SỞ HỮU (StateObject)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                // ↑ Inject vào environment
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    // ↑ MƯỢN từ environment (giống @ObservedObject nhưng implicit)
    // KHÔNG tạo mới — nhận instance từ ancestor
    
    var body: some View {
        Text(authManager.currentUser?.name ?? "Guest")
    }
}
```

```
@StateObject (App level) ←── sở hữu, tạo 1 lần
       │
       │ .environmentObject()
       ▼
@EnvironmentObject (bất kỳ descendant) ←── mượn từ environment
       ≈
@ObservedObject (truyền qua parameter) ←── mượn từ parent
```

---

## 13. iOS 17+ — @Observable thay đổi gì?

```swift
// CŨ: ObservableObject
class VM: ObservableObject {
    @Published var name = ""
}

struct ParentView: View {
    @StateObject var vm = VM()           // TẠO → @StateObject
    var body: some View { ChildView(vm: vm) }
}

struct ChildView: View {
    @ObservedObject var vm: VM           // MƯỢN → @ObservedObject
    var body: some View { Text(vm.name) }
}

// MỚI: @Observable
@Observable class VM {
    var name = ""
}

struct ParentView: View {
    @State var vm = VM()                 // TẠO → @State (thay @StateObject)
    var body: some View { ChildView(vm: vm) }
}

struct ChildView: View {
    var vm: VM                           // MƯỢN → var thường (thay @ObservedObject)
    var body: some View { Text(vm.name) }
}
```

```
              ObservableObject         @Observable (iOS 17+)
              ────────────────         ──────────────────────
TẠO object    @StateObject             @State
MƯỢN object   @ObservedObject          var (property thường)
Environment   @EnvironmentObject       @Environment(Type.self)
Re-render     Per-object (coarse)      Per-property (fine) ✅
```

**@StateObject và @ObservedObject vẫn hoạt động** trên iOS 17+ nhưng Apple khuyến khích migrate sang `@Observable` pattern mới.

---

## 14. Bảng so sánh tổng hợp

```
                          @StateObject              @ObservedObject
                          ────────────              ───────────────
View TẠO object?          ✅ Có                     ❌ Không (nhận từ ngoài)
View SỞ HỮU object?       ✅ Có                     ❌ Không (mượn)
Init expression?           = ClassName()             : ClassName (type only)
Bảo vệ khỏi re-create?   ✅ SwiftUI giữ instance   ❌ Tạo mới mỗi parent render
                          cũ qua re-render          (nếu init tại chỗ)
Init closure chạy?        CHỈ LẦN ĐẦU              MỖI LẦN init
Object lifecycle?          Gắn với view identity     Không quản lý
Object dealloc khi?        View bị remove            Khi không còn reference
Re-render trigger?         @Published thay đổi       @Published thay đổi (giống)
Binding ($vm.prop)?        ✅                        ✅ (giống)
Access control?            Thường private            Thường không private (nhận ngoài)
Dùng cho?                  Screen-level ViewModel    Child component nhận VM
Số lượng / object?         ĐÚNG 1 nơi               Nhiều nơi
iOS minimum?               14+                       13+
Thay thế (iOS 17+)?       @State (cho @Observable)  var thường (cho @Observable)
```

---

## 15. Sai lầm và cách tránh

```
❌ @ObservedObject var vm = VM()     → state reset khi parent re-render
✅ @StateObject var vm = VM()        → state giữ nguyên

❌ @StateObject var vm: VM            → nhận từ ngoài nhưng dùng StateObject (sai vai trò)
✅ @ObservedObject var vm: VM         → nhận từ ngoài, observe changes

❌ Nhiều @StateObject cho cùng object → tạo nhiều instance
✅ 1 @StateObject + nhiều @ObservedObject → 1 instance, nhiều observer

❌ @ObservedObject cho object tạo tại chỗ
✅ @StateObject cho object tạo tại chỗ, @ObservedObject cho object nhận
```

