Chào bạn! Chúng ta lại tiếp tục với bộ đôi toán tử **`reduce`** và **`tryReduce`**. 

Nếu bạn đã hiểu rõ về `scan` ở các phần trước, thì `reduce` sẽ cực kỳ dễ hiểu. Điểm khác biệt DUY NHẤT và quan trọng nhất giữa chúng là:
* **`scan`**: Mỗi lần cộng dồn xong, nó **phát ra ngay** kết quả trung gian.
* **`reduce`**: Nó âm thầm cộng dồn ở hậu trường và **CHỈ phát ra duy nhất 1 kết quả cuối cùng** khi luồng gốc báo hiệu "Đã hoàn thành" (Finished).

Dưới đây là phần code bổ sung để bạn thêm vào `CombineOperatorsView` của mình:

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn thêm 2 `NavigationLink` này vào bên dưới các ví dụ trước:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn) ...

                // 1. NavigationLink cho reduce
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Reduce",
                        description: ".reduce(0) { $0 + $1 }",
                        comparingPublisher: self.reducePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Reduce").font(.headline)
                        Text("Cộng dồn và CHỈ phát kết quả khi luồng kết thúc").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho tryReduce
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryReduce",
                        description: ".tryReduce { ném lỗi nếu tổng > 10 }",
                        comparingPublisher: self.tryReducePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryReduce").font(.headline)
                        Text("Cộng dồn nhưng ném lỗi nếu vi phạm điều kiện").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // MARK: - 1. Hàm Reduce
    func reducePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            // Khởi tạo tổng = 0, cộng dồn từng giá trị vào
            // Sẽ không phát ra bất cứ thứ gì cho đến khi nhận được tín hiệu Finished
            .reduce(0) { accumulated, current in
                accumulated + current
            }
            .map { String($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm TryReduce
    enum ReduceError: Error {
        case limitExceeded
    }

    func tryReducePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            .tryReduce(0) { accumulated, current -> Int in
                let newValue = accumulated + current
                
                // Đặt luật: Nếu tổng cộng dồn vượt quá 10, ta chủ động ném lỗi
                if newValue > 10 {
                    throw ReduceError.limitExceeded
                }
                
                return newValue
            }
            .map { String($0) }
            // Bắt lỗi và hiển thị lên UI, sau đó luồng kết thúc
            .catch { _ in Just("Lỗi") }
            .eraseToAnyPublisher()
    }
}
```

### 💡 Trải nghiệm thực tế khi bạn chạy Test:

#### 1. Sự "nín nhịn" của `reduce`
* **Cách chạy:** Khi bạn bấm Subscribe, luồng trên (`stream1`) sẽ lần lượt nhả bóng `1, 2, 3, 4, 5`. Trong suốt 5 giây đó, luồng dưới (`stream2`) **hoàn toàn trống trơn**.
* Nó đang âm thầm tính toán: $0+1=1$, $1+2=3$, $3+3=6$, $6+4=10$, $10+5=15$.
* Ngay khoảnh khắc luồng trên kết thúc, luồng dưới mới "phun" ra một quả bóng duy nhất mang số **15**.
* **Thực chiến:** Rất hay dùng để tính tổng doanh thu/chi phí từ một luồng dữ liệu hoá đơn tải về từ server. Bạn không cần xem từng bước cộng dồn làm gì, bạn chỉ cần một con số chốt sổ cuối cùng.

#### 2. Kẻ phá bĩnh `tryReduce`
* **Cách chạy:** Quá trình tính toán diễn ra tương tự như trên.
* Tuy nhiên, khi cộng đến số 4 (Tổng đang là 10). Quả bóng số 5 xuất hiện, tính ra `10 + 5 = 15`. 
* Do `15 > 10`, điều kiện `throw ReduceError.limitExceeded` bị kích hoạt. 
* Lúc này, **toàn bộ công sức cộng dồn trước đó bị vứt bỏ hoàn toàn**. Luồng lập tức bị huỷ bỏ, nhảy vào block `.catch` và ném ra đúng một chữ **"Lỗi"**. Bạn sẽ không bao giờ nhận được kết quả tính tổng.
* **Thực chiến:** Giả sử bạn đang tải và ghép các mảnh file (file chunks) lại với nhau. Nếu trong quá trình ghép, bạn phát hiện dung lượng tổng sắp vượt quá bộ nhớ trống của điện thoại, bạn dùng `tryReduce` để ném lỗi ngay lập tức, huỷ bỏ quá trình tải ghép để tránh làm crash app.
