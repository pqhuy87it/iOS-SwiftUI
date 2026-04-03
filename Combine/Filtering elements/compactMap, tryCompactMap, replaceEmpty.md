Chào bạn! Bộ sưu tập các toán tử Combine của bạn đang ngày càng phong phú và "thực chiến" hơn rồi đấy. 

Nhóm toán tử tiếp theo mà bạn hỏi (`compactMap`, `tryCompactMap`, `replaceEmpty`) cực kỳ hữu ích khi làm việc với **Optional (dữ liệu có thể bị nil)** và **Luồng dữ liệu rỗng**. 

Dưới đây là phần code bổ sung để bạn thêm tiếp vào danh sách `List` trong `CombineOperatorsView` của mình, kèm theo phần giải thích chi tiết cơ chế hoạt động.

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn tiếp tục gắn các `NavigationLink` này vào bên dưới các ví dụ trước đó:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn như Map, FlatMap, Scan...) ...
                
                // 1. Thêm NavigationLink cho compactMap
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "CompactMap",
                        description: ".compactMap { loại bỏ nil }",
                        comparingPublisher: self.compactMapPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("CompactMap").font(.headline)
                        Text("Biến đổi dữ liệu và TỰ ĐỘNG lọc bỏ nil").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. Thêm NavigationLink cho tryCompactMap
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryCompactMap",
                        description: ".tryCompactMap { ném lỗi hoặc trả về nil }",
                        comparingPublisher: self.tryCompactMapPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryCompactMap").font(.headline)
                        Text("Lọc bỏ nil, nhưng cũng có quyền ném lỗi").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 3. Thêm NavigationLink cho replaceEmpty
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "ReplaceEmpty",
                        description: ".replaceEmpty(with: \"Trống\")",
                        comparingPublisher: self.replaceEmptyPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("ReplaceEmpty").font(.headline)
                        Text("Phát giá trị mặc định nếu luồng KHÔNG có gì").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }
    
    // MARK: - 1. Hàm CompactMap
    func compactMapPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // compactMap yêu cầu closure trả về một Optional (String?)
            .compactMap { value -> String? in
                // Giả sử ta muốn loại bỏ các số CHẴN ra khỏi luồng
                guard let intValue = Int(value), intValue % 2 != 0 else {
                    // Nếu trả về nil, giá trị này sẽ bị bốc hơi (không truyền tiếp xuống dưới)
                    return nil
                }
                // Nếu trả về một giá trị thực (Optional unwrapped), nó sẽ được đi tiếp
                return value
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm TryCompactMap
    enum CompactError: Error {
        case fatalNumber
    }
    
    func tryCompactMapPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .tryCompactMap { value -> String? in
                // 1. Nếu là số 4 -> CHỦ ĐỘNG NÉM LỖI (Luồng sẽ bị đóng)
                if value == "4" {
                    throw CompactError.fatalNumber
                }
                // 2. Nếu là số 2 -> LỜ ĐI (Trả về nil, luồng vẫn sống nhưng số 2 bị bỏ qua)
                if value == "2" {
                    return nil
                }
                // 3. Các số khác -> Đi tiếp
                return value
            }
            .catch { _ in Just("Lỗi") } // Hứng lỗi từ throw
            .eraseToAnyPublisher()
    }
    
    // MARK: - 3. Hàm ReplaceEmpty
    func replaceEmptyPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // filter { false } sẽ CHẶN đứng toàn bộ dữ liệu đi qua.
            // Biến luồng này thành một luồng hoàn toàn Rỗng (Chỉ phát tín hiệu Complete, không phát data)
            .filter { _ in false }
            
            // Nếu luồng hoàn thành mà chưa từng phát ra bất kỳ giá trị nào, 
            // replaceEmpty sẽ "cứu vớt" bằng cách phát ra giá trị mặc định này.
            .replaceEmpty(with: "Rỗng")
            .eraseToAnyPublisher()
    }
}
```

### 💡 Giải thích hiện tượng khi bạn chạy Test:

#### 1. Tại sao dùng `compactMap`?
* Nó là sự kết hợp hoàn hảo giữa `map` và `filter`. 
* Khi bạn chạy test này, luồng gốc trên UI chạy ra `1, 2, 3, 4, 5`. Nhưng luồng dưới (kết quả) chỉ hiện ra `1, 3, 5`.
* **Thực chiến:** Rất hay dùng khi bạn lấy dữ liệu từ API về dạng `[String: Any]`, bạn dùng `compactMap` để parse sang Model của mình. Nếu parse thất bại (trả về `nil`), item đó tự động bị loại bỏ khỏi danh sách mà không làm sập ứng dụng.

#### 2. `tryCompactMap` có gì đặc biệt?
* Mở rộng thêm quyền lực của `compactMap`: Bạn vừa được quyền lờ đi dữ liệu rác (return `nil`), vừa được quyền báo động đỏ nếu gặp dữ liệu chí mạng (throw `Error`).
* Khi chạy test: 
  * Số 1: Qua lọt.
  * Số 2: Bị lờ đi (trả về nil) -> Không hiện gì.
  * Số 3: Qua lọt.
  * Số 4: Ném lỗi `fatalNumber` -> Nhảy vào `.catch` hiện chữ **"Lỗi"** và luồng **ĐÓNG LẠI TỨC KHẮC**. Số 5 sẽ không bao giờ xuất hiện!

#### 3. Sức mạnh của `replaceEmpty`
* Khi bạn chạy test này, bóng ở luồng trên chạy `1, 2, 3, 4, 5`. Luồng dưới **đứng im hoàn toàn**. 
* Chỉ đến khi quả bóng số 5 xuất hiện (luồng hoàn tất), luồng dưới mới thình lình ném ra chữ **"Rỗng"**.
* **Thực chiến:** Bạn viết một luồng tìm kiếm danh bạ. Nếu luồng chạy xong mà mảng kết quả là rỗng, bạn dùng `.replaceEmpty(with: "Không tìm thấy kết quả nào")` để tự động kích hoạt UI thông báo cho người dùng biết, thay vì để một màn hình trắng bóc!
