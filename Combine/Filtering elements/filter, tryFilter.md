Chào bạn! Nhóm toán tử `filter` và `tryFilter` là những "người gác cổng" cực kỳ quen thuộc và dễ hiểu nhất trong Combine. Chức năng của chúng đúng như tên gọi: **Lọc dữ liệu**.

Dưới đây là phần code bổ sung để bạn thêm tiếp vào danh sách `List` trong `CombineOperatorsView` của mình, kèm theo giải thích chi tiết.

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn thêm 2 `NavigationLink` này vào dưới các ví dụ trước đó:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn) ...
                
                // 1. Thêm NavigationLink cho filter
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Filter",
                        description: ".filter { chỉ giữ số chẵn }",
                        comparingPublisher: self.filterPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Filter").font(.headline)
                        Text("Chỉ cho phép dữ liệu thoả mãn điều kiện đi qua").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. Thêm NavigationLink cho tryFilter
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryFilter",
                        description: ".tryFilter { ném lỗi nếu gặp số 4 }",
                        comparingPublisher: self.tryFilterPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryFilter").font(.headline)
                        Text("Lọc dữ liệu, ném lỗi đóng luồng nếu gặp giá trị cấm").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }
    
    // MARK: - 1. Hàm Filter
    func filterPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // filter yêu cầu closure trả về Bool (true/false)
            .filter { value -> Bool in
                let intValue = Int(value) ?? 0
                // Điều kiện: Chỉ cho phép các số CHẴN đi qua
                return intValue % 2 == 0 
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm TryFilter
    enum FilterError: Error {
        case forbiddenValue
    }
    
    func tryFilterPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .tryFilter { value -> Bool in
                let intValue = Int(value) ?? 0
                
                // 1. Nếu gặp số 4 -> CHỦ ĐỘNG NÉM LỖI (Đóng luồng ngay lập tức)
                if intValue == 4 {
                    throw FilterError.forbiddenValue
                }
                
                // 2. Các số còn lại: Chỉ cho phép số LỚN HƠN 1 đi qua
                return intValue > 1
            }
            .catch { _ in Just("Lỗi") } // Hứng lỗi từ throw để hiển thị lên UI
            .eraseToAnyPublisher()
    }
}
```

### 💡 Giải thích hiện tượng khi bạn chạy Test:

#### 1. Sự đơn giản của `filter`
* Closure của `filter` luôn trả về `true` (cho đi qua) hoặc `false` (chặn lại). Nó **không làm thay đổi kiểu dữ liệu** (vào là `String`, ra vẫn là `String`).
* Khi bạn chạy test: Luồng trên chạy `1, 2, 3, 4, 5`. Luồng dưới sẽ đánh giá từng số. Vì ta cài luật `intValue % 2 == 0`, nên nó chặn số 1, 3, 5 và chỉ cho **2, 4** hiện ra.

#### 2. Sự nghiêm ngặt của `tryFilter`
* Hoạt động giống `filter`, nhưng bạn có quyền xài từ khóa `throw` để báo động đỏ.
* Khi bạn chạy test:
  * Số 1: Lớn hơn 1? -> `false` (Bị chặn lại, luồng vẫn sống).
  * Số 2: Lớn hơn 1? -> `true` (Được đi qua, hiện số **2**).
  * Số 3: Lớn hơn 1? -> `true` (Được đi qua, hiện số **3**).
  * Số 4: Vi phạm luật cấm! -> `throw FilterError` -> Nhảy vào `.catch` in ra chữ **"Lỗi"** và **luồng Combine bị phá hủy hoàn toàn**. Số 5 dù có được luồng trên phát ra thì luồng dưới cũng không thèm quan tâm nữa.
* **Thực chiến:** Rất hữu ích khi xử lý luồng dữ liệu thời gian thực (như WebSockets). Bạn `filter` để chỉ lấy các tin nhắn của một User ID cụ thể, nhưng nếu phát hiện một tin nhắn có chứa mã độc (malicious payload), bạn dùng `tryFilter` để ném lỗi và ngắt ngay kết nối Socket đó để bảo vệ ứng dụng.
