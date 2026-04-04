Chào bạn! Chúng ta đã bước sang một chương cực kỳ thú vị và quan trọng của Combine: **Nhóm toán tử Gộp luồng (Combining Operators)**.

Ba toán tử `combineLatest`, `merge`, và `zip` là "linh hồn" của Combine khi bạn cần xử lý nhiều nguồn dữ liệu cùng lúc (ví dụ: gộp luồng nhập email và luồng nhập password để mở khóa nút Đăng Nhập).

Vì các toán tử này đòi hỏi phải có **ít nhất 2 luồng (publishers)** để gộp, nên trong ví dụ này, ngoài luồng gốc của bạn (phát ra số `1, 2, 3, 4, 5` mỗi giây), mình đã viết thêm một hàm `createSecondStream` để tạo ra luồng thứ hai (phát ra chữ `A, B, C, D, E` chậm hơn, mỗi 1.5 giây) nhằm giúp bạn thấy rõ sự khác biệt giữa 3 cách gộp này.

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn có thể copy đoạn code dưới đây, dán vào file của bạn:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn) ...

                // 1. NavigationLink cho Merge
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Merge",
                        description: ".merge(with: streamB)",
                        comparingPublisher: self.mergePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Merge").font(.headline)
                        Text("Trộn 2 luồng lại với nhau (Ai đến trước ra trước)").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho CombineLatest
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "CombineLatest",
                        description: ".combineLatest(streamB)",
                        comparingPublisher: self.combineLatestPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("CombineLatest").font(.headline)
                        Text("Gộp các giá trị MỚI NHẤT của cả 2 luồng").font(.caption).foregroundColor(.gray)
                    }
                }

                // 3. NavigationLink cho Zip
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Zip",
                        description: ".zip(streamB)",
                        comparingPublisher: self.zipPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Zip").font(.headline)
                        Text("Bắt cặp 1-1 (Chờ đủ đôi mới phát)").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // MARK: - Hàm hỗ trợ tạo Luồng thứ 2 (Phát ra A, B, C, D, E)
    // Luồng gốc của bạn phát số cách nhau 1s. Luồng này sẽ phát chữ cách nhau 1.5s để thấy sự khác biệt.
    func createSecondStream(interval: TimeInterval) -> AnyPublisher<String, Never> {
        let letters = ["A", "B", "C", "D", "E"]
        let publishers = letters.map { 
            Just($0).delay(for: .seconds(interval), scheduler: DispatchQueue.main).eraseToAnyPublisher() 
        }
        return publishers[1...].reduce(publishers[0]) {
            Publishers.Concatenate(prefix: $0, suffix: $1).eraseToAnyPublisher()
        }
    }

    // MARK: - 1. Hàm Merge
    func mergePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        let streamB = createSecondStream(interval: 1.5)
        
        // Merge yêu cầu 2 luồng CÙNG KIỂU dữ liệu (cùng là String).
        // Nó sẽ trộn lẫn các quả bóng của 2 luồng thành 1 hàng dọc.
        return publisher
            .merge(with: streamB)
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm CombineLatest
    func combineLatestPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        let streamB = createSecondStream(interval: 1.5)
        
        return publisher
            // CombineLatest ghép số và chữ thành một Tuple (String, String)
            .combineLatest(streamB)
            // Ta nối Tuple lại thành chuỗi (vd: "1A") để hiện lên UI
            .map { number, letter in
                "\(number)\(letter)"
            }
            .eraseToAnyPublisher()
    }

    // MARK: - 3. Hàm Zip
    func zipPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        let streamB = createSecondStream(interval: 1.5)
        
        return publisher
            // Zip cũng ghép thành Tuple (String, String) nhưng theo logic Bắt cặp
            .zip(streamB)
            .map { number, letter in
                "\(number)\(letter)"
            }
            .eraseToAnyPublisher()
    }
}
```

### 💡 Giải thích sự khác biệt kinh điển giữa 3 toán tử:

Để dễ hình dung, hãy nhớ: 
* **Luồng A (Số):** 1 ... 2 ... 3 ... 4 ... 5 (Nhanh)
* **Luồng B (Chữ):** ... A ... ... B ... ... C (Chậm)

#### 1. `merge` (Trộn làn giao thông)
* **Luật:** Đường ai nấy chạy, hễ có phần tử xuất hiện là đẩy ra luồng chính ngay lập tức.
* **Cách chạy:** Bạn sẽ thấy luồng dưới hiện ra xen kẽ: `1` -> `A` -> `2` -> `3` -> `B` -> `4` -> `5` -> `C`...
* **Thực chiến:** Khi bạn có 2 nút bấm khác nhau (vd: Nút "Tải lại" trên màn hình và Nút "Kéo để tải mới" ở list), cả 2 đều gọi chung một API. Bạn `merge` tín hiệu từ 2 nút này lại thành 1 luồng trigger duy nhất.

#### 2. `combineLatest` (Bảng điều khiển)
* **Luật:** Mỗi khi CÓ BẤT KỲ luồng nào cập nhật giá trị mới, nó sẽ lấy giá trị đó ghép với **giá trị gần nhất** của luồng kia. (Lưu ý: Nó phải chờ cả 2 luồng đều phát ra ít nhất 1 giá trị đầu tiên thì mới bắt đầu ghép).
* **Cách chạy:** * Chờ 1.5s để có đủ `1` và `A` ➔ Ra **`1A`**
  * Luồng số nhảy sang `2` (chữ vẫn đang là A) ➔ Ra **`2A`**
  * Luồng chữ nhảy sang `B` (số đang là 2) ➔ Ra **`2B`**
  * Luồng số nhảy sang `3` ➔ Ra **`3B`**
* **Thực chiến:** Toán tử được dùng NHIỀU NHẤT trong Combine. Dùng để làm Form Validation (Gộp luồng `$username` và `$password` để bật/tắt nút Đăng nhập), hoặc gộp các Filter của danh sách (Màu sắc, Mức giá, Size) để call API mỗi khi người dùng đổi bộ lọc.

#### 3. `zip` (Dây khóa kéo / Vợ chồng)
* **Luật:** Bắt cặp 1-1 theo thứ tự. Người thứ 1 của luồng A phải ghép với Người thứ 1 của luồng B. Nếu 1 bên chạy nhanh quá, nó phải **đứng lại chờ** bên kia.
* **Cách chạy:** * Số 1 đợi Chữ A ➔ Ra **`1A`**
  * Số 2 chạy ra, nhưng phải đứng đợi Chữ B ➔ Ra **`2B`**
  * Số 3 đứng đợi Chữ C ➔ Ra **`3C`**
* **Thực chiến:** Rất hay dùng khi bạn cần gọi 2 API CÙNG MỘT LÚC (ví dụ: API lấy Profile User và API lấy Số dư ví). Màn hình chỉ được phép hiển thị khi **cả 2 API đều đã tải xong**. Thằng nào tải xong trước phải đợi thằng kia tải xong mới hiển thị lên cùng một lượt.
