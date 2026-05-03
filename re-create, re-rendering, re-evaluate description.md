# SwiftUI View là "description", không phải "view thật"

Đây là một trong những concept quan trọng nhất của SwiftUI, và cũng là chỗ nhiều iOS dev (kể cả người đã làm SwiftUI 2-3 năm) hiểu sai. Khi nắm được ý này, rất nhiều "magic" của SwiftUI trở nên hợp lý.

---

## 1. Mental model cũ (UIKit) vs mới (SwiftUI)

### UIKit — view là object thật

```swift
let label = UILabel()
label.text = "Hello"
label.textColor = .red
view.addSubview(label)
```

Ở đây `label` là **một object cụ thể** trong memory. Nó tồn tại liên tục. Bạn giữ reference, mutate property, và những thay đổi đó **ngay lập tức** phản ánh lên màn hình. Object này có địa chỉ memory, có lifecycle rõ ràng (init → addSubview → removeFromSuperview → deinit).

### SwiftUI — view là "công thức mô tả"

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello")
            .foregroundColor(.red)
    }
}
```

`Text("Hello").foregroundColor(.red)` **không phải là một label đang nằm trên màn hình**. Nó là một **struct giá trị** mô tả "tôi muốn có một text màu đỏ ở đây". 

SwiftUI đọc mô tả này, **rồi mới** tự tạo và quản lý view thật phía sau (thực ra là layer của Core Animation, không phải `UILabel`). Bạn không bao giờ thấy hay chạm trực tiếp vào view thật đó.

**Đây là điểm bản lề:** struct `View` của bạn là **bản thiết kế**, không phải **toà nhà**.

---

## 2. Struct giá trị — hệ quả thực tế

Vì `View` là struct, nó có những đặc tính của value type:

```swift
struct ProfileView: View {
    let username: String
    let age: Int
    
    var body: some View {
        VStack {
            Text(username)
            Text("\(age)")
        }
    }
}
```

Cái struct này **chỉ chứa data thuần** — `username`, `age`, và `body` (cũng là struct). Nó **rất rẻ** để tạo, copy, vứt đi:

- Không có heap allocation (trong đa số trường hợp)
- Không có reference counting
- Không có vtable/method dispatch overhead
- Khi function return, có thể bị compiler optimize hoàn toàn

So với `UIView` — vốn là class kế thừa từ `UIResponder`, có hàng trăm property, có CALayer phía sau, có gesture recognizer array — thì `ProfileView` struct nhẹ hơn cả ngàn lần.

**Vì rẻ như vậy, SwiftUI thoải mái tạo lại nó liên tục.** Đó là toàn bộ design philosophy.

---

## 3. "Body được gọi lại nhiều lần" nghĩa là gì?

Hãy xem ví dụ cụ thể:

```swift
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        print("body evaluated, count = \(count)")  // sẽ thấy in ra rất nhiều
        return VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1
            }
        }
    }
}
```

Mỗi lần bạn nhấn button:

1. `count` đổi giá trị (vì là `@State`).
2. SwiftUI biết `body` của `CounterView` **phụ thuộc vào** `count` → đánh dấu cần re-evaluate.
3. SwiftUI gọi lại getter `body` → bạn thấy `print` chạy.
4. Một struct `VStack { Text(...); Button(...) }` **mới** được tạo ra.
5. SwiftUI **so sánh** struct mới này với lần trước.
6. Phát hiện chỉ `Text` đổi nội dung → chỉ update **đúng cái CALayer** của text đó. Button không bị động đến.

**Điểm quan trọng nhất:** ở bước 4, một struct view mới được tạo, nhưng ở bước 6, **không có view thật nào bị tạo lại**. Cái `UILabel`-tương-đương phía sau text vẫn là cùng một object, chỉ có property `text` của nó được update.

Đó chính là khác biệt giữa **"re-create view"** (sai — tốn kém) và **"re-evaluate description"** (đúng — rẻ).

---

## 4. Một analogy giúp bạn nhớ

Hãy nghĩ SwiftUI như **kiến trúc sư + đội xây dựng**:

- Bạn (developer) đưa **bản vẽ** (struct View) cho kiến trúc sư (SwiftUI).
- Kiến trúc sư đọc bản vẽ, ra lệnh cho đội xây (rendering engine) xây toà nhà thật (CALayer tree).
- Khi state đổi, bạn đưa **bản vẽ mới**. Nhìn có vẻ như bạn vẽ lại từ đầu.
- Nhưng kiến trúc sư **không đập toà nhà cũ đi xây lại**. Ông ta đặt 2 bản vẽ cạnh nhau, so sánh (`diff`), thấy "chỉ có cửa sổ tầng 3 đổi màu" → chỉ ra lệnh cho đội xây sơn lại cửa sổ đó.

Bản vẽ rẻ → bạn vẽ lại bao nhiêu lần cũng được. Toà nhà đắt → chỉ sửa những gì cần sửa.

Trong UIKit, **bạn vừa là kiến trúc sư, vừa là đội xây**, vừa cầm bản vẽ vừa cầm búa. Mỗi lần state đổi bạn phải tự đập tự sửa bằng tay (`label.text = newValue`). Đó là lý do code UIKit dài hơn và dễ sai hơn.

---

## 5. Những hệ quả mà senior cần nắm

### a) `body` phải pure — không có side effect

```swift
// ❌ SAI — body bị gọi nhiều lần, request sẽ chạy nhiều lần
var body: some View {
    apiClient.fetchData()  // KHÔNG BAO GIỜ làm vậy
    return Text(data)
}

// ❌ Cũng sai — log analytics mỗi lần re-render
var body: some View {
    Analytics.log("ProfileView shown")
    return Text(...)
}

// ✅ ĐÚNG — side effect đặt vào lifecycle modifier
var body: some View {
    Text(data)
        .task { await loadData() }
        .onAppear { Analytics.log("ProfileView shown") }
}
```

Vì bạn **không kiểm soát** được khi nào `body` chạy. SwiftUI có thể gọi nó 1 lần, 10 lần, hay 100 lần — đó là chi tiết implementation.

### b) Đừng làm việc nặng trong `body`

```swift
// ❌ SAI
var body: some View {
    let sortedItems = items.sorted { $0.priority > $1.priority }  // chạy mỗi re-render
    let filtered = sortedItems.filter { $0.isActive }
    return List(filtered) { ... }
}

// ✅ ĐÚNG — computed lazily hoặc cache trong @State/@Observable
var sortedAndFiltered: [Item] {
    items.sorted { $0.priority > $1.priority }.filter { $0.isActive }
}
```

Vẫn còn chạy mỗi lần body evaluate, nhưng ít nhất tách ra để dễ optimize (ví dụ chuyển sang lazy property của model).

### c) `init` cũng được gọi lại nhiều lần

```swift
struct ChildView: View {
    init(value: Int) {
        print("ChildView init")  // sẽ thấy in nhiều lần
        self.value = value
    }
    let value: Int
    var body: some View { Text("\(value)") }
}
```

Mỗi lần parent re-evaluate `body`, một struct `ChildView` mới được tạo → `init` chạy. Đây là lý do **không bao giờ** khởi tạo `ObservableObject` trong init theo cách thông thường — phải dùng `@StateObject` để SwiftUI quản lý lifecycle thay bạn:

```swift
// ❌ SAI — viewModel bị tạo mới mỗi lần parent re-render → state mất
struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    init(userId: String) {
        self.viewModel = ProfileViewModel(userId: userId)  // tai họa
    }
}

// ✅ ĐÚNG
struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    
    init(userId: String) {
        // _viewModel là wrapper; closure chỉ chạy LẦN ĐẦU
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
    }
}
```

`@StateObject` lưu object vào storage do SwiftUI quản lý — vượt qua lifecycle của struct view. Struct bị vứt đi tạo lại liên tục, nhưng object vẫn nguyên vẹn.

### d) State được lưu ở đâu nếu struct bị vứt liên tục?

Câu hỏi rất hợp lý: nếu `ContentView` là struct và bị tạo lại mỗi re-render, thì `@State private var count = 0` không lẽ reset về 0 mỗi lần?

**Không.** Đây là phần "magic" của property wrapper. `@State` không thực sự lưu data trong struct — nó lưu vào một **storage riêng** do SwiftUI quản lý, được gắn với **identity** của view tại vị trí đó trong tree. Struct view chỉ giữ một con trỏ tới storage đó.

```swift
@State private var count = 0
//  ↑ value = 0 chỉ là default, dùng MỘT LẦN khi tạo storage
//    Lần re-evaluate sau, struct mới tạo, nhưng @State đọc giá trị
//    đã được lưu trong SwiftUI storage → không bị reset
```

Đó là lý do vì sao `@State` chỉ được dùng cho **value type đơn giản** (Int, Bool, String, struct nhỏ) và phải `private` — nó là local state được SwiftUI hộ tống qua các lần re-render.

### e) Hiểu được "view diffing" là gì

Mỗi lần body evaluate xong, SwiftUI có cây mới và cây cũ. Nó **diff** 2 cây để biết update gì. Quá trình diff dựa vào:

- **Type của view** ở mỗi vị trí. Nếu `if-else` chuyển từ `TextView` sang `ImageView` ở cùng vị trí → SwiftUI hiểu là "view khác", destroy cái cũ, tạo cái mới, **state bị mất**.
- **Position trong cây** (structural identity).
- **`.id()` modifier** (explicit identity) nếu có.

Đây là lý do vì sao `if condition { A() } else { B() }` khác hẳn với `(condition ? A() : B())` về mặt animation và state preservation, và vì sao `ForEach` cần `id` ổn định.

---

## 6. Nhìn lại — tại sao thiết kế kiểu này

Apple chọn mental model "view as description" vì:

1. **Declarative**: bạn mô tả "UI nên trông như thế nào tại trạng thái này", không phải "khi event X xảy ra, làm Y, Z, W để update UI". Code ngắn hơn, ít bug "UI lệch state".
2. **Diffing rẻ trên struct value type**: so sánh 2 struct nhanh, predictable. Không có cyclic reference, không có aliasing.
3. **Đa nền tảng**: cùng một bản vẽ có thể được render thành UIKit (iOS), AppKit (macOS), hoặc thậm chí Metal layer trực tiếp (visionOS). Vì bản vẽ tách rời khỏi view thật.
4. **Compiler optimization**: struct + generic + `@frozen` + `some View` cho phép Swift compiler inline rất aggressive. Cây view khổng lồ trong code có thể compile ra binary rất gọn.

---

## Kiểm tra lại cách hiểu

Sau khi đọc xong, bạn nên trả lời được các câu sau ngay:

1. Nếu mình `print` trong `body`, nó in ra mấy lần khi user nhấn 1 button làm đổi state?
2. Tại sao `@StateObject` tồn tại khi đã có `@ObservedObject`?
3. Tại sao không nên gọi network request trong `body`?
4. Khi state đổi, có phải tất cả `UILabel` phía sau bị tạo lại không?
5. `@State var x = 0` — tại sao `x` không bị reset về 0 sau mỗi re-render mặc dù struct bị tạo lại?

Nếu câu nào còn thấy mơ hồ, mình giải thích sâu thêm. Hoặc bạn muốn mình đi tiếp sang **View Identity** (structural vs explicit) — đây là phần xây trên nền concept này và là chìa khóa hiểu animation, transition, và state preservation trong SwiftUI?
