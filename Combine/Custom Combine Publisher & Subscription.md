# Custom Combine Publisher & Subscription — Giải thích chi tiết

## 1. Bức tranh tổng thể — Combine Protocol Chain

Combine hoạt động theo hợp đồng 3 bên:

```
Publisher ←──conform──→ Protocol: Combine.Publisher
    │                       - typealias Output
    │                       - typealias Failure
    │                       - func receive<S>(subscriber: S)
    │
    │  tạo ra
    ▼
Subscription ←──conform──→ Protocol: Combine.Subscription
    │                          - func request(_ demand:)
    │                          - func cancel()
    │
    │  gửi value cho
    ▼
Subscriber ←──conform──→ Protocol: Combine.Subscriber
                             - typealias Input
                             - typealias Failure
                             - func receive(subscription:)
                             - func receive(_ input:) -> Demand
                             - func receive(completion:)
```

**Luồng kết nối (handshake):**

```
1. subscriber đăng ký:     publisher.receive(subscriber: s)
2. publisher tạo subscription rồi giao cho subscriber:
                            subscriber.receive(subscription: sub)
3. subscriber yêu cầu data: subscription.request(.max(1))
4. subscription gửi value:  subscriber.receive(value)
5. kết thúc:                subscriber.receive(completion:)
```

---

## 2. Tại sao cần `Combine.Subscription` thay vì `Subscription`?

Trong đoạn code, class có tên `Subscription` — **trùng tên** với protocol `Combine.Subscription`. Swift sẽ nhầm lẫn nếu không phân biệt:

```swift
// ❌ Ambiguous: Swift nghĩ class đang kế thừa chính nó
class Subscription<S>: Subscription { ... }

// ✅ Dùng module prefix để chỉ rõ protocol từ framework Combine
class Subscription<S>: Combine.Subscription { ... }
```

Tương tự, `PhotoService.Publisher` cũng conform `Combine.Publisher` — cùng lý do.

---

## 3. Mổ xẻ dòng khai báo Subscription

```swift
class Subscription<S: Subscriber>: Combine.Subscription
    where S.Input == UIImage,
          S.Failure == PhotoService.Publisher.Failure
```

Dòng này gồm **4 thành phần** ghép lại:

### 3a. `<S: Subscriber>` — Generic type parameter với constraint

```swift
class Subscription<S: Subscriber>
//                 ↑       ↑
//           Type param   Constraint: S phải conform protocol Subscriber
```

Tại sao generic? Vì Subscription cần **giữ reference đến subscriber** để gửi value, nhưng subscriber có thể là bất kỳ type nào conform `Subscriber` (có thể là `Subscribers.Sink`, một ViewModel custom, hay bất kỳ object nào). Generic cho phép Subscription hoạt động với mọi loại subscriber mà không cần type erasure.

```swift
private let subscriber: S  // giữ reference cụ thể, không mất type info
```

### 3b. `: Combine.Subscription` — Conform protocol

```swift
class Subscription<S: Subscriber>: Combine.Subscription
//                                 ↑
//                    Conform protocol Subscription từ Combine framework
```

Protocol `Combine.Subscription` yêu cầu implement:

```swift
func request(_ demand: Subscribers.Demand)  // subscriber yêu cầu bao nhiêu value
func cancel()                                // huỷ subscription
var combineIdentifier: CombineIdentifier { get }  // identity duy nhất
```

### 3c. `where S.Input == UIImage` — Ràng buộc Output type

```swift
where S.Input == UIImage
//    ↑            ↑
//    Subscriber   Phải nhận UIImage
//    nhận gì?
```

`Subscriber` protocol có associated type `Input` — kiểu dữ liệu nó chấp nhận. Constraint này đảm bảo: subscriber phải là loại **nhận được UIImage**. Nếu ai đó cố subscribe với `Subscriber` nhận `String` → **compiler báo lỗi**.

### 3d. `where S.Failure == PhotoService.Publisher.Failure` — Ràng buộc Error type

```swift
where S.Failure == PhotoService.Publisher.Failure
//    ↑                   ↑
//    Subscriber          = PhotoService.Error
//    xử lý lỗi gì?
```

`PhotoService.Publisher.Failure` chính là `PhotoService.Error` (typealias ở Publisher). Constraint này đảm bảo subscriber xử lý **đúng loại lỗi** mà publisher phát ra.

### Tổng hợp — Đọc như một câu tiếng Việt

> "Class `Subscription` là generic trên type `S`. `S` phải là một `Subscriber` mà nhận `UIImage` làm input và xử lý `PhotoService.Error` làm failure. Class này conform protocol `Combine.Subscription`."

Tương đương logic:

```swift
// Nếu Swift hỗ trợ viết gộp (không hợp lệ, chỉ minh hoạ):
class Subscription<S>: Combine.Subscription
    where S: Subscriber,          // S phải là Subscriber
          S.Input == UIImage,     // nhận UIImage
          S.Failure == PhotoService.Error  // lỗi là PhotoService.Error
```

---

## 4. Mối liên hệ với `receive<S>(subscriber:)` ở Publisher

```swift
// Trong PhotoService.Publisher:
public func receive<S: Subscriber>(subscriber: S)
    where Failure == S.Failure,   // Publisher.Failure == Subscriber.Failure
          Output == S.Input {     // Publisher.Output == Subscriber.Input
    
    let subscription = Subscription(
        quality: quality,
        shouldFail: ...,
        subscriber: subscriber    // S được truyền vào Subscription<S>
    )
    subscriber.receive(subscription: subscription)
}
```

**Chuỗi type matching:**

```
Publisher                    Subscriber S              Subscription<S>
─────────                    ────────────              ───────────────
Output  = UIImage      ←→   S.Input  = UIImage    ←→  where S.Input == UIImage
Failure = PhotoService.Error ←→ S.Failure = ...    ←→  where S.Failure == ...
```

Khi `receive(subscriber:)` được gọi:
1. Swift suy ra concrete type `S` từ subscriber truyền vào
2. Kiểm tra constraints: `S.Input == UIImage` ✅, `S.Failure == PhotoService.Error` ✅
3. `Subscription<S>` được khởi tạo với **đúng type** subscriber đó
4. Subscription giữ `subscriber: S` → gọi `subscriber.receive(value)` sau này

---

## 5. Luồng thực thi hoàn chỉnh

```swift
// Người dùng gọi:
PhotoService()
    .fetchPhoto(quality: .high, failingTimes: 2)  // → Publisher
    .sink(receiveCompletion: { ... },              // → tạo Subscribers.Sink
          receiveValue: { image in ... })           //    S = Subscribers.Sink<UIImage, PhotoService.Error>
    .store(in: &cancellables)
```

```
Bước 1: sink tạo Subscribers.Sink<UIImage, PhotoService.Error>
        ↓
Bước 2: publisher.receive(subscriber: sinkSubscriber)
        ↓
Bước 3: Publisher tạo Subscription<Subscribers.Sink<UIImage, PhotoService.Error>>
        Swift kiểm tra:
          Subscribers.Sink.Input   == UIImage             ✅
          Subscribers.Sink.Failure == PhotoService.Error   ✅
        ↓
Bước 4: subscriber.receive(subscription: subscription)
        Sink nhận subscription, gọi subscription.request(.unlimited)
        ↓
Bước 5: Subscription.request(_:) chạy
        Sau random delay, gửi UIImage hoặc Error cho subscriber
        ↓
Bước 6: subscriber.receive(UIImage(...))      → sink closure nhận ảnh
        subscriber.receive(completion: .finished)  → pipeline kết thúc
```

---

## 6. `request(_ demand:)` — Logic phát ảnh

```swift
func request(_ demand: Subscribers.Demand) {
    let randomDelay = TimeInterval.random(in: 0.5...2.5)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) { [weak self] in
        guard let self = self else { return }
        
        switch self.quality {
        case .high:
            guard self.shouldFail else {
                // Thành công: gửi ảnh rồi hoàn thành
                _ = self.subscriber.receive(UIImage(named: "hq.jpg")!)
                self.subscriber.receive(completion: .finished)
                return
            }
            // Thất bại: gửi error
            self.subscriber.receive(completion: .failure(.failedFetching(self.quality)))
            
        case .low:
            // Low quality luôn thành công
            _ = self.subscriber.receive(UIImage(named: "lq.jpg")!)
            self.subscriber.receive(completion: .finished)
        }
    }
}
```

Đây là nơi Subscription thực sự **làm việc** — mô phỏng network call với delay ngẫu nhiên. Kết quả được gửi trực tiếp qua `self.subscriber.receive(...)` nhờ generic `S` đã giữ đúng type.

---

## 7. Tại sao không dùng `AnySubscriber` thay Generic?

```swift
// Cách 1: Generic (đoạn code hiện tại) ✅
class Subscription<S: Subscriber>: ... where S.Input == UIImage {
    private let subscriber: S           // concrete type, zero overhead
    subscriber.receive(value)           // static dispatch, nhanh
}

// Cách 2: Type-erased (thay thế) — hoạt động nhưng kém tối ưu
class Subscription: Combine.Subscription {
    private let subscriber: AnySubscriber<UIImage, PhotoService.Error>
    subscriber.receive(value)           // dynamic dispatch qua existential
}
```

| | Generic `<S>` | `AnySubscriber` |
|---|---|---|
| Performance | Static dispatch, inline-able | Dynamic dispatch qua existential container |
| Type safety | Compile-time check đầy đủ | Vẫn type-safe nhưng mất khả năng tối ưu |
| Boilerplate | Khai báo dài hơn | Ngắn hơn |
| Convention | ✅ Chuẩn Apple/Combine | Dùng khi cần flexibility |

→ **Generic là convention chuẩn** của Combine, giống cách Apple viết trong framework gốc.

---

## 8. Tóm tắt cú pháp

```swift
class Subscription<S: Subscriber>: Combine.Subscription
//    ↑            ↑                ↑
//    Tên class    Generic param    Conform protocol (dùng prefix tránh trùng tên)
//
    where S.Input == UIImage,
//        ↑
//        Ràng buộc 1: Subscriber phải nhận UIImage
//
          S.Failure == PhotoService.Publisher.Failure
//        ↑
//        Ràng buộc 2: Subscriber phải xử lý đúng loại Error
```

Ba ràng buộc kết hợp (`S: Subscriber` + `S.Input == UIImage` + `S.Failure == Error`) tạo thành **hợp đồng type-safe** đảm bảo: Subscription chỉ hoạt động với subscriber tương thích, và compiler kiểm tra tất cả tại compile-time.

--------------

Đây là một ví dụ rất tốt về Custom Publisher pattern trong Combine, Huy. Dòng khai báo đó nhìn dài nhưng thực chất ghép từ 4 ý:

**`<S: Subscriber>`** — Generic: Subscription không biết trước subscriber cụ thể là type gì, chỉ biết nó conform `Subscriber`. Nhờ generic, nó giữ reference `private let subscriber: S` với concrete type → static dispatch, performance tốt hơn dùng `AnySubscriber`.

**`: Combine.Subscription`** — Conform protocol. Phải dùng prefix `Combine.` vì class cũng tên `Subscription` → nếu không có prefix, Swift nghĩ class kế thừa chính nó.

**`where S.Input == UIImage`** — Ràng buộc subscriber phải nhận `UIImage`. Nếu ai subscribe với type khác (ví dụ `String`) → compiler báo lỗi ngay.

**`S.Failure == PhotoService.Publisher.Failure`** — Ràng buộc subscriber phải xử lý đúng loại error (`PhotoService.Error`). Đảm bảo chuỗi type matching xuyên suốt từ Publisher → Subscription → Subscriber khớp nhau hoàn toàn tại compile-time.

Điểm hay của pattern này là **Combine handshake**: Publisher không trực tiếp gửi data, mà tạo Subscription rồi giao cho Subscriber. Subscriber gọi `request(_:)` trên Subscription để yêu cầu data — đây là cơ chế **back-pressure** của Combine.
