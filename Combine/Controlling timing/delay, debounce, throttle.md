Chào bạn! Chúng ta đang bước sang một nhóm toán tử cực kỳ quyền lực và được sử dụng nhiều bậc nhất trong thực tế: **Nhóm kiểm soát thời gian (Time-Manipulation Operators)**.

Ba toán tử **`delay`**, **`debounce`** và **`throttle`** chính là "chìa khóa" giúp app của bạn chạy mượt mà, không bị sập Server do gọi API quá nhiều, và chống lại việc người dùng bấm nút liên tục (spam click).

Vì luồng gốc của bạn đang phát ra các số `1, 2, 3, 4, 5` cách nhau **đúng 1 giây**, mình đã tinh chỉnh các tham số thời gian trong ví dụ dưới đây để bạn thấy rõ nhất sự kỳ diệu của chúng.

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn tiếp tục thêm 3 `NavigationLink` này vào cuối danh sách:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn) ...

                // 1. NavigationLink cho delay
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Delay",
                        description: ".delay(for: 2)",
                        comparingPublisher: self.delayPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Delay").font(.headline)
                        Text("Dời thời gian phát của toàn bộ luồng chậm lại X giây").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho debounce
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Debounce",
                        description: ".debounce(for: 1.5)",
                        comparingPublisher: self.debouncePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Debounce").font(.headline)
                        Text("Chờ người dùng 'ngừng tay' X giây rồi mới lấy giá trị").font(.caption).foregroundColor(.gray)
                    }
                }

                // 3. NavigationLink cho throttle
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Throttle",
                        description: ".throttle(for: 2.5)",
                        comparingPublisher: self.throttlePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Throttle").font(.headline)
                        Text("Ép nhịp độ: Chỉ nhận 1 giá trị mỗi X giây").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // MARK: - 1. Hàm Delay
    func delayPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // Giữ nguyên mọi thứ (giá trị, khoảng cách giữa các phần tử)
            // Chỉ đơn giản là dời vạch xuất phát chậm lại 2 giây.
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm Debounce
    func debouncePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // Debounce sẽ khởi động một cái đồng hồ đếm ngược 1.5 giây.
            // Mỗi khi có bóng mới rơi xuống, nó sẽ RESET đồng hồ về 1.5s.
            // Nếu đồng hồ đếm được về 0 (tức là đã yên tĩnh được 1.5s), nó mới nhả quả bóng gần nhất ra.
            .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - 3. Hàm Throttle
    func throttlePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // Throttle ép luồng phải chạy theo một nhịp điệu cố định (ở đây là 2.5 giây).
            // Trong khoảng thời gian 2.5s đó, ai chen vào sẽ bị nuốt chửng. 
            // Hết 2.5s, nó sẽ lấy phần tử MỚI NHẤT (latest: true) để nhả ra.
            .throttle(for: .seconds(2.5), scheduler: DispatchQueue.main, latest: true)
            .eraseToAnyPublisher()
    }
}
```

### 💡 Trải nghiệm thực tế và Ứng dụng kinh điển:

#### 1. Sự "cao su" của `delay`
* **Cách chạy:** Bấm Subscribe. Luồng trên lập tức rớt bóng `1, 2, 3...`. Luồng dưới đứng im. Phải đúng **2 giây sau**, bóng `1` ở luồng dưới mới rớt xuống, và nó cứ rớt đều đặn `2, 3, 4, 5` song song với luồng trên nhưng luôn **đi trễ 2 nhịp**.
* **Thực chiến:** Làm hiệu ứng UI. Ví dụ bạn muốn hiện nút "Bỏ qua quảng cáo" (Skip Ad) nhưng bắt người dùng phải đợi 5 giây mới được bấm. Bạn dùng `.delay(for: 5)` để kích hoạt trạng thái hiển thị nút.

#### 2. Tính nhẫn nại của `debounce` (Cực kỳ quan trọng)
* **Cách chạy:** Ở đây ta cài đặt `.debounce(1.5)`. 
  * Giây 1: Luồng trên nhả `1`. Đồng hồ bắt đầu đếm ngược 1.5s.
  * Giây 2: Đồng hồ đếm mới được 1 giây thì luồng trên lại nhả bóng `2`. Đồng hồ bị **reset** đếm lại 1.5s từ đầu. Bóng 1 bị vứt bỏ!
  * Tương tự, bóng 3 và 4 cũng làm đồng hồ bị reset liên tục. Luồng dưới vẫn trống trơn.
  * Giây 5: Luồng trên nhả bóng `5` và **Kết thúc**.
  * Lúc này không còn ai quấy rầy nữa. Đồng hồ yên ổn đếm đủ 1.5s. Luồng dưới thình lình nhả ra đúng 1 quả bóng **`5`**.
* **Thực chiến:** **Đây là thuật toán làm thanh Tìm Kiếm (Search Bar)!** Khi người dùng gõ chữ `H - A - N - O - I`, thay vì gọi API 5 lần (gây tốn tiền Server), `debounce(0.5)` sẽ chờ người dùng gõ xong chữ `I`, dừng tay nửa giây, rồi mới gọi API một lần duy nhất với chữ `HANOI`.

#### 3. Cảnh sát giao thông `throttle`
* **Cách chạy:** Ta cài `.throttle(2.5)`.
  * Giây 1: Bóng `1` rơi. `throttle` lập tức cho đi qua. Sau đó nó kéo rào chắn xuống, khóa đường trong 2.5 giây.
  * Giây 2, 3: Bóng `2` và `3` rơi xuống. Rào chắn đang khóa, chúng bị chặn lại. `throttle` ghi nhớ bóng `3` (vì nó là `latest`).
  * Giây 3.5: Rào chắn mở (hết 2.5s). Nó nhả bóng **`3`** ra, rồi tiếp tục kéo rào đóng lại 2.5s nữa.
  * Giây 4, 5: Bóng `4`, `5` rơi xuống. Bóng 5 được ghi nhớ.
  * Giây 6.0: Rào chắn mở, nhả bóng **`5`**.
  * **Kết quả:** Luồng dưới sẽ hiện `1`, `3`, `5`.
* **Thực chiến:** **Chống spam click (Rate Limiting).** Người dùng bấm nút "Thanh toán" liên tục 10 lần trong 1 giây vì máy bị lag. Bạn dùng `.throttle(2)` để ép luồng: Bấm lần 1 gọi API thanh toán luôn, 9 lần bấm sau trong vòng 2 giây sẽ bị vứt sọt rác, đảm bảo User không bị trừ tiền 10 lần!
