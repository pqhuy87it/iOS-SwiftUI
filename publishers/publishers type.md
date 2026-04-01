# Combine: Tất cả các loại Publishers — Giải thích chi tiết

## 1. Phân loại tổng thể

```
Publishers trong Combine
│
├── 1. Convenience Publishers (tạo từ giá trị có sẵn)
│       Just, Empty, Fail, Deferred, Future, Record
│
├── 2. Sequence Publishers (từ collection)
│       [Array].publisher, Set.publisher, Range.publisher
│
├── 3. Subject Publishers (inject value thủ công)
│       PassthroughSubject, CurrentValueSubject
│
├── 4. @Published (property wrapper)
│       $property → Published<T>.Publisher
│
├── 5. Foundation Publishers (từ Apple framework)
│       URLSession, NotificationCenter, Timer, KVO
│
├── 6. Combining Publishers (kết hợp nhiều publisher)
│       Merge, CombineLatest, Zip, SwitchToLatest, FlatMap
│
├── 7. Wrapping Publishers (type erasure & adapter)
│       AnyPublisher, eraseToAnyPublisher()
│
└── 8. SwiftUI-specific
│       ObservableObject.objectWillChange
```

---

## 2. Convenience Publishers — Tạo từ giá trị có sẵn

### 2.1 `Just` — Phát đúng 1 value rồi finished

```swift
Just(42)
// Output = Int, Failure = Never
```

```
Timeline: ──42──|
                 ↑ .finished
```

`Just` luôn có `Failure = Never`. Mỗi subscriber mới đều nhận **cùng một value**.

```swift
// Dùng phổ biến: fallback trong catch, giá trị mặc định
URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: User.self, decoder: JSONDecoder())
    .catch { _ in Just(User.default) }    // fallback khi lỗi
    .sink { user in print(user) }
    .store(in: &cancellables)

// Dùng trong flatMap: trả về 1 value đồng bộ
$searchQuery
    .flatMap { query -> AnyPublisher<[Item], Never> in
        guard !query.isEmpty else {
            return Just([]).eraseToAnyPublisher()  // trả mảng rỗng ngay
        }
        return searchService.search(query)
    }
```

### 2.2 `Empty` — Không phát value, chỉ complete (hoặc không)

```swift
Empty<Int, Never>()
// Timeline: ──|   (finished ngay lập tức)

Empty<Int, Never>(completeImmediately: false)
// Timeline: ──────────   (im lặng mãi mãi, không complete)
```

```swift
// Dùng khi cần "không làm gì" trong pipeline
$query
    .flatMap { query -> AnyPublisher<[Result], Error> in
        guard isOnline else {
            return Empty().eraseToAnyPublisher()   // offline → không emit gì
        }
        return api.search(query)
    }

// Dùng trong test: publisher không bao giờ complete
let neverCompleting = Empty<Int, Never>(completeImmediately: false)
```

### 2.3 `Fail` — Phát lỗi ngay lập tức

```swift
Fail<Int, MyError>(error: .notFound)
// Timeline: ──✗(.notFound)
// Không emit value nào, chỉ error
```

```swift
// Dùng trong validation pipeline
func validateAge(_ age: Int) -> AnyPublisher<Int, ValidationError> {
    guard age >= 18 else {
        return Fail(error: .underAge).eraseToAnyPublisher()
    }
    return Just(age)
        .setFailureType(to: ValidationError.self)
        .eraseToAnyPublisher()
}
```

### 2.4 `Deferred` — Tạo publisher MỚI mỗi lần subscribe

```swift
Deferred {
    Just(Date())    // mỗi subscriber nhận thời điểm subscribe KHÁC NHAU
}
```

**Khác biệt then chốt với `Just`:**

```swift
// Just: capture value LÚC KHỞI TẠO
let justDate = Just(Date())
// → Mọi subscriber nhận CÙNG Date

// Deferred: tạo publisher MỚI mỗi lần subscribe
let deferredDate = Deferred { Just(Date()) }
// → Subscriber A nhận Date lúc A subscribe
// → Subscriber B nhận Date lúc B subscribe (khác A)
```

```swift
// Ứng dụng quan trọng: wrap async/await thành publisher
func fetchUser(id: String) -> AnyPublisher<User, Error> {
    Deferred {
        Future { promise in
            Task {
                do {
                    let user = try await api.getUser(id)
                    promise(.success(user))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    .eraseToAnyPublisher()
    // Deferred đảm bảo: mỗi lần subscribe → gọi API mới
    // Không có Deferred: Future chỉ chạy 1 lần, cache kết quả
}
```

### 2.5 `Future` — Async operation phát đúng 1 value

```swift
Future<String, Error> { promise in
    // Chạy async operation
    DispatchQueue.global().async {
        let result = heavyComputation()
        promise(.success(result))     // hoặc promise(.failure(error))
    }
}
// Timeline: ────────"result"──|
```

**⚠️ Đặc điểm quan trọng: Future chạy closure NGAY khi khởi tạo, không đợi subscriber:**

```swift
// ❌ Closure chạy ngay, dù chưa có subscriber
let future = Future<Int, Never> { promise in
    print("Executing!")      // ← chạy NGAY TẠI ĐÂY
    promise(.success(42))
}
// Output: "Executing!" (dù chưa sink)

// ✅ Wrap trong Deferred để lazy
let lazy = Deferred {
    Future<Int, Never> { promise in
        print("Executing!")  // ← chỉ chạy khi có subscriber
        promise(.success(42))
    }
}
// Chưa output gì cho đến khi .sink()
```

```swift
// Bridge callback-based API sang Combine
func fetchLocation() -> Future<CLLocation, Error> {
    Future { promise in
        locationManager.requestLocation { location, error in
            if let error = error {
                promise(.failure(error))
            } else {
                promise(.success(location!))
            }
        }
    }
}
```

### 2.6 `Record` — Publisher với sequence value/completion ghi sẵn

```swift
let record = Record<Int, Never>(output: [1, 2, 3, 4, 5], completion: .finished)
// Phát 1, 2, 3, 4, 5 rồi finished
// Giống [1,2,3,4,5].publisher nhưng có thể khai báo completion tuỳ ý

// Ghi lại recording qua builder
let record = Record<Int, MyError> { recording in
    recording.receive(1)
    recording.receive(2)
    recording.receive(completion: .failure(.someError))
}
// Phát 1, 2 rồi error
```

```swift
// Dùng phổ biến trong Unit Test — mock publisher behavior
func testSearchResults() {
    let mockPublisher = Record<[Item], Error>(
        output: [[], [item1], [item1, item2]],
        completion: .finished
    )
    
    let vm = SearchViewModel(searchPublisher: mockPublisher.eraseToAnyPublisher())
    // Test từng step...
}
```

---

## 3. Sequence Publisher — Từ Collection

### `Sequence.publisher`

Mọi type conform `Sequence` đều có property `.publisher`:

```swift
// Array
[1, 2, 3].publisher
// Timeline: ──1──2──3──|

// Set (thứ tự không xác định)
Set([1, 2, 3]).publisher
// Timeline: ──2──1──3──|  (thứ tự bất kỳ)

// Range
(1...5).publisher
// Timeline: ──1──2──3──4──5──|

// String (từng Character)
"Hello".publisher
// Timeline: ──H──e──l──l──o──|

// Dictionary (từng key-value pair)
["a": 1, "b": 2].publisher
// Output type = Dictionary<String, Int>.Element = (key: String, value: Int)
```

**Đặc điểm: phát ĐỒNG BỘ, lần lượt, rồi finished ngay:**

```swift
[1, 2, 3, 4, 5].publisher
    .filter { $0.isMultiple(of: 2) }   // chỉ giữ số chẵn
    .map { $0 * 10 }                    // nhân 10
    .sink { print($0) }                 // 20, 40
    .store(in: &cancellables)
```

---

## 4. Subject Publishers — Inject value từ bên ngoài

### 4.1 `PassthroughSubject` — Relay, không giữ state

```swift
let subject = PassthroughSubject<String, Never>()

subject.sink { print($0) }.store(in: &cancellables)

subject.send("A")    // ✅ "A"
subject.send("B")    // ✅ "B"
subject.send(completion: .finished)
subject.send("C")    // ❌ Đã finished, bị bỏ qua
```

```
                  subscribe
                     ↓
Timeline: ─────────[S]──"A"──"B"──|
                         ✅   ✅

Value gửi TRƯỚC subscribe → mất:
Timeline: ──"X"──[S]──"A"──"B"──|
             ❌        ✅   ✅
```

```swift
// Ứng dụng: bridge event imperative → reactive
class PaymentCoordinator {
    let paymentResult = PassthroughSubject<PaymentStatus, PaymentError>()
    
    func processPayment(amount: Decimal) {
        gateway.charge(amount) { [weak self] result in
            switch result {
            case .success(let receipt):
                self?.paymentResult.send(.completed(receipt))
                self?.paymentResult.send(completion: .finished)
            case .failure(let error):
                self?.paymentResult.send(completion: .failure(.gatewayError(error)))
            }
        }
    }
}

// ViewModel subscribe
coordinator.paymentResult
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { ... },
        receiveValue: { status in self.paymentStatus = status }
    )
    .store(in: &cancellables)
```

### 4.2 `CurrentValueSubject` — Giữ value hiện tại, replay cho subscriber mới

```swift
let subject = CurrentValueSubject<String, Never>("Initial")

print(subject.value)  // "Initial" — đọc đồng bộ bất kỳ lúc nào

subject.sink { print($0) }.store(in: &cancellables)
// ✅ "Initial" — nhận value hiện tại NGAY khi subscribe

subject.send("Updated")
// ✅ "Updated"
print(subject.value)  // "Updated"
```

```
                      subscribe
                         ↓
Timeline: ──"Init"────[S:nhận "Init"]──"Updated"──
```

```swift
// Ứng dụng: state management (thay thế @Published khi không cần ObservableObject)
class AuthManager {
    let authState = CurrentValueSubject<AuthState, Never>(.loggedOut)
    
    var isLoggedIn: Bool {
        authState.value != .loggedOut    // đọc đồng bộ
    }
    
    func login(token: String) {
        authState.send(.loggedIn(token))
    }
    
    func logout() {
        authState.send(.loggedOut)
    }
}

// Bất kỳ nơi nào subscribe đều nhận trạng thái hiện tại ngay
authManager.authState
    .sink { state in updateUI(for: state) }
    .store(in: &cancellables)
```

### So sánh nhanh

```
PassthroughSubject            CurrentValueSubject
────────────────              ────────────────────
Không initial value           Bắt buộc initial value
Không giữ state               .value luôn có
Subscribe muộn = mất          Subscribe muộn = nhận value hiện tại
Dùng cho: events, triggers    Dùng cho: state, configuration
```

---

## 5. `@Published` — Property Wrapper Publisher

```swift
class ViewModel: ObservableObject {
    @Published var query = ""
}

let vm = ViewModel()
vm.$query    // Published<String>.Publisher
//  ↑ prefix $ truy cập publisher
```

**`@Published` = `CurrentValueSubject` tích hợp sẵn** vào property, nhưng:
- Phát trên **willSet** (trước khi value thay đổi)
- `Failure = Never` luôn
- Tự trigger `objectWillChange` cho SwiftUI

```swift
class FormViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var isValid = false
    
    init() {
        // $email, $password là publishers
        Publishers.CombineLatest($email, $password)
            .map { email, password in
                email.contains("@") && password.count >= 8
            }
            .assign(to: &$isValid)  // gán vào @Published khác
    }
}
```

---

## 6. Foundation Publishers — Từ Apple Framework

### 6.1 `URLSession.DataTaskPublisher`

```swift
URLSession.shared.dataTaskPublisher(for: url)
// Output = (data: Data, response: URLResponse)
// Failure = URLError
```

```swift
struct APIClient {
    func fetchUsers() -> AnyPublisher<[User], Error> {
        let url = URL(string: "https://api.example.com/users")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let http = response as? HTTPURLResponse,
                      200..<300 ~= http.statusCode else {
                    throw APIError.badResponse
                }
                return data
            }
            .decode(type: [User].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
```

### 6.2 `NotificationCenter.Publisher`

```swift
NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
// Output = Notification
// Failure = Never
// ⚠️ Không bao giờ complete — publisher vô hạn
```

```swift
// Lắng nghe keyboard show/hide
NotificationCenter.default
    .publisher(for: UIResponder.keyboardWillShowNotification)
    .compactMap { notification -> CGFloat? in
        (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height
    }
    .sink { [weak self] height in
        self?.keyboardHeight = height
    }
    .store(in: &cancellables)
```

### 6.3 `Timer.TimerPublisher`

```swift
Timer.publish(every: 1.0, on: .main, in: .common)
    .autoconnect()
// Output = Date
// Failure = Never
// Mỗi 1 giây emit Date hiện tại
```

```swift
// Countdown timer
class CountdownViewModel: ObservableObject {
    @Published var remainingSeconds = 60
    private var cancellable: AnyCancellable?
    
    func start() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .scan(60) { remaining, _ in remaining - 1 }
            .prefix(while: { $0 >= 0 })     // dừng khi hết giờ
            .assign(to: &$remainingSeconds)
    }
    
    func stop() {
        cancellable?.cancel()
    }
}
```

### 6.4 KVO Publisher — Observe property changes

```swift
// Observe property qua KVO
let observation = player.publisher(for: \.currentItem?.duration)
// Output = CMTime?
// Failure = Never
```

```swift
// Observe WKWebView loading progress
webView.publisher(for: \.estimatedProgress)
    .sink { [weak self] progress in
        self?.progressBar.progress = Float(progress)
    }
    .store(in: &cancellables)

// Observe scroll position
scrollView.publisher(for: \.contentOffset)
    .map { $0.y }
    .removeDuplicates()
    .sink { [weak self] offsetY in
        self?.handleScroll(offsetY)
    }
    .store(in: &cancellables)
```

---

## 7. Combining Publishers — Kết hợp nhiều nguồn

### 7.1 `Merge` — Gộp nhiều publisher cùng type thành 1 stream

```swift
let pub1 = PassthroughSubject<Int, Never>()
let pub2 = PassthroughSubject<Int, Never>()

pub1.merge(with: pub2)
    .sink { print($0) }
    .store(in: &cancellables)

pub1.send(1)    // 1
pub2.send(2)    // 2
pub1.send(3)    // 3
```

```
pub1: ──1─────3──
pub2: ────2──────
merge:──1──2──3──    (interleave theo thời gian)
```

```swift
// Gộp nhiều nguồn notification
let appActive = NotificationCenter.default
    .publisher(for: UIApplication.didBecomeActiveNotification)
    .map { _ in "Active" }

let appBackground = NotificationCenter.default
    .publisher(for: UIApplication.didEnterBackgroundNotification)
    .map { _ in "Background" }

appActive.merge(with: appBackground)
    .sink { state in print("App state: \(state)") }
    .store(in: &cancellables)

// Merge nhiều hơn 2
Publishers.MergeMany(pub1, pub2, pub3, pub4)
// Hoặc từ array
Publishers.MergeMany(arrayOfPublishers)
```

### 7.2 `CombineLatest` — Kết hợp value MỚI NHẤT từ mỗi publisher

```swift
let name = CurrentValueSubject<String, Never>("Huy")
let age = CurrentValueSubject<Int, Never>(25)

name.combineLatest(age)
    .sink { name, age in
        print("\(name), \(age)")
    }
    .store(in: &cancellables)
// "Huy, 25"

name.send("John")     // "John, 25"  ← age giữ value cũ
age.send(30)           // "John, 30"  ← name giữ value cũ
```

```
name: ──"Huy"────"John"──────────
age:  ──────25────────────30─────
out:  ──("Huy",25)─("John",25)─("John",30)──
           ↑ emit khi CẢ HAI đã có ít nhất 1 value
             ↑ sau đó, mỗi khi EITHER thay đổi → emit combo mới nhất
```

```swift
// Ứng dụng kinh điển: form validation
class SignupViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published private(set) var canSubmit = false
    
    init() {
        Publishers.CombineLatest3($email, $password, $confirmPassword)
            .map { email, pass, confirm in
                email.contains("@") &&
                pass.count >= 8 &&
                pass == confirm
            }
            .assign(to: &$canSubmit)
    }
}
// CombineLatest2, CombineLatest3, CombineLatest4 (tối đa 4)
```

### 7.3 `Zip` — Ghép cặp 1-1 theo thứ tự

```swift
let letters = PassthroughSubject<String, Never>()
let numbers = PassthroughSubject<Int, Never>()

letters.zip(numbers)
    .sink { letter, number in print("\(letter)\(number)") }
    .store(in: &cancellables)

letters.send("A")       // chờ number...
numbers.send(1)          // "A1" ← ghép cặp
letters.send("B")        // chờ number...
letters.send("C")        // chờ number... (B vẫn chờ)
numbers.send(2)          // "B2"
numbers.send(3)          // "C3"
```

```
letters: ──A─────B──C──────
numbers: ────1────────2──3─
zip:     ────A1───────B2─C3    (ghép theo thứ tự, đợi cả hai)
```

**Khác biệt Zip vs CombineLatest:**

```
CombineLatest: "Mỗi khi either thay đổi → emit combo mới nhất"
Zip:           "Đợi cả hai có value MỚI → ghép cặp 1-1"
```

```swift
// Ứng dụng: đợi 2 API call hoàn thành đồng thời
let userPublisher = api.fetchUser(id: 1)
let postsPublisher = api.fetchPosts(userId: 1)

userPublisher.zip(postsPublisher)
    .sink(
        receiveCompletion: { ... },
        receiveValue: { user, posts in
            // Cả 2 đã xong → hiển thị profile + posts
            self.displayProfile(user, posts: posts)
        }
    )
    .store(in: &cancellables)
```

### 7.4 `SwitchToLatest` — Chỉ subscribe publisher MỚI NHẤT

```swift
let outer = PassthroughSubject<AnyPublisher<String, Never>, Never>()
// Publisher of Publishers

outer
    .switchToLatest()
    .sink { print($0) }
    .store(in: &cancellables)
```

```
outer emit PubA → subscribe A
  A emit "A1" → ✅ "A1"
  A emit "A2" → ✅ "A2"
outer emit PubB → CANCEL A, subscribe B
  A emit "A3" → ❌ đã bị cancel
  B emit "B1" → ✅ "B1"
```

```swift
// Ứng dụng kinh điển: search — cancel request cũ khi user gõ tiếp
$searchQuery
    .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
    .map { query in
        self.api.search(query)    // trả về publisher
    }
    .switchToLatest()             // cancel search cũ, chỉ giữ mới nhất
    .assign(to: &$results)
```

### 7.5 `FlatMap` — Transform value thành publisher rồi merge

```swift
$userId
    .flatMap { id in
        api.fetchUser(id: id)    // mỗi id → publisher mới
    }
    .sink { user in print(user) }
    .store(in: &cancellables)
```

```
$userId:  ──1──────2──────────
flatMap:  ──[fetchUser(1)]──[fetchUser(2)]──
output:   ────────User1────────User2──
          (merge tất cả inner publishers)
```

**`flatMap` vs `switchToLatest`:**

```
flatMap:          MERGE tất cả inner publishers (giữ hết)
switchToLatest:   CANCEL cũ, chỉ giữ inner publisher mới nhất
```

```swift
// flatMap(maxPublishers:) — giới hạn concurrent
$downloadURLs
    .flatMap(maxPublishers: .max(3)) { url in
        downloadFile(url)    // tối đa 3 download đồng thời
    }
    .sink { file in saveFile(file) }
    .store(in: &cancellables)
```

---

## 8. Type Erasure — `AnyPublisher`

### Vấn đề: concrete type quá phức tạp

```swift
// Return type thực sự:
// Publishers.FlatMap<Publishers.ReplaceError<URLSession.DataTaskPublisher>,
//   Publishers.Map<Publishers.Debounce<Publishers.RemoveDuplicates<
//     Published<String>.Publisher>, RunLoop>, URL>>
```

Không ai muốn viết type này trong function signature.

### Giải pháp: `eraseToAnyPublisher()`

```swift
func searchUsers(query: String) -> AnyPublisher<[User], Error> {
    //                                ↑ type đơn giản, ẩn chi tiết
    URLSession.shared.dataTaskPublisher(for: buildURL(query))
        .map(\.data)
        .decode(type: [User].self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    //  ↑ wrap thành AnyPublisher, ẩn concrete type
}
```

```swift
// Dùng khi:
// 1. Return type của function/property
func fetchData() -> AnyPublisher<Data, Error> { ... }

// 2. Lưu publisher vào property
var searchPublisher: AnyPublisher<[Item], Never>

// 3. Protocol abstraction
protocol DataService {
    func fetch() -> AnyPublisher<[Item], Error>
}
```

---

## 9. Bảng tham chiếu tổng hợp

| Publisher | Output | Failure | Emit | Complete? | Dùng khi |
|---|---|---|---|---|---|
| `Just(value)` | T | Never | 1 value | Có, ngay | Giá trị mặc định, fallback |
| `Empty()` | T | F | 0 value | Tuỳ chọn | Placeholder, skip logic |
| `Fail(error:)` | T | F | 0 value | Error ngay | Validation fail, mock error |
| `Deferred { }` | T | F | Tuỳ inner | Tuỳ inner | Lazy creation, mỗi subscribe tạo mới |
| `Future { }` | T | F | 1 value | Có | Bridge callback → Combine |
| `Record` | T | F | N value | Tuỳ | Unit test, mock sequence |
| `[].publisher` | Element | Never | N value | Có | Iterate collection |
| `PassthroughSubject` | T | F | Manual | Manual | Events, triggers |
| `CurrentValueSubject` | T | F | Manual + replay 1 | Manual | State management |
| `@Published` | T | Never | willSet | Khi dealloc | ViewModel properties |
| `URLSession` | (Data,Resp) | URLError | 1 value | Có | Network requests |
| `NotificationCenter` | Notification | Never | ∞ | ❌ Không | System events |
| `Timer.publish` | Date | Never | ∞ | ❌ Không | Periodic updates |
| `KVO .publisher(for:)` | T | Never | ∞ | ❌ Không | Property observation |

| Combining | Behaviour | Type khớp? |
|---|---|---|
| `Merge` | Gộp stream, interleave | Cùng Output + Failure |
| `CombineLatest` | Mỗi khi either thay đổi → emit combo mới nhất | Output có thể khác |
| `Zip` | Ghép cặp 1-1, đợi cả hai | Output có thể khác |
| `SwitchToLatest` | Cancel cũ, chỉ giữ mới nhất | Publisher of Publishers |
| `FlatMap` | Transform → publisher, merge tất cả | Output phải cùng type |

---

## 10. Ví dụ tổng hợp — Kết hợp nhiều loại Publisher

```swift
class DashboardViewModel: ObservableObject {
    // @Published → Publisher
    @Published var selectedCity = "Hanoi"
    @Published private(set) var weather: Weather?
    @Published private(set) var news: [Article] = []
    @Published private(set) var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // ① @Published publisher + debounce + switchToLatest
        $selectedCity
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoading = true
            })
            .map { [weak self] city -> AnyPublisher<(Weather, [Article]), Error> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()  // ② Empty publisher
                }
                
                // ③ Zip: đợi 2 API hoàn thành
                return self.weatherAPI.fetch(city: city)
                    .zip(self.newsAPI.fetch(city: city))
                    .eraseToAnyPublisher()
            }
            .switchToLatest()  // ④ Cancel request cũ khi city thay đổi
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("Error: \(error)")
                    }
                },
                receiveValue: { [weak self] weather, news in
                    self?.isLoading = false
                    self?.weather = weather
                    self?.news = news
                }
            )
            .store(in: &cancellables)
        
        // ⑤ Timer publisher: refresh mỗi 5 phút
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let city = self?.selectedCity else { return }
                self?.selectedCity = city  // trigger pipeline ① lại
            }
            .store(in: &cancellables)
        
        // ⑥ NotificationCenter publisher: refresh khi app active
        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                guard let city = self?.selectedCity else { return }
                self?.selectedCity = city
            }
            .store(in: &cancellables)
    }
}
```

---

Đây là bức tranh toàn cảnh về tất cả Publishers trong Combine, Huy. Tóm gọn theo nhóm:

**Convenience Publishers** — `Just` (1 value), `Empty` (0 value), `Fail` (error ngay), `Future` (1 async value), `Deferred` (tạo mới mỗi lần subscribe). Lưu ý quan trọng: `Future` chạy closure **ngay khi khởi tạo**, không đợi subscriber — nên thường wrap trong `Deferred` để lazy.

**Subjects** — `PassthroughSubject` (relay, không giữ state) và `CurrentValueSubject` (giữ `.value`, replay cho subscriber mới). Đây là cầu nối giữa code imperative và reactive.

**Foundation Publishers** — Apple tích hợp sẵn vào `URLSession`, `NotificationCenter`, `Timer`, KVO. Lưu ý: `NotificationCenter` và `Timer` **không bao giờ complete** — publisher vô hạn.

**Combining Publishers** là nhóm mạnh nhất: `Merge` (gộp stream), `CombineLatest` (combo mới nhất khi either thay đổi — kinh điển cho form validation), `Zip` (ghép cặp 1-1, đợi cả hai — dùng đợi nhiều API), `SwitchToLatest` (cancel cũ chỉ giữ mới nhất — kinh điển cho search).

Điểm cần nhớ: mỗi publisher khai báo `<Output, Failure>`, và pipeline chỉ kết nối khi type khớp xuyên suốt. `AnyPublisher` dùng để ẩn concrete type phức tạp khi expose ra function signature.
