# SwiftUI: `UIHostingController` — Giải thích chi tiết

## 1. Bản chất — Cầu nối SwiftUI → UIKit

`UIHostingController` là **UIViewController subclass** chứa một **SwiftUI View** bên trong. Nó cho phép nhúng bất kỳ SwiftUI View nào vào trong hệ thống UIKit (UINavigationController, UITabBarController, present modally, add as child VC...).

```
UIKit World                          SwiftUI World
────────────                         ───────────────
UINavigationController
  └── UIHostingController ──────────── SwiftUI View
        ↑ UIViewController              ↑ some View
        ↑ UIKit hiểu                    ↑ SwiftUI hiểu
        
UIHostingController = ADAPTER giữa hai thế giới
```

Hình dung: **khung ảnh** (UIHostingController) chứa **bức tranh** (SwiftUI View). Khung ảnh nói ngôn ngữ UIKit, bức tranh nói ngôn ngữ SwiftUI.

---

## 2. Tại sao cần UIHostingController?

### Tình huống 1: App UIKit đang migration dần sang SwiftUI

```
App UIKit lớn (100+ ViewControllers)
  │
  ├── LoginVC (UIKit) ← giữ nguyên
  ├── HomeVC (UIKit) ← giữ nguyên
  ├── ProfileVC → ProfileView (SwiftUI) ← MỚI, viết bằng SwiftUI
  ├── SettingsVC (UIKit) ← giữ nguyên
  └── OnboardingVC → OnboardingView (SwiftUI) ← MỚI
  
ProfileView cần NẰM TRONG UINavigationController UIKit
→ UIHostingController wrap ProfileView → push vào nav stack UIKit
```

### Tình huống 2: Feature mới viết SwiftUI, app vẫn UIKit

```swift
// UIKit VC muốn present SwiftUI view
class HomeViewController: UIViewController {
    func showNewFeature() {
        let swiftUIView = NewFeatureView()
        let hostingVC = UIHostingController(rootView: swiftUIView)
        present(hostingVC, animated: true)
        // ↑ Present SwiftUI view như UIKit VC bình thường
    }
}
```

### Tình huống 3: SceneDelegate / AppDelegate app

```swift
// App chưa dùng @main App protocol
// Vẫn dùng SceneDelegate → cần UIHostingController cho root
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = hostingController
        window?.makeKeyAndVisible()
    }
}
```

---

## 3. Cú pháp cơ bản

### Khởi tạo

```swift
// SwiftUI View
struct ProfileView: View {
    let username: String
    
    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
            Text(username)
                .font(.title)
        }
    }
}

// Wrap trong UIHostingController
let profileView = ProfileView(username: "Huy")
let hostingController = UIHostingController(rootView: profileView)
//                                          ↑ rootView: bất kỳ SwiftUI View nào
```

### Generic type

```swift
// UIHostingController là generic trên Root View
class UIHostingController<Content: View>: UIViewController {
    var rootView: Content
    init(rootView: Content)
}

// Type cụ thể tự suy
let vc = UIHostingController(rootView: ProfileView(username: "Huy"))
// Type: UIHostingController<ProfileView>

// Hoặc khai báo tường minh
let vc: UIHostingController<ProfileView> = .init(rootView: ProfileView(username: "Huy"))
```

---

## 4. Sử dụng trong UIKit Navigation

### Push vào UINavigationController

```swift
class HomeViewController: UIViewController {
    func navigateToProfile() {
        let profileView = ProfileView(username: "Huy")
        let hostingVC = UIHostingController(rootView: profileView)
        
        hostingVC.title = "Profile"
        hostingVC.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.pushViewController(hostingVC, animated: true)
    }
}
```

```
UINavigationController
  ├── HomeViewController (UIKit)
  │     │ tap "Profile"
  │     ▼ push
  └── UIHostingController
        └── ProfileView (SwiftUI)
            └── VStack { Image, Text }
```

### Present modally

```swift
class SettingsViewController: UIViewController {
    func showAbout() {
        let aboutView = AboutView()
        let hostingVC = UIHostingController(rootView: aboutView)
        
        // Modal presentation
        hostingVC.modalPresentationStyle = .pageSheet
        if let sheet = hostingVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(hostingVC, animated: true)
    }
}
```

### UITabBarController tab

```swift
class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tab 1: UIKit
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        // Tab 2: SwiftUI
        let favoritesView = FavoritesView()
        let favoritesVC = UIHostingController(rootView: favoritesView)
        favoritesVC.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart"), tag: 1)
        
        // Tab 3: SwiftUI
        let settingsView = SettingsView()
        let settingsVC = UIHostingController(rootView: settingsView)
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 2)
        
        viewControllers = [
            UINavigationController(rootViewController: homeVC),
            UINavigationController(rootViewController: favoritesVC),
            UINavigationController(rootViewController: settingsVC)
        ]
    }
}
```

```
UITabBarController
  ├── Tab 1: UINavigationController → HomeVC (UIKit)
  ├── Tab 2: UINavigationController → UIHostingController → FavoritesView (SwiftUI)
  └── Tab 3: UINavigationController → UIHostingController → SettingsView (SwiftUI)
```

---

## 5. Add as Child View Controller — Nhúng vào một phần màn hình

```swift
class DashboardViewController: UIViewController {
    private var chartHostingController: UIHostingController<ChartView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()     // UIKit header
        embedSwiftUIChart() // SwiftUI chart ở giữa
        setupFooter()     // UIKit footer
    }
    
    private func embedSwiftUIChart() {
        let chartView = ChartView(data: chartData)
        let hostingVC = UIHostingController(rootView: chartView)
        
        // 1. Add as child VC
        addChild(hostingVC)
        
        // 2. Add view
        view.addSubview(hostingVC.view)
        
        // 3. Setup constraints
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            hostingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hostingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            hostingVC.view.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // 4. Notify child
        hostingVC.didMove(toParent: self)
        
        self.chartHostingController = hostingVC
    }
    
    // Update SwiftUI view khi data thay đổi
    func updateChart(newData: [DataPoint]) {
        chartHostingController?.rootView = ChartView(data: newData)
        //                      ↑ THAY ĐỔI rootView → SwiftUI re-render
    }
}
```

```
┌─── DashboardViewController (UIKit) ───────────┐
│ ┌─── UIView (Header) ──────────────────────┐  │
│ │ Dashboard Title          [Filter Button]  │  │  ← UIKit
│ └───────────────────────────────────────────┘  │
│                                                 │
│ ┌─── UIHostingController ──────────────────┐   │
│ │ ┌─── ChartView (SwiftUI) ──────────────┐ │  │
│ │ │          📊 Chart                     │ │  │  ← SwiftUI
│ │ │     rendered by SwiftUI               │ │  │
│ │ └──────────────────────────────────────┘ │  │
│ └──────────────────────────────────────────┘   │
│                                                 │
│ ┌─── UITableView (Footer) ─────────────────┐  │
│ │ Recent transactions...                    │  │  ← UIKit
│ └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

### Remove child hosting controller

```swift
func removeChart() {
    chartHostingController?.willMove(toParent: nil)
    chartHostingController?.view.removeFromSuperview()
    chartHostingController?.removeFromParent()
    chartHostingController = nil
}
```

---

## 6. Update rootView — Truyền data mới cho SwiftUI

### Cách 1: Thay đổi rootView trực tiếp

```swift
let hostingVC = UIHostingController(rootView: CounterView(count: 0))

// Sau đó, update:
hostingVC.rootView = CounterView(count: 5)
// ↑ SwiftUI diff rootView cũ vs mới → re-render phần thay đổi
```

### Cách 2: Dùng ObservableObject / @Observable — Recommended

```swift
// ViewModel chia sẻ giữa UIKit và SwiftUI
class ProfileViewModel: ObservableObject {
    @Published var name = "Huy"
    @Published var avatar: UIImage?
    @Published var isLoading = false
}

// SwiftUI View observe ViewModel
struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(viewModel.name).font(.title)
            }
        }
    }
}

// UIKit VC
class ProfileViewController: UIViewController {
    private let viewModel = ProfileViewModel()
    private var hostingVC: UIHostingController<ProfileView>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SwiftUI view observe cùng ViewModel
        let profileView = ProfileView(viewModel: viewModel)
        hostingVC = UIHostingController(rootView: profileView)
        
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.view.frame = view.bounds
        hostingVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingVC.didMove(toParent: self)
    }
    
    func fetchProfile() {
        viewModel.isLoading = true
        // ↑ @Published thay đổi → SwiftUI re-render TỰ ĐỘNG
        //   Không cần gọi hostingVC.rootView = ... 
        
        api.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.viewModel.isLoading = false
                self?.viewModel.name = result.name
                // ↑ Thay đổi ViewModel → SwiftUI tự update
            }
        }
    }
}
```

**ViewModel approach tốt hơn rootView replacement** vì:

```
rootView replacement:
  hostingVC.rootView = NewView(...)
  → Tạo View MỚI mỗi lần → có thể mất state (@State bên trong)

ViewModel approach:
  viewModel.property = newValue
  → SwiftUI re-render CÙNG View → giữ state → hiệu quả hơn
```

---

## 7. Sizing — Kiểm soát kích thước

### Preferred content size

```swift
let hostingVC = UIHostingController(rootView: CompactView())

// SwiftUI view tự tính ideal size
hostingVC.preferredContentSize = hostingVC.sizeThatFits(in: CGSize(width: 300, height: .infinity))
//                                          ↑ Hỏi SwiftUI: "cần bao nhiêu space?"
```

### sizeThatFits — Hỏi SwiftUI ideal size

```swift
let hostingVC = UIHostingController(rootView: MyView())

// Tính toán size cần thiết
let idealSize = hostingVC.sizeThatFits(in: CGSize(width: 320, height: .greatestFiniteMagnitude))
// ← "Nếu width = 320, SwiftUI cần height bao nhiêu?"
// → CGSize(width: 320, height: 180) ← SwiftUI trả lời

// Dùng cho constraint
hostingVC.view.heightAnchor.constraint(equalToConstant: idealSize.height).isActive = true
```

### Self-sizing trong UITableView / UICollectionView

```swift
// UITableViewCell chứa SwiftUI view
class SwiftUITableCell: UITableViewCell {
    private var hostingController: UIHostingController<AnyView>?
    
    func configure(with view: some View, parentVC: UIViewController) {
        // Remove old
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        
        // Add new
        let hc = UIHostingController(rootView: AnyView(view))
        hc.view.backgroundColor = .clear
        
        parentVC.addChild(hc)
        contentView.addSubview(hc.view)
        
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hc.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hc.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hc.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        hc.didMove(toParent: parentVC)
        hostingController = hc
    }
}
```

---

## 8. Background Color — Trong suốt

```swift
let hostingVC = UIHostingController(rootView: MyView())

// Mặc định: background trắng (light) hoặc đen (dark)
// Muốn trong suốt (khi embed vào UIKit view):
hostingVC.view.backgroundColor = .clear

// iOS 16+: safeAreaRegions
hostingVC.safeAreaRegions = []
// ← Bỏ qua safe area → SwiftUI content mở rộng hết bounds
```

---

## 9. Hướng ngược: UIKit → SwiftUI — `UIViewControllerRepresentable`

`UIHostingController` là SwiftUI → UIKit. Hướng ngược lại dùng `UIViewControllerRepresentable`:

```
SwiftUI → UIKit:  UIHostingController
                  (Wrap SwiftUI View trong UIViewController)

UIKit → SwiftUI:  UIViewControllerRepresentable / UIViewRepresentable
                  (Wrap UIViewController / UIView trong SwiftUI View)
```

```swift
// UIKit → SwiftUI
struct MapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }
    func updateUIView(_ uiView: MKMapView, context: Context) { }
}

// SwiftUI → UIKit
let hostingVC = UIHostingController(rootView: ProfileView())
navigationController?.pushViewController(hostingVC, animated: true)
```

---

## 10. Ví dụ thực tế — Migration gradual

### App structure — Mix UIKit + SwiftUI

```swift
// AppDelegate
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

// SceneDelegate
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = MainTabBarController()
        window.makeKeyAndVisible()
        self.window = window
    }
}

// Main tab bar — UIKit orchestrator
class MainTabBarController: UITabBarController {
    let sharedAuthManager = AuthManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tab 1: UIKit (legacy, chưa migrate)
        let feedVC = FeedViewController()
        let feedNav = UINavigationController(rootViewController: feedVC)
        feedNav.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "house"), tag: 0)
        
        // Tab 2: SwiftUI (mới viết)
        let exploreView = ExploreView()
            .environmentObject(sharedAuthManager)
        let exploreVC = UIHostingController(rootView: exploreView)
        let exploreNav = UINavigationController(rootViewController: exploreVC)
        exploreNav.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        // Tab 3: SwiftUI (mới viết)
        let profileView = ProfileView()
            .environmentObject(sharedAuthManager)
        let profileVC = UIHostingController(rootView: profileView)
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)
        
        viewControllers = [feedNav, exploreNav, profileNav]
    }
}

// UIKit VC push SwiftUI screen
class FeedViewController: UIViewController {
    func didTapPost(_ post: Post) {
        // Navigate sang SwiftUI detail view
        let detailView = PostDetailView(post: post)
        let detailVC = UIHostingController(rootView: detailView)
        detailVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
```

### SwiftUI View navigate ngược sang UIKit VC

```swift
struct ExploreView: View {
    var body: some View {
        List(items) { item in
            Button(item.name) {
                // Cần access UIKit navigation
                navigateToLegacyDetail(item)
            }
        }
    }
    
    private func navigateToLegacyDetail(_ item: Item) {
        // Tìm UINavigationController từ hierarchy
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController,
              let tabBar = rootVC as? UITabBarController,
              let navController = tabBar.selectedViewController as? UINavigationController
        else { return }
        
        let legacyVC = LegacyDetailViewController(item: item)
        navController.pushViewController(legacyVC, animated: true)
    }
}
```

**Cách tốt hơn: Router / Coordinator pattern**

```swift
// Router protocol
protocol AppRouter: AnyObject {
    func navigateToPostDetail(_ post: Post)
    func navigateToSettings()
    func presentLogin()
}

// SwiftUI view nhận router
struct ExploreView: View {
    weak var router: AppRouter?
    
    var body: some View {
        List(posts) { post in
            Button(post.title) {
                router?.navigateToPostDetail(post)
            }
        }
    }
}

// UIKit coordinator implement router
class MainCoordinator: AppRouter {
    let navigationController: UINavigationController
    
    func navigateToPostDetail(_ post: Post) {
        // Quyết định dùng UIKit VC hay SwiftUI view
        let detailView = PostDetailView(post: post)
        let vc = UIHostingController(rootView: detailView)
        navigationController.pushViewController(vc, animated: true)
    }
}
```

---

## 11. UIHostingController ẩn Navigation Bar

```swift
let hostingVC = UIHostingController(rootView: 
    MyView()
        .navigationTitle("Title")
        .navigationBarHidden(true)
)

// HOẶC từ UIKit side:
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
}
```

### Conflict giữa SwiftUI navigation và UIKit navigation

```swift
// ⚠️ Nếu SwiftUI View có NavigationStack bên trong
// VÀ UIHostingController nằm trong UINavigationController
// → HAI navigation bars chồng nhau!

// ❌ Double navigation bar
let nav = UINavigationController(rootViewController:
    UIHostingController(rootView:
        NavigationStack {    // ← SwiftUI nav bar
            Text("Hello")
                .navigationTitle("Title")
        }
    )
)
// UINavigationController + NavigationStack = 2 bars!

// ✅ Chọn MỘT: UIKit nav HOẶC SwiftUI nav
// Option A: dùng UINavigationController, bỏ NavigationStack
let nav = UINavigationController(rootViewController:
    UIHostingController(rootView:
        Text("Hello")    // ← KHÔNG có NavigationStack
    )
)

// Option B: dùng NavigationStack, bỏ UINavigationController
let vc = UIHostingController(rootView:
    NavigationStack {    // ← SwiftUI quản lý navigation
        Text("Hello")
            .navigationTitle("Title")
    }
)
// Present vc trực tiếp, KHÔNG wrap trong UINavigationController
```

---

## 12. Sai lầm thường gặp

### ❌ Quên addChild / didMove khi embed

```swift
// ❌ Chỉ addSubview → lifecycle events không đúng
let hostingVC = UIHostingController(rootView: MyView())
view.addSubview(hostingVC.view)
// ← onAppear, onDisappear KHÔNG chạy đúng
// ← Safe area insets có thể sai

// ✅ Đúng quy trình child VC
addChild(hostingVC)                          // 1
view.addSubview(hostingVC.view)              // 2
hostingVC.view.frame = view.bounds           // 3
hostingVC.didMove(toParent: self)            // 4
```

### ❌ Double navigation bar

```swift
// ❌ UINavigationController + NavigationStack = 2 bars
// (Giải thích ở section 11)

// ✅ Chọn 1: UIKit nav hoặc SwiftUI nav
```

### ❌ rootView replacement mất @State

```swift
// ❌ Thay rootView → @State bên trong reset
hostingVC.rootView = MyView(data: newData)
// MyView có @State var isExpanded = false
// → isExpanded reset về false mỗi lần thay rootView

// ✅ Dùng ViewModel → @Published → SwiftUI tự update
viewModel.data = newData
// → MyView giữ @State, chỉ re-render phần data thay đổi
```

### ❌ Quên background clear

```swift
// ❌ UIHostingController có background mặc định (trắng/đen)
// → Nhúng vào UIKit view có background custom → thấy viền trắng

// ✅ Clear background
hostingVC.view.backgroundColor = .clear
```

### ❌ Memory leak — quên remove child

```swift
// ❌ Replace SwiftUI content mà không cleanup
func showNewContent() {
    let newHC = UIHostingController(rootView: NewView())
    addChild(newHC)
    view.addSubview(newHC.view)
    newHC.didMove(toParent: self)
    // ← Old hosting controller vẫn là child → memory leak
}

// ✅ Remove cũ trước khi add mới
func showNewContent() {
    // Cleanup old
    oldHostingVC?.willMove(toParent: nil)
    oldHostingVC?.view.removeFromSuperview()
    oldHostingVC?.removeFromParent()
    
    // Add new
    let newHC = UIHostingController(rootView: NewView())
    addChild(newHC)
    view.addSubview(newHC.view)
    newHC.didMove(toParent: self)
    oldHostingVC = newHC
}
```

---

## 13. Tóm tắt

| Khía cạnh | Chi tiết |
|---|---|
| **Là gì?** | UIViewController subclass chứa SwiftUI View — adapter SwiftUI → UIKit |
| **Dùng khi?** | Nhúng SwiftUI View vào UIKit app (migration, mixed codebase) |
| **Khởi tạo** | `UIHostingController(rootView: someSwiftUIView)` |
| **rootView** | Property đọc/ghi — thay đổi → SwiftUI re-render |
| **Update data** | Ưu tiên ViewModel (@ObservedObject) thay vì thay rootView |
| **Sizing** | `sizeThatFits(in:)` — hỏi SwiftUI ideal size |
| **Background** | Mặc định trắng/đen — set `.clear` khi embed |
| **Child VC** | BẮT BUỘC `addChild` + `didMove(toParent:)` khi embed |
| **Navigation** | Chọn MỘT: UIKit nav HOẶC SwiftUI nav — tránh double bar |
| **Hướng ngược** | UIKit → SwiftUI: `UIViewRepresentable` / `UIViewControllerRepresentable` |
| **Migration** | Gradual: UIKit shell + SwiftUI screens qua UIHostingController |

`UIHostingController` là **adapter** nhúng SwiftUI View vào thế giới UIKit, Huy — thiết yếu cho migration gradual từ UIKit sang SwiftUI. Ba điểm cốt lõi:

**UIViewController chứa SwiftUI View.** `UIHostingController(rootView: someSwiftUIView)` tạo UIViewController bình thường → push vào `UINavigationController`, present modally, add as child VC, đặt làm root của `UIWindow` — tất cả UIKit operations đều hoạt động. SwiftUI View bên trong được render và manage bởi SwiftUI framework, UIKit chỉ cung cấp "container".

**Update data: ưu tiên ViewModel thay vì thay rootView.** `hostingVC.rootView = NewView(...)` hoạt động nhưng tạo View MỚI mỗi lần → `@State` bên trong bị reset. Cách tốt hơn: chia sẻ `ObservableObject` ViewModel giữa UIKit VC và SwiftUI View → thay đổi ViewModel property → SwiftUI tự re-render → giữ nguyên `@State` internal. UIKit VC chỉ cần `viewModel.name = "New"` thay vì tạo lại toàn bộ rootView.

**Ba sai lầm phổ biến nhất:** (1) **Double navigation bar** — `UINavigationController` + `NavigationStack` bên trong SwiftUI = 2 bars chồng nhau → chọn MỘT. (2) **Quên child VC lifecycle** — chỉ `addSubview` mà không `addChild` + `didMove(toParent:)` → `onAppear`/`onDisappear` không chạy đúng, safe area sai. (3) **Background mặc định** trắng/đen → khi embed một phần màn hình, cần `hostingVC.view.backgroundColor = .clear` để thấy background UIKit phía sau.
