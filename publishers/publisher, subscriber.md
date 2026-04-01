# Combine: Publisher & Subscriber — Giải thích chi tiết

## 1. Mô hình tổng thể — Dòng chảy dữ liệu

Combine hoạt động theo mô hình **"dòng sông"**: dữ liệu chảy từ nguồn (Publisher) qua các trạm xử lý (Operator) đến đích (Subscriber).

```
Publisher ────▶ Operator ────▶ Operator ────▶ Subscriber
(nguồn phát)   (biến đổi)     (biến đổi)     (nơi tiêu thụ)

Ví dụ cụ thể:
URLSession      .map()         .decode()       .sink()
  ↓               ↓               ↓              ↓
emit Data    lấy .data       decode JSON     cập nhật UI
```

**Quy tắc cốt lõi:** Pipeline **không chạy** cho đến khi có Subscriber. Combine là **demand-driven** (kéo), không phải push-driven (đẩy).

---

## 2. Publisher — Nguồn phát dữ liệu

### Protocol định nghĩa

```swift
protocol Publisher {
    associatedtype Output    // Kiểu dữ liệu phát ra
    associatedtype Failure: Error   // Kiểu lỗi (Never nếu không lỗi)
    
    func receive<S: Subscriber>(subscriber: S)
        where S.Input == Output, S.Failure == Failure
}
```

Mỗi Publisher phải khai báo hai thứ: **phát ra gì** (`Output`) và **lỗi gì** (`Failure`).

### Publisher phát gì?

Publisher chỉ phát **3 loại sự kiện**, theo thứ tự:

```
──── value ──── value ──── value ──── completion ────▌
      ↑          ↑          ↑              ↑
   Output     Output     Output     .finished hoặc
  (0...∞)    (0...∞)    (0...∞)     .failure(Error)
                                    (đúng 1 lần, kết thúc)
```

Sau khi gửi completion (dù `.finished` hay `.failure`), **không bao giờ** phát thêm value.

### Các loại Publisher phổ biến

#### Built-in Publishers (Apple cung cấp sẵn)

```swift
// 1. Just — phát đúng 1 value rồi finished
Just(42)
// Output = Int, Failure = Never
// Timeline: ──42──|

// 2. Empty — không phát gì, chỉ finished (hoặc không bao giờ finished)
Empty<Int, Never>()
// Timeline: ──|
Empty<Int, Never>(completeImmediately: false)
// Timeline: ────────── (im lặng mãi mãi)

// 3. Fail — phát lỗi ngay lập tức
Fail<Int, MyError>(error: .notFound)
// Timeline: ──✗

// 4. Sequence — phát từng phần tử của collection
[1, 2, 3, 4, 5].publisher
// Timeline: ──1──2──3──4──5──|

// 5. Future — phát 1 value async rồi finished
Future<String, Error> { promise in
    DispatchQueue.global().async {
        promise(.success("Hello"))
    }
}
// Timeline: ────────"Hello"──|

// 6. Deferred — tạo publisher MỚI mỗi lần có subscriber
Deferred {
    Just(Date())    // mỗi subscriber nhận thời điểm subscribe khác nhau
}
```

#### Foundation Publishers

```swift
// 7. URLSession
URLSession.shared.dataTaskPublisher(for: url)
// Output = (data: Data, response: URLResponse)
// Failure = URLError

// 8. NotificationCenter
NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
// Output = Notification
// Failure = Never
// ⚠️ Không bao giờ complete → vô hạn

// 9. Timer
Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
// Output = Date
// Failure = Never
// Mỗi giây emit Date hiện tại

// 10. KVO
object.publisher(for: \.property)
// Observe thay đổi property qua KVO
```

#### SwiftUI / Combine Publishers

```swift
// 11. @Published (projected value)
class ViewModel: ObservableObject {
    @Published var name = ""
}
let vm = ViewModel()
vm.$name    // Published<String>.Publisher
// Output = String, Failure = Never
// Emit giá trị MỚI mỗi khi name thay đổi (willSet)

// 12. Subjects — Publisher mà code bên ngoài inject value
let passthrough = PassthroughSubject<Int, Never>()
// Relay thuần — không giữ state

let current = CurrentValueSubject<Int, Never>(0)
// Giữ value hiện tại, replay cho subscriber mới
```

### Publisher là LAZY

```swift
let publisher = URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: User.self, decoder: JSONDecoder())

// ← TẠI ĐÂY: CHƯA CÓ network request nào được gửi
// Publisher chỉ MÔ TẢ pipeline, không thực thi

// Network request chỉ chạy khi có subscriber:
publisher
    .sink(receiveCompletion: { ... }, receiveValue: { ... })
    .store(in: &cancellables)
// ← BÂY GIỜ mới gửi request
```

---

## 3. Subscriber — Nơi tiêu thụ dữ liệu

### Protocol định nghĩa

```swift
protocol Subscriber {
    associatedtype Input      // Kiểu dữ liệu nhận vào (khớp Publisher.Output)
    associatedtype Failure: Error  // Kiểu lỗi (khớp Publisher.Failure)
    
    func receive(subscription: Subscription)    // Bước 1: nhận subscription
    func receive(_ input: Input) -> Subscribers.Demand  // Bước 2: nhận value
    func receive(completion: Subscribers.Completion<Failure>)  // Bước 3: kết thúc
}
```

### Built-in Subscribers

#### `sink` — Subscriber đa năng nhất

```swift
// Biến thể 1: Chỉ nhận value (Failure phải là Never)
publisher
    .sink(receiveValue: { value in
        print(value)
    })

// Biến thể 2: Nhận cả value và completion
publisher
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished: print("Done")
            case .failure(let error): print("Error: \(error)")
            }
        },
        receiveValue: { value in
            print(value)
        }
    )
```

`sink` trả về `AnyCancellable` — **bắt buộc giữ reference**, nếu không subscription bị huỷ ngay:

```swift
// ❌ AnyCancellable không được giữ → dealloc → cancel ngay
func setup() {
    publisher.sink { print($0) }
    // subscription chết cuối scope
}

// ✅ Giữ trong Set
private var cancellables = Set<AnyCancellable>()
func setup() {
    publisher
        .sink { print($0) }
        .store(in: &cancellables)   // sống cùng object
}
```

#### `assign` — Subscriber gán value vào property

```swift
// Gán vào property của object khác
publisher
    .assign(to: \.label.text, on: viewController)

// Gán vào @Published property của self (an toàn, không retain cycle)
$searchQuery
    .map { $0.uppercased() }
    .assign(to: &$formattedQuery)
```

#### Custom Subscriber

```swift
class IntSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never
    
    // Bước 1: Nhận subscription, yêu cầu số lượng value
    func receive(subscription: Subscription) {
        subscription.request(.max(3))    // chỉ muốn nhận 3 value
    }
    
    // Bước 2: Nhận từng value, trả về demand bổ sung
    func receive(_ input: Int) -> Subscribers.Demand {
        print("Received: \(input)")
        return .none     // không yêu cầu thêm
        // .max(1) → yêu cầu thêm 1
        // .unlimited → nhận tất cả
    }
    
    // Bước 3: Nhận completion
    func receive(completion: Subscribers.Completion<Never>) {
        print("Completed")
    }
}

let subscriber = IntSubscriber()
[1, 2, 3, 4, 5].publisher.subscribe(subscriber)
// Output:
// Received: 1
// Received: 2
// Received: 3
// (4, 5 không được nhận vì demand chỉ là 3)
```

---

## 4. Handshake — Quy trình kết nối Publisher ↔ Subscriber

Đây là quy trình **bắt tay 3 bước** mà Combine thực hiện bên trong:

```
        Publisher                  Subscriber
            │                          │
            │◄─── 1. subscribe() ──────│  Subscriber đăng ký
            │                          │
            │──── 2. receive ─────────▶│  Publisher tạo Subscription
            │     (subscription)       │  và giao cho Subscriber
            │                          │
            │◄─── 3. request ──────────│  Subscriber yêu cầu demand
            │     (.max(N) / .unlimited)│  (bao nhiêu value?)
            │                          │
            │──── 4. receive ─────────▶│  Publisher gửi value
            │     (value)              │  (tối đa N value)
            │──── 4. receive ─────────▶│
            │     (value)              │
            │         ...              │
            │                          │
            │──── 5. receive ─────────▶│  Publisher gửi completion
            │     (completion)         │  (.finished hoặc .failure)
            │                          │
```

### Minh hoạ với code

```swift
[1, 2, 3].publisher            // Publisher: Sequence<[Int], Never>
    .sink { print($0) }        // Subscriber: Sink<Int, Never>

// BÊN TRONG Combine xảy ra:

// Bước 1: sink gọi publisher.subscribe(sinkSubscriber)
// Bước 2: publisher tạo Subscription, gọi subscriber.receive(subscription:)
// Bước 3: sink gọi subscription.request(.unlimited)
// Bước 4: subscription gửi 1, 2, 3 qua subscriber.receive(_:)
// Bước 5: subscription gửi .finished qua subscriber.receive(completion:)
```

### Demand — Back-pressure

Subscriber kiểm soát **tốc độ** nhận data qua demand:

```swift
// .unlimited — nhận tất cả, không giới hạn (phổ biến nhất)
subscription.request(.unlimited)

// .max(N) — nhận tối đa N value
subscription.request(.max(3))
// Sau khi nhận 3, publisher tạm dừng
// Subscriber có thể yêu cầu thêm qua return value của receive(_:)

// .none — không yêu cầu thêm (tạm dừng)
func receive(_ input: Int) -> Subscribers.Demand {
    return .none
}
```

```
Subscriber demand = .max(2)

Publisher: ──1──2──[đợi]──      (chỉ gửi 2, rồi dừng)
                     │
Subscriber trả .max(1) khi nhận value 2
                     │
Publisher: ──────────3──[đợi]   (gửi thêm 1)
```

`sink` và `assign` luôn request `.unlimited` — nhận hết mọi thứ publisher phát.

---

## 5. Operator — Publisher biến đổi Publisher

Operator là **cả Publisher lẫn Subscriber**: nó subscribe upstream, biến đổi data, rồi phát xuống downstream. Mỗi operator tạo ra **Publisher mới** với Output/Failure có thể khác.

```swift
[1, 2, 3, 4, 5].publisher     // Publisher<Int, Never>
    .filter { $0 > 2 }         // Publisher<Int, Never>      ← lọc
    .map { $0 * 10 }           // Publisher<Int, Never>      ← biến đổi
    .map { String($0) }        // Publisher<String, Never>   ← đổi Output type
    .sink { print($0) }        // Subscriber<String, Never>
// Output: "30", "40", "50"
```

### Type thay đổi qua từng bước

```
[1,2,3,4,5].publisher     Output=Int,    Failure=Never
       │
  .filter { $0 > 2 }      Output=Int,    Failure=Never    (giữ nguyên type)
       │
  .map { $0 * 10 }         Output=Int,    Failure=Never    (giữ nguyên type)
       │
  .map { String($0) }      Output=String, Failure=Never    (Int → String)
       │
  .sink { }                 Input=String,  Failure=Never    (khớp với Output ở trên)
```

### Phân loại Operator

```swift
// ── Biến đổi value ──
.map { $0 * 2 }                    // transform từng value
.compactMap { Int($0) }            // transform + bỏ nil
.flatMap { innerPublisher($0) }    // transform thành publisher mới
.scan(0) { sum, val in sum + val } // accumulate

// ── Lọc ──
.filter { $0 > 0 }                // chỉ giữ value thoả điều kiện
.removeDuplicates()                // bỏ value trùng liên tiếp
.first()                           // chỉ lấy value đầu tiên
.last()                            // chỉ lấy value cuối cùng
.dropFirst(3)                      // bỏ 3 value đầu

// ── Timing ──
.debounce(for: .seconds(0.3), scheduler: RunLoop.main)
.throttle(for: .seconds(1), scheduler: RunLoop.main, latest: true)
.delay(for: .seconds(2), scheduler: RunLoop.main)
.timeout(.seconds(5), scheduler: RunLoop.main)

// ── Kết hợp nhiều Publisher ──
.merge(with: otherPublisher)       // merge 2 stream cùng type
.combineLatest(otherPublisher)     // kết hợp value mới nhất từ 2 stream
.zip(otherPublisher)               // ghép cặp 1-1

// ── Error handling ──
.tryMap { try transform($0) }     // map có thể throw
.mapError { $0 as? MyError ?? .unknown }
.replaceError(with: defaultValue)  // thay error bằng default
.retry(3)                          // thử lại khi fail
.catch { error in fallbackPublisher }

// ── Scheduling ──
.receive(on: DispatchQueue.main)   // chuyển sang main thread
.subscribe(on: DispatchQueue.global())  // chạy subscription trên background
```

---

## 6. Ví dụ thực tế hoàn chỉnh — Search ViewModel

```swift
class SearchViewModel: ObservableObject {
    // ── Publishers (nguồn) ──
    @Published var query = ""                    // nguồn: user input
    
    // ── Subscriber đích ──
    @Published private(set) var results: [Item] = []
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let service: SearchService
    
    init(service: SearchService = .shared) {
        self.service = service
        
        // Pipeline: Publisher → Operators → Subscriber
        $query                                              // 1. Publisher<String, Never>
            .debounce(for: .milliseconds(300),              // 2. Đợi user ngừng gõ 300ms
                      scheduler: RunLoop.main)
            .removeDuplicates()                             // 3. Bỏ query trùng
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }  // 4. Bỏ query rỗng
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isSearching = true                    // 5. Side effect: bật loading
                self?.errorMessage = nil
            })
            .map { [service] query in                       // 6. Tạo network publisher
                service.search(query)
                    .catch { error -> Just<[Item]> in
                        // Handle error trong inner publisher
                        return Just([])
                    }
            }
            .switchToLatest()                               // 7. Chỉ lấy kết quả mới nhất
            .receive(on: DispatchQueue.main)                // 8. Về main thread
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isSearching = false                   // 9. Tắt loading
            })
            .assign(to: &$results)                          // 10. Subscriber: gán vào results
    }
}
```

```
User gõ "Swift"

$query:         ──"S"──"Sw"──"Swi"──"Swif"──"Swift"──
                                                  │
debounce(300ms):  ────────────────────────────"Swift"──
                                                  │
removeDuplicates: ────────────────────────────"Swift"──
                                                  │
filter(!empty):   ────────────────────────────"Swift"──
                                                  │
handleEvents:     ──────────────────── isSearching=true
                                                  │
map → search:     ────────────────────── Publisher<[Item]>
                                                  │
switchToLatest:   ─────────────────────── [Item1, Item2, ...]
                                                  │
receive(main):    ────────────── chuyển về main thread
                                                  │
handleEvents:     ──────────────── isSearching=false
                                                  │
assign:           ──────────────── results = [Item1, Item2, ...]
```

---

## 7. Type Matching — Quy tắc kết nối

Publisher và Subscriber **chỉ kết nối được** khi type khớp:

```
Publisher.Output  ==  Subscriber.Input
Publisher.Failure ==  Subscriber.Failure
```

```swift
// ✅ Khớp: Publisher<Int, Never> → Subscriber<Int, Never>
[1, 2, 3].publisher         // <Int, Never>
    .sink { (value: Int) in }   // <Int, Never>

// ❌ Không khớp: Output khác
[1, 2, 3].publisher         // <Int, Never>
    .sink { (value: String) in }  // Compile error: Int ≠ String

// ✅ Dùng operator để chuyển type
[1, 2, 3].publisher         // <Int, Never>
    .map { String($0) }     // <String, Never>  ← chuyển Int → String
    .sink { (value: String) in }  // <String, Never>  ✅

// ❌ Không khớp: Failure khác
URLSession.shared.dataTaskPublisher(for: url)   // <(Data,Response), URLError>
    .sink(receiveValue: { })  // Error: sink(receiveValue:) yêu cầu Failure == Never

// ✅ Loại bỏ error trước
URLSession.shared.dataTaskPublisher(for: url)   // <(Data,Response), URLError>
    .replaceError(with: (Data(), URLResponse())) // <(Data,Response), Never>
    .sink(receiveValue: { })                      // ✅ Failure == Never
```

---

## 8. Vòng đời — Từ subscribe đến cancel

```
1. SUBSCRIBE
   subscriber kết nối publisher
        │
2. ACTIVE
   publisher emit value theo demand
        │
   ┌────┴────┐
   │         │
3a. COMPLETE              3b. CANCEL
   publisher gửi           AnyCancellable dealloc
   .finished / .failure    hoặc gọi .cancel()
        │                       │
        ▼                       ▼
4. TERMINATED — không value nào được emit thêm
```

```swift
var cancellable: AnyCancellable?

// 1. Subscribe
cancellable = Timer.publish(every: 1, on: .main, in: .common)
    .autoconnect()
    .sink { date in print(date) }

// 2. Active — timer emit mỗi giây

// 3b. Cancel — dừng subscription
cancellable = nil     // AnyCancellable dealloc → cancel
// hoặc
cancellable?.cancel() // gọi trực tiếp

// 4. Terminated — timer ngừng, không emit nữa
```

---

## 9. Tổng kết

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  PUBLISHER                                                       │
│  "Tôi PHÁT dữ liệu. Tôi khai báo Output type và Failure type.    │
│   Tôi chỉ bắt đầu khi có Subscriber yêu cầu (demand-driven).     │
│   Tôi phát 0...∞ value, rồi kết thúc bằng completion."           │
│                                                                  │
│  SUBSCRIBER                                                      │
│  "Tôi NHẬN dữ liệu. Input phải khớp Publisher.Output.            │
│   Tôi kiểm soát TỐC ĐỘ nhận qua demand (.max / .unlimited).      │
│   Tôi là điểm cuối kích hoạt toàn bộ pipeline."                  │
│                                                                  │
│  OPERATOR                                                        │
│  "Tôi vừa là Subscriber (nhận từ upstream)                       │
│   vừa là Publisher (phát cho downstream).                        │
│   Tôi biến đổi Output/Failure type dọc theo pipeline."           │
│                                                                  │
│  Publisher ──▶ Operator ──▶ Operator ──▶ Subscriber              │
│  (nguồn)      (biến đổi)   (biến đổi)   (tiêu thụ)               │
│                                                                  │
│  Kết nối bằng type matching:                                     │
│  Publisher.Output == Subscriber.Input                            │
│  Publisher.Failure == Subscriber.Failure                         │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘

---

Publisher và Subscriber là hai trụ cột của Combine framework, Huy. Mọi thứ khác (`sink`, `assign`, `map`, `filter`...) đều xây dựng trên hai protocol này.

**Publisher** là nguồn phát — nó khai báo "tôi phát ra Output gì, lỗi Failure gì" nhưng **không tự chạy**. Pipeline chỉ là mô tả cho đến khi có Subscriber kết nối. Publisher phát 0 đến vô hạn value, rồi kết thúc bằng đúng 1 completion (`.finished` hoặc `.failure`). Sau completion, không gì được phát thêm.

**Subscriber** là điểm cuối kích hoạt pipeline. Nó kiểm soát tốc độ nhận data qua cơ chế **demand** (back-pressure): `.unlimited` nhận tất cả, `.max(N)` chỉ nhận N value. `sink` và `assign` luôn request `.unlimited`. Custom Subscriber có thể kiểm soát demand chi tiết hơn.

Điểm mà nhiều người bỏ qua là **Operator cũng vừa là Subscriber vừa là Publisher** — `.map()` subscribe upstream, biến đổi data, rồi phát xuống downstream. Đó là lý do operator có thể chain liên tiếp, mỗi bước thay đổi Output/Failure type, và type matching được compiler kiểm tra xuyên suốt cả pipeline tại compile-time.
```
