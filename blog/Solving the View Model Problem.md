Chào bạn, bài viết/video **"Solving the View Model Problem (Part 1)"** của objc.io đề cập đến một trong những vấn đề đau đầu và phổ biến nhất đối với các lập trình viên sử dụng mô hình MVVM trong SwiftUI: **Quản lý vòng đời (lifetime) của ViewModel khi nó phụ thuộc vào tham số từ View cha.**

Dưới đây là tổng hợp các ý chính và đoạn code hoàn chỉnh để giải quyết vấn đề này.

### 📝 Tổng hợp các ý chính của bài viết

1. **Vấn đề cốt lõi (The View Model Problem):**
   Trong SwiftUI, chúng ta thường có một `ViewModel` cần nhận dữ liệu từ View cha (ví dụ: `UserViewModel` cần nhận `name` để khởi tạo).
   Cách viết ngây thơ nhất thường là: `UserView(viewModel: UserViewModel(name: "Chris"))`.

2. **Hiện tượng "Reset dữ liệu" do Re-render:**
   Mỗi khi View cha có bất kỳ một sự thay đổi State nào (chẳng hạn người dùng bấm một biến đếm `Stepper` ở View cha), View cha sẽ được vẽ lại (re-render). Khi đó, dòng lệnh khởi tạo `UserViewModel(name: "Chris")` lại bị gọi lại một lần nữa. 
   Hậu quả: 
   * Tốn tài nguyên vì liên tục khởi tạo object mới.
   * **Nghiêm trọng nhất:** Toàn bộ trạng thái đang có bên trong ViewModel (ví dụ: số lần user click, dữ liệu đang tải từ mạng) sẽ bị xóa sạch và reset về 0.

3. **Bất cập của các cách khắc phục thông thường:**
   * **Dùng `@StateObject` (hoặc `@State` ở iOS 17):** Nếu bạn bọc ViewModel vào `@State` để bảo vệ nó khỏi việc bị khởi tạo lại, bạn sẽ gặp một lỗi khác. Đó là `@State` chỉ lưu giá trị **lần đầu tiên**. Nếu sau này View cha muốn đổi tên từ "Chris" sang "John", ViewModel của bạn sẽ "mù và điếc", nó không nhận được tên "John" vì nó không được khởi tạo lại.
   * **Đưa ViewModel ra ngoài:** Tạo ViewModel ở tầng cao hơn rồi truyền xuống. Tuy nhiên điều này đi ngược lại triết lý khai báo của SwiftUI và bắt bạn phải tự quản lý vòng đời bộ nhớ bằng tay (rất rườm rà).

*(Lưu ý: Ở Part 2 và 3 của series này, các tác giả sẽ tự build một Macro riêng để giải quyết. Tuy nhiên, bằng API chuẩn của Apple, chúng ta vẫn có cách giải quyết triệt để vấn đề này).*

---

### 💻 Code hoàn chỉnh giải quyết "The View Model Problem"

Cách giải quyết chuẩn xác nhất bằng API mặc định của Apple hiện tại (iOS 17+ với `@Observable`) là: **Dùng `@State` để giữ cho ViewModel sống sót qua các lần re-render, và dùng `.onChange` để liên tục "bơm" dữ liệu mới từ View cha vào ViewModel.**

Bạn copy đoạn code sau và chạy thử trên Xcode nhé (yêu cầu iOS 17+):

```swift
import SwiftUI
import Observation

// MARK: - 1. View Model
@Observable 
class UserViewModel {
    var name: String
    var clicks = 0
    
    init(name: String) {
        self.name = name
        print("✅ UserViewModel được khởi tạo (Nếu dòng này in liên tục là code bị lỗi!)")
    }
}

// MARK: - 2. View Con (Xử lý vấn đề)
struct UserView: View {
    // Thuộc tính nhận từ View cha
    let name: String 
    
    // Dùng @State để bảo vệ ViewModel không bị reset khi View cha re-render
    @State private var viewModel: UserViewModel
    
    init(name: String) {
        self.name = name
        // Khởi tạo @State trong hàm init (Chỉ chạy thực sự vào lần đầu tiên View xuất hiện)
        _viewModel = State(wrappedValue: UserViewModel(name: name))
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Tên User: \(viewModel.name)")
                .font(.title2).bold()
            
            Button("Click vào tôi: \(viewModel.clicks)") {
                viewModel.clicks += 1 // Tăng state nội bộ
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        
        // 👉 CHÌA KHÓA GIẢI QUYẾT BÀI TOÁN:
        // Lắng nghe sự thay đổi của biến 'name' từ View cha.
        // Khi cha truyền 'name' mới, ta cập nhật thủ công vào ViewModel đang sống.
        .onChange(of: name) { oldValue, newValue in
            viewModel.name = newValue
            print("🔄 ViewModel đã cập nhật tên mới thành: \(newValue)")
        }
    }
}

// MARK: - 3. View Cha (Môi trường test)
struct ContentView: View {
    @State private var parentCounter = 0
    @State private var userName = "Chris"
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Giải quyết View Model Problem")
                .font(.headline)
            
            // Truyền tham số cho View con
            UserView(name: userName)
            
            Divider()
            
            // Bảng điều khiển của View Cha để Test
            VStack(spacing: 20) {
                Text("Khu vực của View Cha")
                    .foregroundColor(.gray)
                
                // TEST 1: Bấm nút này sẽ làm ContentView re-render.
                // Thành công: Nút bấm bên trong UserView KHÔNG bị reset về 0.
                Stepper("Tương tác làm cha re-render: \(parentCounter)", value: $parentCounter)
                
                // TEST 2: Đổi tham số truyền vào
                // Thành công: Tên bên trong UserView thay đổi theo mà không bị mất số click.
                HStack {
                    Button("Đổi tên thành 'John'") { userName = "John" }
                    Spacer()
                    Button("Đổi tên 'Anna'") { userName = "Anna" }
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
```

### 💡 Tại sao kiến trúc này lại thành công?
1. Khi bạn bấm cái **Stepper** ở View cha, View cha vẽ lại, nó gọi lại dòng `UserView(name: userName)`. 
2. Hàm `init` của `UserView` bị gọi lại, nhưng vì `viewModel` được đánh dấu là `@State`, SwiftUI đủ thông minh để **bỏ qua** việc gán giá trị mới, giúp cho biến `clicks` vẫn được giữ nguyên. (Bạn có thể kiểm tra ở cửa sổ Console, dòng chữ ✅ chỉ hiện đúng 1 lần).
3. Khi bạn bấm nút **Đổi tên**, View cha truyền tên mới vào. Modifier `.onChange(of: name)` chộp được sự thay đổi này và ghi đè cái tên mới vào trong class ViewModel. Bạn đạt được cả 2 mục đích: **Giữ được trạng thái cũ + Nhận được dữ liệu mới!**
