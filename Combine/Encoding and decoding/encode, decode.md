Chào bạn! Vậy là chúng ta đã giải quyết êm đẹp được lỗi `timeout` rồi. Bây giờ, hãy đến với một cặp toán tử "huyền thoại" và không thể thiếu trong bất kỳ ứng dụng nào có giao tiếp với mạng Internet (API): **`encode`** và **`decode`**.

Trong thực tế, khi bạn tải dữ liệu từ Server về, nó thường là một cục **`Data`** (định dạng JSON). Bạn cần dùng `decode` để biến cục Data đó thành **Model/Struct** (như `User`, `Product`) để hiển thị lên app. Ngược lại, khi bạn muốn gửi dữ liệu lên Server, bạn dùng `encode` để biến Model của bạn thành cục `Data`.

Để thực hiện ví dụ này, chúng ta cần định nghĩa một Struct đơn giản (ví dụ: `User`).

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn thêm đoạn code này vào bên dưới các ví dụ trước nhé:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn) ...

                // 1. NavigationLink cho encode
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Encode",
                        description: ".encode(encoder: JSONEncoder())",
                        comparingPublisher: self.encodePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Encode").font(.headline)
                        Text("Biến đổi Model (Struct/Class) thành cục Data (JSON)").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho decode
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Decode",
                        description: ".decode(type: User.self, decoder: JSONDecoder())",
                        comparingPublisher: self.decodePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Decode").font(.headline)
                        Text("Phân tích cục Data (JSON) thành Model. Ném lỗi nếu sai định dạng.").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // MARK: - Model hỗ trợ cho Encode/Decode
    // Chú ý: Bắt buộc phải tuân thủ protocol Codable
    struct User: Codable {
        let id: Int
        let name: String
    }

    // MARK: - 1. Hàm Encode
    func encodePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // 1. Biến các số "1", "2" thành các đối tượng Model thực thụ
            .map { value -> User in
                let id = Int(value) ?? 0
                return User(id: id, name: "Người dùng \(id)")
            }
            // 2. Ép kiểu Model thành Data thông qua JSONEncoder
            // Toán tử này có thể ném lỗi (EncodingError) nên kiểu trả về sẽ bị biến thành Error
            .encode(encoder: JSONEncoder())
            
            // 3. (Chỉ dành cho UI) Biến cục Data thành String dạng JSON để bạn nhìn thấy được trên màn hình
            .compactMap { data in
                String(data: data, encoding: .utf8)
            }
            // Bắt lỗi nếu quá trình mã hóa thất bại
            .catch { _ in Just("Lỗi Encode") }
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm Decode
    func decodePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // 1. Giả lập việc nhận Data từ mạng (API)
            .map { value -> Data in
                // Cố tình gài bẫy: Khi đến số 3, ta trả về một chuỗi JSON BỊ LỖI (thiếu ngoặc kép ở chữ name)
                if value == "3" {
                    let badJSON = "{ \"id\": 3, \"name\": Lỗi định dạng }"
                    return badJSON.data(using: .utf8)!
                }
                
                // Các số khác: Trả về JSON chuẩn
                let goodJSON = "{ \"id\": \(value), \"name\": \"Người dùng \(value)\" }"
                return goodJSON.data(using: .utf8)!
            }
            
            // 2. Giải mã (Decode) cục Data thành Model User
            // Nếu JSON bị lỗi hoặc thiếu trường dữ liệu, nó sẽ NÉM LỖI (DecodingError) và ngắt luồng ngay lập tức.
            .decode(type: User.self, decoder: JSONDecoder())
            
            // 3. Lấy tên User ra để hiển thị lên UI
            .map { user in
                user.name
            }
            // Hứng lỗi (do số 3 gây ra)
            .catch { _ in Just("Lỗi Decode JSON!") }
            .eraseToAnyPublisher()
    }
}
```

### 💡 Trải nghiệm thực tế và Ứng dụng:

#### 1. Người phiên dịch `encode`
* **Cách chạy:** Luồng trên phát ra số `1`. Luồng dưới lập tức biến nó thành một object `User`, sau đó dùng `JSONEncoder` để "đúc" thành một chuỗi JSON chuẩn. Kết quả trên màn hình bạn sẽ thấy luồng dưới chạy ra chuỗi dài thòng: **`{"id":1,"name":"Người dùng 1"}`**.
* **Thực chiến:** Khi người dùng điền Form đăng ký (Tên, Email, Mật khẩu), bạn gom chúng lại thành 1 cục Struct `RegisterRequest`. Sau đó bạn dùng `.encode(encoder: JSONEncoder())` để nhào nặn cục Struct đó thành `Data` rồi nhét vào `URLRequest.httpBody` để gửi lên Server.

#### 2. Kẻ soi lỗi định dạng `decode`
* **Cách chạy:** * Giây 1, 2: `tryMap` giả lập việc bạn nhận được Data JSON hoàn hảo từ mạng. `decode` phân tích thành công, luồng dưới nhả ra **`Người dùng 1`**, **`Người dùng 2`**.
  * Giây 3: Do ta cố tình gửi chuỗi JSON bị lỗi syntax (thiếu ngoặc kép), `JSONDecoder` ngay lập tức báo động đỏ. Lệnh `throw DecodingError` được kích hoạt ở hậu trường. Luồng Combine bị sập, nhảy thẳng vào block `.catch` và in ra chữ **"Lỗi Decode JSON!"**.
* **Thực chiến:** Đây là toán tử bạn sẽ dùng **TRONG MỌI HÀM GỌI API GET** của mình. Nó thay thế hoàn toàn cho cái thời kỳ đau khổ phải dùng `JSONSerialization.jsonObject` và ngồi cast kiểu dữ liệu bằng tay (`as? [String: Any]`). Chỉ cần 1 dòng lệnh duy nhất `.decode(type: MyModel.self, decoder: JSONDecoder())`, Combine sẽ làm mọi thứ tự động cho bạn! Nếu Backend trả về dữ liệu sai cấu trúc (ví dụ: đáng lẽ là `Int` thì lại trả về `String`), app sẽ nhảy vào luồng lỗi thay vì bị crash.
