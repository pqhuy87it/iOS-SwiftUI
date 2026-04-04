Chào bạn! Chúng ta lại tiếp tục "trang bị vũ khí" cho phòng thí nghiệm Combine của bạn. Hai toán tử hôm nay, **`measureInterval`** và **`timeout`**, đóng vai trò như những **"người gác đền thời gian"**.

Nếu nhóm `delay/debounce/throttle` dùng để *điều khiển* thời gian phát, thì nhóm này dùng để *giám sát* và *trừng phạt* nếu luồng dữ liệu vi phạm quy tắc về thời gian.

Dưới đây là phần code để bạn bổ sung vào `CombineOperatorsView` của mình:

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn thêm 2 `NavigationLink` này vào cuối danh sách nhé:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn) ...

                // 1. NavigationLink cho measureInterval
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "MeasureInterval",
                        description: ".measureInterval(using: RunLoop.main)",
                        comparingPublisher: self.measureIntervalPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("MeasureInterval").font(.headline)
                        Text("Đo lường thời gian trôi qua giữa 2 lần phát dữ liệu").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho timeout
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Timeout",
                        description: ".timeout(.seconds(2))",
                        comparingPublisher: self.timeoutPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Timeout").font(.headline)
                        Text("Chờ dữ liệu tối đa X giây, quá hạn là cắt luồng báo lỗi").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // MARK: - 1. Hàm MeasureInterval
    func measureIntervalPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // Bấm giờ xem khoảng cách giữa các quả bóng rớt xuống là bao lâu.
            // 💡 Thủ thuật: Dùng RunLoop.main thay vì DispatchQueue.main để 
            // kết quả trả về là TimeInterval (Double) đếm theo giây, rất dễ format.
            .measureInterval(using: RunLoop.main)
            .map { interval in
                // Chuyển đổi con số thời gian thành String (ví dụ: "1.0s")
                // Toán tử này NUỐT giá trị gốc (1, 2, 3...) và thay bằng Khoảng Thời Gian.
                String(format: "%.1fs", interval.magnitude)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm Timeout
    enum TimeError: Error {
        case tookTooLong
    }

    func timeoutPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // 1. Gài bẫy để test: Khi gặp số 3, ta cố tình "treo" luồng mất 5 giây
            .flatMap { value -> AnyPublisher<String, Never> in
                if value == "3" {
                    return Just(value)
                        .delay(for: .seconds(5), scheduler: DispatchQueue.main)
                        .eraseToAnyPublisher()
                }
                return Just(value).eraseToAnyPublisher()
            }
            // 2. Thiết lập tối hậu thư: Nếu luồng im lặng quá 2 giây -> NÉM LỖI TỨC KHẮC
            .timeout(.seconds(2), scheduler: DispatchQueue.main, customError: { TimeError.tookTooLong })
            
            // 3. Hứng lỗi để báo lên UI
            .catch { _ in Just("Hết giờ!") }
            .eraseToAnyPublisher()
    }
}
```

### 💡 Trải nghiệm thực tế và Ứng dụng:

#### 1. Chiếc đồng hồ bấm giờ `measureInterval`
* **Cách chạy:** Khi bạn bấm Subscribe, quả bóng `1` ở luồng trên rớt xuống, luồng dưới không quan tâm bóng số mấy, nó chỉ đo xem "Đã bao lâu kể từ lúc bắt đầu/từ quả bóng trước?". Vì luồng gốc của bạn được cài đặt phát 1 giây/lần, nên luồng dưới sẽ liên tục nhả ra các quả bóng ghi chữ **`1.0s`** (hoặc `1.1s` tùy độ trễ của máy tính).
* **Lưu ý:** Toán tử này **làm mất đi dữ liệu gốc**. Nếu bạn muốn giữ lại dữ liệu gốc để xử lý tiếp mà vẫn muốn biết thời gian, bạn không dùng toán tử này mà ghi trực tiếp mốc `Date()` vào bên trong `.map { ... }`.
* **Thực chiến:** Rất hay dùng trong việc phân tích hành vi người dùng (Analytics). Ví dụ: Đo xem người dùng mất bao nhiêu giây kể từ lúc mở màn hình cho đến khi bấm nút "Mua hàng", hoặc đo xem người dùng gõ phím nhanh cỡ nào.

#### 2. Tối hậu thư `timeout`
* **Cách chạy:** Ở ví dụ trên, ta đặt hạn chót là **2 giây**.
  * Giây 1: Bóng `1` rớt -> Qua trót lọt. Đồng hồ timeout reset về 0.
  * Giây 2: Bóng `2` rớt -> Qua trót lọt. Đồng hồ reset.
  * Lúc này, theo `flatMap` giả lập, bóng số `3` bị "kẹt mạng" và bắt hệ thống phải chờ 5 giây.
  * **BOOM!** Khi đồng hồ đếm được 2 giây mà vẫn chưa thấy tăm hơi bóng `3` đâu, `timeout` cạn kiệt kiên nhẫn. Nó lập tức kéo cầu dao, đánh sập luồng (hủy bỏ hoàn toàn việc chờ đợi). Luồng rơi vào `.catch` và nhả ra quả bóng **`Hết giờ!`**. Bóng số 3, 4, 5 vĩnh viễn không bao giờ xuất hiện nữa.
* **Thực chiến:** **Đây là toán tử bắt buộc phải có khi gọi API (Networking).** Rất nhiều ứng dụng rơi vào trạng thái "Loading xoay vòng vô tận" vì Server bị sập nhưng không trả về lỗi, khiến app cứ chờ mãi. Bạn đính kèm `.timeout(.seconds(15))` vào mỗi API để chắc chắn rằng: Quá 15 giây mà không có kết quả, tự động văng lỗi "Kết nối mạng yếu" để người dùng còn biết đường bấm thử lại!
