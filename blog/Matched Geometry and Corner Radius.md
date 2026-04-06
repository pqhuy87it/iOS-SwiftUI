Chào bạn, bài viết **"Matched Geometry and Corner Radius"** của objc.io trình bày một vấn đề rất thường gặp trong SwiftUI: Làm sao để tạo hiệu ứng bo góc (corner radius) mượt mà khi view đang thay đổi kích thước và vị trí bằng `matchedGeometryEffect`.

Dưới đây là phần tổng hợp các ý chính và đoạn code hoàn chỉnh để bạn có thể chạy thử trực tiếp trên Xcode.

### 📝 Tổng hợp các ý chính của bài viết

1. **Vấn đề đặt ra:**
   * Khi bạn dùng `matchedGeometryEffect` để biến đổi một view nhỏ thành view to, SwiftUI thực chất đang tạo ra 2 view riêng biệt (một cái từ từ hiện ra, một cái từ từ mờ đi). 
   * Do đó, nếu bạn dùng toán tử 3 ngôi cho bo góc kiểu `.cornerRadius(large ? 32 : 8)`, nó sẽ **không có animation**. Góc bo sẽ bị giật cục và thay đổi lập tức thành 32 ngay khi bấm.

2. **Cách tiếp cận 1: Dùng Custom Transition (Khá rắc rối)**
   * Tác giả thử tạo một `Transition` tuỳ chỉnh để lấy trạng thái (phase) của animation (chẳng hạn như trạng thái `.identity`). 
   * Tuy nhiên, cách này làm thay đổi thứ tự layout. SwiftUI áp dụng transition ở bên ngoài padding hoặc frame, dẫn đến hiện tượng view bị cắt xén (clipping) sai lệch, bắt buộc lập trình viên phải đặt thứ tự các modifier cực kỳ cẩn thận mới chạy được.

3. **Cách tiếp cận 2: Dùng Animatable Environment Value (Giải pháp tối ưu)**
   * Thay vì cố ép bo góc chạy theo `matchedGeometryEffect`, tác giả tách chúng ra hoàn toàn.
   * Tạo một **Biến môi trường (Environment Value)** để lưu giá trị góc bo.
   * Tạo một **Animatable ViewModifier**. Khi có animation, Modifier này sẽ nội suy (tính toán các giá trị trung gian từ 8 lên 32) và liên tục đẩy vào biến môi trường.
   * `View` bên trong chỉ việc đọc biến môi trường đó ra và bo góc tương ứng. Kết quả là hiệu ứng diễn ra cực kỳ mượt mà.

---

### 💻 Code hoàn chỉnh (Giải pháp tối ưu - Có thể chạy ngay)

Bạn có thể copy toàn bộ đoạn code dưới đây, dán vào một file SwiftUI (ví dụ: `ContentView.swift`) để chạy thử. Mình đã tinh chỉnh lại code dùng chuẩn `EnvironmentKey` thay cho Macro `@Entry` để đảm bảo có thể chạy được trên mọi phiên bản Xcode hiện tại.

```swift
import SwiftUI

// MARK: - 1. Tạo Environment Key để lưu giá trị góc bo
struct CornerRadiusKey: EnvironmentKey {
    static let defaultValue: Double = 0
}

extension EnvironmentValues {
    var myCornerRadius: Double {
        get { self[CornerRadiusKey.self] }
        set { self[CornerRadiusKey.self] = newValue }
    }
}

// MARK: - 2. Tạo View tĩnh đọc góc bo từ Môi trường (Environment)
struct MyView: View {
    // Lắng nghe liên tục giá trị myCornerRadius thay đổi
    @Environment(\.myCornerRadius) private var cornerRadius: Double

    var body: some View {
        Rectangle()
            .fill(Color.yellow)
            .overlay {
                Text("Hello")
                    .fontWeight(.bold)
            }
            .cornerRadius(cornerRadius) // Áp dụng góc bo nhận được
    }
}

// MARK: - 3. Tạo một Animatable Modifier để thực hiện tính toán Animation
struct AnimatedCornerRadius: ViewModifier, Animatable {
    var value: Double
    
    // Thuộc tính bắt buộc của Animatable để SwiftUI biết cần tính toán giá trị nào
    var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            // Liên tục đẩy giá trị đang được animation vào environment
            .environment(\.myCornerRadius, value)
    }
}

// MARK: - 4. Màn hình chính
struct ContentView: View {
    @State private var large = false
    @Namespace private var ns
    
    var body: some View {
        VStack {
            if large {
                MyView()
                    .matchedGeometryEffect(id: "id", in: ns)
                    .padding(20)
            } else {
                MyView()
                    .matchedGeometryEffect(id: "id", in: ns)
                    .frame(width: 100, height: 50)
            }
        }
        // Áp dụng Modifier có khả năng animation
        // 32 là bo góc lớn, 8 là bo góc nhỏ
        .modifier(AnimatedCornerRadius(value: large ? 32 : 8))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle()) // Để có thể click bất kỳ đâu trên màn hình
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: large)
        .onTapGesture {
            large.toggle()
        }
    }
}

#Preview {
    ContentView()
}
```

### 🧠 Tại sao cách này lại hiệu quả?
Khi bạn gọi `.animation()`, giá trị của `large` thay đổi. SwiftUI sẽ nhờ `AnimatedCornerRadius` (do nó tuân thủ `Animatable`) tính ra các con số trung gian chạy dần từ `8` đến `32` (ví dụ: 8.5, 9.2, 15.6...). Những con số trung gian này liên tục được tuồn vào `environment(\.myCornerRadius)`. View `MyView` chộp được các số này và cập nhật độ bo của mình vào cùng lúc với lúc `matchedGeometryEffect` đang bay trên màn hình!
