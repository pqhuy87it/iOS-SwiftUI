# Combine: `makeConnectable()` & `ConnectablePublisher`

## 1. Vấn đề — Publisher bắt đầu emit ngay khi có subscriber

Mặc định, publisher bắt đầu emit value **ngay khi subscriber đầu tiên subscribe**. Nếu có nhiều subscriber subscribe ở thời điểm khác nhau → subscriber muộn **bỏ lỡ** value:

```swift
let publisher = [1, 2, 3, 4, 5].publisher

// Subscriber 1 — subscribe ngay
publisher
    .sink { print("Sub1: \($0)") }
    .store(in: &cancellables)
// Sub1: 1, Sub1: 2, Sub1: 3, Sub1: 4, Sub1: 5 ← nhận đủ

// Subscriber 2 — subscribe SAU (thực tế: vẫn nhận đủ vì Sequence là cold)
```

Với **hot publishers** hoặc publishers có side effect, vấn đề rõ ràng hơn:

```swift
let publisher = URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .share()    // share giữa nhiều subscriber

// Subscriber 1 subscribe → trigger network request
publisher.sink { data in print("Sub1: \(data)") }

// Subscriber 2 subscribe 0.1 giây sau → request ĐÃ CHẠY
// Có thể BỎ LỠ kết quả nếu response về trước Sub2 subscribe
publisher.sink { data in print("Sub2: \(data)") }
```

→ Cần cơ chế: **đợi tất cả subscriber sẵn sàng, rồi mới bắt đầu emit**.

---

## 2. `ConnectablePublisher` — Publisher có "công tắc"

`ConnectablePublisher` là publisher đặc biệt — **không tự emit** khi có subscriber. Nó chỉ emit khi ta gọi `.connect()` thủ công.

```
Publisher thường:
  subscribe → emit ngay lập tức
  
ConnectablePublisher:
  subscribe → chờ...
  subscribe → chờ...
  subscribe → chờ...
  connect() → BẮT ĐẦU emit cho TẤT CẢ subscribers
```

Hình dung: publisher thường là **vòi nước tự chảy** khi mở van. ConnectablePublisher là vòi nước có **nút bấm riêng** — mở van (subscribe) chưa chảy, phải bấm nút (connect) mới chảy.

---

## 3. `makeConnectable()` — Biến publisher thường thành ConnectablePublisher

### Cú pháp

```swift
let connectable = somePublisher.makeConnectable()
// Type: Publishers.MakeConnectable<SomePublisher>
// Conform: ConnectablePublisher
```

### Ví dụ cơ bản

```swift
let url = URL(string: "https://api.example.com/data")!

// 1. Tạo connectable publisher
let connectable = URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: [User].self, decoder: JSONDecoder())
    .makeConnectable()
//  ↑ Giờ là ConnectablePublisher — KHÔNG tự chạy

// 2. Subscribe nhiều subscriber (chưa có gì xảy ra)
connectable
    .sink(
        receiveCompletion: { print("Sub1 completion: \($0)") },
        receiveValue: { print("Sub1: \($0.count) users") }
    )
    .store(in: &cancellables)

connectable
    .sink(
        receiveCompletion: { print("Sub2 completion: \($0)") },
        receiveValue: { print("Sub2: \($0.count) users") }
    )
    .store(in: &cancellables)

// ← TẠI ĐÂY: chưa có network request nào

// 3. Connect — BẮT ĐẦU!
let connection = connectable.connect()
// ← BÂY GIỜ: network request gửi đi
// ← Cả Sub1 và Sub2 đều nhận kết quả
```

### Timeline

```
t=0:   connectable tạo xong          (chưa gì xảy ra)
t=1:   Sub1 subscribe                (chưa gì xảy ra)
t=2:   Sub2 subscribe                (chưa gì xảy ra)
t=3:   connectable.connect()         ← TRIGGER: network request
t=4:   response trả về
       Sub1 nhận: [User]             ✅
       Sub2 nhận: [User]             ✅
       (cùng data, cùng lúc)
```

---

## 4. `connect()` trả về `Cancellable`

```swift
let connection = connectable.connect()
// Type: Cancellable

// Huỷ connection → ngừng emit cho TẤT CẢ subscribers
connection.cancel()
```

```swift
// Giữ connection trong property
class ViewModel {
    private var connection: Cancellable?
    private var cancellables = Set<AnyCancellable>()
    
    func setup() {
        let connectable = publisher.makeConnectable()
        
        connectable.sink { ... }.store(in: &cancellables)
        connectable.sink { ... }.store(in: &cancellables)
        
        // Bắt đầu khi sẵn sàng
        connection = connectable.connect()
    }
    
    func stop() {
        connection?.cancel()    // dừng tất cả
    }
}
```

---

## 5. `autoconnect()` — Tự động connect khi có subscriber ĐẦU TIÊN

Một số publisher (như `Timer.publish`) trả về `ConnectablePublisher` mặc định. Dùng `autoconnect()` để **bỏ qua bước connect thủ công**:

```swift
// Timer.publish trả về ConnectablePublisher
let timer = Timer.publish(every: 1, on: .main, in: .common)
// ← Chưa chạy, đợi connect()

// Cách 1: connect thủ công
let connection = timer.connect()

// Cách 2: autoconnect — tự connect khi subscriber đầu tiên subscribe
timer.autoconnect()
    .sink { date in print(date) }
    .store(in: &cancellables)
// ← Tự connect ngay, timer bắt đầu chạy
```

**`autoconnect()` biến ConnectablePublisher thành publisher thường** — tiện nhưng mất khả năng kiểm soát thời điểm bắt đầu.

---

## 6. `makeConnectable()` vs `share()` vs `multicast`

Cả ba đều liên quan đến **chia sẻ publisher giữa nhiều subscribers**. Hiểu rõ sự khác biệt:

### 6.1 Publisher thường — Mỗi subscriber tạo subscription RIÊNG

```swift
let networkPub = URLSession.shared.dataTaskPublisher(for: url)

networkPub.sink { ... }   // ← network request #1
networkPub.sink { ... }   // ← network request #2 (KHÁC!)
// 2 subscribers → 2 requests → 2 responses
```

### 6.2 `share()` — Chia sẻ subscription, nhưng hot (bắt đầu ngay)

```swift
let shared = URLSession.shared.dataTaskPublisher(for: url)
    .share()

shared.sink { ... }   // ← subscribe + trigger request ngay
shared.sink { ... }   // ← subscribe SAU, có thể bỏ lỡ nếu response về rồi
// 1 request, nhưng Sub2 có thể miss
```

```
share():
  Sub1 subscribe → REQUEST bắt đầu ngay
  Sub2 subscribe (muộn hơn)
  Response trả về → Sub1 nhận ✅, Sub2 nhận ✅ (nếu kịp subscribe)
                                    Sub2 ❌ (nếu response về trước)
```

### 6.3 `makeConnectable()` — Chia sẻ + kiểm soát thời điểm bắt đầu

```swift
let connectable = URLSession.shared.dataTaskPublisher(for: url)
    .share()
    .makeConnectable()

connectable.sink { ... }   // ← subscribe, chưa request
connectable.sink { ... }   // ← subscribe, chưa request
connectable.connect()       // ← BÂY GIỜ mới request
// 1 request, CẢ HAI subscriber đều nhận
```

```
makeConnectable():
  Sub1 subscribe → chờ...
  Sub2 subscribe → chờ...
  connect()      → REQUEST bắt đầu
  Response       → Sub1 nhận ✅, Sub2 nhận ✅ (đảm bảo cả hai)
```

### 6.4 `multicast` — ConnectablePublisher với Subject tuỳ chỉnh

```swift
let multicasted = URLSession.shared.dataTaskPublisher(for: url)
    .multicast(subject: PassthroughSubject())
//                       ↑ Subject phân phối value cho subscribers

multicasted.sink { ... }
multicasted.sink { ... }
multicasted.connect()    // trigger + phân phối qua subject
```

`multicast` cho phép chọn **loại Subject** — `PassthroughSubject` (không replay) hay `CurrentValueSubject` (replay value cuối).

### Bảng so sánh

```
                    Publisher thường    share()         makeConnectable()    multicast
                    ────────────────    ───────         ─────────────────    ─────────
Subscription        Riêng mỗi sub      Chung 1         Chung 1              Chung 1
Network requests    N requests          1 request       1 request            1 request
Bắt đầu khi?       Subscribe ngay      Subscribe ngay  connect() thủ công   connect() thủ công
Sub muộn miss?      Không (cold)        Có thể          Không (đợi connect)  Không (đợi connect)
Kiểm soát timing?  ❌                   ❌               ✅                    ✅
Custom Subject?     ❌                   ❌               ❌                    ✅
```

---

## 7. Ứng dụng thực tế

### 7.1 Đảm bảo nhiều subscriber nhận cùng data từ 1 API call

```swift
class DashboardViewModel: ObservableObject {
    @Published var userInfo: UserInfo?
    @Published var stats: Stats?
    @Published var notifications: [Notification] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var connection: Cancellable?
    
    func loadDashboard() {
        // 1 API call trả về tất cả dashboard data
        let connectable = api.fetchDashboard()
            .share()
            .makeConnectable()
        
        // Subscriber 1: extract user info
        connectable
            .map(\.userInfo)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] info in self?.userInfo = info }
            )
            .store(in: &cancellables)
        
        // Subscriber 2: extract stats
        connectable
            .map(\.stats)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] stats in self?.stats = stats }
            )
            .store(in: &cancellables)
        
        // Subscriber 3: extract notifications
        connectable
            .map(\.notifications)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] notifs in self?.notifications = notifs }
            )
            .store(in: &cancellables)
        
        // Tất cả subscriber sẵn sàng → connect
        connection = connectable.connect()
        // ← 1 network request, 3 subscribers nhận cùng response
    }
}
```

```
                            ┌── map(\.userInfo) ──▶ Sub1: userInfo
API.fetchDashboard() ──────┼── map(\.stats) ─────▶ Sub2: stats
     (1 request)           └── map(\.notifications)▶ Sub3: notifications
```

### 7.2 Timer chia sẻ giữa nhiều view

```swift
class SharedTimerManager {
    static let shared = SharedTimerManager()
    
    let timer: Publishers.MakeConnectable<Publishers.Autoconnect<Timer.TimerPublisher>>
    private var connection: Cancellable?
    private var subscriberCount = 0
    
    private init() {
        // Timer connectable — chỉ chạy khi connect
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .makeConnectable()
    }
    
    func start() {
        subscriberCount += 1
        if connection == nil {
            connection = timer.connect()
        }
    }
    
    func stop() {
        subscriberCount -= 1
        if subscriberCount <= 0 {
            connection?.cancel()
            connection = nil
            subscriberCount = 0
        }
    }
}
```

### 7.3 Multicast với replay (CurrentValueSubject)

```swift
class ConfigManager {
    private var cancellables = Set<AnyCancellable>()
    private var connection: Cancellable?
    
    // Dùng CurrentValueSubject → subscriber muộn nhận value cuối cùng
    let config: Publishers.Multicast<AnyPublisher<AppConfig, Error>, CurrentValueSubject<AppConfig, Error>>
    
    init() {
        config = api.fetchConfig()
            .multicast(subject: CurrentValueSubject<AppConfig, Error>(.default))
        //                       ↑ CurrentValueSubject: replay value cuối cho sub mới
    }
    
    func start() {
        connection = config.connect()
    }
}

// Subscriber 1 (subscribe trước connect)
configManager.config
    .sink(receiveCompletion: { _ in }, receiveValue: { config in
        applyTheme(config.theme)
    })
    .store(in: &cancellables)

// Subscriber 2 (subscribe SAU response về)
// → Vẫn nhận config nhờ CurrentValueSubject replay
configManager.config
    .sink(receiveCompletion: { _ in }, receiveValue: { config in
        setupFeatureFlags(config.flags)
    })
    .store(in: &cancellables)
```

### 7.4 Batch subscribers rồi connect

```swift
class AnalyticsCoordinator {
    private var cancellables = Set<AnyCancellable>()
    private var connection: Cancellable?
    
    func setupTracking(for eventStream: AnyPublisher<AnalyticsEvent, Never>) {
        let connectable = eventStream
            .share()
            .makeConnectable()
        
        // Logger
        connectable
            .sink { event in Logger.log(event) }
            .store(in: &cancellables)
        
        // Analytics service
        connectable
            .filter { $0.isSignificant }
            .throttle(for: .seconds(5), scheduler: DispatchQueue.global(), latest: true)
            .sink { event in AnalyticsService.send(event) }
            .store(in: &cancellables)
        
        // Crash reporter
        connectable
            .filter { $0.type == .error }
            .sink { event in CrashReporter.record(event) }
            .store(in: &cancellables)
        
        // Tất cả đã đăng ký → bắt đầu nhận events
        connection = connectable.connect()
    }
}
```

```
                          ┌── Logger (tất cả events)
eventStream ──connect()──┼── Analytics (significant, throttled)
                          └── CrashReporter (errors only)
```

---

## 8. ConnectablePublisher Protocol

```swift
protocol ConnectablePublisher: Publisher {
    func connect() -> Cancellable
}
```

Chỉ thêm **1 method**: `connect()`. Mọi thứ khác (subscribe, operators) giống publisher thường.

### Publishers đã là ConnectablePublisher sẵn

```swift
// Timer.publish — ConnectablePublisher mặc định
Timer.publish(every: 1, on: .main, in: .common)
// → Phải .connect() hoặc .autoconnect() mới chạy

// multicast — trả về ConnectablePublisher
publisher.multicast(subject: PassthroughSubject())

// makeConnectable — biến publisher bất kỳ thành connectable
publisher.makeConnectable()
```

---

## 9. Luồng thực thi bên trong

```
makeConnectable() wrap publisher gốc:
┌─────────────────────────────────────────────────┐
│ MakeConnectable                                  │
│                                                  │
│  ┌──────────────────┐                            │
│  │ Original Publisher│  ← CHƯA subscribe vào     │
│  └──────────────────┘                            │
│                                                  │
│  Subscribers: [Sub1, Sub2, Sub3]  ← ghi nhận     │
│                                                  │
│  connect() được gọi:                             │
│    1. Subscribe vào Original Publisher            │
│    2. Forward mọi value cho [Sub1, Sub2, Sub3]   │
│                                                  │
│  connection.cancel():                            │
│    1. Cancel subscription vào Original Publisher  │
│    2. Ngừng forward value                        │
│                                                  │
└─────────────────────────────────────────────────┘
```

---

## 10. Kết hợp phổ biến

### `share()` + `makeConnectable()` — Pattern chuẩn

```swift
// share() đảm bảo: 1 subscription duy nhất cho upstream
// makeConnectable() đảm bảo: đợi tất cả subscriber sẵn sàng

let connectable = expensivePublisher
    .share()               // 1 subscription cho upstream
    .makeConnectable()     // đợi connect() mới bắt đầu

connectable.sink { ... }.store(in: &cancellables)  // Sub1
connectable.sink { ... }.store(in: &cancellables)  // Sub2

let connection = connectable.connect()              // GO!
```

**Không có `share()`:**

```swift
// ⚠️ makeConnectable() ALONE không tự share
// Mỗi subscriber vẫn có thể tạo subscription riêng
// Tuỳ implementation, có thể trigger upstream nhiều lần

// ✅ Luôn kết hợp share() + makeConnectable() cho safety
```

### `multicast` + `autoconnect()` — Share với auto-start

```swift
let shared = publisher
    .multicast { PassthroughSubject() }
    .autoconnect()
// → Share qua subject, tự connect khi subscriber đầu tiên

shared.sink { ... }   // ← auto connect, bắt đầu emit
shared.sink { ... }   // ← cũng nhận value (nếu kịp)
```

---

## 11. Sai lầm thường gặp

### ❌ Quên gọi `connect()`

```swift
let connectable = publisher.makeConnectable()

connectable.sink { print($0) }.store(in: &cancellables)

// ← QUÊN connect() → subscriber KHÔNG BAO GIỜ nhận value
// Không có lỗi, không có warning — im lặng tuyệt đối
```

### ❌ Connect trước khi subscribe

```swift
let connectable = [1, 2, 3].publisher.makeConnectable()

let connection = connectable.connect()   // emit ngay
// ← Sequence phát đồng bộ 1, 2, 3 rồi finished

connectable.sink { print($0) }.store(in: &cancellables)
// ← Subscribe SAU khi data đã emit → BỎ LỠ tất cả
```

### ❌ Quên giữ Cancellable từ connect()

```swift
func setup() {
    let connectable = publisher.makeConnectable()
    connectable.sink { ... }.store(in: &cancellables)
    
    connectable.connect()
    // ← Cancellable không được giữ
    // ← Tuỳ implementation: có thể bị cancel ngay (ít gặp nhưng unsafe)
}

// ✅ Giữ connection
connection = connectable.connect()
```

---

## 12. Tóm tắt

| Khía cạnh | Chi tiết |
|---|---|
| **Là gì?** | `makeConnectable()` biến publisher thường thành `ConnectablePublisher` — publisher có "công tắc" |
| **Vấn đề giải quyết** | Đảm bảo nhiều subscriber subscribe xong hết rồi mới bắt đầu emit |
| **connect()** | Trigger publisher bắt đầu emit — trả về `Cancellable` để huỷ sau |
| **autoconnect()** | Bỏ qua connect thủ công — tự connect khi subscriber đầu tiên subscribe |
| **share() + makeConnectable()** | Pattern chuẩn: 1 subscription upstream + kiểm soát timing |
| **multicast(subject:)** | ConnectablePublisher với Subject tuỳ chỉnh (replay, buffer...) |
| **Timer.publish** | ConnectablePublisher mặc định — phải connect/autoconnect |
| **Dùng khi** | Nhiều subscriber cần cùng data, expensive operations, batch setup |

----

`@FocusState` giải quyết bài toán kiểm soát keyboard/focus bằng code trong SwiftUI, Huy. Ba điểm cốt lõi:

**Hai dạng sử dụng:** Dạng `Bool` (`@FocusState var isFocused: Bool`) cho 1 field — `true` hiện keyboard, `false` ẩn. Dạng `Enum?` (`@FocusState var field: Field?`) cho nhiều fields — gán `.email` focus vào email, gán `nil` ẩn keyboard. Dạng Enum mạnh hơn nhiều vì biết chính xác field nào đang active.

**`.focused()` modifier** là cầu nối giữa `@FocusState` và TextField. Không có modifier này, `@FocusState` không biết field nào để focus. Dạng Bool: `.focused($isFocused)`. Dạng Enum: `.focused($focusedField, equals: .email)`.

**Ứng dụng thực tế phổ biến nhất:** chuyển field khi nhấn Return (`.onSubmit { focusedField = .nextField }` + `.submitLabel(.next)`), ẩn keyboard khi tap bên ngoài (`isInputFocused = false`), auto-focus khi view xuất hiện, toolbar Done button cho NumberPad/DecimalPad, và OTP input auto-advance. Pattern login form kết hợp focus-based validation (chỉ hiện error khi field **mất focus**) rất phổ biến trong production.

Lưu ý: `@FocusState` chỉ dùng trong View struct, không dùng trong ViewModel. Và nó không nhận initial value — mặc định `false` (Bool) hoặc `nil` (Optional Enum).
