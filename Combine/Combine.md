Chào bạn! Dựa trên tài liệu chính thức của Apple về **Combine**, framework này cung cấp một cách tiếp cận theo hướng "Lập trình phản ứng" (Reactive Programming) để xử lý các sự kiện bất đồng bộ theo thời gian. 

Thay vì phải dùng closures, delegates hay NotificationCenter một cách rời rạc, Combine nhóm mọi thứ thành các luồng dữ liệu (data streams).

Dưới đây là tổng hợp và phân nhóm các đối tượng (objects/protocols) cốt lõi nhất mà Apple đề cập trong tài liệu Combine, giúp bạn dễ dàng hình dung bức tranh tổng thể:

### 1. Nhóm Nguồn phát và Người nhận (Core Components)
Đây là hai nhân tố tạo nên "trái tim" của Combine. Mọi thứ trong Combine đều bắt nguồn từ việc một bên phát dữ liệu và một bên lắng nghe dữ liệu đó.

* **`Publisher` (Nguồn phát):** Là một protocol định nghĩa cách thức và loại dữ liệu sẽ được phát đi theo thời gian. Một Publisher có 2 kiểu (types) đi kèm: `Output` (Kiểu dữ liệu phát ra) và `Failure` (Kiểu lỗi nếu xảy ra, hoặc `Never` nếu không bao giờ có lỗi).
* **`Subscriber` (Người nhận/đăng ký):** Là protocol nhận các giá trị từ `Publisher`. Khi một Subscriber kết nối với Publisher, nó có thể yêu cầu số lượng dữ liệu muốn nhận và xử lý từng giá trị khi chúng đến.
* **`Subscription` (Bản hợp đồng kết nối):** Khi Subscriber đăng ký vào Publisher, một `Subscription` được tạo ra. Nó đại diện cho kết nối giữa hai bên và kiểm soát luồng dữ liệu (ví dụ: Subscriber có thể dùng nó để yêu cầu thêm dữ liệu hoặc huỷ kết nối).

### 2. Nhóm Chủ thể (Subjects)
`Subject` là một đối tượng đặc biệt đóng vai trò **vừa là Publisher, vừa là Subscriber**. Khác với Publisher thông thường (thường chỉ phát dữ liệu khi có người đăng ký), Subject cho phép bạn "bơm" (inject) dữ liệu vào luồng bất kỳ lúc nào bằng phương thức `send()`.

Apple cung cấp 2 loại Subject chính:
* **`PassthroughSubject`:** Đóng vai trò như một cái chuông cửa. Nó chỉ phát dữ liệu cho những ai **đang lắng nghe ngay lúc đó**. Nếu dữ liệu được phát ra trước khi Subscriber đăng ký, dữ liệu đó sẽ bị bỏ qua. Nó không lưu giữ trạng thái.
* **`CurrentValueSubject`:** Giống như một cái công tắc đèn. Nó **luôn lưu giữ giá trị mới nhất**. Bất cứ khi nào có một Subscriber mới đăng ký, nó sẽ ngay lập tức phát giá trị hiện tại cho người đó, rồi mới tiếp tục phát các giá trị tiếp theo.

### 3. Nhóm Toán tử (Operators)
Đây là các hàm (methods) được gắn trên `Publisher` giúp bạn biến đổi, lọc, hoặc kết hợp luồng dữ liệu trước khi nó đến tay `Subscriber`. Mỗi toán tử nhận vào một Publisher và trả ra một Publisher mới.

* **Toán tử biến đổi (Mapping):** `map`, `flatMap`, `compactMap`, `replaceNil`... (Dùng để đổi kiểu dữ liệu A sang B).
* **Toán tử lọc (Filtering):** `filter`, `removeDuplicates`, `compactMap`, `dropFirst`... (Dùng để loại bỏ các dữ liệu không mong muốn).
* **Toán tử kết hợp (Combining):** `merge`, `zip`, `combineLatest`... (Gộp nhiều luồng Publisher thành một luồng duy nhất).
* **Toán tử xử lý lỗi (Error Handling):** `catch`, `retry`, `mapError`, `replaceError`... (Bắt lỗi và đưa ra hướng giải quyết để luồng không bị sập).

### 4. Nhóm Lập lịch và Luồng xử lý (Schedulers)
Trong lập trình bất đồng bộ, việc quyết định đoạn code chạy ở luồng (thread) nào là cực kỳ quan trọng (ví dụ: việc tính toán nặng để ở Background thread, việc cập nhật UI phải ở Main thread).

* **`Scheduler`:** Là protocol định nghĩa *thời điểm* và *nơi* mà quá trình xử lý diễn ra.
* **`subscribe(on:)`:** Quyết định luồng mà thao tác đăng ký và công việc nặng của Publisher sẽ diễn ra (thường là luồng nền - Background Queue).
* **`receive(on:)`:** Quyết định luồng mà Subscriber sẽ nhận kết quả (thường dùng `DispatchQueue.main` để cập nhật Giao diện người dùng).
* *Các đối tượng hỗ trợ Scheduler:* `DispatchQueue`, `RunLoop`, `OperationQueue`.

### 5. Nhóm Quản lý Bộ nhớ (Memory Management)
Nếu bạn mở một luồng lắng nghe mà quên đóng lại, ứng dụng sẽ bị rò rỉ bộ nhớ (Memory Leak). Nhóm này sinh ra để giải quyết việc đó.

* **`Cancellable`:** Một protocol định nghĩa đối tượng có khả năng bị huỷ (cancel).
* **`AnyCancellable`:** Một class cụ thể lưu giữ tham chiếu của `Subscription`. Khi đối tượng `AnyCancellable` này bị giải phóng khỏi bộ nhớ (deinit), nó sẽ tự động gọi hàm `cancel()` để ngắt kết nối luồng Combine.
* **`.store(in: &cancellables)`:** Hàm phổ biến nhất, giúp bạn gom tất cả các luồng Combine vào một mảng (Set) `AnyCancellable` để quản lý tập trung. Khi Class chứa mảng này bị huỷ, tất cả luồng Combine sẽ tự động huỷ theo một cách an toàn.

**Tóm tắt cách chúng hoạt động cùng nhau:**
Bạn tạo một **Publisher** -> Dùng các **Operators** để nhào nặn dữ liệu -> Đẩy nó về Main Thread bằng **Scheduler** -> Đăng ký nhận bằng **Subscriber** (ví dụ: `.sink`) -> Lưu kết nối vào **AnyCancellable** để tránh rò rỉ bộ nhớ.
