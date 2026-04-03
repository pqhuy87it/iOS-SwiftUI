Chào bạn! Rất tuyệt vời khi bạn đang tiếp tục khám phá sâu hơn về các Operators của Combine.

Khác biệt cốt lõi giữa `map` và `tryMap` nằm ở chữ **"try"**:
* `map`: Nhận vào giá trị A, bắt buộc phải trả về giá trị B. Không được phép xảy ra lỗi.
* `tryMap`: Nhận vào giá trị A, trả về giá trị B. **NHƯNG** nếu có gì đó không ổn (ví dụ: chuỗi không thể chuyển thành số), bạn được quyền **ném ra một lỗi (throw Error)**.

**💡 Điểm cực kỳ quan trọng cần nhớ:** Trong Combine, một khi luồng (stream) ném ra một lỗi, **luồng đó sẽ NGAY LẬP TỨC BỊ ĐÓNG (Terminate)**. Nó sẽ không bao giờ phát thêm bất kỳ giá trị nào nữa, cho dù nguồn phát gốc vẫn đang gửi dữ liệu.

Dưới đây là đoạn code cập nhật cho `CombineOperatorsView` bổ sung thêm ví dụ `tryMap`. Trong ví dụ này, mình giả lập luật: *"Nếu gặp số 3 thì ném lỗi"*. Để khớp với kiểu dữ liệu của View hiện tại (bắt buộc `Failure` là `Never`), mình đã dùng thêm toán tử `.catch` để bắt cái lỗi đó, biến nó thành chữ `"Lỗi"` rồi để luồng tự ngắt.

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // 1. Map
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Map",
                        description: ".map { $0 * 2 }",
                        comparingPublisher: self.mapPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Map").font(.headline)
                        Text("Biến đổi 1-1, không ném lỗi").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. FlatMap
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "FlatMap",
                        description: ".flatMap { ... }",
                        comparingPublisher: self.flatMapPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("FlatMap").font(.headline)
                        Text("Từ 1 tạo ra nhiều giá trị (1 luồng mới)").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 3. TryMap (VÍ DỤ MỚI)
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryMap",
                        description: ".tryMap { ném lỗi nếu là số 3 }",
                        comparingPublisher: self.tryMapPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryMap").font(.headline)
                        Text("Có thể ném lỗi -> Luồng sẽ bị ĐÓNG").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }
    
    // MARK: - 1. Map Publisher
    func mapPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { (Int($0) ?? 0) * 2 }
            .map { String($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. FlatMap Publisher
    func flatMapPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher.flatMap { value -> AnyPublisher<String, Never> in
            let firstValue = Just("\(value)a").eraseToAnyPublisher()
            let secondValue = Just("\(value)b")
                .delay(for: .seconds(0.4), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
            
            return firstValue.append(secondValue).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - 3. TryMap Publisher (Ví dụ Mới)
    
    // Định nghĩa một Error tùy chỉnh
    enum MyCombineError: Error {
        case badNumber
    }
    
    func tryMapPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .tryMap { value -> String in
                // Giả lập logic kiểm tra: Nếu luồng chính phát ra số "3", ta CHỦ ĐỘNG ném lỗi
                if value == "3" {
                    throw MyCombineError.badNumber
                }
                
                // Nếu không lỗi, biến đổi bình thường (nhân 10)
                let intValue = Int(value) ?? 0
                return String(intValue * 10)
            }
            // Vì tryMap đổi kiểu lỗi từ 'Never' sang 'Error'
            // Ta cần dùng .catch để "hứng" lỗi này lại cho khớp với UI (đòi hỏi Never)
            .catch { error -> Just<String> in
                // Khi bắt được lỗi, phát ra một chữ "Lỗi" duy nhất.
                // LƯU Ý: Sau hàm catch này, luồng Combine chính thức CHẾT (Hoàn thành).
                return Just("Lỗi")
            }
            .eraseToAnyPublisher()
    }
}

#Preview {
    CombineOperatorsView()
}
```

### 🔍 Chuyện gì sẽ xảy ra khi bạn test `TryMap`?

1. Luồng gốc (`TunnelView` ở trên) vẫn sẽ đẻ ra các số: **1, 2, 3, 4, 5** (cách nhau 1 giây).
2. Luồng dưới (đã qua `tryMap`) sẽ phản ứng như sau:
   * Khi nhận "1" ➔ Ra **"10"**
   * Khi nhận "2" ➔ Ra **"20"**
   * Khi nhận "3" ➔ `tryMap` ném lỗi `badNumber` ➔ Nhảy vào `.catch` ➔ Ra chữ **"Lỗi"**.
   * **Điều kỳ diệu:** Khi luồng gốc phát tiếp "4" và "5", **luồng dưới không hiện gì cả!** Lý do là vì một Combine pipeline khi đã phát ra lỗi (Failure) thì hợp đồng kết nối (Subscription) bị xé bỏ ngay lập tức. Đây là tính năng rất mạnh của `tryMap` dùng để "bảo vệ" ứng dụng (ví dụ: đang gọi API mà mạng rớt thì ngắt luồng luôn, không xử lý tiếp các data rác phía sau).
