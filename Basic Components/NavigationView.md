# SwiftUI: Navigation — Giải thích chi tiết

## 1. Tổng quan — Hai thế hệ Navigation

```
iOS 13–15: NavigationView          (DEPRECATED từ iOS 16)
iOS 16+:   NavigationStack          (thay thế NavigationView stack)
           NavigationSplitView      (thay thế NavigationView column/sidebar)
```

`NavigationView` vẫn hoạt động nhưng Apple **khuyến cáo chuyển sang API mới**. Bài viết này giải thích cả hai để hiểu legacy code và viết code mới đúng cách.

---

## 2. `NavigationView` (iOS 13–15) — Legacy

### Cơ bản

`NavigationView` là container tạo **navigation hierarchy** — cho phép push/pop view bằng `NavigationLink`.

```swift
NavigationView {
    List(items) { item in
        NavigationLink(destination: DetailView(item: item)) {
            Text(item.name)
        }
    }
    .navigationTitle("Items")
    .navigationBarTitleDisplayMode(.large)
}
```

```
┌─────────────────────────────┐
│ ◀ Back        Items         │  ← Navigation Bar
├─────────────────────────────┤
│ Item 1                    > │  ← NavigationLink
│ Item 2                    > │
│ Item 3                    > │
│                             │
└─────────────────────────────┘
         │ tap Item 2
         ▼
┌─────────────────────────────┐
│ ◀ Items    Item 2 Detail    │  ← Push animation
├─────────────────────────────┤
│ Detail content for Item 2   │
│                             │
└─────────────────────────────┘
```

### NavigationLink (legacy — destination-based)

```swift
// Destination được tạo NGAY khi List render ← performance issue
NavigationLink(destination: DetailView(item: item)) {
    // Label (UI hiển thị trong list)
    HStack {
        Image(systemName: "star")
        Text(item.name)
    }
}
```

### Toolbar & Navigation Bar

```swift
NavigationView {
    List { ... }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)  // .large, .inline, .automatic
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") { showAdd = true }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
}
```

### Hạn chế của NavigationView

```
1. NavigationLink tạo destination view NGAY khi render
   → 100 items = 100 DetailView khởi tạo → tốn memory/CPU

2. Không có programmatic navigation mạnh
   → Khó deep link, khó navigate từ ViewModel

3. Behavior khác nhau iPhone vs iPad
   → iPhone: stack (push/pop)
   → iPad: sidebar + detail (split view) — khó kiểm soát

4. Không thể pop nhiều level hoặc pop to root dễ dàng
```

---

## 3. `NavigationStack` (iOS 16+) — Thay thế NavigationView

### Cơ bản

```swift
NavigationStack {
    List(items) { item in
        NavigationLink(value: item) {
            // ↑ Chỉ truyền VALUE, KHÔNG truyền destination
            Text(item.name)
        }
    }
    .navigationTitle("Items")
    .navigationDestination(for: Item.self) { item in
        // ↑ Destination được tạo CHỈ KHI navigate
        DetailView(item: item)
    }
}
```

**Khác biệt cốt lõi:** `NavigationLink(value:)` chỉ truyền **data** (value-based), destination được định nghĩa riêng bằng `.navigationDestination(for:)`. Destination **chỉ tạo khi cần** (lazy) → performance tốt hơn nhiều.

### Programmatic Navigation với path

```swift
struct ContentView: View {
    @State private var path = NavigationPath()
    //                        ↑ Stack lưu trữ navigation history
    
    var body: some View {
        NavigationStack(path: $path) {
            //               ↑ Bind path → kiểm soát stack bằng code
            List(items) { item in
                NavigationLink(value: item) {
                    Text(item.name)
                }
            }
            .navigationDestination(for: Item.self) { item in
                DetailView(item: item)
            }
            .navigationDestination(for: String.self) { text in
                TextView(text: text)
            }
        }
    }
    
    // Programmatic navigation
    func navigateToItem(_ item: Item) {
        path.append(item)            // push
    }
    
    func navigateToMultiple() {
        path.append(Item(name: "A"))  // push A
        path.append(Item(name: "B"))  // push B (trên A)
    }
    
    func goBack() {
        path.removeLast()            // pop 1 level
    }
    
    func goToRoot() {
        path.removeLast(path.count)  // pop tất cả → về root
        // hoặc: path = NavigationPath()
    }
}
```

```
path = []              → Root View
path = [itemA]         → Root → DetailView(itemA)
path = [itemA, itemB]  → Root → DetailView(itemA) → DetailView(itemB)
path.removeLast()      → Root → DetailView(itemA)
path = NavigationPath() → Root
```

### NavigationPath — Type-erased stack

```swift
// NavigationPath chấp nhận NHIỀU type khác nhau
@State private var path = NavigationPath()

path.append(Item(name: "Phone"))    // Item
path.append("Settings")             // String
path.append(42)                      // Int
// Stack: [Item, String, Int] → 3 levels deep

// Mỗi type cần .navigationDestination riêng:
.navigationDestination(for: Item.self) { item in ... }
.navigationDestination(for: String.self) { text in ... }
.navigationDestination(for: Int.self) { num in ... }
```

### Typed path — Khi chỉ 1 type

```swift
// Nếu chỉ navigate với 1 type → dùng array đơn giản
@State private var path: [Item] = []

NavigationStack(path: $path) {
    List(items) { item in
        NavigationLink(value: item) { Text(item.name) }
    }
    .navigationDestination(for: Item.self) { item in
        DetailView(item: item)
    }
}

// Push
path.append(item)

// Pop to root
path.removeAll()
```

---

## 4. `NavigationSplitView` (iOS 16+) — Multi-column

### iPad / macOS — Sidebar + Detail

```swift
NavigationSplitView {
    // SIDEBAR (cột trái)
    List(categories, selection: $selectedCategory) { category in
        Label(category.name, systemImage: category.icon)
    }
    .navigationTitle("Categories")
} detail: {
    // DETAIL (cột phải)
    if let category = selectedCategory {
        CategoryDetailView(category: category)
    } else {
        ContentUnavailableView("Select a Category",
            systemImage: "sidebar.left")
    }
}
```

```
iPad Landscape:
┌──────────────┬──────────────────────────┐
│  Categories  │                          │
├──────────────┤   Select a Category      │
│ ☰ Tech       │                          │
│ ☰ Science    │   (placeholder)          │
│ ☰ Art        │                          │
└──────────────┴──────────────────────────┘

Tap "Tech":
┌──────────────┬──────────────────────────┐
│  Categories  │                          │
├──────────────┤   Tech Articles          │
│ ▶ Tech       │   - Article 1            │
│ ☰ Science    │   - Article 2            │
│ ☰ Art        │                          │
└──────────────┴──────────────────────────┘
```

### Three-column layout

```swift
NavigationSplitView {
    // SIDEBAR
    List(categories, selection: $selectedCategory) { ... }
} content: {
    // CONTENT (cột giữa)
    if let category = selectedCategory {
        List(category.items, selection: $selectedItem) { item in
            Text(item.name)
        }
    }
} detail: {
    // DETAIL (cột phải)
    if let item = selectedItem {
        ItemDetailView(item: item)
    }
}
```

```
┌─────────┬──────────────┬────────────────────┐
│ Sidebar │   Content    │      Detail        │
│         │              │                    │
│ ☰ Cat1  │ ☰ Item A     │   Item B Detail    │
│ ▶ Cat2  │ ▶ Item B     │   ...              │
│ ☰ Cat3  │ ☰ Item C     │                    │
└─────────┴──────────────┴────────────────────┘
```

### iPhone — Tự động thành stack

NavigationSplitView trên iPhone **tự động collapse thành navigation stack** — sidebar → content → detail push lần lượt. Không cần code riêng.

### Column visibility

```swift
@State private var columnVisibility = NavigationSplitViewVisibility.all

NavigationSplitView(columnVisibility: $columnVisibility) {
    Sidebar()
} detail: {
    Detail()
}

// Điều khiển hiển thị cột:
// .all — hiện tất cả
// .doubleColumn — sidebar + detail
// .detailOnly — chỉ detail
// .automatic — tuỳ platform
```

---

## 5. Navigation Modifiers — Tuỳ chỉnh Navigation Bar

### Title

```swift
.navigationTitle("Home")

// Display mode (iOS)
.navigationBarTitleDisplayMode(.large)       // title lớn, co lại khi scroll
.navigationBarTitleDisplayMode(.inline)      // title nhỏ trên thanh bar
.navigationBarTitleDisplayMode(.automatic)   // tuỳ context
```

### Toolbar

```swift
.toolbar {
    // Vị trí khác nhau
    ToolbarItem(placement: .topBarTrailing) {
        Button("Save") { save() }
    }
    
    ToolbarItem(placement: .topBarLeading) {
        Button("Cancel") { dismiss() }
    }
    
    ToolbarItem(placement: .bottomBar) {
        HStack {
            Button(action: {}) { Image(systemName: "trash") }
            Spacer()
            Button(action: {}) { Image(systemName: "square.and.arrow.up") }
        }
    }
    
    // Nhóm items
    ToolbarItemGroup(placement: .topBarTrailing) {
        Button(action: {}) { Image(systemName: "magnifyingglass") }
        Button(action: {}) { Image(systemName: "ellipsis") }
    }
    
    // Keyboard toolbar
    ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        Button("Done") { focusedField = nil }
    }
}
```

### Ẩn navigation bar / back button

```swift
.navigationBarHidden(true)          // ẩn toàn bộ bar (legacy)
.toolbar(.hidden, for: .navigationBar)  // iOS 16+

.navigationBarBackButtonHidden(true)    // ẩn nút back
// Thường kết hợp custom back button:
.toolbar {
    ToolbarItem(placement: .topBarLeading) {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
        }
    }
}
```

### Toolbar background

```swift
// iOS 16+
.toolbarBackground(.ultraThinMaterial, for: .navigationBar)
.toolbarBackground(.visible, for: .navigationBar)
.toolbarColorScheme(.dark, for: .navigationBar)
```

---

## 6. Deep Linking & Programmatic Navigation

### 6.1 Deep link từ URL

```swift
enum Route: Hashable {
    case productList(category: String)
    case productDetail(id: Int)
    case settings
    case profile(userId: String)
}

struct AppView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .productList(let category):
                        ProductListView(category: category)
                    case .productDetail(let id):
                        ProductDetailView(id: id)
                    case .settings:
                        SettingsView()
                    case .profile(let userId):
                        ProfileView(userId: userId)
                    }
                }
        }
        .onOpenURL { url in
            // myapp://product/123
            if let route = parseDeepLink(url) {
                path.append(route)
            }
        }
    }
    
    func parseDeepLink(_ url: URL) -> Route? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        switch components.host {
        case "product":
            if let id = Int(components.path.dropFirst()) {
                return .productDetail(id: id)
            }
        case "settings":
            return .settings
        default: break
        }
        return nil
    }
}
```

### 6.2 Navigate từ ViewModel

```swift
// Router object chia sẻ path
@Observable
class Router {
    var path = NavigationPath()
    
    func navigateToProduct(_ id: Int) {
        path.append(Route.productDetail(id: id))
    }
    
    func navigateToSettings() {
        path.append(Route.settings)
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

struct AppView: View {
    @State private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    routeToView(route)
                }
        }
        .environment(router)
    }
}

// Bất kỳ view con nào cũng navigate được:
struct SomeChildView: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        Button("Go to Settings") {
            router.navigateToSettings()
        }
    }
}
```

### 6.3 Save/Restore navigation state

```swift
// NavigationPath conform Codable → save/restore được
struct AppView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            HomeView()
                .navigationDestination(for: Route.self) { ... }
        }
        .onAppear { restorePath() }
        .onChange(of: path) { _, _ in savePath() }
    }
    
    func savePath() {
        guard let data = try? JSONEncoder().encode(path.codable) else { return }
        UserDefaults.standard.set(data, forKey: "navigationPath")
    }
    
    func restorePath() {
        guard let data = UserDefaults.standard.data(forKey: "navigationPath"),
              let decoded = try? JSONDecoder().decode(
                  NavigationPath.CodableRepresentation.self, from: data
              ) else { return }
        path = NavigationPath(decoded)
    }
}
```

---

## 7. Presentation Modifiers — Sheet, Alert, FullScreenCover

```swift
struct ContentView: View {
    @State private var showSheet = false
    @State private var showAlert = false
    @State private var selectedItem: Item?
    
    var body: some View {
        NavigationStack {
            List(items) { item in
                Button(item.name) {
                    selectedItem = item
                }
            }
            
            // Sheet (modal card)
            .sheet(isPresented: $showSheet) {
                SheetView()
            }
            
            // Sheet với item (Identifiable)
            .sheet(item: $selectedItem) { item in
                // Hiện khi selectedItem != nil
                // Dismiss khi selectedItem = nil
                DetailView(item: item)
            }
            
            // Full screen cover
            .fullScreenCover(isPresented: $showFullScreen) {
                FullScreenView()
            }
            
            // Alert
            .alert("Delete?", isPresented: $showAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) { deleteItem() }
            } message: {
                Text("This action cannot be undone.")
            }
            
            // Confirmation dialog (action sheet)
            .confirmationDialog("Options", isPresented: $showDialog) {
                Button("Share") { }
                Button("Edit") { }
                Button("Delete", role: .destructive) { }
            }
        }
    }
}
```

### Dismiss programmatically

```swift
struct SheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form { ... }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            save()
                            dismiss()
                        }
                    }
                }
        }
    }
}
```

---

## 8. Migration: NavigationView → NavigationStack

```swift
// ━━━ TRƯỚC (iOS 13–15) ━━━
NavigationView {                                         // 1. NavigationView
    List(items) { item in
        NavigationLink(destination: DetailView(item: item)) {  // 2. destination inline
            Text(item.name)
        }
    }
    .navigationTitle("Items")
}

// ━━━ SAU (iOS 16+) ━━━
NavigationStack {                                        // 1. NavigationStack
    List(items) { item in
        NavigationLink(value: item) {                    // 2. value-based
            Text(item.name)
        }
    }
    .navigationTitle("Items")
    .navigationDestination(for: Item.self) { item in     // 3. destination riêng
        DetailView(item: item)
    }
}
```

```swift
// ━━━ TRƯỚC: iPad split view ━━━
NavigationView {
    Sidebar()
    DetailView()
}

// ━━━ SAU: NavigationSplitView ━━━
NavigationSplitView {
    Sidebar()
} detail: {
    DetailView()
}
```

---

## 9. Ví dụ thực tế hoàn chỉnh — App với Tab + Navigation

```swift
// MARK: - Route
enum Route: Hashable {
    case productDetail(Product)
    case categoryList(Category)
    case cart
    case orderConfirmation(Order)
}

// MARK: - Router
@Observable
class AppRouter {
    var homePath = NavigationPath()
    var searchPath = NavigationPath()
    var profilePath = NavigationPath()
    
    func resetAll() {
        homePath = NavigationPath()
        searchPath = NavigationPath()
        profilePath = NavigationPath()
    }
}

// MARK: - App
struct ShopApp: View {
    @State private var router = AppRouter()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)
            
            SearchTab()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(1)
            
            ProfileTab()
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(2)
        }
        .environment(router)
    }
}

// MARK: - Home Tab
struct HomeTab: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        @Bindable var router = router
        
        NavigationStack(path: $router.homePath) {
            ScrollView {
                LazyVStack {
                    ForEach(featuredProducts) { product in
                        NavigationLink(value: Route.productDetail(product)) {
                            ProductCard(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Shop")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .productDetail(let product):
                    ProductDetailView(product: product)
                case .categoryList(let category):
                    CategoryListView(category: category)
                case .cart:
                    CartView()
                case .orderConfirmation(let order):
                    OrderConfirmationView(order: order)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        router.homePath.append(Route.cart)
                    } label: {
                        Image(systemName: "cart")
                    }
                }
            }
        }
    }
}

// MARK: - Product Detail (pushes further)
struct ProductDetailView: View {
    @Environment(Router.self) private var router
    let product: Product
    
    var body: some View {
        ScrollView {
            VStack {
                // Product info...
                
                Button("Buy Now") {
                    let order = Order(product: product)
                    router.homePath.append(Route.orderConfirmation(order))
                    // Push thêm 1 level: Home → Product → Order Confirmation
                }
                
                Button("View Category") {
                    router.homePath.append(Route.categoryList(product.category))
                }
            }
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

---

## 10. Tóm tắt

| | NavigationView (legacy) | NavigationStack (iOS 16+) | NavigationSplitView (iOS 16+) |
|---|---|---|---|
| **Push/Pop** | NavigationLink(destination:) | NavigationLink(value:) + .navigationDestination | Selection binding |
| **Programmatic** | Hạn chế | ✅ NavigationPath | ✅ Selection binding |
| **Deep link** | Khó | ✅ Append path | ✅ Set selection |
| **Pop to root** | Hack | `path = NavigationPath()` | Reset selection |
| **Lazy destination** | ❌ Tạo ngay | ✅ Tạo khi navigate | ✅ |
| **Multi-column** | Hành vi lạ | ❌ (stack only) | ✅ Sidebar/Content/Detail |
| **iPhone** | Stack | Stack | Auto-collapse thành stack |
| **iPad** | Split (khó kiểm soát) | Stack | Split (kiểm soát tốt) |
| **Save/Restore** | ❌ | ✅ Codable path | ✅ |

### Quy tắc chọn (iOS 16+)

```
Push/pop navigation (drill-down)?
  → NavigationStack ✅

Sidebar + Detail (iPad / macOS)?
  → NavigationSplitView ✅

Cần hỗ trợ iOS 13–15?
  → NavigationView (legacy) + migration plan
```

-----

Navigation trong SwiftUI có hai thế hệ, Huy. Ba điểm cốt lõi:

**NavigationView (legacy, iOS 13–15) → NavigationStack (iOS 16+).** Khác biệt lớn nhất: NavigationView dùng `NavigationLink(destination:)` — destination được **tạo ngay khi render** (100 items = 100 DetailView khởi tạo). NavigationStack dùng `NavigationLink(value:)` + `.navigationDestination(for:)` — destination **chỉ tạo khi navigate** (lazy). Performance khác biệt rõ rệt với list lớn.

**Programmatic Navigation — sức mạnh thực sự của NavigationStack.** Bind `NavigationPath` vào stack → kiểm soát hoàn toàn bằng code: `path.append(route)` để push, `path.removeLast()` để pop, `path = NavigationPath()` để pop-to-root. Kết hợp với Router object inject qua `.environment()` → bất kỳ view con nào cũng navigate được. Hỗ trợ deep linking (parse URL → append route), save/restore state (NavigationPath conform Codable). NavigationView legacy gần như không làm được những điều này.

**NavigationSplitView cho iPad/macOS.** Sidebar + Content + Detail layout, tự động collapse thành stack trên iPhone. Dùng `selection` binding thay vì push/pop. Kiểm soát column visibility bằng `NavigationSplitViewVisibility`. Quy tắc chọn đơn giản: drill-down (push/pop) → NavigationStack; sidebar + detail (multi-column) → NavigationSplitView.
