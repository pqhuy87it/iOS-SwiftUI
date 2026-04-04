Chào bạn! Nếu nhóm `first` ở phần trước là những kẻ "thiếu kiên nhẫn" (chộp ngay phát đầu rồi nghỉ), thì nhóm **`last`**, **`last(where:)`** và **`tryLast(where:)`** lại quay trở về làm những kẻ **"tham lam" và "nhẫn nại"** (như `max`, `min`, `reduce`).

Đặc điểm cốt lõi của nhóm này là: **Chúng bắt buộc phải chờ đến khi luồng gốc báo hiệu "Finished" (Kết thúc) thì mới chịu phát ra kết quả**. Lý do rất đơn giản: Nếu luồng chưa kết thúc, làm sao nó biết được đâu là phần tử "cuối cùng"?

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

                // 1. NavigationLink cho last
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Last",
                        description: ".last()",
                        comparingPublisher: self.lastPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Last").font(.headline)
                        Text("Lấy phần tử cuối cùng (Chỉ phát khi kết thúc)").font(.caption).foregroundColor(.gray)
                    }
                }

                // 2. NavigationLink cho lastWhere
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "LastWhere",
                        description: ".last(where: { số chẵn })",
                        comparingPublisher: self.lastWherePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("LastWhere").font(.headline)
                        Text("Lấy phần tử thỏa mãn điều kiện xuất hiện CUỐI CÙNG").font(.caption).foregroundColor(.gray)
                    }
                }

                // 3. NavigationLink cho tryLastWhere
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryLastWhere",
                        description: ".tryLast(where: { ném lỗi nếu là 5 })",
                        comparingPublisher: self.tryLastWherePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryLastWhere").font(.headline)
                        Text("Chờ lấy phần tử cuối, nhưng ném lỗi nếu giẫm mìn").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Combine Operators")
        }
    }

    // MARK: - 1. Hàm Last
    func lastPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            // Âm thầm ghi nhớ phần tử đi qua.
            // Chỉ khi luồng báo Finished, nó mới nhả phần tử cuối cùng nó nhớ được.
            .last()
            .eraseToAnyPublisher()
    }

    // MARK: - 2. Hàm LastWhere
    func lastWherePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            // Tìm số CHẴN cuối cùng của luồng
            .last(where: { value in
                value % 2 == 0
            })
            .map { String($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - 3. Hàm TryLastWhere
    enum LastError: Error {
        case fatalEnd
    }

    func tryLastWherePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            .tryLast(where: { value -> Bool in
                // 1. Cái bẫy ở phút chót: Nếu số cuối cùng là 5 -> NÉM LỖI
                if value == 5 {
                    throw LastError.fatalEnd
                }
                
                // 2. Điều kiện tìm kiếm: Lấy số nhỏ hơn 4
                return value < 4
            })
            .map { String($0) }
            .catch { _ in Just("Lỗi") } // Hứng lỗi lên UI
            .eraseToAnyPublisher()
    }
}
```

### 💡 Trải nghiệm thực tế khi bạn chạy Test:

#### 1. Sự kiên nhẫn của `last()`
* **Cách chạy:** Luồng trên lần lượt nhả bóng `1, 2, 3, 4, 5`. Luồng dưới đứng im như tượng. Combine liên tục đè lên bộ nhớ: nhớ số 1, quên 1 nhớ 2, quên 2 nhớ 3... Khi quả bóng 5 kết thúc, luồng dưới chốt hạ ném ra một quả bóng số **`5`**.
* **Lưu ý:** Giống `max/min`, đừng bao giờ dùng `.last()` cho các luồng vô hạn (như lắng nghe vị trí GPS hay Timer chạy liên tục), vì nó sẽ không bao giờ phát ra dữ liệu.

#### 2. Kẻ đến sau `last(where:)`
* **Cách chạy:** Ta tìm số CHẴN cuối cùng.
  * Nhận `1` -> Bỏ qua.
  * Nhận `2` -> Thỏa mãn! Nó ghi nhớ số 2 (nhưng CHƯA PHÁT RA vì luồng chưa kết thúc).
  * Nhận `3` -> Bỏ qua.
  * Nhận `4` -> Thỏa mãn! Nó xóa số 2 và ghi nhớ số 4.
  * Nhận `5` -> Bỏ qua. Luồng kết thúc!
* Lúc này luồng dưới mới ném ra quả bóng số **`4`**.

#### 3. Cú lừa ở phút chót `tryLast(where:)`
* **Mục tiêu:** Bạn muốn lấy số `< 4` cuối cùng (chính là số 3).
* **Diễn biến:** * Máy tính âm thầm ghi nhớ: Gặp số `1` (lưu lại), gặp số `2` (lưu đè), gặp số `3` (lưu đè).
  * Mọi chuyện đang rất tốt đẹp. Bạn đinh ninh khi luồng kết thúc sẽ nhận được số 3.
  * Quả bóng `4` đi qua -> Bỏ qua.
  * **BOOM!** Quả bóng `5` vừa xuất hiện ở luồng trên, luật cấm `if value == 5 { throw }` bị vi phạm. 
  * Tất cả công sức chờ đợi đổ sông đổ biển. Luồng sập ngay lập tức, nhảy vào block `.catch` và in ra chữ **"Lỗi"**. Bạn mất trắng số 3.
* **Thực chiến:** Bạn viết app tải một file lớn gồm nhiều chunk (mảnh). Bạn dùng `last` để báo trạng thái "Hoàn thành 100%". Nhưng nếu mảnh cuối cùng tải về bị lỗi mã hash (corrupted), bạn dùng `tryLast` để ném lỗi "File hỏng" thay vì báo "Thành công".
