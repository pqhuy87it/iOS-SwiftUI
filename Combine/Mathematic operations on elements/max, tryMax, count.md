Chào bạn! Ba toán tử tiếp theo mà bạn nhắc đến (`max`, `tryMax`, `count`) thuộc nhóm **Toán tử tham lam (Greedy Operators)**. 

Tại sao lại gọi là "tham lam"? Bởi vì chúng sẽ **nuốt toàn bộ** dữ liệu đầu vào và **tuyệt đối không phát ra bất kỳ kết quả nào** cho đến khi luồng gốc chính thức thông báo "Đã hoàn thành" (Finished).

Dưới đây là phần code bổ sung để bạn ghép vào `CombineOperatorsView` của mình:

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn thêm các `NavigationLink` này vào bên dưới các ví dụ trước:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn) ...

                // 1. NavigationLink cho max
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Max",
                        description: ".max()",
                        comparingPublisher: self.maxPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Max").font(.headline)
                        Text("Tìm giá trị lớn nhất (Chỉ phát khi kết thúc)").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho tryMax
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryMax",
                        description: ".tryMax { ném lỗi nếu thấy số 4 }",
                        comparingPublisher: self.tryMaxPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryMax").font(.headline)
                        Text("Tìm max nhưng ném lỗi nếu vi phạm điều kiện").font(.caption).foregroundColor(.gray)
                    }
                }

                // 3. NavigationLink cho count
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Count",
                        description: ".count()",
                        comparingPublisher: self.countPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Count").font(.headline)
                        Text("Đếm số lượng phần tử (Chỉ phát khi kết thúc)").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // MARK: - 1. Hàm Max
    func maxPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // Chuyển String thành Int để so sánh độ lớn (Nếu để String nó sẽ so sánh theo bảng chữ cái)
            .map { Int($0) ?? 0 }
            // Tìm giá trị lớn nhất trong suốt vòng đời của luồng
            .max()
            .map { String($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm TryMax
    enum MaxError: Error {
        case illegalValue
    }

    func tryMaxPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            // tryMax cho phép chúng ta tự định nghĩa logic so sánh (đâu là số lớn hơn)
            // Đồng thời cho phép ném lỗi nếu phát hiện dữ liệu bất thường
            .tryMax { currentMax, newValue -> Bool in
                // Giả lập: Nếu phát hiện số 4 truyền vào, hệ thống báo lỗi ngay lập tức
                if newValue == 4 || currentMax == 4 {
                    throw MaxError.illegalValue
                }
                
                // Trả về true nếu newValue lớn hơn currentMax (Logic so sánh bình thường)
                return currentMax < newValue
            }
            .map { String($0) }
            .catch { _ in Just("Lỗi") } // Hứng lỗi và in ra UI
            .eraseToAnyPublisher()
    }

    // MARK: - 3. Hàm Count
    func countPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // Chỉ đơn giản là đếm xem có bao nhiêu phần tử đã lọt qua luồng này
            .count()
            .map { String($0) }
            .eraseToAnyPublisher()
    }
}
```

### 💡 Trải nghiệm thực tế khi bạn chạy Test:

#### 1. Sự chờ đợi của `max()`
* **Cách chạy:** Khi luồng trên bắt đầu đẻ bóng `1, 2, 3, 4, 5`, luồng dưới không hề nhúc nhích. Hệ thống đang âm thầm ghi nhớ xem số nào lớn nhất. Chỉ khi luồng trên kết thúc, luồng dưới mới ném ra quả bóng duy nhất là số **`5`**.
* **Thực chiến:** Bạn dùng khi cần quét một tệp log tải về từ mạng và muốn tìm ra "Nhiệt độ cao nhất trong ngày", "Giao dịch có số tiền lớn nhất". Nhớ kỹ là nó chỉ hoạt động với các luồng **có điểm kết thúc (Finite Stream)**, nếu bạn dùng `.max()` để theo dõi vị trí chuột, nó sẽ không bao giờ trả về kết quả vì luồng chuột là luồng vô hạn (Infinite Stream).

#### 2. Kẻ khó tính `tryMax`
* **Cách chạy:** Combine liên tục so sánh để cập nhật `currentMax`.
    * Nhận `1`, max = 1
    * Nhận `2`, max = 2
    * Nhận `3`, max = 3
    * Nhận `4` ➔ Hàm so sánh kích hoạt luật cấm `throw MaxError.illegalValue`. 
* Lập tức luồng bị phá hủy. Sự chờ đợi kết thúc trong thất bại. Nó nảy vào `.catch` và chỉ in ra chữ **"Lỗi"** duy nhất. Dù số 5 có lớn hơn đi chăng nữa thì nó cũng đã bị lờ đi rồi.

#### 3. Bộ đếm `count()`
* **Cách chạy:** Giống hệt `max`, luồng dưới sẽ đứng im chờ đợi. Sau 5 giây khi luồng trên chạy xong 5 quả bóng, luồng dưới mới hiển thị kết quả là **`5`** (tổng cộng 5 phần tử).
* **Thực chiến:** Giả sử bạn kết hợp `filter` và `count`: `.filter { $0 > 10 }.count()`. Nó cực kỳ hữu ích để đếm xem "Có bao nhiêu học sinh qua môn từ tệp dữ liệu điểm thi này".
