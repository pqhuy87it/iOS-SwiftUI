Chào bạn! Bạn đang xây dựng một "phòng thí nghiệm" Combine thật sự chất lượng. Nhóm toán tử tiếp theo này (`replaceError`, `removeDuplicates`, `tryRemoveDuplicates`) tập trung vào việc **làm sạch dữ liệu** và **khôi phục sau lỗi**.

Dưới đây là phần code bổ sung để bạn ghép vào danh sách `List` trong `CombineOperatorsView` của mình.

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn thêm các `NavigationLink` này vào dưới các ví dụ trước đó:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn) ...

                // 1. NavigationLink cho replaceError
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "ReplaceError",
                        description: ".replaceError(with: \"Sửa lỗi\")",
                        comparingPublisher: self.replaceErrorPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("ReplaceError").font(.headline)
                        Text("Thay thế lỗi bằng một giá trị mặc định").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho removeDuplicates
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "RemoveDuplicates",
                        description: ".removeDuplicates()",
                        comparingPublisher: self.removeDuplicatesPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("RemoveDuplicates").font(.headline)
                        Text("Loại bỏ các giá trị trùng lặp liên tiếp").font(.caption).foregroundColor(.gray)
                    }
                }

                // 3. NavigationLink cho tryRemoveDuplicates
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryRemoveDuplicates",
                        description: ".tryRemoveDuplicates { ném lỗi nếu trùng số 4 }",
                        comparingPublisher: self.tryRemoveDuplicatesPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryRemoveDuplicates").font(.headline)
                        Text("Loại bỏ trùng lặp hoặc ném lỗi nếu cần").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // MARK: - 1. Hàm ReplaceError
    enum MyError: Error { case fail }

    func replaceErrorPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .tryMap { value -> String in
                // Giả lập: Nếu gặp số 3 thì ném lỗi
                if value == "3" { throw MyError.fail }
                return value
            }
            // 👉 Khi gặp lỗi, thay bằng chữ "Đã Sửa" và HOÀN THÀNH luồng.
            .replaceError(with: "Đã Sửa")
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm RemoveDuplicates
    func removeDuplicatesPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // Để thấy rõ hiệu ứng, ta biến đổi luồng 1,2,3,4,5 thành 1,1,1,2,2...
            .flatMap { value -> AnyPublisher<String, Never> in
                return [value, value].publisher.eraseToAnyPublisher()
            }
            // 👉 Loại bỏ các phần tử trùng lặp đứng cạnh nhau
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    // MARK: - 3. Hàm TryRemoveDuplicates
    func tryRemoveDuplicatesPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        // Tạo chuỗi có trùng lặp để test: 1, 2, 3, 4, 4, 5
        let customPublisher = publisher.flatMap { value -> AnyPublisher<String, Never> in
            if value == "4" { return ["4", "4"].publisher.eraseToAnyPublisher() }
            return [value].publisher.eraseToAnyPublisher()
        }

        return customPublisher
            .tryRemoveDuplicates { prev, current in
                // Nếu thấy 2 số 4 đi liền nhau -> Báo động đỏ, ném lỗi!
                if prev == "4" && current == "4" {
                    throw MyError.fail
                }
                // Điều kiện trùng lặp thông thường
                return prev == current
            }
            .catch { _ in Just("Lỗi Trùng") }
            .eraseToAnyPublisher()
    }
}
```

### 💡 Giải thích chi tiết cơ chế hoạt động:



#### 1. `replaceError` - "Cứu vãn tình thế"
* **Cách chạy:** Khi luồng phát đến số "3", `tryMap` ném lỗi. Thay vì để ứng dụng nhận về một `Failure` và ngắt quãng, `replaceError` sẽ "nhét" giá trị `"Đã Sửa"` vào vị trí đó.
* **Lưu ý:** Sau khi `replaceError` phát ra giá trị thay thế, luồng sẽ tự động gửi tín hiệu **Finished** (kết thúc). Bạn sẽ thấy bóng số 4 và 5 ở luồng gốc không bao giờ xuất hiện ở luồng dưới nữa.
* **Thực chiến:** Rất hay dùng trong việc tải ảnh. Nếu URL ảnh bị lỗi, bạn dùng `.replaceError(with: imageDefault)` để hiện ảnh placeholder.

#### 2. `removeDuplicates` - "Chống rung / Chống lặp"
* **Cách chạy:** Toán tử này chỉ so sánh phần tử **hiện tại** với phần tử **ngay trước đó**. Nếu chúng giống nhau, nó sẽ chặn lại. 
* Trong ví dụ trên, mình dùng `flatMap` để nhân đôi mỗi số (1->1,1). `removeDuplicates` sẽ lọc bỏ số thứ hai, kết quả luồng dưới sẽ trông giống hệt luồng trên (1, 2, 3, 4, 5).
* **Thực chiến:** Dùng khi người dùng bấm nút liên tục (spam click) hoặc khi lắng nghe tọa độ chuột/cuộn màn hình, giúp giảm thiểu việc xử lý dữ liệu thừa khi giá trị không thay đổi.

#### 3. `tryRemoveDuplicates` - "Giám sát trùng lặp"
* Nó cho phép bạn tự định nghĩa logic thế nào là trùng lặp (không nhất thiết phải giống hệt nhau) và có quyền ném lỗi nếu sự trùng lặp đó vi phạm quy tắc an toàn.
* **Cách chạy:** Khi bạn thấy hai số "4" đi liền nhau, ứng dụng coi đó là một lỗi nghiêm trọng và ném `MyError`. Luồng sẽ hiện chữ `"Lỗi Trùng"` và dừng lại.
* **Thực chiến:** Giả sử bạn nhận dữ liệu từ cảm biến nhiệt độ. Nếu 2 giá trị liên tiếp giống hệt nhau và quá cao, bạn có thể ném lỗi để ngắt hệ thống cảnh báo cháy.
