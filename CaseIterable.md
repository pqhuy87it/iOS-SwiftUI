# SwiftUI: `CaseIterable` — Giải thích chi tiết

## 1. Bản chất — Tự động liệt kê tất cả case của enum

`CaseIterable` là Swift protocol cung cấp **property `allCases`** — một array chứa **tất cả case** của enum theo thứ tự khai báo. SwiftUI dùng nó rất nhiều vì UI thường cần lặp qua tất cả case (Picker, Segmented Control, Filter bar, Settings...).

```swift
enum Flavor: CaseIterable {
    case chocolate, vanilla, strawberry
}

Flavor.allCases
// [.chocolate, .vanilla, .strawberry]
// Type: [Flavor]
```

Compiler **tự động synthesize** `allCases` — không cần viết thủ công.

---

## 2. Khai báo và sử dụng cơ bản

### Conform CaseIterable

```swift
enum Season: String, CaseIterable {
    case spring = "Spring"
    case summer = "Summer"
    case autumn = "Autumn"
    case winter = "Winter"
}

// Tự động có:
Season.allCases        // [.spring, .summer, .autumn, .winter]
Season.allCases.count  // 4
```

### Thường kết hợp với các protocol khác

```swift
enum Category: String, CaseIterable, Identifiable {
    case all, electronics, clothing, food, books
    
    var id: String { rawValue }
    // ↑ Identifiable: cần cho ForEach
    // ↑ CaseIterable: cần cho allCases
    // ↑ String RawValue: cần cho display text
}
```

Combo phổ biến nhất trong SwiftUI:

```
enum MyEnum: String, CaseIterable, Identifiable {
    ...
    var id: String { rawValue }    // hoặc var id: Self { self }
}
```

---

## 3. CaseIterable trong SwiftUI — Nơi sử dụng

### 3.1 `Picker` — Chọn từ tất cả case

```swift
enum SortOrder: String, CaseIterable, Identifiable {
    case nameAsc = "Name ↑"
    case nameDesc = "Name ↓"
    case priceAsc = "Price ↑"
    case priceDesc = "Price ↓"
    
    var id: Self { self }
}

struct SortPicker: View {
    @Binding var selection: SortOrder
    
    var body: some View {
        Picker("Sort by", selection: $selection) {
            ForEach(SortOrder.allCases) { order in
                Text(order.rawValue).tag(order)
            }
        }
    }
}
```

### 3.2 Segmented Control

```swift
enum Tab: String, CaseIterable, Identifiable {
    case featured = "Featured"
    case popular = "Popular"
    case recent = "Recent"
    
    var id: Self { self }
}

struct ContentView: View {
    @State private var selectedTab: Tab = .featured
    
    var body: some View {
        VStack {
            Picker("Tab", selection: $selectedTab) {
                ForEach(Tab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            
            // Content dựa trên tab
            switch selectedTab {
            case .featured: FeaturedView()
            case .popular:  PopularView()
            case .recent:   RecentView()
            }
        }
    }
}
```

```
┌──────────┬──────────┬──────────┐
│ Featured │ Popular  │  Recent  │  ← Segmented từ allCases
└──────────┴──────────┴──────────┘
```

### 3.3 Horizontal Filter Bar

```swift
enum ProductFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case electronics = "Electronics"
    case clothing = "Clothing"
    case food = "Food"
    case books = "Books"
    
    var id: Self { self }
    
    var icon: String {
        switch self {
        case .all: "square.grid.2x2"
        case .electronics: "desktopcomputer"
        case .clothing: "tshirt"
        case .food: "fork.knife"
        case .books: "book"
        }
    }
}

struct FilterBar: View {
    @Binding var selected: ProductFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ProductFilter.allCases) { filter in
                    Button {
                        withAnimation { selected = filter }
                    } label: {
                        Label(filter.rawValue, systemImage: filter.icon)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(selected == filter ? .blue : .gray.opacity(0.15))
                            )
                            .foregroundStyle(selected == filter ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
```

### 3.4 Settings Form

```swift
enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: Self { self }
    
    var icon: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }
}

enum Language: String, CaseIterable, Identifiable {
    case english = "English"
    case vietnamese = "Tiếng Việt"
    case japanese = "日本語"
    
    var id: Self { self }
}

struct SettingsView: View {
    @AppStorage("theme") private var theme: AppTheme = .system
    @AppStorage("language") private var language: Language = .english
    
    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $theme) {
                    ForEach(AppTheme.allCases) { theme in
                        Label(theme.rawValue, systemImage: theme.icon)
                            .tag(theme)
                    }
                }
                
                Picker("Language", selection: $language) {
                    ForEach(Language.allCases) { lang in
                        Text(lang.rawValue).tag(lang)
                    }
                }
            }
        }
    }
}
```

### 3.5 List tất cả options

```swift
enum Priority: Int, CaseIterable, Identifiable, Comparable {
    case low = 0
    case medium = 1
    case high = 2
    case critical = 3
    
    var id: Int { rawValue }
    
    var label: String {
        switch self {
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        case .critical: "Critical"
        }
    }
    
    var color: Color {
        switch self {
        case .low: .gray
        case .medium: .blue
        case .high: .orange
        case .critical: .red
        }
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct PriorityPicker: View {
    @Binding var selected: Priority
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Priority").font(.headline)
            
            ForEach(Priority.allCases) { priority in
                Button {
                    selected = priority
                } label: {
                    HStack {
                        Circle()
                            .fill(priority.color)
                            .frame(width: 12, height: 12)
                        Text(priority.label)
                        Spacer()
                        if selected == priority {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
```

### 3.6 TabView

```swift
enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case search = "Search"
    case favorites = "Favorites"
    case profile = "Profile"
    
    var id: Self { self }
    
    var icon: String {
        switch self {
        case .home: "house.fill"
        case .search: "magnifyingglass"
        case .favorites: "heart.fill"
        case .profile: "person.fill"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.rawValue, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
    }
    
    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .home: HomeView()
        case .search: SearchView()
        case .favorites: FavoritesView()
        case .profile: ProfileView()
        }
    }
}
```

### 3.7 Onboarding pages

```swift
enum OnboardingPage: Int, CaseIterable, Identifiable {
    case welcome, features, permissions, getStarted
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .welcome: "Welcome"
        case .features: "Features"
        case .permissions: "Permissions"
        case .getStarted: "Get Started"
        }
    }
    
    var description: String {
        switch self {
        case .welcome: "Thanks for downloading our app"
        case .features: "Discover what you can do"
        case .permissions: "We need a few permissions"
        case .getStarted: "You're all set!"
        }
    }
    
    var imageName: String {
        switch self {
        case .welcome: "hand.wave"
        case .features: "star.fill"
        case .permissions: "lock.shield"
        case .getStarted: "checkmark.circle"
        }
    }
}

struct OnboardingView: View {
    @State private var currentPage: OnboardingPage = .welcome
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(OnboardingPage.allCases) { page in
                VStack(spacing: 24) {
                    Image(systemName: page.imageName)
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                    Text(page.title).font(.title.bold())
                    Text(page.description)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding(40)
                .tag(page)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        
        // Page indicator dots tự động từ allCases
    }
}
```

---

## 4. Computed Properties trên Enum — Tập trung logic

Pattern phổ biến: enum vừa là data model vừa chứa display logic:

```swift
enum TransactionType: String, CaseIterable, Identifiable {
    case income, expense, transfer, investment
    
    var id: Self { self }
    
    // Display
    var label: String {
        switch self {
        case .income: "Income"
        case .expense: "Expense"
        case .transfer: "Transfer"
        case .investment: "Investment"
        }
    }
    
    var icon: String {
        switch self {
        case .income: "arrow.down.circle.fill"
        case .expense: "arrow.up.circle.fill"
        case .transfer: "arrow.left.arrow.right.circle.fill"
        case .investment: "chart.line.uptrend.xyaxis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .income: .green
        case .expense: .red
        case .transfer: .blue
        case .investment: .purple
        }
    }
}

// View chỉ cần:
ForEach(TransactionType.allCases) { type in
    Label(type.label, systemImage: type.icon)
        .foregroundStyle(type.color)
}
// ← Không có switch/if trong View — logic tập trung trong enum
```

---

## 5. CaseIterable + Identifiable — Tại sao cần cả hai

### CaseIterable cung cấp `allCases`

```swift
enum Color: CaseIterable {
    case red, green, blue
}
Color.allCases  // [.red, .green, .blue] — để lặp
```

### Identifiable cung cấp `id`

```swift
// ForEach yêu cầu Identifiable HOẶC id keypath
ForEach(Color.allCases) { color in ... }
// ❌ Error: Color does not conform to Identifiable
```

### Giải pháp — Conform cả hai

```swift
enum Color: String, CaseIterable, Identifiable {
    case red, green, blue
    var id: Self { self }
    //        ↑ Enum tự conform Hashable → dùng self làm id
}

ForEach(Color.allCases) { color in
    Text(color.rawValue)  // ✅
}
```

### Alternative: `id: \.self` thay vì Identifiable

```swift
enum Color: String, CaseIterable {
    case red, green, blue
    // Không conform Identifiable
}

ForEach(Color.allCases, id: \.self) { color in
    Text(color.rawValue)  // ✅ dùng \.self làm id
}
// Hoạt động vì enum tự conform Hashable
// Nhưng conform Identifiable rõ ràng hơn, dùng được ở nhiều nơi
```

---

## 6. Custom `allCases` — Override khi cần

### Enum có associated value → KHÔNG tự synthesize

```swift
// ❌ Compiler không thể tự sinh allCases
enum Filter: CaseIterable {
    case all
    case category(String)    // ← associated value → không biết liệt kê gì
}
// Error: does not conform to CaseIterable
```

### Giải pháp: implement thủ công

```swift
enum Filter: CaseIterable {
    case all
    case active
    case completed
    case category(String)
    
    // Tự define allCases — chỉ liệt kê cases KHÔNG có associated value
    // hoặc liệt kê với giá trị cụ thể
    static var allCases: [Filter] {
        [.all, .active, .completed,
         .category("Work"),
         .category("Personal"),
         .category("Shopping")]
    }
}
```

### Loại trừ case khỏi allCases

```swift
enum Status: String, CaseIterable {
    case draft, published, archived, deleted
    
    // Chỉ hiện status "active" cho user
    static var visibleCases: [Status] {
        allCases.filter { $0 != .deleted }
    }
}

// Trong UI
Picker("Status", selection: $status) {
    ForEach(Status.visibleCases, id: \.self) { status in
        Text(status.rawValue.capitalized).tag(status)
    }
}
```

### allCases động theo điều kiện

```swift
enum Feature: String, CaseIterable, Identifiable {
    case basicSearch = "Search"
    case advancedFilters = "Advanced Filters"
    case export = "Export"
    case analytics = "Analytics"
    case adminPanel = "Admin Panel"
    
    var id: Self { self }
    
    static func availableCases(for role: UserRole) -> [Feature] {
        switch role {
        case .free:
            return [.basicSearch]
        case .premium:
            return [.basicSearch, .advancedFilters, .export, .analytics]
        case .admin:
            return allCases
        }
    }
}

// UI
ForEach(Feature.availableCases(for: currentUser.role)) { feature in
    FeatureRow(feature: feature)
}
```

---

## 7. CaseIterable với @AppStorage

```swift
// Enum cần RawRepresentable để lưu vào AppStorage
enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: Self { self }
}

struct SettingsView: View {
    @AppStorage("appTheme") private var theme: AppTheme = .system
    //                                         ↑ RawRepresentable (String)
    //                                           → lưu "system"/"light"/"dark" vào UserDefaults
    
    var body: some View {
        Picker("Theme", selection: $theme) {
            ForEach(AppTheme.allCases) { t in
                Text(t.rawValue.capitalized).tag(t)
            }
        }
    }
}
```

---

## 8. Pattern thực tế — Enum-driven UI

### Complete example: Filter + Sort + Display

```swift
// MARK: - Enums
enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case completed = "Done"
    
    var id: Self { self }
    
    func apply(to tasks: [TodoTask]) -> [TodoTask] {
        switch self {
        case .all: return tasks
        case .active: return tasks.filter { !$0.isDone }
        case .completed: return tasks.filter { $0.isDone }
        }
    }
}

enum TaskSort: String, CaseIterable, Identifiable {
    case dateDesc = "Newest"
    case dateAsc = "Oldest"
    case priority = "Priority"
    case alphabetical = "A-Z"
    
    var id: Self { self }
    var icon: String {
        switch self {
        case .dateDesc: "arrow.down"
        case .dateAsc: "arrow.up"
        case .priority: "exclamationmark.triangle"
        case .alphabetical: "textformat.abc"
        }
    }
    
    func apply(to tasks: [TodoTask]) -> [TodoTask] {
        switch self {
        case .dateDesc: return tasks.sorted { $0.date > $1.date }
        case .dateAsc: return tasks.sorted { $0.date < $1.date }
        case .priority: return tasks.sorted { $0.priority > $1.priority }
        case .alphabetical: return tasks.sorted { $0.title < $1.title }
        }
    }
}

// MARK: - ViewModel
@Observable
class TaskListViewModel {
    var tasks: [TodoTask] = []
    var filter: TaskFilter = .all
    var sort: TaskSort = .dateDesc
    
    var displayedTasks: [TodoTask] {
        sort.apply(to: filter.apply(to: tasks))
        // ↑ enum methods xử lý logic — ViewModel chỉ compose
    }
}

// MARK: - View
struct TaskListView: View {
    @State private var vm = TaskListViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter bar — segmented từ allCases
            Picker("Filter", selection: $vm.filter) {
                ForEach(TaskFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Sort menu — items từ allCases
            HStack {
                Text("\(vm.displayedTasks.count) tasks")
                    .foregroundStyle(.secondary)
                Spacer()
                Menu {
                    ForEach(TaskSort.allCases) { sort in
                        Button {
                            vm.sort = sort
                        } label: {
                            Label(sort.rawValue, systemImage: sort.icon)
                            if vm.sort == sort {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
            .padding(.horizontal)
            
            // Task list
            List(vm.displayedTasks) { task in
                TaskRow(task: task)
            }
        }
    }
}
```

---

## 9. CaseIterable count — Validate & Debug

```swift
enum OnboardingStep: CaseIterable {
    case welcome, profile, preferences, complete
}

// Đếm steps
let totalSteps = OnboardingStep.allCases.count  // 4

// Progress
let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep)!
let progress = Double(currentIndex) / Double(totalSteps - 1)
// step 0: 0%, step 1: 33%, step 2: 66%, step 3: 100%

// Next / Previous
func nextStep() {
    guard let index = OnboardingStep.allCases.firstIndex(of: currentStep),
          index + 1 < OnboardingStep.allCases.count else { return }
    currentStep = OnboardingStep.allCases[index + 1]
}
```

---

## 10. Sai lầm thường gặp

### ❌ Quên Identifiable khi dùng ForEach

```swift
enum Size: String, CaseIterable {
    case small, medium, large
}

// ❌ Error: Size does not conform to Identifiable
ForEach(Size.allCases) { size in Text(size.rawValue) }

// ✅ Giải pháp 1: conform Identifiable
enum Size: String, CaseIterable, Identifiable {
    case small, medium, large
    var id: Self { self }
}

// ✅ Giải pháp 2: id keypath
ForEach(Size.allCases, id: \.self) { size in Text(size.rawValue) }
```

### ❌ Quên .tag() trong Picker

```swift
// ❌ Picker không biết map selection → option
Picker("Size", selection: $size) {
    ForEach(Size.allCases) { size in
        Text(size.rawValue)         // thiếu .tag()
    }
}

// ✅ Thêm .tag()
Picker("Size", selection: $size) {
    ForEach(Size.allCases) { size in
        Text(size.rawValue).tag(size)   // ← bắt buộc
    }
}
```

**Lưu ý:** Khi `ForEach` loop trên enum đã Identifiable, và `selection` binding cùng type → `.tag()` có thể tự suy. Nhưng **luôn viết tường minh `.tag()`** trong Picker để tránh bug im lặng.

### ❌ Enum có associated value → compile error

```swift
// ❌ CaseIterable không tự synthesize khi có associated value
enum Result: CaseIterable {
    case success(String)    // ← associated value
    case failure(Error)     // ← associated value
}
// Error: does not conform to CaseIterable

// ✅ Implement thủ công hoặc thiết kế lại
enum ResultType: String, CaseIterable {
    case success, failure
    // Tách associated value ra ngoài
}
```

### ❌ Dùng rawValue trực tiếp cho display khi cần localization

```swift
// ❌ rawValue không localize được
enum Status: String, CaseIterable {
    case pending, approved, rejected
}
Text(status.rawValue)  // "pending" — không capitalize, không localize

// ✅ Computed property cho display
enum Status: String, CaseIterable, Identifiable {
    case pending, approved, rejected
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .pending: String(localized: "Pending")
        case .approved: String(localized: "Approved")
        case .rejected: String(localized: "Rejected")
        }
    }
}
Text(status.displayName)  // "Đang chờ" (Vietnamese locale)
```

---

## 11. Tóm tắt

| Khía cạnh | Chi tiết |
|---|---|
| **Là gì?** | Protocol cung cấp `allCases` — array tất cả case của enum |
| **Tự synthesize?** | ✅ Khi enum **không có** associated value |
| **Thứ tự** | Theo thứ tự khai báo trong source code |
| **Combo phổ biến** | `enum X: String, CaseIterable, Identifiable` |
| **SwiftUI dùng ở** | Picker, Segmented, Filter bar, Settings, TabView, Onboarding, Menu |
| **Cần tag?** | ✅ Luôn `.tag(value)` trong Picker |
| **Associated value** | ❌ Không tự synthesize → implement `allCases` thủ công |
| **Custom allCases** | Override static var cho filtered/dynamic cases |
| **Best practice** | Tập trung display logic (label, icon, color) trong computed properties trên enum |

----

`CaseIterable` cung cấp `allCases` — array tự động liệt kê tất cả case của enum, Huy. Ba điểm cốt lõi:

**Combo chuẩn trong SwiftUI: `enum X: String, CaseIterable, Identifiable`.** `CaseIterable` cho `allCases` (để ForEach lặp qua). `Identifiable` cho `id` (để ForEach track identity). `String` RawValue cho display text + lưu `@AppStorage`. Ba protocol bổ trợ nhau — thiếu một cái là gặp issue.

**Tập trung display logic trong enum — pattern mạnh nhất.** Thay vì switch/if rải rác khắp View, đặt `label`, `icon`, `color`, và cả business logic (`func apply(to:)`) ngay trong enum. View chỉ cần `ForEach(MyEnum.allCases) { item in Label(item.label, systemImage: item.icon).foregroundStyle(item.color) }` — cực kỳ gọn và dễ maintain. Thêm case mới → thêm trong enum → compiler bắt tất cả switch chưa handle.

**Associated value thì KHÔNG tự synthesize.** `enum Filter { case category(String) }` → compiler không biết liệt kê những `String` nào → phải implement `static var allCases` thủ công. Giải pháp thiết kế: tách associated value ra khỏi enum CaseIterable, hoặc define `allCases` với giá trị cụ thể (`[.category("Work"), .category("Personal")]`).

Sai lầm hay gặp: quên `.tag(value)` trong Picker — Picker không biết map selection sang option → selection không hoạt động, không có warning. Luôn viết `.tag()` tường minh dù đôi khi Swift tự suy được.
