Chào bạn! Nhóm toán tử **`first`**, **`first(where:)`** và **`tryFirst(where:)`** chính là thái cực hoàn toàn trái ngược với nhóm "tham lam" (`max`, `min`, `reduce`) mà chúng ta đã tìm hiểu. 

Nếu `max` bắt bạn phải đợi mòn mỏi đến cuối luồng mới chịu nhả kết quả, thì nhóm `first` lại cực kỳ **"thiếu kiên nhẫn"**. Ngay khi chộp được thứ nó cần, nó sẽ lập tức phát ra giá trị đó và **xé hợp đồng (hủy luồng gốc ngay lập tức - short-circuit)**, không cần biết phía sau còn bao nhiêu dữ liệu.

Dưới đây là phần code bổ sung để bạn ghép vào `CombineOperatorsView` của mình:

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn thêm 3 `NavigationLink` này vào bên dưới các ví dụ trước:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn) ...

                // 1. NavigationLink cho first
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "First",
                        description: ".first()",
                        comparingPublisher: self.firstPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("First").font(.headline)
                        Text("Lấy phần tử đầu tiên và ngắt luồng ngay lập tức").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho firstWhere
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "FirstWhere",
                        description: ".first(where: { $0 > 3 })",
                        comparingPublisher: self.firstWherePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("FirstWhere").font(.headline)
                        Text("Lấy phần tử ĐẦU TIÊN thỏa mãn điều kiện").font(.caption).foregroundColor(.gray)
                    }
                }

                // 3. NavigationLink cho tryFirstWhere
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryFirstWhere",
                        description: ".tryFirst(where: { ném lỗi nếu là 2 })",
                        comparingPublisher: self.tryFirstWherePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryFirstWhere").font(.headline)
                        Text("Tìm theo điều kiện, ném lỗi nếu vi phạm luật").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // MARK: - 1. Hàm First
    func firstPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // Chộp lấy phần tử đầu tiên xuất hiện.
            // Sau khi lấy được, Combine tự động gọi .cancel() lên luồng gốc.
            .first()
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm FirstWhere
    func firstWherePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            // Bỏ qua các phần tử không thỏa mãn.
            // Ngay khi tìm thấy số ĐẦU TIÊN LỚN HƠN 3, lấy nó và hủy luồng.
            .first(where: { value in
                value > 3
            })
            .map { String($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - 3. Hàm TryFirstWhere
    enum FirstError: Error {
        case fatalEncounter
    }

    func tryFirstWherePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            .tryFirst(where: { value -> Bool in
                // 1. Cái bẫy: Nếu quét trúng số 2 -> NÉM LỖI VÀ ĐÓNG LUỒNG
                if value == 2 {
                    throw FirstError.fatalEncounter
                }
                
                // 2. Mục tiêu tìm kiếm: Tìm số đầu tiên lớn hơn 4
                return value > 4
            })
            .map { String($0) }
            .catch { _ in Just("Lỗi") } // Hứng lỗi lên UI
            .eraseToAnyPublisher()
    }
}
```

### 💡 Trải nghiệm thực tế khi bạn chạy Test:

#### 1. Kẻ đánh nhanh rút gọn `first()`
* **Cách chạy:** Khi bạn bấm Subscribe, luồng gốc nhả ra số `1`. Ngay tắp lự, luồng dưới bắt lấy số **`1`**, hiển thị lên màn hình, và thông báo *Finished*. Các số `2, 3, 4, 5` ở luồng gốc thậm chí còn chưa kịp sinh ra thì hợp đồng đã bị hủy bỏ.
* **Thực chiến:** Rất hay dùng khi bạn truy vấn Database (ví dụ CoreData/Realm). Database có thể trả về một luồng (stream) liên tục cập nhật, nhưng bạn chỉ muốn đọc dữ liệu đúng 1 lần lúc vừa mở app, bạn dùng `.first()` để lấy phát đầu tiên rồi ngắt kết nối để tiết kiệm bộ nhớ.

#### 2. Sự kén chọn của `first(where:)`
* **Cách chạy:** Ở đây ta đặt điều kiện `$0 > 3`.
  * Luồng gốc nhả `1` -> Bỏ qua.
  * Luồng gốc nhả `2` -> Bỏ qua.
  * Luồng gốc nhả `3` -> Bỏ qua.
  * Luồng gốc nhả `4` -> BINGO! Nó lớn hơn 3. Luồng dưới ngay lập tức hiển thị số **`4`** rồi hủy bỏ luồng gốc. Quả bóng số 5 sẽ bị chặn đứng không được sinh ra.
* **Thực chiến:** Giống như khi bạn kết nối Bluetooth. Có hàng tá thiết bị quét được xung quanh, nhưng bạn dùng `.first(where: { $0.name == "AirPods" })`. Ngay khi thấy AirPods, app sẽ kết nối và ngừng quét các thiết bị khác để đỡ tốn pin.

#### 3. Cạm bẫy của `tryFirst(where:)`
* Ở ví dụ này, mục tiêu của bạn là tìm số đầu tiên `> 4` (tức là số 5).
* Tuy nhiên, ta gài luật cấm: `if value == 2 { throw }`.
* **Cách chạy:**
  * Quả bóng `1` xuất hiện -> Chưa lớn hơn 4, bỏ qua.
  * Quả bóng `2` xuất hiện -> Dẫm phải mìn! Câu lệnh `throw` kích hoạt. Luồng sụp đổ ngay lập tức, nhảy vào block `.catch` và in ra chữ **"Lỗi"**. Cuộc tìm kiếm số 5 bị hủy bỏ hoàn toàn từ giữa chừng.
