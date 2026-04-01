# Combine Subjects: `PassthroughSubject`, `CurrentValueSubject` & `send()`

## 1. Subject là gì?

Subject là một **Publisher đặc biệt** — vừa là Publisher (phát value), vừa cho phép bên ngoài **chủ động inject value** vào pipeline thông qua method `send()`. Nó đóng vai trò **cầu nối** giữa code imperative (UIKit callback, delegate, closure) và thế giới reactive của Combine.

```
Code imperative ──send()──▶ Subject ──▶ Operator ──▶ Subscriber
```

---

## 2. `PassthroughSubject<Output, Failure>`

### Bản chất

Một relay thuần tuý — **không giữ state**. Nó chỉ forward value đến subscriber tại thời điểm `send()` được gọi. Nếu không có subscriber nào đang lắng nghe, value **bị mất**.

```swift
let subject = PassthroughSubject<Int, Never>()

// Chưa có subscriber → value bị mất
subject.send(999)  // không ai nhận

// Bây giờ mới subscribe
subject
    .sink { print($0) }
    .store(in: &cancellables)

subject.send(1)  // ✅ in ra: 1
subject.send(2)  // ✅ in ra: 2
```

### Đặc điểm

| Thuộc tính | Giá trị |
|---|---|
| Giữ value hiện tại? | ❌ Không |
| Subscriber mới nhận value cũ? | ❌ Không |
| Replay khi subscribe? | ❌ Không |
| Khi nào dùng? | Event stream (tap, notification, trigger) — chỉ quan tâm "từ bây giờ trở đi" |

### Ví dụ thực tế — Button tap stream

```swift
class PaymentViewModel: ObservableObject {
    // Event không có "giá trị hiện tại" → PassthroughSubject
    let payTapped = PassthroughSubject<Void, Never>()
    @Published private(set) var status: PaymentStatus = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    init(service: PaymentService) {
        payTapped
            .throttle(for: .seconds(1), scheduler: RunLoop.main, latest: false)
            .flatMap { service.processPayment() }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                self?.status = result
            })
            .store(in: &cancellables)
    }
}

// Trong View
Button("Pay") { viewModel.payTapped.send() }
```

---

## 3. `CurrentValueSubject<Output, Failure>`

### Bản chất

Giống `PassthroughSubject` nhưng **luôn giữ một value hiện tại**. Khi khởi tạo bắt buộc truyền initial value. Khi có subscriber mới → **ngay lập tức nhận value hiện tại** (replay 1).

```swift
let subject = CurrentValueSubject<Int, Never>(0) // initial = 0

subject.send(10)
subject.send(20)

// Subscribe SAU khi đã send 10, 20
subject
    .sink { print($0) }
    .store(in: &cancellables)
// ✅ in ra: 20  (giá trị hiện tại, KHÔNG phải 0 hay 10)

subject.send(30)
// ✅ in ra: 30
```

### Truy cập giá trị hiện tại bất kỳ lúc nào

```swift
let temperature = CurrentValueSubject<Double, Never>(25.0)
temperature.send(30.5)

print(temperature.value)  // 30.5 — đọc đồng bộ, không cần subscribe
```

### Đặc điểm

| Thuộc tính | Giá trị |
|---|---|
| Giữ value hiện tại? | ✅ Có (property `.value`) |
| Subscriber mới nhận value cũ? | ✅ Nhận value **hiện tại** (mới nhất) |
| Replay khi subscribe? | ✅ Replay **1 value** (value hiện tại) |
| Khi nào dùng? | State có giá trị mặc định — settings, configuration, trạng thái hiện tại |

### So sánh nhanh

```
PassthroughSubject         CurrentValueSubject
─────────────────         ─────────────────────
Không initial value    →   Bắt buộc initial value
Không giữ state        →   Luôn giữ .value
Subscribe muộn = mất   →   Subscribe muộn = nhận value hiện tại
Event-driven           →   State-driven
```

---

## 4. `.send()` — Ba vai trò

### 4a. `send(_ value: Output)` — Phát value

```swift
let subject = PassthroughSubject<Int, Never>()
subject.send(1)    // emit Int value = 1 xuống tất cả subscriber
subject.send(2)    // emit Int value = 2
```

### 4b. `send(completion:)` — Kết thúc pipeline

```swift
// Kết thúc bình thường
subject.send(completion: .finished)

// Kết thúc với lỗi (khi Failure != Never)
let errorSubject = PassthroughSubject<Int, URLError>()
errorSubject.send(completion: .failure(URLError(.badServerResponse)))
```

Sau khi gửi completion, **mọi `send()` tiếp theo đều bị bỏ qua**:

```swift
subject.send(completion: .finished)
subject.send(99)  // ❌ Không có hiệu lực — pipeline đã đóng
```

### 4c. `send(_ subject: Publisher)` — Phát một publisher con (trong context CurrentValueSubject chứa publisher)

Đây là case đặc biệt trong đoạn code mẫu: `CurrentValueSubject` có `Output` là **một Publisher khác**. Khi gọi `send(intSubject2)`, nó thay đổi "publisher con hiện tại" mà `flatMap` sẽ subscribe vào.

---

## 5. Phân tích đoạn code từng bước

### Setup

```swift
typealias IntPublisher = PassthroughSubject<Int, Never>

let intSubject1 = IntPublisher()  // Publisher con #1
let intSubject2 = IntPublisher()  // Publisher con #2
let intSubject3 = IntPublisher()  // Publisher con #3

// Publisher "cha" — chứa publisher con, khởi tạo với intSubject1
let publisher = CurrentValueSubject<IntPublisher, Never>(intSubject1)
//              ↑ Output = IntPublisher (một publisher khác!)
//                                       ↑ initial value = intSubject1
```

**Cấu trúc 2 tầng:**

```
publisher (cha)          Tầng 1: emit các IntPublisher
   │
   ├── intSubject1       Tầng 2: mỗi IntPublisher emit Int
   ├── intSubject2
   └── intSubject3
```

### Pipeline

```swift
publisher
    .flatMap(maxPublishers: .max(2)) { $0 }
    //       ↑ TỐI ĐA 2 publisher con được subscribe đồng thời
    //                                   ↑ $0 = IntPublisher, trả về chính nó
    .sink(receiveValue: { results.append($0) })
    .store(in: &subscriptions)
```

`flatMap(maxPublishers: .max(2))` nghĩa là:
- Mỗi khi publisher cha emit một IntPublisher, `flatMap` **subscribe vào nó** và merge output (Int) vào stream chính.
- Nhưng **tối đa chỉ 2 inner subscription** cùng lúc. Publisher con thứ 3 trở đi sẽ bị **buffer** (chờ slot trống).

### Thực thi từng dòng

```
Trạng thái ban đầu:
┌─────────────────────────────────────────────────────┐
│ flatMap slots: [ __, __ ]  (max 2)                  │
│ CurrentValueSubject khởi tạo → emit intSubject1     │
│ flatMap subscribe intSubject1 → slot [S1, __ ]      │
│ results = []                                        │
└─────────────────────────────────────────────────────┘
```

```swift
intSubject1.send(1)
```
```
S1 đang active → nhận 1
flatMap forward 1 → sink
results = [1] ✅
```

```swift
publisher.send(intSubject2)
```
```
Publisher cha emit intSubject2
flatMap còn 1 slot trống → subscribe intSubject2
Slots: [S1, S2]  (đầy)
```

```swift
intSubject2.send(2)
```
```
S2 đang active → nhận 2
flatMap forward 2 → sink
results = [1, 2] ✅
```

```swift
publisher.send(intSubject3)
```
```
Publisher cha emit intSubject3
flatMap ĐÃ ĐẦY (2/2) → intSubject3 bị BUFFER ⏸️
Slots: [S1, S2]  (vẫn đầy, S3 chờ)
```

```swift
intSubject3.send(3)
```
```
S3 CHƯA được subscribe (đang buffer) → không ai lắng nghe
Value 3 bị MẤT (PassthroughSubject không giữ state)
results = [1, 2]  (không đổi) ❌ 3 không vào
```

```swift
intSubject2.send(4)
```
```
S2 đang active → nhận 4
flatMap forward 4 → sink
results = [1, 2, 4] ✅
```

```swift
publisher.send(completion: .finished)
```
```
Publisher cha kết thúc → flatMap biết không còn publisher con mới
Các inner subscription (S1, S2) vẫn active cho đến khi chúng complete
S3 trong buffer bị discard (cha đã finished)
Pipeline sẽ complete khi tất cả active inner publishers complete
```

### Kết quả cuối cùng

```swift
results == [1, 2, 4]  // ✅ đúng với expected
// 3 bị mất vì intSubject3 chưa được subscribe khi send(3)
```

---

## 6. Tại sao `3` bị mất? — Giải thích trọng tâm

Đây là kết hợp của **hai đặc tính**:

```
┌──────────────────────────────────┐     ┌─────────────────────────────────┐
│   flatMap(maxPublishers: .max(2))│     │    PassthroughSubject           │
│                                  │     │                                 │
│  "Tôi chỉ subscribe tối đa       │  +  │  "Tôi không giữ value.          │
│   2 inner publishers. S3 phải    │     │   Nếu không ai lắng nghe lúc    │
│   chờ slot trống."               │     │   send(), value mất vĩnh viễn"  │
└──────────────────────────────────┘     └─────────────────────────────────┘
                    │                                     │
                    └──────────── KẾT HỢP ────────────────┘
                                    │
                    intSubject3.send(3) → KHÔNG AI NGHE → MẤT
```

Nếu `intSubject3` là **`CurrentValueSubject`** thay vì `PassthroughSubject`, giá trị `3` sẽ được giữ lại trong `.value`, và khi flatMap có slot trống để subscribe, nó sẽ nhận được `3`.

---

## 7. Tổng hợp nhanh

| Keyword | Vai trò | Ghi nhớ |
|---|---|---|
| `PassthroughSubject` | Publisher không state, chỉ relay | "Phát thanh trực tiếp — bỏ lỡ là mất" |
| `CurrentValueSubject` | Publisher có state, replay value hiện tại | "Bảng điểm — luôn hiện điểm mới nhất" |
| `.send(value)` | Inject value vào pipeline | "Đẩy data vào ống" |
| `.send(publisher)` | Thay đổi inner publisher (khi Output là Publisher) | "Chuyển kênh" |
| `.send(completion:)` | Đóng pipeline vĩnh viễn | "Tắt vòi — không mở lại được" |

--------

Đây là một đoạn code rất hay để hiểu sâu về Combine, Huy. Điểm mấu chốt nằm ở cấu trúc **2 tầng publisher**:

**Tầng 1** — `CurrentValueSubject<IntPublisher, Never>`: publisher "cha" emit ra các publisher con. Vì là `CurrentValueSubject`, nó khởi tạo với `intSubject1` và replay ngay cho `flatMap`.

**Tầng 2** — Mỗi `PassthroughSubject<Int, Never>` là publisher con emit giá trị Int thực sự.

`flatMap(maxPublishers: .max(2))` là chìa khoá giải thích tại sao `3` bị mất: nó chỉ cho phép tối đa 2 inner subscription đồng thời. Khi `intSubject3` được gửi xuống, cả 2 slot đã bị `intSubject1` và `intSubject2` chiếm → `intSubject3` bị buffer. Và vì `PassthroughSubject` không giữ state, khi `intSubject3.send(3)` được gọi mà chưa ai subscribe → value `3` mất vĩnh viễn.
