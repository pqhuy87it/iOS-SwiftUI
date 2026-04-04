Chào bạn! Nhóm toán tử hôm nay chúng ta tìm hiểu là sự kết hợp của **`prepend`** (chèn vào đầu), nhóm **`prefix`** (trái ngược hoàn toàn với `drop`), và **`output`** (lấy theo vị trí). 

Nếu `drop` là "cánh cổng ban đầu đóng, sau mới mở", thì `prefix` là **"cánh cổng ban đầu mở toang, nhưng hễ có biến là đóng sập vĩnh viễn"**.

Dưới đây là đoạn code để bạn bổ sung vào `CombineOperatorsView`:

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn tiếp tục thêm 5 `NavigationLink` này vào bên dưới các ví dụ trước:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn) ...

                // 1. NavigationLink cho prepend
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Prepend",
                        description: ".prepend(\"0\")",
                        comparingPublisher: self.prependPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Prepend").font(.headline)
                        Text("Chèn thêm phần tử vào ngay đầu luồng").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho prefixUntilOutput
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "PrefixUntil",
                        description: ".prefix(untilOutputFrom: trigger)",
                        comparingPublisher: self.prefixUntilPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("PrefixUntilOutput").font(.headline)
                        Text("Lấy dữ liệu cho đến khi luồng khác lên tiếng thì ngắt").font(.caption).foregroundColor(.gray)
                    }
                }

                // 3. NavigationLink cho prefixWhile
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "PrefixWhile",
                        description: ".prefix(while: { $0 < 4 })",
                        comparingPublisher: self.prefixWhilePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("PrefixWhile").font(.headline)
                        Text("Lấy dữ liệu chừng nào điều kiện còn ĐÚNG").font(.caption).foregroundColor(.gray)
                    }
                }

                // 4. NavigationLink cho tryPrefixWhile
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryPrefixWhile",
                        description: ".tryPrefix(while: { ném lỗi nếu là 3 })",
                        comparingPublisher: self.tryPrefixWhilePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryPrefixWhile").font(.headline)
                        Text("Lấy dữ liệu, nhưng có quyền ném lỗi đóng luồng").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 5. NavigationLink cho output
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Output",
                        description: ".output(at: 2)",
                        comparingPublisher: self.outputPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Output(at:)").font(.headline)
                        Text("Chỉ lấy đúng phần tử ở vị trí Index chỉ định").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // MARK: - 1. Hàm Prepend
    func prependPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // Chèn giá trị "0" vào trước khi luồng gốc kịp phát ra bất cứ thứ gì.
            // Bạn có thể chèn 1 mảng bằng .prepend(["-2", "-1", "0"])
            .prepend("0")
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm PrefixUntilOutput
    func prefixUntilPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        // Tạo một trigger bắn tín hiệu sau 2.5 giây
        let trigger = Just("Stop")
            .delay(for: .seconds(2.5), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return publisher
            // Cho phép dữ liệu đi qua thoải mái, nhưng hễ trigger kêu "Stop" là đóng sập cửa (Finished)
            .prefix(untilOutputFrom: trigger)
            .eraseToAnyPublisher()
    }

    // MARK: - 3. Hàm PrefixWhile
    func prefixWhilePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            // Cho phép lọt qua nếu điều kiện là TRUE.
            // Hễ gặp FALSE lần đầu tiên -> Đóng sập cửa, Finished luồng, hủy các phần tử sau.
            .prefix(while: { value in
                value < 4
            })
            .map { String($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - 4. Hàm TryPrefixWhile
    enum PrefixError: Error {
        case fatalBreak
    }

    func tryPrefixWhilePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            .tryPrefix(while: { value -> Bool in
                // Gài bẫy: Đang yên đang lành nếu dẫm phải số 3 -> Ném lỗi sập luồng
                if value == 3 {
                    throw PrefixError.fatalBreak
                }
                return value < 5
            })
            .map { String($0) }
            .catch { _ in Just("Lỗi") } // Bắt lỗi lên UI
            .eraseToAnyPublisher()
    }
    
    // MARK: - 5. Hàm Output
    func outputPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // Chỉ lấy duy nhất phần tử ở vị trí Index thứ 2 (Tức là phần tử thứ 3 xuất hiện, vì đếm từ 0).
            // Lấy xong lập tức Finished luồng.
            .output(at: 2)
            .eraseToAnyPublisher()
    }
}
```

### 💡 Trải nghiệm thực tế khi bạn chạy Test:

#### 1. Kẻ chen ngang `prepend`
* **Cách chạy:** Ngay khoảnh khắc bạn bấm Subscribe (chưa đầy 1 giây), quả bóng số **`0`** đã lập tức rớt xuống ở luồng dưới. Sau đó 1 giây, luồng gốc mới bắt đầu đẻ ra `1, 2, 3, 4, 5`.
* **Thực chiến:** Rất hay dùng để set "trạng thái khởi tạo" (Initial State) cho UI trước khi data thực sự load xong từ mạng (ví dụ chèn một model có trạng thái `isLoading = true` lên đầu).

#### 2. Chiếc máy chém thời gian `prefix(untilOutputFrom:)`
* **Cách chạy:** Đây là đối thủ không đội trời chung với `dropUntil`.
  * Giây 1, 2: Cửa đang mở toang, bóng `1, 2` lọt qua.
  * Giây 2.5: Luồng Trigger bắn tín hiệu `"Stop"`. Lập tức Combine kéo cầu dao, kết thúc luồng.
  * Giây 3, 4, 5: Luồng gốc dù có phát tiếp `3, 4, 5` thì cửa đã bị khóa chặt, không có gì lọt qua được nữa.
* **Thực chiến:** Cực kỳ hữu ích trong iOS để ngắt các luồng lắng nghe khi View bị hủy. Ví dụ: `.prefix(untilOutputFrom: viewDidDisappearPublisher)`.

#### 3. Chơi theo luật `prefix(while:)`
* **Cách chạy:** Luật là `value < 4`.
  * Số 1, 2, 3: Đều nhỏ hơn 4 -> Đi qua trót lọt.
  * Số 4: Vi phạm luật (`4 < 4` là sai). Ngay khoảnh khắc số 4 chạm cổng, cổng đóng sập lại mãi mãi. Luồng gửi tín hiệu Finished. Số 5 bị bỏ rơi phía sau.

#### 4. Cái bẫy `tryPrefix(while:)`
* **Cách chạy:** Đang đi qua mượt mà ở `1` và `2`. Vừa bước tới số `3`, lệnh `throw` bị kích hoạt. Thay vì kết thúc luồng êm đẹp như `prefixWhile`, nó đập nát luồng và ném ra chữ **"Lỗi"** ở block `.catch`.

#### 5. Bắn tỉa `output(at:)`
* **Cách chạy:** Index 0 là số 1, Index 1 là số 2, Index 2 là số 3.
* Luồng dưới đứng im ở giây 1 và 2. Đến giây thứ 3, nó chộp ngay quả bóng số **`3`**, hiển thị lên, và lập tức Finished (xé hợp đồng với luồng gốc). Số 4 và 5 sẽ không bao giờ xuất hiện.
* **Mở rộng:** Ngoài `at:`, Combine còn cung cấp `.output(in: 1...3)` để lấy một dải phần tử (từ index 1 đến 3) rồi kết thúc. Rất tiện lợi!
