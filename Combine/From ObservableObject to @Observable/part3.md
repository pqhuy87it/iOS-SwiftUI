Chào bạn! Bài viết **Phần 3** trong series của `flyingharley.dev` đi sâu vào phân tích cuộc cách mạng thực sự của SwiftUI: **Sự dịch chuyển từ `ObservableObject` (Combine) sang framework Observation nguyên bản (`@Observable`)**. 

Tác giả đã chỉ ra những "nỗi đau" của kiến trúc cũ và cách `@Observable` giải quyết chúng một cách triệt để. Dưới đây là tóm tắt các ý chính và đoạn code hoàn chỉnh minh họa chính xác ví dụ mà tác giả đã đề cập:

### 1. Tóm tắt ý chính của bài viết (Phần 3)

* **Vấn đề của thời kỳ cũ (Combine Era):**
  * **Cơ chế Push-based gây cập nhật dư thừa (Over-invalidation):** Kiến trúc cũ dựa vào tín hiệu `objectWillChange`. Tác giả lấy ví dụ: Một màn hình Profile có *Header* hiển thị tên người dùng (username) và *Footer* hiển thị thanh tiến trình tải xuống (downloadProgress). Khi tiến trình tải xuống cập nhật liên tục, **toàn bộ View** (bao gồm cả Header không liên quan) cũng bị ép vẽ lại (re-render), làm giảm hiệu năng nghiêm trọng đối với các app lớn.
  * **Lỗi với mô hình lồng nhau (Nested Observable Objects):** Nếu ViewModel cha chứa một ViewModel con (Nested), khi biến ở con thay đổi, ViewModel cha sẽ **không** tự động báo cho View biết. Lập trình viên phải tự viết các đoạn code "chuyển tiếp" (manual forwarding) rất cực nhọc.

* **Sức mạnh của `@Observable` (Từ Swift 5.9 / iOS 17):**
  * **Cơ chế Pull-based & Theo dõi truy cập (Access-tracked):** Framework mới này mang đến **Tính chính xác tuyệt đối (Precise Invalidation)**. SwiftUI giờ đây theo dõi xem View nào đang thực sự "đọc" thuộc tính nào. Nếu `downloadProgress` thay đổi, **chỉ có** khu vực Footer bị vẽ lại, còn Header chứa `username` sẽ hoàn toàn đứng im.
  * **Tự động hỗ trợ Nested Models:** Các mô hình tham chiếu lồng nhau (nested reference models) giờ đây hoạt động hoàn hảo mà không cần viết thêm bất kỳ dòng code thủ công nào.

---

### 2. Đoạn code thực chiến giải quyết bài toán của tác giả

Dưới đây là đoạn code hoàn chỉnh mô phỏng chính xác ví dụ **Profile View** (với Username và DownloadProgress) mà tác giả đã nhắc đến trong bài. Nó chứng minh khả năng xử lý **Nested Model** và **Precise Invalidation** của `@Observable`.

Bạn hãy copy đoạn code này vào Xcode (iOS 17+) để chạy thử:

```swift
import SwiftUI
import Observation

// MARK: - 1. CHILD MODEL (Nested Object)
// Lớp con quản lý tiến trình tải xuống
@Observable
class DownloadTask {
    var progress: Double = 0.0
    var isDownloading: Bool = false
    
    func startDownload() {
        isDownloading = true
        progress = 0.0
        
        // Giả lập tiến trình tải xuống chạy liên tục (high-frequency updates)
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.progress < 100 {
                self.progress += 2
            } else {
                self.isDownloading = false
                timer.invalidate()
            }
        }
    }
}

// MARK: - 2. PARENT VIEW MODEL
// Lớp cha chứa thông tin User và chứa luôn Lớp con bên trong
@Observable
class UserProfileViewModel {
    var username: String = "Harley Pham"
    
    // Tự động hỗ trợ Nested Object (Mô hình lồng nhau) mà không cần code phức tạp
    var downloader: DownloadTask = DownloadTask()
}

// MARK: - 3. MAIN VIEW
struct ProfileView: View {
    // Khởi tạo ViewModel cha bằng @State (Chuẩn mới từ iOS 17)
    @State private var viewModel = UserProfileViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            
            // --- HEADER ---
            // Khu vực này chỉ đọc 'username'.
            // KHI PROGRESS THAY ĐỔI, KHU VỰC NÀY SẼ KHÔNG BỊ VẼ LẠI!
            HeaderView(username: viewModel.username)
            
            Divider()
            
            // --- FOOTER ---
            // Khu vực này đọc 'downloader'. Nó sẽ tự động vẽ lại liên tục khi tải xuống.
            FooterView(downloadTask: viewModel.downloader)
            
        }
        .padding()
    }
}

// MARK: - 4. SUB-VIEWS

struct HeaderView: View {
    let username: String
    
    var body: some View {
        // Bạn có thể check console: Dòng này chỉ in ra 1 lần duy nhất khi View khởi tạo!
        let _ = print("✅ HeaderView đã render!") 
        
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("Xin chào, \(username)!")
                .font(.title)
                .fontWeight(.bold)
        }
    }
}

struct FooterView: View {
    // Không cần @ObservedObject, chỉ cần khai báo biến bình thường!
    var downloadTask: DownloadTask 
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tiến trình tải xuống: \(Int(downloadTask.progress))%")
                .font(.headline)
            
            ProgressView(value: downloadTask.progress, total: 100)
                .progressViewStyle(.linear)
                .tint(.green)
            
            Button(action: {
                downloadTask.startDownload()
            }) {
                Text(downloadTask.isDownloading ? "Đang tải..." : "Bắt đầu tải")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(downloadTask.isDownloading ? Color.gray : Color.green)
                    .cornerRadius(10)
            }
            .disabled(downloadTask.isDownloading || downloadTask.progress >= 100)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
}
```

### 💡 Điểm "Ăn Tiền" Của Đoạn Code:
1. **Kiểm chứng Precise Invalidation:** Trong hàm `body` của `HeaderView`, mình có đặt một dòng `print("✅ HeaderView đã render!")`. Khi bạn bấm nút "Bắt đầu tải", thanh tiến trình ở `FooterView` sẽ chạy mượt mà, nhưng console sẽ **không hề** in ra thêm dòng chữ nào. Điều đó chứng tỏ `HeaderView` không hề bị ảnh hưởng bởi việc cập nhật UI của thằng khác!
2. **Kiểm chứng Nested Model:** Biến `downloader` nằm lồng bên trong `UserProfileViewModel`. SwiftUI dễ dàng thấu hiểu và lắng nghe sự thay đổi của biến con này mà không bắt bạn phải viết thêm bất kỳ dòng code `objectWillChange.send()` thủ công nào như thời dùng Combine nữa.
