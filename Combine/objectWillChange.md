# SwiftUI: `objectWillChange` — Giải thích chi tiết

## 1. Bản chất — Publisher báo hiệu "tôi SẮP thay đổi"

`objectWillChange` là **Combine publisher** được `ObservableObject` protocol cung cấp. Nó phát signal **TRƯỚC** khi bất kỳ `@Published` property nào thay đổi, cho SwiftUI biết cần re-render.

```swift
protocol ObservableObject: AnyObject {
    associatedtype ObjectWillChangePublisher: Publisher
        where ObjectWillChangePublisher.Failure == Never
    
    var objectWillChange: ObjectWillChangePublisher { get }
    //  ↑ Publisher phát Void signal trước mỗi thay đổi
}
```

### Tên nói lên tất cả

```
objectWillChange
  ↑       ↑
  object  WILL change (SẮP thay đổi, chưa thay đổi)
          không phải "did change"
```

---

## 2. Tự động Synthesize — Không cần viết

Khi class conform `ObservableObject`, Swift **tự động tạo** `objectWillChange` publisher:

```swift
class UserVM: ObservableObject {
    @Published var name = ""
    @Published var age = 0
    // objectWillChange được TỰ ĐỘNG TẠO
    // Type: ObservableObjectPublisher (typealias cho PassthroughSubject<Void, Never>)
}

let vm = UserVM()
print(type(of: vm.objectWillChange))
// ObservableObjectPublisher
// = PassthroughSubject<Void, Never>
// Output = Void (không mang data, chỉ là signal)
// Failure = Never (không bao giờ fail)
```

---

## 3. Cơ chế hoạt động — @Published trigger objectWillChange

### Luồng tự động

```swift
class VM: ObservableObject {
    @Published var count = 0
}

let vm = VM()
vm.count = 5
```

```
vm.count = 5
     │
     ▼
@Published var count — willSet fires
     │
     ▼
objectWillChange.send()        ← TỰ ĐỘNG, trước khi count thay đổi
     │
     ▼
SwiftUI nhận signal → schedule re-render
     │
     ▼
count thực sự thay đổi: 0 → 5
     │
     ▼
SwiftUI re-render body → đọc count = 5 → UI hiển thị 5
```

### Timing: willSet, KHÔNG phải didSet

```swift
class VM: ObservableObject {
    @Published var name = "Old"
}

let vm = VM()

vm.objectWillChange
    .sink { 
        print("Signal received!")
        print("Current name: \(vm.name)")    // ← vẫn là giá trị CŨ
    }
    .store(in: &cancellables)

vm.name = "New"
// Output:
// Signal received!
// Current name: Old     ← CHƯA thay đổi tại thời điểm signal!
//
// Sau đó name mới = "New"
```

```
Timeline:
──── objectWillChange.send() ──── name = "New" ────
     ↑ signal phát                ↑ giá trị thay đổi
     ↑ name VẪN = "Old"          ↑ BÂY GIỜ name = "New"
```

### Tại sao "will" thay vì "did"?

SwiftUI dùng **willSet** vì cần **schedule re-render trước** khi giá trị thay đổi. Khi body chạy lại, giá trị **đã thay đổi xong** → body đọc giá trị mới. Nếu dùng didSet, có thể xảy ra race condition giữa signal và render.

---

## 4. Một publisher cho TẤT CẢ properties

`objectWillChange` là **1 publisher DUY NHẤT** cho toàn bộ object — không phân biệt property nào thay đổi:

```swift
class ProfileVM: ObservableObject {
    @Published var name = ""           // thay đổi → objectWillChange.send()
    @Published var email = ""          // thay đổi → objectWillChange.send()
    @Published var avatar: UIImage?    // thay đổi → objectWillChange.send()
    @Published var isLoading = false   // thay đổi → objectWillChange.send()
}
```

```
name thay đổi ──┐
email thay đổi ──┼──▶ objectWillChange.send()  ──▶ TẤT CẢ views re-render
avatar thay đổi ─┤      (cùng 1 publisher)
isLoading đổi ───┘
```

**Hệ quả:** Thay đổi `isLoading` → view chỉ hiển thị `name` CŨNG re-render (dù không dùng `isLoading`). Đây là hạn chế **coarse-grained** của `ObservableObject` → iOS 17+ `@Observable` khắc phục bằng per-property tracking.

---

## 5. Subscribe thủ công — Lắng nghe objectWillChange bằng Combine

### Cơ bản

```swift
let vm = ProfileVM()

vm.objectWillChange
    .sink { _ in
        // ← Gọi mỗi khi BẤT KỲ @Published property SẮP thay đổi
        print("VM is about to change")
    }
    .store(in: &cancellables)

vm.name = "Huy"     // "VM is about to change"
vm.email = "a@b.c"  // "VM is about to change"
```

### Debounce nhiều thay đổi liên tiếp

```swift
// Nhiều property thay đổi gần nhau → gộp thành 1 signal
vm.objectWillChange
    .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
    .sink { _ in
        print("VM settled — save now")
        self.autoSave()
    }
    .store(in: &cancellables)

vm.name = "Huy"       // signal 1
vm.email = "h@e.com"  // signal 2 (ngay sau signal 1)
vm.age = 25            // signal 3 (ngay sau signal 2)
// debounce 100ms → chỉ 1 lần "VM settled — save now"
```

### Đếm số lần thay đổi

```swift
vm.objectWillChange
    .scan(0) { count, _ in count + 1 }
    .sink { count in
        print("Change #\(count)")
    }
    .store(in: &cancellables)
```

### Trigger side effect (auto-save, analytics)

```swift
class DocumentVM: ObservableObject {
    @Published var title = ""
    @Published var content = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Auto-save 2 giây sau thay đổi cuối cùng
        objectWillChange
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellables)
    }
    
    private func save() {
        print("Auto-saving: \(title)")
    }
}

// User gõ title liên tục → debounce → save 1 lần sau khi ngừng gõ 2s
```

---

## 6. Custom objectWillChange — Override publisher tự động

### Khi nào cần custom?

Mặc định, **mọi @Published** trigger `objectWillChange`. Đôi khi cần:
- Chỉ notify khi **một số property cụ thể** thay đổi
- Thêm **logic filtering** trước khi notify
- Dùng **publisher type khác**

### Override objectWillChange

```swift
class SelectiveVM: ObservableObject {
    // Custom publisher — TỰ QUẢN LÝ khi nào notify
    let objectWillChange = ObservableObjectPublisher()
    //  ↑ Khai báo tường minh → compiler KHÔNG tự synthesize
    //    → @Published KHÔNG tự trigger nữa
    //    → Phải gọi objectWillChange.send() THỦ CÔNG
    
    var name = "" {
        willSet { objectWillChange.send() }
        // ↑ Notify khi name thay đổi ✅
    }
    
    var email = "" {
        willSet { objectWillChange.send() }
        // ↑ Notify khi email thay đổi ✅
    }
    
    var internalCache: [String: Data] = [:]
    // ↑ KHÔNG gọi objectWillChange.send()
    // → Thay đổi cache KHÔNG trigger re-render ✅ (tiết kiệm)
}
```

### Selective notification — Chỉ notify khi giá trị THỰC SỰ khác

```swift
class SmartVM: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    var score: Int = 0 {
        willSet {
            // Chỉ notify khi giá trị THỰC SỰ thay đổi
            if newValue != score {
                objectWillChange.send()
            }
        }
    }
    
    // Không notify nếu: score = 5, rồi set score = 5 lần nữa
    // Mặc định @Published vẫn notify dù giá trị giống nhau
}
```

### Throttled notification

```swift
class HighFrequencyVM: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    //                      ↑ PassthroughSubject thay vì ObservableObjectPublisher
    //                        (cùng type signature: <Void, Never>)
    
    private var throttledPublisher: AnyCancellable?
    private let _willChange = PassthroughSubject<Void, Never>()
    
    var sensorValue: Double = 0 {
        willSet { _willChange.send() }
    }
    
    init() {
        // Throttle: tối đa 10 updates/giây cho UI
        throttledPublisher = _willChange
            .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }
}
// Sensor update 100 lần/giây → UI chỉ re-render 10 lần/giây
```

---

## 7. @Published vs Manual willSet — Khi nào cần custom

### @Published (tự động) — Đủ cho 90% trường hợp

```swift
class SimpleVM: ObservableObject {
    @Published var name = ""      // tự trigger objectWillChange
    @Published var items: [Item] = []
    @Published var isLoading = false
    // Không cần viết gì thêm — @Published xử lý tất cả
}
```

### Manual willSet (custom) — Khi cần kiểm soát

```swift
class AdvancedVM: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    // ← Khai báo tường minh = @Published KHÔNG tự trigger nữa
    
    // Property CẦN notify UI
    var items: [Item] = [] {
        willSet { objectWillChange.send() }
    }
    
    // Property KHÔNG cần notify (internal state)
    var fetchTask: Task<Void, Never>?
    var retryCount = 0
    var lastFetchDate: Date?
    // ← Không có willSet → thay đổi IM LẶNG → không re-render thừa
    
    // Property notify CÓ ĐIỀU KIỆN
    var progress: Double = 0 {
        willSet {
            // Chỉ notify khi thay đổi > 1% (tránh re-render quá nhiều)
            if abs(newValue - progress) > 0.01 {
                objectWillChange.send()
            }
        }
    }
}
```

### So sánh

```
@Published (tự động):
  ✅ Gọn, không boilerplate
  ✅ Tự trigger objectWillChange
  ✅ Có Combine Publisher ($property)
  ❌ KHÔNG kiểm soát được khi nào notify
  ❌ Notify dù giá trị giống nhau
  ❌ Mọi @Published đều trigger → có thể re-render thừa

Manual willSet (custom):
  ✅ Kiểm soát chính xác khi nào notify
  ✅ Có thể filter (chỉ notify khi giá trị khác)
  ✅ Có thể throttle / debounce
  ✅ Property không cần notify → không willSet → không re-render
  ❌ Boilerplate nhiều hơn
  ❌ Không có Combine Publisher ($property)
  ❌ Dễ quên gọi send() → UI không update
```

---

## 8. objectWillChange trong SwiftUI lifecycle

### SwiftUI subscribe tự động

```swift
struct ProfileView: View {
    @ObservedObject var vm: ProfileVM
    // ← SwiftUI TỰ ĐỘNG subscribe vm.objectWillChange
    //   Không cần viết .sink() hay .onReceive()
    
    var body: some View {
        Text(vm.name)
        // objectWillChange.send() → SwiftUI re-render body
    }
}
```

### .onReceive — Subscribe thủ công trong View

```swift
struct DebugView: View {
    @ObservedObject var vm: ProfileVM
    
    var body: some View {
        Text(vm.name)
            .onReceive(vm.objectWillChange) { _ in
                // ← Gọi MỖI LẦN objectWillChange phát
                print("VM is changing at \(Date())")
            }
    }
}
```

### Nhiều objects → Nhiều objectWillChange

```swift
struct DashboardView: View {
    @ObservedObject var userVM: UserVM
    @ObservedObject var cartVM: CartVM
    @ObservedObject var settingsVM: SettingsVM
    
    // SwiftUI subscribe CẢ 3 objectWillChange
    // Bất kỳ VM nào thay đổi → DashboardView re-render
    
    var body: some View {
        VStack {
            Text(userVM.name)          // từ userVM
            Text("\(cartVM.itemCount)") // từ cartVM
            Toggle("Dark", isOn: $settingsVM.isDark) // từ settingsVM
        }
    }
}
```

```
userVM.objectWillChange ──┐
cartVM.objectWillChange ──┼──▶ DashboardView.body re-render
settingsVM.objectWillChange──┘
```

---

## 9. objectWillChange và @Published kết hợp Combine

### Dùng objectWillChange cho "bất kỳ thay đổi nào"

```swift
class FormVM: ObservableObject {
    @Published var field1 = ""
    @Published var field2 = ""
    @Published var field3 = ""
    
    @Published private(set) var isDirty = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // "Bất kỳ field nào thay đổi → đánh dấu dirty"
        objectWillChange
            .first()    // chỉ cần biết LẦN ĐẦU thay đổi
            .sink { [weak self] _ in
                self?.isDirty = true
            }
            .store(in: &cancellables)
    }
}
```

### Dùng $published cho property CỤ THỂ

```swift
class SearchVM: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [Item] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // $query cho pipeline search (property cụ thể)
        $query
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { [weak self] q -> AnyPublisher<[Item], Never> in
                guard let self, !q.isEmpty else { return Just([]).eraseToAnyPublisher() }
                return self.search(q)
            }
            .assign(to: &$results)
        
        // objectWillChange cho logging (bất kỳ thay đổi)
        objectWillChange
            .sink { _ in print("SearchVM changed") }
            .store(in: &cancellables)
    }
}
```

### So sánh $property vs objectWillChange

```
$property (Published.Publisher):
  → Phát GIARÁ TRỊ MỚI của property CỤ THỂ
  → Output = property type (String, Int, [Item]...)
  → Dùng cho: debounce, map, filter trên 1 property

objectWillChange (ObservableObjectPublisher):
  → Phát Void signal cho BẤT KỲ property nào
  → Output = Void (không mang data)
  → Dùng cho: "có gì đó thay đổi" — auto-save, dirty flag, logging
```

```swift
vm.$name         // Published<String>.Publisher → phát "Huy", "John"...
vm.objectWillChange  // PassthroughSubject<Void, Never> → phát (), ()...
```

---

## 10. Ví dụ thực tế hoàn chỉnh — Auto-save Document

```swift
class DocumentVM: ObservableObject {
    @Published var title = "Untitled"
    @Published var content = ""
    @Published var tags: [String] = []
    @Published private(set) var lastSaved: Date?
    @Published private(set) var hasUnsavedChanges = false
    
    private var cancellables = Set<AnyCancellable>()
    private let saveService: SaveService
    
    init(saveService: SaveService = .shared) {
        self.saveService = saveService
        
        // 1. Đánh dấu dirty khi BẤT KỲ thay đổi (objectWillChange)
        objectWillChange
            .map { _ in true }
            .assign(to: &$hasUnsavedChanges)
        
        // 2. Auto-save 3 giây sau thay đổi cuối (objectWillChange + debounce)
        objectWillChange
            .debounce(for: .seconds(3), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellables)
        
        // 3. Validate title riêng ($title — property cụ thể)
        $title
            .removeDuplicates()
            .sink { [weak self] title in
                if title.isEmpty {
                    self?.title = "Untitled"
                }
            }
            .store(in: &cancellables)
    }
    
    func save() {
        let doc = Document(title: title, content: content, tags: tags)
        saveService.save(doc)
        lastSaved = Date()
        hasUnsavedChanges = false
    }
}
```

```
User gõ title: "My Doc"
  → @Published title willSet → objectWillChange.send()
  → hasUnsavedChanges = true (pipeline 1)
  → debounce timer reset (pipeline 2)

User gõ content: "Hello world"
  → @Published content willSet → objectWillChange.send()
  → debounce timer reset lại

User ngừng gõ 3 giây
  → debounce fire → save()
  → lastSaved = now, hasUnsavedChanges = false
```

---

## 11. Sai lầm thường gặp

### ❌ Gọi objectWillChange.send() SAU khi thay đổi

```swift
// ❌ Send sau khi đổi → SwiftUI có thể đọc giá trị CŨ
var name = "" {
    didSet {
        objectWillChange.send()    // ❌ didSet = SAU khi đổi
    }
}

// ✅ Send TRƯỚC khi đổi
var name = "" {
    willSet {
        objectWillChange.send()    // ✅ willSet = TRƯỚC khi đổi
    }
}
```

### ❌ Khai báo objectWillChange tường minh nhưng vẫn dùng @Published

```swift
// ❌ Confusing: custom objectWillChange + @Published
class BadVM: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    // ↑ Khai báo tường minh → @Published KHÔNG tự trigger
    
    @Published var name = ""
    // ↑ @Published KHÔNG trigger objectWillChange vì đã custom
    // → name thay đổi nhưng UI KHÔNG update!
}

// ✅ Chọn MỘT trong hai:
// Option A: dùng @Published (tự động, phổ biến nhất)
class GoodVM_A: ObservableObject {
    @Published var name = ""    // tự trigger objectWillChange
}

// Option B: dùng custom objectWillChange (thủ công)
class GoodVM_B: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    var name = "" { willSet { objectWillChange.send() } }
}
```

### ❌ Quên rằng objectWillChange phát Void

```swift
// ❌ Cố đọc giá trị mới từ objectWillChange
vm.objectWillChange
    .sink { value in
        // value là Void — KHÔNG chứa data
        // Không biết property NÀO thay đổi, giá trị MỚI là gì
    }

// ✅ Nếu cần biết property cụ thể → dùng $property
vm.$name
    .sink { newName in
        print("Name changed to: \(newName)")
    }
```

### ❌ objectWillChange.send() từ background thread

```swift
// ❌ UI update phải trên main thread
DispatchQueue.global().async {
    self.objectWillChange.send()    // ❌ background thread
    self.name = "New"
}

// ✅ Ensure main thread
DispatchQueue.main.async {
    self.objectWillChange.send()    // ✅ main thread
    self.name = "New"
}

// Hoặc dùng @Published + receive(on:) — @Published tự handle
```

---

## 12. Tóm tắt

| Khía cạnh | Chi tiết |
|---|---|
| **Là gì?** | Combine publisher trong ObservableObject — phát signal TRƯỚC mỗi thay đổi |
| **Type** | `ObservableObjectPublisher` = `PassthroughSubject<Void, Never>` |
| **Output** | `Void` — chỉ signal, không mang data property cụ thể |
| **Timing** | **willSet** — phát TRƯỚC khi giá trị thay đổi |
| **Tự động** | @Published properties tự trigger `objectWillChange.send()` |
| **Custom** | Khai báo `let objectWillChange = ObservableObjectPublisher()` → @Published không tự trigger → phải gọi send() thủ công trong willSet |
| **SwiftUI subscribe** | Tự động qua @StateObject / @ObservedObject / @EnvironmentObject |
| **Manual subscribe** | `.onReceive(vm.objectWillChange)` hoặc `vm.objectWillChange.sink { }` |
| **Granularity** | 1 publisher cho TẤT CẢ properties (coarse-grained) |
| **Dùng trong Combine** | Auto-save (debounce), dirty flag, logging, change counting |
| **vs $property** | $property: giá trị cụ thể. objectWillChange: "có gì đó thay đổi" |
| **iOS 17+** | @Observable thay thế — per-property tracking, không cần objectWillChange |

`objectWillChange` là Combine publisher **phát signal TRƯỚC mỗi thay đổi** trong ObservableObject, Huy. Ba điểm cốt lõi:

**Timing: "will" chứ không phải "did".** Signal phát **trước** khi giá trị thay đổi (willSet semantic). Tại thời điểm subscriber nhận signal, property vẫn giữ **giá trị CŨ**. SwiftUI nhận signal → schedule re-render → khi body chạy lại, giá trị đã thay đổi xong → body đọc giá trị mới. Gọi `send()` trong `didSet` (sau khi đổi) là sai lầm phổ biến — SwiftUI có thể đọc giá trị cũ.

**1 publisher cho TẤT CẢ properties — coarse-grained.** Bất kỳ `@Published` property nào thay đổi → cùng 1 `objectWillChange.send()` → tất cả views observe object đều re-render, kể cả views không dùng property đó. Output là `Void` — không biết property nào thay đổi, giá trị mới là gì. Cần biết property cụ thể → dùng `$property` (Published.Publisher). Đây là hạn chế chính → iOS 17 `@Observable` khắc phục bằng per-property tracking.

**Custom objectWillChange — kiểm soát chính xác.** Khai báo `let objectWillChange = ObservableObjectPublisher()` tường minh → `@Published` **KHÔNG tự trigger nữa** → phải gọi `send()` thủ công trong `willSet`. Ứng dụng: property internal (cache, retryCount) không gọi `send()` → không re-render thừa. Property thay đổi liên tục (sensor, progress) → chỉ notify khi thay đổi > ngưỡng. Kết hợp debounce trên objectWillChange → auto-save sau khi user ngừng sửa.
