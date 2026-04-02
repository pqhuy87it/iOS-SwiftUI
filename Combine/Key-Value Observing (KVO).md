Chào bạn! Bài viết từ Apple Developer mà bạn đang tham khảo hướng dẫn cách kết hợp một tính năng rất lâu đời của Objective-C là **Key-Value Observing (KVO)** với framework hiện đại **Combine** của Swift.

Thay vì phải thiết lập các hàm `observeValue(forKeyPath:...)` rườm rà và dễ mắc lỗi bộ nhớ như ngày xưa, Combine cung cấp một API cực kỳ thanh lịch là `publisher(for:)` để biến bất kỳ thay đổi nào của thuộc tính thành một luồng dữ liệu (data stream).

### 💡 2 Điều kiện bắt buộc (Quy tắc cốt lõi):
Để KVO hoạt động được với Combine, class và thuộc tính của bạn **bắt buộc** phải tuân thủ 2 điều kiện sau của Objective-C:
1. **Class phải kế thừa từ `NSObject`**.
2. **Thuộc tính cần theo dõi phải được đánh dấu bằng từ khoá `@objc dynamic`**.

---

### 💻 Đoạn code hoàn chỉnh chạy được luôn

Dưới đây là đoạn code hoàn chỉnh minh họa cách hoạt động của tính năng này. Bạn có thể copy toàn bộ và dán vào Xcode Playground hoặc một file Swift Command Line để chạy thử và xem log in ra:

```swift
import Foundation
import Combine

// MARK: - 1. Định nghĩa Class chứa dữ liệu cần theo dõi
// Bắt buộc kế thừa NSObject
class UserSettings: NSObject {
    
    // Bắt buộc thêm @objc dynamic trước biến muốn theo dõi
    @objc dynamic var username: String
    @objc dynamic var volumeLevel: Float
    
    init(username: String, volumeLevel: Float) {
        self.username = username
        self.volumeLevel = volumeLevel
        super.init()
    }
}

// MARK: - 2. Class Quản lý và Lắng nghe (Observer)
class SettingsObserver {
    var userSettings: UserSettings
    
    // Túi chứa các "đăng ký" (subscriptions) để không bị huỷ giữa chừng
    private var cancellables = Set<AnyCancellable>()
    
    init(settings: UserSettings) {
        self.userSettings = settings
        setupBindings()
    }
    
    private func setupBindings() {
        // Theo dõi sự thay đổi của biến 'username'
        userSettings.publisher(for: \.username)
            .sink { newName in
                print("👤 [Username Changed]: Tên người dùng mới là '\(newName)'")
            }
            .store(in: &cancellables)
        
        // Theo dõi sự thay đổi của biến 'volumeLevel'
        // Bạn có thể kết hợp các toán tử của Combine (như filter) dễ dàng
        userSettings.publisher(for: \.volumeLevel)
            .filter { $0 > 0.0 } // Chỉ in ra nếu âm lượng > 0
            .sink { newVolume in
                print("🔊 [Volume Changed]: Âm lượng đang ở mức \(newVolume * 100)%")
            }
            .store(in: &cancellables)
    }
}

// MARK: - 3. Chạy thử nghiệm (Test)

// Tạo object cấu hình ban đầu
let mySettings = UserSettings(username: "Guest", volumeLevel: 0.5)

// Tạo observer để bắt đầu lắng nghe
let observer = SettingsObserver(settings: mySettings)

print("\n--- Bắt đầu thay đổi dữ liệu ---\n")

// Thay đổi dữ liệu - Combine sẽ tự động bắt được và in ra log
mySettings.username = "HuyPham"
mySettings.volumeLevel = 0.8
mySettings.volumeLevel = 0.0 // Sẽ không in ra vì đã bị .filter { $0 > 0.0 } chặn lại
mySettings.username = "Admin"
mySettings.volumeLevel = 1.0
```

### 🔍 Giải thích thêm về phương thức `publisher(for:)`
Mặc định, khi bạn gọi `publisher(for: \.tên_thuộc_tính)`, nó sẽ tự động phát ra (emit) **giá trị hiện tại ngay lập tức**, sau đó mới phát ra các **giá trị mới** mỗi khi thuộc tính đó thay đổi (tương đương với option `[.initial, .new]` trong KVO truyền thống).

Đây là một kỹ thuật tuyệt vời khi bạn phải làm việc với các API hoặc thư viện cũ của Apple (như `AVFoundation`, `OperationQueue`, v.v.) vốn dùng KVO, giúp bạn chuyển đổi luồng dữ liệu của chúng sang Combine một cách mượt mà và an toàn!
