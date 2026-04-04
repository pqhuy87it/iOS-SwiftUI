Chào bạn! Bạn đã đi đến những mảnh ghép xử lý lỗi (Error Handling) quyền lực nhất của Combine rồi đấy.

Nếu ở các phần trước, bạn đã biết đến `.replaceError` (thay thế lỗi bằng **1 giá trị duy nhất**), thì **`catch`** và **`tryCatch`** là phiên bản nâng cấp hoàn hảo của nó: **Thay thế lỗi bằng MỘT LUỒNG (PUBLISHER) HOÀN TOÀN MỚI**.

Điều này giống như việc bạn đang đi trên một cây cầu (luồng gốc), cầu bị sập (lỗi). Thay vì rơi xuống vực (`Failure`), `catch` sẽ giăng ra một tấm lưới an toàn và nối cho bạn một cây cầu dự phòng khác để tiếp tục đi tiếp!

Dưới đây là phần code bổ sung để bạn ghép vào `CombineOperatorsView` của mình:

### 1. Code bổ sung vào `CombineOperatorsView`

Bạn thêm 2 `NavigationLink` này vào cuối danh sách:

```swift
import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                // ... (Các NavigationLink cũ của bạn) ...

                // 1. NavigationLink cho catch
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Catch",
                        description: ".catch { nối vào luồng dự phòng }",
                        comparingPublisher: self.catchPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Catch").font(.headline)
                        Text("Khi lỗi, thay thế bằng một luồng dự phòng mới").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho tryCatch
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryCatch",
                        description: ".tryCatch { cố gắng cứu, nhưng có thể ném lỗi }",
                        comparingPublisher: self.tryCatchPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryCatch").font(.headline)
                        Text("Cứu viện luồng lỗi, nhưng có quyền ném ra lỗi khác").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // Định nghĩa Lỗi cho các bài test
    enum TestError: Error {
        case bridgeCollapsed
        case backupFailed
    }

    // MARK: - 1. Hàm Catch
    func catchPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // 1. Cố tình tạo ra lỗi: Khi đi đến số 3 thì đánh sập luồng gốc
            .tryMap { value -> String in
                if value == "3" {
                    throw TestError.bridgeCollapsed
                }
                return value
            }
            // 2. Cứu viện bằng catch: Hứng lấy lỗi và trả về một Luồng (Publisher) mới
            .catch { error -> AnyPublisher<String, Never> in
                // Khi luồng gốc sập, ta tạo ra một luồng dự phòng phát ra 2 chữ "Cứu" và "Viện"
                // Cách nhau 1 giây giống hệt luồng gốc để bạn dễ quan sát
                let firstBackup = Just("Cứu")
                    .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                let secondBackup = Just("Viện")
                    .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                
                return firstBackup.append(secondBackup).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm TryCatch
    func tryCatchPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // 1. Vẫn tạo ra lỗi ở số 3
            .tryMap { value -> String in
                if value == "3" { throw TestError.bridgeCollapsed }
                return value
            }
            // 2. tryCatch: Cố gắng cứu viện, nhưng quá trình cứu viện cũng có thể gặp lỗi!
            .tryCatch { error -> AnyPublisher<String, Error> in
                // Giả lập: Cố gắng gọi luồng dự phòng nhưng luồng dự phòng cũng bị sập nốt.
                // tryCatch cho phép dùng từ khoá `throw` để ném ra một lỗi MỚI
                throw TestError.backupFailed
            }
            // Vì UI của chúng ta bắt buộc kiểu lỗi là Never, nên ta phải dùng catch 1 lần nữa ở cuối để dọn dẹp
            .catch { newError in 
                Just("Toang!")
            }
            .eraseToAnyPublisher()
    }
}
```

### 💡 Trải nghiệm thực tế và Ứng dụng:

#### 1. Sự ma thuật của `catch`
* **Cách chạy:** * Giây 1, 2: Bóng `1`, `2` lọt qua bình thường.
  * Giây 3: Quả bóng số 3 xuất hiện ở luồng gốc -> `tryMap` kích hoạt lỗi `bridgeCollapsed`. Luồng gốc **chết ngay lập tức** (Bóng 4, 5 bị hủy).
  * Lập tức, `catch` nhảy vào can thiệp. Nó vứt bỏ luồng gốc đã hỏng, và móc nối UI của bạn vào luồng dự phòng.
  * Giây 4, 5: Bạn sẽ thấy luồng dưới thình lình ném ra chữ **"Cứu"**, rồi sau đó là chữ **"Viện"**. Kết thúc luồng êm đẹp!
* **Thực chiến (Rất hay dùng):** Bạn gọi API tải dữ liệu từ Server. Nếu Server sập hoặc rớt mạng (bắn ra `URLError`), thay vì để App báo lỗi, bạn dùng `.catch` để lập tức trả về một Publisher **đọc dữ liệu cũ từ Database (CoreData/Realm)** lên cho người dùng xem tạm. Người dùng thậm chí không biết là mạng vừa bị lỗi!

#### 2. Kẻ liều mạng `tryCatch`
* Mọi thứ giống hệt `catch`, nhưng khối lệnh bên trong `tryCatch` cho phép bạn dùng `throw`. 
* **Cách chạy:** Giây 1, 2 bình thường. Giây 3 luồng gốc sập. `tryCatch` nhảy vào định cứu, nhưng bản thân nó cũng ném ra lỗi `backupFailed`. Cuối cùng hệ thống rơi vào `.catch` chót và in ra chữ **"Toang!"**.
* **Thực chiến:** Giả sử bạn gọi API Tải danh sách bạn bè bị lỗi (hết hạn Token). Trong `tryCatch`, bạn tạo ra một Publisher gọi API *Refresh Token*. Nhưng nhỡ đâu Refresh Token cũng thất bại (user bị khóa tài khoản)? Lúc này bạn `throw` lỗi bắt User văng ra màn hình Đăng Nhập.

Sự kết hợp giữa `tryMap` -> `catch` chính là "bộ xương sống" của mọi ứng dụng dùng Combine để giao tiếp với mạng Internet (Networking) đó! Chúc bạn có những phút giây vọc vạch Combine thật thú vị!
