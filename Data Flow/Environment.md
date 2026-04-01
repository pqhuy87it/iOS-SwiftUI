Trong SwiftUI, `@Environment` là một property wrapper giúp các View con truy cập vào các giá trị môi trường (Environment Values) được cung cấp bởi hệ thống hoặc các View cha. Nó giống như một "biến toàn cục" nhưng được quản lý theo phạm vi (scope) của View Hierarchy.

---

### 1. @Environment là gì?

Hãy tưởng tượng `@Environment` giống như việc bạn bước vào một căn phòng (View) và muốn biết:

* Trời đang sáng hay tối? (`colorScheme`)
* Cỡ chữ hệ thống đang là bao nhiêu? (`sizeCategory`)
* Ngôn ngữ hiện tại là gì? (`locale`)

Thay vì phải truyền các thông tin này qua từng lớp View (như props trong React hay init trong UIKit), bạn chỉ cần "hỏi" môi trường bằng `@Environment`.

### 2. Cách sử dụng cơ bản

Bạn khai báo biến với `@Environment` và chỉ định `KeyPath` tới giá trị bạn muốn lấy.

#### Ví dụ 1: Kiểm tra Light/Dark Mode (`colorScheme`)

```swift
import SwiftUI

struct ContentView: View {
    // 1. Khai báo biến môi trường
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Text(colorScheme == .dark ? "Đang ở Dark Mode 🌙" : "Đang ở Light Mode ☀️")
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding()
                .background(colorScheme == .dark ? Color.gray : Color.yellow)
        }
    }
}

```

* **Giải thích:** Khi người dùng đổi chế độ sáng/tối trong Settings, View này sẽ tự động được vẽ lại (re-render) với giá trị mới.

#### Ví dụ 2: Tự động dismiss (đóng) màn hình (`dismiss`)

Đây là cách phổ biến nhất để đóng một `sheet` hoặc quay lại màn hình trước trong `NavigationStack`.

```swift
struct DetailView: View {
    // Lấy hàm dismiss từ môi trường
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Button("Đóng màn hình") {
            dismiss() // Gọi hàm để đóng view
        }
    }
}

```

### 3. Các Environment Value phổ biến

SwiftUI cung cấp sẵn rất nhiều key hữu ích:

| KeyPath | Kiểu dữ liệu | Công dụng |
| --- | --- | --- |
| `\.colorScheme` | `ColorScheme` | Biết đang là Light hay Dark mode. |
| `\.dismiss` | `DismissAction` | Hàm để đóng view hiện tại. |
| `\.locale` | `Locale` | Lấy thông tin vùng miền/ngôn ngữ. |
| `\.scenePhase` | `ScenePhase` | Biết app đang active, inactive hay background. |
| `\.isEnabled` | `Bool` | Kiểm tra xem view (hoặc nút bấm) có đang bị disable không. |
| `\.horizontalSizeClass` | `UserInterfaceSizeClass` | Biết màn hình đang rộng (iPad) hay hẹp (iPhone). |

### 4. Tạo Custom Environment Key (Nâng cao)

Đôi khi bạn muốn truyền dữ liệu riêng của mình xuống toàn bộ cây View (ví dụ: Theme màu sắc của App).

**Bước 1: Tạo EnvironmentKey**

```swift
struct MyCustomColorKey: EnvironmentKey {
    static let defaultValue: Color = .blue // Giá trị mặc định
}

```

**Bước 2: Mở rộng EnvironmentValues**

```swift
extension EnvironmentValues {
    var myThemeColor: Color {
        get { self[MyCustomColorKey.self] }
        set { self[MyCustomColorKey.self] = newValue }
    }
}

```

**Bước 3: Sử dụng**

```swift
// View con lấy giá trị
struct ChildView: View {
    @Environment(\.myThemeColor) var themeColor

    var body: some View {
        Text("Hello World")
            .foregroundColor(themeColor)
    }
}

// View cha truyền giá trị xuống
struct ParentView: View {
    var body: some View {
        ChildView()
            .environment(\.myThemeColor, .red) // Truyền màu đỏ xuống
    }
}

```

### 5. Phân biệt @Environment và @EnvironmentObject

* **`@Environment`**: Dùng cho các giá trị đơn giản (String, Int, Enum, Struct) hoặc các cài đặt hệ thống có sẵn. Truy cập qua **KeyPath**.
* **`@EnvironmentObject`**: Dùng cho các Class phức tạp (ObservableObject) chứa logic dữ liệu (như UserData, AppSettings). Truy cập qua **kiểu dữ liệu Class**.

### Tổng kết

* Dùng `@Environment` để đọc các cấu hình hệ thống (Dark mode, dismiss action, locale...).
* Nó giúp code gọn gàng, tránh việc truyền tham số lồng nhau (Prop Drilling).
* View sẽ tự động cập nhật khi giá trị môi trường thay đổi.
