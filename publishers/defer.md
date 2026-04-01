# `defer` trong Swift & Ứng dụng trong SwiftUI

Huy, thực tế **không có type `Deferred` riêng** trong SwiftUI. Cái bạn đang hỏi nhiều khả năng thuộc một trong hai chủ đề:

1. **`defer` keyword** của Swift — dùng trong các hàm/scope liên quan đến SwiftUI
2. **Deferred View Initialization** — pattern trì hoãn khởi tạo View (LazyView)

Mình sẽ giải thích chi tiết cả hai.

---

## 1. `defer` keyword trong Swift

`defer` định nghĩa một block code sẽ **luôn được thực thi khi scope hiện tại kết thúc**, bất kể scope đó thoát ra bằng cách nào (return sớm, throw error, hay chạy hết bình thường).

### Cú pháp cơ bản

```swift
func processData() {
    let file = openFile()
    defer {
        closeFile(file) // Luôn được gọi khi thoát hàm
    }
    
    guard let data = readData(file) else { return } // defer vẫn chạy
    
    if data.isEmpty { throw DataError.empty } // defer vẫn chạy
    
    // Xử lý data...
    // defer vẫn chạy khi hàm kết thúc bình thường
}
```

### Thứ tự thực thi — Stack LIFO

Khi có **nhiều `defer`**, chúng thực thi theo thứ tự **ngược lại** (defer sau chạy trước):

```swift
func example() {
    defer { print("1️⃣ First defer") }
    defer { print("2️⃣ Second defer") }
    defer { print("3️⃣ Third defer") }
    print("Function body")
}
// Output:
// Function body
// 3️⃣ Third defer
// 2️⃣ Second defer
// 1️⃣ First defer
```

### Scope-level — `defer` trong loop & do block

`defer` gắn với **scope gần nhất**, không phải hàm:

```swift
for i in 1...3 {
    defer { print("Deferred \(i)") }
    print("Processing \(i)")
}
// Processing 1 → Deferred 1
// Processing 2 → Deferred 2
// Processing 3 → Deferred 3
```

---

## 2. Ứng dụng `defer` trong SwiftUI Development

### 2.1. Đảm bảo layout update

```swift
func reloadData() {
    defer { self.setNeedsLayout() }
    
    removeAllSubviews()
    
    guard let dataSource = dataSource else { return }
    // Dù return sớm, setNeedsLayout() vẫn được gọi
    
    for item in dataSource.items {
        addSubview(createItemView(item))
    }
}
```

### 2.2. Đảm bảo completion handler luôn được gọi

```swift
func fetchUser(completion: @escaping (Result<User, Error>) -> Void) {
    var result: Result<User, Error>?
    
    defer {
        guard let result = result else {
            completion(.failure(FetchError.unknown))
            return
        }
        completion(result)
    }
    
    guard let url = URL(string: endpoint) else { return }
    // defer đảm bảo completion(.failure) được gọi
    
    // ... networking code
    result = .success(user)
    // defer gọi completion(.success)
}
```

### 2.3. CATransaction / AVCaptureSession

```swift
func animateChanges() {
    CATransaction.begin()
    defer { CATransaction.commit() } // Luôn commit
    
    CATransaction.setAnimationDuration(0.5)
    layer.opacity = 0.2
    layer.cornerRadius = 16
}

func setupCamera() {
    session.beginConfiguration()
    defer { session.commitConfiguration() } // Luôn commit config
    
    do {
        let input = try AVCaptureDeviceInput(device: device)
        session.addInput(input)
    } catch {
        return // defer vẫn commit
    }
}
```

### 2.4. Debugging / Logging trong ViewModel

```swift
class ArticleViewModel: ObservableObject {
    @Published var articles: [Article] = []
    
    func loadArticles() async {
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime
            print("📊 loadArticles took \(elapsed)s")
        }
        
        guard let url = URL(string: apiEndpoint) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            articles = try JSONDecoder().decode([Article].self, from: data)
        } catch {
            print("Error: \(error)")
        }
    }
}
```

---

## 3. Deferred View Initialization (LazyView Pattern)

Đây là pattern quan trọng hơn trong ngữ cảnh SwiftUI. Vấn đề: SwiftUI có thể **khởi tạo view ngay lập tức** dù chưa hiển thị.

### Vấn đề

```swift
// ❌ DetailView được init NGAY khi body được evaluate
.sheet(isPresented: $showDetail) {
    DetailView(viewModel: DetailViewModel()) // init ngay!
}

NavigationLink(destination: HeavyView()) {
    Text("Go") // HeavyView() init ngay!
}
```

### Giải pháp: LazyView wrapper

```swift
struct LazyView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: some View {
        build() // Chỉ gọi khi view thực sự cần render
    }
}
```

### Sử dụng

```swift
// ✅ DetailView chỉ init khi sheet thực sự hiển thị
.sheet(isPresented: $showDetail) {
    LazyView(DetailView(viewModel: DetailViewModel()))
}

// ✅ HeavyView chỉ init khi navigate đến
NavigationLink(destination: LazyView(HeavyView())) {
    Text("Go")
}

// ✅ Trong TabView
TabView {
    LazyView(HomeView())
        .tabItem { Label("Home", systemImage: "house") }
    LazyView(ProfileView())
        .tabItem { Label("Profile", systemImage: "person") }
}
```

### Kết hợp với `@autoclosure` nâng cao

```swift
struct DeferredView<Content: View>: View {
    @State private var shouldRender = false
    let content: () -> Content
    
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        if shouldRender {
            content()
        } else {
            Color.clear.onAppear {
                shouldRender = true
            }
        }
    }
}
```

Pattern này **chỉ khởi tạo content khi view thực sự xuất hiện trên screen**, hữu ích cho các view có init nặng (fetch API, query DB, tính toán phức tạp).

---

## Tóm tắt

| Khái niệm | Mục đích | Khi nào dùng |
|---|---|---|
| `defer` keyword | Cleanup code khi thoát scope | Begin/commit transactions, close files, đảm bảo callback |
| LazyView pattern | Trì hoãn khởi tạo View | Sheet, NavigationLink, TabView với view nặng |
| DeferredView | Chỉ render khi onAppear | View phụ thuộc API/DB, tối ưu performance |

Bạn đang quan tâm cụ thể đến phần nào — `defer` keyword hay deferred view initialization?
