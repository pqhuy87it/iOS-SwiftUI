Chào bạn! Nối tiếp nhóm toán tử tham lam ở phần trước, chúng ta có **`min`** và **`tryMin`**.

Cơ chế hoạt động của chúng hoàn toàn giống hệt `max` và `tryMax`, chỉ khác là thay vì tìm giá trị lớn nhất, chúng đi tìm **giá trị nhỏ nhất** trong suốt vòng đời của luồng (Stream). Chúng cũng sẽ "nuốt" toàn bộ dữ liệu và **chỉ phát ra một kết quả duy nhất khi luồng gốc đã hoàn thành (Finished)**.

Dưới đây là phần code bổ sung để bạn ghép vào `CombineOperatorsView` của mình:

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn thêm 2 `NavigationLink` này vào bên dưới các ví dụ trước:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn như max, count...) ...

                // 1. NavigationLink cho min
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Min",
                        description: ".min()",
                        comparingPublisher: self.minPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Min").font(.headline)
                        Text("Tìm giá trị nhỏ nhất (Chỉ phát khi kết thúc)").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho tryMin
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryMin",
                        description: ".tryMin { ném lỗi nếu thấy số 4 }",
                        comparingPublisher: self.tryMinPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryMin").font(.headline)
                        Text("Tìm min nhưng ném lỗi nếu vi phạm điều kiện").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // MARK: - 1. Hàm Min
    func minPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // Chuyển String thành Int để so sánh chính xác theo giá trị số
            .map { Int($0) ?? 0 }
            // Tìm giá trị nhỏ nhất. Nó sẽ chờ luồng gốc kết thúc mới phát ra kết quả.
            .min()
            .map { String($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm TryMin
    enum MinError: Error {
        case illegalValue
    }

    func tryMinPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            // tryMin cho phép tự định nghĩa thế nào là "nhỏ hơn" và ném lỗi nếu cần
            .tryMin { currentMin, newValue -> Bool in
                // Giả lập luật cấm: Nếu gặp số 4, hệ thống từ chối tính toán tiếp và báo lỗi
                if newValue == 4 || currentMax == 4 {
                    throw MinError.illegalValue
                }
                
                // Trả về true nếu newValue NHỎ HƠN currentMin
                // (Đừng nhầm với tryMax là currentMax < newValue nhé)
                return newValue < currentMin 
            }
            .map { String($0) }
            // Bắt lỗi và hiện thông báo lên UI
            .catch { _ in Just("Lỗi") }
            .eraseToAnyPublisher()
    }
}
```

### 💡 Trải nghiệm thực tế khi bạn chạy Test:

#### 1. Sự chờ đợi của `min()`
* **Cách chạy:** Luồng trên chạy `1, 2, 3, 4, 5`. Luồng dưới đứng im. Combine đang ghi nhớ số `1` là nhỏ nhất. Khi số 5 chạy xong (kết thúc), luồng dưới sẽ "chốt đơn" và ném ra đúng một quả bóng mang số **`1`**.
* **Thực chiến:** Tương tự như `max`, bạn dùng nó để phân tích dữ liệu hàng loạt (như tìm "Sản phẩm có giá rẻ nhất" từ một danh sách tải về). Nếu nguồn phát là vô hạn (như dữ liệu giá cổ phiếu cập nhật realtime), `min` sẽ không bao giờ chạy vì nó mãi chờ tín hiệu kết thúc. Nếu cần tìm min theo thời gian thực (chạy tới đâu update tới đó), bạn phải dùng `scan`.

#### 2. Kẻ hủy diệt `tryMin`
* **Cách chạy:** Quá trình tìm kiếm diễn ra âm thầm ở hậu trường:
    * Nhận `1`, min = 1
    * Nhận `2`, min vẫn là 1
    * Nhận `3`, min vẫn là 1
    * Nhận `4` ➔ Chạm nọc! Lệnh `throw MinError.illegalValue` được kích hoạt.
* Ngay lúc đó, hợp đồng Combine bị xé bỏ. Luồng nhảy vào block `.catch` và ném ra chữ **"Lỗi"**. Kết quả là bạn sẽ không bao giờ thấy được số 1 (dù nó thực sự là số nhỏ nhất), vì luồng đã bị ép dừng đột ngột.
