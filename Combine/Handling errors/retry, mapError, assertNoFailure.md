Chào bạn! Chúng ta đang khép lại series các toán tử Combine với 3 "bảo bối" cuối cùng trong nhóm Xử lý lỗi (Error Handling): **`retry`**, **`mapError`** và **`assertNoFailure`**.

Nếu `catch` là "giăng lưới tạo cầu dự phòng", thì:
* **`retry`**: "Ngã ở đâu, đứng lên làm lại ở đó" (Tự động thử lại luồng).
* **`mapError`**: "Phiên dịch viên" (Biến lỗi hệ thống thành lỗi người dùng dễ hiểu).
* **`assertNoFailure`**: "Lời thề sắt đá" (Đảm bảo 100% không có lỗi, nếu có thì đập nát app - giống hệt việc force unwrap `!` trong Swift).

Dưới đây là phần code bổ sung để bạn ghép vào `CombineOperatorsView`:

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn thêm 3 `NavigationLink` này vào cuối danh sách nhé:

```swift
import SwiftUI
import Combine

// Helper class để đếm số lần thử lại cho ví dụ retry
class RetryTracker {
    var attempts = 0
}

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn) ...

                // 1. NavigationLink cho retry
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Retry",
                        description: ".retry(2)",
                        comparingPublisher: self.retryPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Retry").font(.headline)
                        Text("Khi gặp lỗi, tự động đăng ký lại luồng từ đầu").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho mapError
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "MapError",
                        description: ".mapError { đổi lỗi A thành lỗi B }",
                        comparingPublisher: self.mapErrorPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("MapError").font(.headline)
                        Text("Chuyển đổi kiểu lỗi (vd: từ lỗi mạng sang lỗi UI)").font(.caption).foregroundColor(.gray)
                    }
                }

                // 3. NavigationLink cho assertNoFailure
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "AssertNoFailure",
                        description: ".assertNoFailure()",
                        comparingPublisher: self.assertNoFailurePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("AssertNoFailure").font(.headline)
                        Text("Cam kết không có lỗi. Nếu có, Crash App ngay lập tức!").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // Các lỗi dùng để test
    enum NetworkError: Error {
        case timeout
        case serverDown
    }
    
    enum UIError: Error {
        case friendlyMessage(String)
    }

    // MARK: - 1. Hàm Retry
    func retryPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        let tracker = RetryTracker()
        
        return publisher
            .tryMap { value -> String in
                // Giả lập mạng chập chờn: 2 lần đầu tiên khi chạm mốc số 3 đều bị văng lỗi.
                // Đến lần thứ 3 mới cho qua.
                if value == "3" && tracker.attempts < 2 {
                    tracker.attempts += 1
                    throw NetworkError.timeout
                }
                return value
            }
            // 👉 Tính năng ma thuật: Thử kết nối lại tối đa 2 lần nếu luồng bị lỗi
            .retry(2)
            .catch { _ in Just("Lỗi vĩnh viễn") } // Nếu sau 2 lần retry vẫn lỗi, thì giăng lưới catch
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm MapError
    func mapErrorPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .tryMap { value -> String in
                if value == "4" {
                    // Hệ thống ném ra một lỗi kĩ thuật (NetworkError)
                    throw NetworkError.serverDown
                }
                return value
            }
            // 👉 "Phiên dịch" lỗi: Đổi từ NetworkError khô khan sang UIError thân thiện
            .mapError { originalError -> UIError in
                return UIError.friendlyMessage("Bảo trì Server")
            }
            // Bắt cái UIError đó để in lên màn hình
            .catch { error -> Just<String> in
                if case let UIError.friendlyMessage(msg) = error {
                    return Just(msg)
                }
                return Just("Lỗi không xác định")
            }
            .eraseToAnyPublisher()
    }

    // MARK: - 3. Hàm AssertNoFailure
    func assertNoFailurePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // setFailureType để giả vờ luồng này CÓ THỂ xảy ra lỗi (Error)
            .setFailureType(to: Error.self)
            
            // 👉 Lời thề: "Tôi cá 100% luồng này không bao giờ có lỗi. Nếu có, hãy crash app!"
            // Toán tử này sẽ ép kiểu luồng từ <String, Error> về lại thành <String, Never>
            .assertNoFailure("Cảnh báo: Nếu thấy dòng này trên console nghĩa là App đã bị Crash!")
            .eraseToAnyPublisher()
    }
}
```

### 💡 Trải nghiệm thực tế và Ứng dụng:

#### 1. Sự kiên trì của `retry`
* **Bạn sẽ thấy hiện tượng rất thú vị:**
  * Luồng gốc chạy `1, 2`. Đến số `3`, nó bị lỗi Timeout.
  * Lập tức `retry` bắt tay vào việc: Nó xé bỏ hợp đồng cũ và **KẾT NỐI LẠI TỪ ĐẦU (Resubscribe)** với luồng gốc.
  * Luồng dưới sẽ hiện tiếp `1, 2`. Đến số `3` lại bị lỗi lần nữa.
  * `retry` thử lại lần 2 (cũng là lần cuối). Nó lại chạy `1, 2`. Lần này bộ đếm đã đủ, số `3` lọt qua!
  * **Kết quả hiển thị trên màn hình của bạn sẽ là:** `1`, `2`, `1`, `2`, `1`, `2`, `3`, `4`, `5`.
* **Thực chiến:** LUÔN LUÔN đính kèm `.retry(1)` hoặc `.retry(2)` vào sau các luồng gọi API tải ảnh hoặc call Network. Vì mạng di động 4G rất hay rớt gói tin nhỏ, việc tự động gọi lại 1-2 lần giúp app "trâu bò" và mượt mà hơn rất nhiều trong mắt người dùng.

#### 2. Phiên dịch viên `mapError`
* **Cách chạy:** Khi đến số `4`, `tryMap` ném ra lỗi `NetworkError.serverDown`. `mapError` tóm lấy lỗi đó, chặn không cho truyền xuống dưới, mà bọc nó lại thành `UIError.friendlyMessage("Bảo trì Server")`. Khối `.catch` cuối cùng hứng được lỗi này và hiện ra chữ **"Bảo trì Server"**.
* **Thực chiến:** Đây là chuẩn mực Kiến trúc (Clean Architecture). Tầng Data/Network ném ra các lỗi như `URLError`, `DecodingError`. Nhưng View thì không được biết mấy lỗi đó là gì. Bạn dùng `mapError` ở ViewModel để "phiên dịch" tất cả các loại lỗi kỹ thuật đó thành `MyAppError` có chứa các câu thông báo thân thiện như *"Vui lòng kiểm tra lại 4G"*.

#### 3. Lệnh tử hình `assertNoFailure`
* **Cách chạy:** Khi bạn chạy test này, bóng `1, 2, 3, 4, 5` đi qua rất mượt mà vì chúng ta KHÔNG gài bẫy `throw` nào cả.
* **Cảnh báo Crash:** Nếu ở trên `assertNoFailure` bạn cố tình gắn thêm một lệnh `.tryMap { ... throw ... }`, ngay khi dẫm phải lỗi đó, **App của bạn sẽ văng ra (Crash) ngay lập tức** y hệt như khi bạn gọi `fatalError()` hoặc dùng mảng vượt quá index.
* **Thực chiến:** Được dùng trong những trường hợp bạn chắc chắn 100% logic của mình đúng, nhưng Compiler của Swift không tin bạn. Thay vì phải viết `.catch { return Just("") }` một cách giả tạo, bạn dùng `.assertNoFailure()` để ép luồng từ `Error` về `Never` một cách quyết đoán nhất!

Bộ ví dụ của bạn thực sự đã trở thành một "Từ điển sống" cực kì tuyệt vời cho Combine rồi đó!
