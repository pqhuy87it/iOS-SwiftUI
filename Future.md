# Combine: `Future` — Wrap Async Call thành One-Shot Publisher

## 1. Vấn đề — Hai thế giới không tương thích

Rất nhiều API cũ dùng **callback/completion handler**:

```swift
// Callback-based (thế giới cũ)
func fetchUser(id: String, completion: @escaping (Result<User, Error>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        let user = try! JSONDecoder().decode(User.self, from: data!)
        completion(.success(user))
    }.resume()
}

// Gọi:
fetchUser(id: "123") { result in
    switch result {
    case .success(let user): print(user)
    case .failure(let error): print(error)
    }
}
```

Nhưng Combine pipeline cần **Publisher**:

```swift
// Combine pipeline muốn thế này:
$userId
    .flatMap { id in fetchUser(id: id) }   // ← cần Publisher, không phải callback
    .receive(on: DispatchQueue.main)
    .assign(to: &$user)
```

**Callback không phải Publisher** → không chain operator, không compose được.

→ Cần **cầu nối** biến callback thành Publisher. Đó là `Future`.

---

## 2. `Future` là gì?

### Định nghĩa

`Future` là publisher **phát đúng 1 value rồi complete** (hoặc fail) — gọi là **one-shot**. Nó nhận một closure chứa `promise` — function dùng để báo kết quả:

```swift
Future<Output, Failure> { promise in
    // Thực hiện async work...
    // Khi xong, gọi promise:
    promise(.success(value))     // phát value + finished
    // HOẶC
    promise(.failure(error))     // phát error
}
```

### Anatomy

```swift
Future<User, Error> { promise in
//     ↑      ↑        ↑
//   Output  Failure  (Result<User, Error>) -> Void
//                     promise là closure nhận Result
}
```

`promise` có type: `(Result<Output, Failure>) -> Void`

→ Gọi **đúng 1 lần**. Sau khi gọi, Future phát value (hoặc error) rồi complete. Gọi thêm lần nữa → bị bỏ qua.

### Timeline

```
Success:
──────────[async work]──────────value──|
                                ↑        ↑
                          promise(.success)  .finished

Failure:
──────────[async work]──────────✗
                                ↑
                          promise(.failure)
```

---

## 3. Wrap callback-based API → Future

### Trước (callback)

```swift
func fetchUser(id: String, completion: @escaping (Result<User, Error>) -> Void) {
    let url = URL(string: "https://api.example.com/users/\(id)")!
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        do {
            let user = try JSONDecoder().decode(User.self, from: data!)
            completion(.success(user))
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
```

### Sau (Future wrapper)

```swift
func fetchUser(id: String) -> Future<User, Error> {
    Future { promise in
        // Gọi API cũ bên trong, bridge kết quả qua promise
        let url = URL(string: "https://api.example.com/users/\(id)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                promise(.failure(error))     // callback error → promise failure
                return
            }
            do {
                let user = try JSONDecoder().decode(User.self, from: data!)
                promise(.success(user))      // callback success → promise success
            } catch {
                promise(.failure(error))
            }
        }.resume()
    }
}
```

### Giờ dùng được trong Combine pipeline

```swift
$userId
    .flatMap { id in fetchUser(id: id) }    // ✅ Future là Publisher
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { ... },
        receiveValue: { user in self.user = user }
    )
    .store(in: &cancellables)
```

---

## 4. Các loại async API phổ biến → Future

### 4.1 Callback đơn giản

```swift
// API gốc:
func loadImage(url: URL, completion: @escaping (UIImage?) -> Void)

// Future wrapper:
func loadImage(url: URL) -> Future<UIImage, Error> {
    Future { promise in
        loadImage(url: url) { image in
            if let image = image {
                promise(.success(image))
            } else {
                promise(.failure(ImageError.loadFailed))
            }
        }
    }
}
```

### 4.2 Delegate-based API

```swift
// CLLocationManager dùng delegate → wrap thành Future
func requestCurrentLocation() -> Future<CLLocation, Error> {
    Future { promise in
        let delegate = LocationDelegate { result in
            promise(result)    // bridge delegate callback → promise
        }
        let manager = CLLocationManager()
        manager.delegate = delegate
        manager.requestLocation()
    }
}
```

### 4.3 Core Data async fetch

```swift
func fetchTodos() -> Future<[Todo], Error> {
    Future { [weak self] promise in
        guard let context = self?.persistentContainer.viewContext else {
            promise(.failure(CoreDataError.noContext))
            return
        }
        context.perform {
            do {
                let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                let entities = try context.fetch(request)
                let todos = entities.map { Todo(entity: $0) }
                promise(.success(todos))
            } catch {
                promise(.failure(error))
            }
        }
    }
}
```

### 4.4 Firebase / third-party SDK

```swift
// Firebase Auth
func signIn(email: String, password: String) -> Future<FirebaseAuth.User, Error> {
    Future { promise in
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                promise(.failure(error))
            } else if let user = result?.user {
                promise(.success(user))
            } else {
                promise(.failure(AuthError.unknown))
            }
        }
    }
}

// Firestore
func fetchDocument(id: String) -> Future<MyModel, Error> {
    Future { promise in
        Firestore.firestore().document("collection/\(id)").getDocument { snapshot, error in
            if let error = error {
                promise(.failure(error))
            } else if let data = snapshot?.data(),
                      let model = try? Firestore.Decoder().decode(MyModel.self, from: data) {
                promise(.success(model))
            } else {
                promise(.failure(FirestoreError.decodeFailed))
            }
        }
    }
}
```

### 4.5 async/await → Future (bridge ngược)

```swift
// Khi codebase dùng Combine nhưng API mới là async/await
func fetchUser(id: String) -> Future<User, Error> {
    Future { promise in
        Task {
            do {
                let user = try await api.getUser(id: id)
                promise(.success(user))
            } catch {
                promise(.failure(error))
            }
        }
    }
}
```

---

## 5. ⚠️ Đặc điểm quan trọng: Future chạy closure NGAY LẬP TỨC

### Vấn đề

```swift
let future = Future<Int, Never> { promise in
    print("🔥 Executing!")       // ← CHẠY NGAY khi Future được tạo
    promise(.success(42))
}
// Output: "🔥 Executing!"
// ← Dù CHƯA có subscriber nào!
```

**Khác với hầu hết Publisher khác** (lazy — chỉ chạy khi có subscriber), Future **eager** — chạy closure ngay khi khởi tạo.

### Hệ quả

```swift
// ❌ Network request gửi NGAY, dù chưa subscribe
let userFuture = fetchUser(id: "123")
// ← request đã gửi rồi!

// Subscribe sau 5 giây
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    userFuture
        .sink(receiveCompletion: { ... }, receiveValue: { ... })
        .store(in: &cancellables)
    // ← nhận kết quả đã cache từ lần chạy trước
}
```

### Hệ quả 2: Subscribe nhiều lần → KHÔNG chạy lại

```swift
let future = Future<Date, Never> { promise in
    print("Running")
    promise(.success(Date()))
}

// Subscribe lần 1
future.sink { print("Sub1: \($0)") }.store(in: &cancellables)
// Output: "Running"
// Output: "Sub1: 2026-03-27 10:00:00"

// Subscribe lần 2
future.sink { print("Sub2: \($0)") }.store(in: &cancellables)
// Output: "Sub2: 2026-03-27 10:00:00"  ← CÙNG Date, KHÔNG chạy lại closure
// "Running" KHÔNG in lần 2
```

Future **cache kết quả** — subscriber sau nhận kết quả giống subscriber đầu.

---

## 6. `Deferred` + `Future` — Giải pháp cho Lazy Execution

### `Deferred` biến Future từ eager → lazy

```swift
func fetchUser(id: String) -> AnyPublisher<User, Error> {
    Deferred {
        Future { promise in
            print("🔥 NOW executing")
            api.getUser(id: id) { result in
                promise(result)
            }
        }
    }
    .eraseToAnyPublisher()
}
```

**`Deferred`** tạo **Future MỚI mỗi lần có subscriber**:

```swift
let publisher = fetchUser(id: "123")
// ← KHÔNG có gì chạy

publisher.sink { ... }.store(in: &cancellables)
// ← "🔥 NOW executing" — chạy lần 1

publisher.sink { ... }.store(in: &cancellables)
// ← "🔥 NOW executing" — chạy lần 2 (Future MỚI, Date MỚI)
```

### So sánh

```
Future alone (eager):
─────────────────────────────────────────────
Tạo Future    ← closure CHẠY NGAY
     │
Subscribe 1   ← nhận cached result
Subscribe 2   ← nhận cached result (CÙNG giá trị)

Deferred { Future } (lazy):
─────────────────────────────────────────────
Tạo Deferred  ← không gì chạy
     │
Subscribe 1   ← tạo Future MỚI → closure chạy → nhận result
Subscribe 2   ← tạo Future MỚI → closure chạy → nhận result MỚI
```

### Quy tắc

```
Future đơn thuần:
→ Dùng khi chỉ subscribe 1 lần VÀ muốn chạy ngay

Deferred { Future }:
→ Dùng khi cần lazy execution
→ Dùng khi có thể subscribe nhiều lần (retry, flatMap)
→ ĐÂY LÀ PATTERN CHUẨN cho production code
```

---

## 7. `Deferred { Future }` + `retry` — Tại sao Deferred quan trọng

```swift
// ❌ Future alone + retry = VÔ NGHĨA
Future<Data, Error> { promise in
    api.fetchData { result in promise(result) }
}
.retry(3)
// retry re-subscribe Future → nhận CACHED result (cùng error!)
// → retry 3 lần nhận cùng 1 error → không bao giờ thành công

// ✅ Deferred { Future } + retry = ĐÚNG
Deferred {
    Future<Data, Error> { promise in
        api.fetchData { result in promise(result) }
    }
}
.retry(3)
// retry re-subscribe Deferred → tạo Future MỚI → gọi API MỚI
// → có cơ hội thành công ở lần retry tiếp theo
```

```
❌ Future + retry(2):
  attempt 1: Future chạy → error → cache error
  retry 1:   re-subscribe → nhận cached error → fail ngay
  retry 2:   re-subscribe → nhận cached error → fail ngay
  → 1 network call, 3 failures (vô nghĩa)

✅ Deferred { Future } + retry(2):
  attempt 1: Deferred tạo Future MỚI → network call → error
  retry 1:   Deferred tạo Future MỚI → network call → error
  retry 2:   Deferred tạo Future MỚI → network call → SUCCESS ✅
  → 3 network calls thực sự, có cơ hội recover
```

---

## 8. One-shot nghĩa là gì?

"One-shot" = publisher **phát tối đa 1 value rồi complete**. So sánh:

```
One-shot (Future):
──────────value──|           (1 value + finished)
──────────✗                  (hoặc 1 error)

Continuous (@Published, Timer, NotificationCenter):
──value──value──value──value──...   (0...∞ values, có thể không complete)

Multi-shot (Sequence):
──1──2──3──4──5──|           (nhiều values + finished)
```

Future giống **một lời hứa**: "Tôi sẽ cho bạn **đúng 1 kết quả** (thành công hoặc thất bại) trong tương lai."

Tương tự concept `Promise` trong JavaScript, `Task` trong C#, `Single` trong RxSwift.

---

## 9. Ví dụ thực tế hoàn chỉnh — Service Layer

### Service Protocol

```swift
protocol UserService {
    func fetchUser(id: String) -> AnyPublisher<User, ServiceError>
    func updateUser(_ user: User) -> AnyPublisher<User, ServiceError>
    func uploadAvatar(data: Data) -> AnyPublisher<URL, ServiceError>
}
```

### Implementation — Mỗi method dùng Deferred + Future

```swift
class APIUserService: UserService {
    
    func fetchUser(id: String) -> AnyPublisher<User, ServiceError> {
        Deferred {
            Future { promise in
                let url = URL(string: "https://api.example.com/users/\(id)")!
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        promise(.failure(.network(error)))
                        return
                    }
                    guard let http = response as? HTTPURLResponse,
                          200..<300 ~= http.statusCode else {
                        promise(.failure(.badResponse))
                        return
                    }
                    do {
                        let user = try JSONDecoder().decode(User.self, from: data!)
                        promise(.success(user))
                    } catch {
                        promise(.failure(.decodingFailed(error)))
                    }
                }.resume()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateUser(_ user: User) -> AnyPublisher<User, ServiceError> {
        Deferred {
            Future { promise in
                var request = URLRequest(url: URL(string: "https://api.example.com/users/\(user.id)")!)
                request.httpMethod = "PUT"
                request.httpBody = try? JSONEncoder().encode(user)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        promise(.failure(.network(error)))
                        return
                    }
                    do {
                        let updated = try JSONDecoder().decode(User.self, from: data!)
                        promise(.success(updated))
                    } catch {
                        promise(.failure(.decodingFailed(error)))
                    }
                }.resume()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func uploadAvatar(data: Data) -> AnyPublisher<URL, ServiceError> {
        Deferred {
            Future { promise in
                StorageSDK.upload(data: data, path: "avatars/\(UUID().uuidString)") { result in
                    switch result {
                    case .success(let downloadURL):
                        promise(.success(downloadURL))
                    case .failure(let error):
                        promise(.failure(.uploadFailed(error)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
```

### ViewModel sử dụng

```swift
class ProfileViewModel: ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    
    private let service: UserService
    private var cancellables = Set<AnyCancellable>()
    
    init(service: UserService) {
        self.service = service
    }
    
    func loadUser(id: String) {
        isLoading = true
        error = nil
        
        service.fetchUser(id: id)             // one-shot: 1 User hoặc 1 Error
            .retry(2)                          // thử lại 2 lần (Deferred → gọi API mới)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let err) = completion {
                        self?.error = err.localizedDescription
                    }
                },
                receiveValue: { [weak self] user in
                    self?.user = user
                }
            )
            .store(in: &cancellables)
    }
    
    // Chain nhiều one-shot publishers
    func updateProfileAndAvatar(name: String, avatarData: Data) {
        isLoading = true
        
        // Upload avatar trước → lấy URL → update user
        service.uploadAvatar(data: avatarData)        // one-shot: URL
            .flatMap { [weak self] avatarURL -> AnyPublisher<User, ServiceError> in
                guard let self, var user = self.user else {
                    return Fail(error: .unknown).eraseToAnyPublisher()
                }
                user.name = name
                user.avatarURL = avatarURL
                return self.service.updateUser(user)  // one-shot: User
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let err) = completion {
                        self?.error = err.localizedDescription
                    }
                },
                receiveValue: { [weak self] updatedUser in
                    self?.user = updatedUser
                }
            )
            .store(in: &cancellables)
    }
}
```

```
Upload Avatar (one-shot)
    │
    ▼ success: URL
flatMap → Update User (one-shot)
    │
    ▼ success: User
sink → Cập nhật UI

Nếu bất kỳ step nào fail → error chảy thẳng xuống sink.receiveCompletion
```

---

## 10. Future vs các lựa chọn khác

### Khi nào dùng Future?

```
Callback-based API cần bridge sang Combine?
    │
    ├── Kết quả ĐÚNG 1 LẦN (fetch, upload, auth)
    │   → Future ✅ (wrap trong Deferred cho production)
    │
    ├── Kết quả NHIỀU LẦN (download progress, location updates)
    │   → PassthroughSubject / Custom Publisher ✅
    │   → Future ❌ (chỉ phát 1 value)
    │
    └── API đã là async/await?
        │
        ├── Codebase dùng Combine → Deferred { Future { Task { } } }
        │
        └── Codebase dùng async/await → dùng trực tiếp, không cần Future
```

### Tóm tắt

| Khía cạnh | Chi tiết |
|---|---|
| **Future là gì?** | One-shot publisher: phát đúng 1 value (hoặc 1 error) rồi complete |
| **Dùng khi?** | Bridge callback → Combine (network, database, SDK) |
| **Eager hay Lazy?** | **Eager** — closure chạy NGAY khi tạo, cache kết quả |
| **Pattern chuẩn?** | `Deferred { Future { promise in ... } }` — lazy, retry-safe |
| **promise gọi mấy lần?** | Đúng 1 lần. Lần sau bị bỏ qua |
| **Giống gì?** | JavaScript `Promise`, RxSwift `Single`, C# `Task<T>` |

---

Đây là pattern cầu nối rất quan trọng trong Combine, Huy. Tóm gọn ý chính:

**"One-shot"** nghĩa là publisher phát **đúng 1 value rồi complete** (hoặc 1 error) — giống một lời hứa: "Tôi sẽ trả cho bạn 1 kết quả trong tương lai." Phù hợp cho network request, database fetch, upload — những thứ trả về 1 kết quả duy nhất.

**Future** là cầu nối giữa thế giới callback và Combine. Nhận closure chứa `promise`, gọi `promise(.success(value))` hoặc `promise(.failure(error))` đúng 1 lần. Nhờ vậy callback-based API (Firebase, CoreLocation, third-party SDK) có thể dùng trong `.flatMap()`, `.retry()`, `.combineLatest()`...

**Bẫy lớn nhất:** Future là **eager** — closure chạy NGAY khi khởi tạo, không đợi subscriber, và **cache kết quả** cho mọi subscriber sau. Nếu dùng với `.retry()` → retry nhận cùng cached error → vô nghĩa.

**Pattern chuẩn production:** luôn wrap trong `Deferred`:
```swift
Deferred { Future { promise in ... } }.eraseToAnyPublisher()
```
`Deferred` tạo Future MỚI mỗi lần subscribe → lazy, retry-safe, mỗi subscriber nhận kết quả độc lập. Đây là pattern gần như bắt buộc khi dùng Future trong codebase thực tế.
