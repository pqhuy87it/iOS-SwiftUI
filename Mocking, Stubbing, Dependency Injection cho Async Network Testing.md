# Mocking, Stubbing, Dependency Injection cho Async Network Testing

Đây là một topic cực kỳ quan trọng cho production code base — không có testing strategy tốt cho async networking thì refactor sẽ thành nightmare. Em sẽ đi từ concepts cơ bản, phân tích trade-offs của từng approach, rồi đến production patterns thực tế.

## 1. Phân biệt Mock vs Stub vs Fake vs Spy

Đây là điểm rất nhiều dev nhầm lẫn. Theo phân loại của Martin Fowler:

| Type | Mục đích chính | Có verify behavior? | Có logic? |
|---|---|---|---|
| **Dummy** | Object truyền vào nhưng không dùng | Không | Không |
| **Stub** | Trả về data định sẵn | Không | Không/đơn giản |
| **Fake** | Implementation thật nhưng simplified | Không | Có (in-memory DB...) |
| **Spy** | Stub + ghi lại các call để verify | Có (manual) | Có |
| **Mock** | Pre-programmed expectations + verification | Có (auto fail nếu sai) | Có |

### Ví dụ minh họa cho `APIClient`:

```swift
protocol APIClient {
    func fetchProducts() async throws -> [Product]
}

// 1. STUB — chỉ trả về data
final class StubAPIClient: APIClient {
    let products: [Product]
    
    init(products: [Product] = []) {
        self.products = products
    }
    
    func fetchProducts() async throws -> [Product] {
        return products
    }
}

// 2. FAKE — có logic thật nhưng simplified (in-memory thay vì network)
final class FakeAPIClient: APIClient {
    private var storage: [Product] = []
    
    func fetchProducts() async throws -> [Product] {
        try await Task.sleep(for: .milliseconds(50))  // simulate latency
        return storage
    }
    
    func addProduct(_ product: Product) {
        storage.append(product)
    }
}

// 3. SPY — record calls
final class SpyAPIClient: APIClient {
    private(set) var fetchProductsCallCount = 0
    private(set) var fetchProductsCalledAt: [Date] = []
    
    func fetchProducts() async throws -> [Product] {
        fetchProductsCallCount += 1
        fetchProductsCalledAt.append(Date())
        return []
    }
}

// 4. MOCK — pre-programmed expectations + verification
final class MockAPIClient: APIClient {
    var fetchProductsResult: Result<[Product], Error> = .success([])
    private(set) var fetchProductsCallCount = 0
    
    func fetchProducts() async throws -> [Product] {
        fetchProductsCallCount += 1
        switch fetchProductsResult {
        case .success(let products): return products
        case .failure(let error): throw error
        }
    }
}
```

**Lưu ý quan trọng:** Trong Swift community, từ "mock" thường dùng **chung chung** cho tất cả test doubles. Nhưng khi communicate với senior dev, gọi đúng tên giúp clear intent hơn.

---

## 2. Dependency Injection — Foundation của testability

### 2.1. Tại sao DI là điều kiện tiên quyết?

Không có DI = không thể test:

```swift
// ❌ Không thể test — APIClient hardcoded
final class ProductListViewModel {
    @Published var products: [Product] = []
    
    func loadProducts() async {
        // Singleton — không thể inject test double
        products = (try? await APIClient.shared.fetchProducts()) ?? []
    }
}

// ✅ Testable — APIClient injected
final class ProductListViewModel {
    @Published var products: [Product] = []
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func loadProducts() async {
        products = (try? await apiClient.fetchProducts()) ?? []
    }
}
```

### 2.2. Các DI patterns phổ biến

#### Pattern A — Constructor Injection (recommend nhất)

```swift
final class ProductService {
    private let apiClient: APIClient
    private let cache: ProductCache
    private let logger: Logger
    
    init(apiClient: APIClient, cache: ProductCache, logger: Logger) {
        self.apiClient = apiClient
        self.cache = cache
        self.logger = logger
    }
}

// Test
let sut = ProductService(
    apiClient: MockAPIClient(),
    cache: InMemoryCache(),
    logger: SilentLogger()
)
```

**Pros:** dependencies rõ ràng, immutable, không có hidden state.
**Cons:** init dài khi nhiều dependencies → đây là code smell cảnh báo "class này đang làm quá nhiều".

#### Pattern B — Default Parameter Injection

```swift
final class ProductService {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = LiveAPIClient()) {
        self.apiClient = apiClient
    }
}

// Production
let service = ProductService()  // tự dùng LiveAPIClient

// Test
let service = ProductService(apiClient: MockAPIClient())
```

**Pros:** convenient cho production code, vẫn testable.
**Cons:** Default value tạo coupling ngầm, khó migrate sang DI container sau.

#### Pattern C — Property Injection (cho ViewController)

```swift
final class ProductListViewController: UIViewController {
    var viewModel: ProductListViewModel!
    
    // Set bởi parent / DI container
}
```

**Cons:** Implicit unwrapped optional, dễ crash nếu quên inject.

#### Pattern D — Environment Injection (SwiftUI)

```swift
private struct APIClientKey: EnvironmentKey {
    static let defaultValue: APIClient = LiveAPIClient()
}

extension EnvironmentValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

// View
struct ProductListView: View {
    @Environment(\.apiClient) private var apiClient
    
    var body: some View { /* ... */ }
}

// Test
ProductListView()
    .environment(\.apiClient, MockAPIClient())
```

**Pros:** SwiftUI-native, tự propagate qua view hierarchy.
**Cons:** Type-erased, dễ "lạc" dependency trong large hierarchy.

#### Pattern E — DI Container (Factory, Resolver, Swinject)

```swift
import Factory

extension Container {
    var apiClient: Factory<APIClient> {
        self { LiveAPIClient() }
    }
    
    var productService: Factory<ProductService> {
        self { ProductService(apiClient: self.apiClient()) }
    }
}

// Production
let service = Container.shared.productService()

// Test
Container.shared.apiClient.register { MockAPIClient() }
let service = Container.shared.productService()
```

**Pros:** Centralized, scope management (singleton/transient), good for large codebase.
**Cons:** Magic ngầm, runtime resolution có thể fail, learning curve.

### 2.3. Recommendation theo size

| Project size | Recommend |
|---|---|
| Small (1-5 screens) | Default parameter injection |
| Medium (5-30 screens) | Constructor injection + manual factory |
| Large (30+ screens, multi-module) | DI container (Factory, Swinject) |

---

## 3. Architecting cho testability

### 3.1. Layered architecture với protocol boundaries

```swift
// Layer 1: Network primitive
protocol HTTPClient: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

// Layer 2: Domain repository
protocol ProductRepository: Sendable {
    func fetchProducts() async throws -> [Product]
    func fetchProduct(id: UUID) async throws -> Product
    func searchProducts(query: String) async throws -> [Product]
}

// Layer 3: Use case (optional, cho complex domain)
protocol GetFeaturedProductsUseCase: Sendable {
    func execute() async throws -> [Product]
}

// Layer 4: ViewModel
@MainActor
final class HomeViewModel {
    private let getFeaturedProducts: GetFeaturedProductsUseCase
    // ...
}
```

**Lý do dùng nhiều layer:**
- Mỗi layer có protocol → mock độc lập.
- Test ViewModel: mock UseCase, không cần care về Repository hay HTTP.
- Test Repository: mock HTTPClient, không cần care về real URL session.

### 3.2. Endpoint pattern — tách network concerns

```swift
struct Endpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let body: Data?
    
    func urlRequest(baseURL: URL) -> URLRequest {
        var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: true)!
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = method.rawValue
        request.httpBody = body
        return request
    }
}

extension Endpoint {
    static func products() -> Endpoint {
        Endpoint(path: "/products", method: .get, queryItems: [], body: nil)
    }
    
    static func product(id: UUID) -> Endpoint {
        Endpoint(path: "/products/\(id)", method: .get, queryItems: [], body: nil)
    }
}
```

Benefit: test endpoint construction riêng, không phụ thuộc network.

---

## 4. Mocking HTTP layer — 3 levels

### Level 1 — Protocol-based mock (recommend)

Mock ở mức **protocol APIClient**, không touch URLSession:

```swift
protocol APIClient: Sendable {
    func fetchProducts() async throws -> [Product]
    func fetchProduct(id: UUID) async throws -> Product
}

// Production
final class LiveAPIClient: APIClient {
    private let session: URLSession
    private let baseURL: URL
    
    init(session: URLSession = .shared, baseURL: URL) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func fetchProducts() async throws -> [Product] {
        let (data, _) = try await session.data(from: baseURL.appending(path: "/products"))
        return try JSONDecoder.api.decode([Product].self, from: data)
    }
    
    // ...
}

// Test
final class MockAPIClient: APIClient {
    var fetchProductsHandler: () async throws -> [Product] = { [] }
    var fetchProductHandler: (UUID) async throws -> Product = { _ in throw TestError.notImplemented }
    
    func fetchProducts() async throws -> [Product] {
        try await fetchProductsHandler()
    }
    
    func fetchProduct(id: UUID) async throws -> Product {
        try await fetchProductHandler(id)
    }
}
```

**Trade-off:** Đơn giản, không test được encoding/decoding/URL construction. Nhưng đó là **trách nhiệm của LiveAPIClient**, không phải ViewModel.

### Level 2 — `URLProtocol` interception

Mock ở **mức URLSession**, intercept network call thật:

```swift
final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() {
        guard let handler = Self.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

// Test setup
func makeTestSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}

// Test
@Test func fetchProducts_whenServerReturns200_returnsProducts() async throws {
    let expectedProducts = [Product.fixture(id: UUID(), name: "iPhone")]
    let json = try JSONEncoder().encode(expectedProducts)
    
    MockURLProtocol.requestHandler = { request in
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        return (response, json)
    }
    
    let client = LiveAPIClient(session: makeTestSession(), baseURL: URL(string: "https://test.com")!)
    let products = try await client.fetchProducts()
    
    #expect(products == expectedProducts)
}
```

**Trade-off:** Test được toàn bộ pipeline (URL building, encoding, decoding, error handling). Phức tạp hơn nhưng cho integration test rất tốt.

### Level 3 — Local HTTP server (Embassy, Hummingbird)

Chạy server thật trên localhost. Em ít dùng cho unit test, chủ yếu cho contract testing với backend team. Slow nhưng cao nhất confidence.

### Comparison Levels

| Level | Speed | Confidence | Use case |
|---|---|---|---|
| L1: Protocol mock | Rất nhanh | Trung bình | Test ViewModel, business logic |
| L2: URLProtocol | Nhanh | Cao | Test APIClient, decoding, error mapping |
| L3: Local server | Chậm | Rất cao | Contract test với backend |

**Pattern em hay dùng:** L1 cho 80% test (ViewModel/Service), L2 cho 20% (APIClient), L3 chỉ cho critical paths.

---

## 5. Testing Async Code — Patterns chi tiết

### 5.1. Setup với Swift Testing (iOS 17+)

```swift
import Testing
@testable import MyApp

@Suite("ProductListViewModel Tests")
struct ProductListViewModelTests {
    
    @Test("loadProducts thành công cập nhật products")
    func loadProductsSuccess() async throws {
        // Arrange
        let expectedProducts = [Product.fixture(id: UUID(), name: "iPhone 15")]
        let mockClient = MockAPIClient()
        mockClient.fetchProductsHandler = { expectedProducts }
        
        let sut = await ProductListViewModel(apiClient: mockClient)
        
        // Act
        await sut.loadProducts()
        
        // Assert
        await #expect(sut.products == expectedProducts)
        await #expect(sut.isLoading == false)
        await #expect(sut.error == nil)
    }
    
    @Test("loadProducts thất bại set error")
    func loadProductsFailure() async throws {
        let mockClient = MockAPIClient()
        mockClient.fetchProductsHandler = { throw NetworkError.serverError(500) }
        
        let sut = await ProductListViewModel(apiClient: mockClient)
        
        await sut.loadProducts()
        
        await #expect(sut.products.isEmpty)
        await #expect(sut.error is NetworkError)
    }
}
```

### 5.2. XCTest variant (legacy nhưng vẫn phổ biến)

```swift
import XCTest
@testable import MyApp

final class ProductListViewModelTests: XCTestCase {
    
    func test_loadProducts_success_updatesProducts() async throws {
        let expectedProducts = [Product.fixture()]
        let mockClient = MockAPIClient()
        mockClient.fetchProductsHandler = { expectedProducts }
        
        let sut = await ProductListViewModel(apiClient: mockClient)
        
        await sut.loadProducts()
        
        let products = await sut.products
        XCTAssertEqual(products, expectedProducts)
    }
}
```

### 5.3. Test loading state (state transitions)

Đây là pattern khó — cần verify state thay đổi trong khi async đang chạy:

```swift
@Test("loadProducts set isLoading=true rồi false")
func loadProductsLoadingState() async throws {
    // Arrange: dùng continuation để control timing
    let mockClient = MockAPIClient()
    let continuationBox = ContinuationBox<[Product]>()
    
    mockClient.fetchProductsHandler = {
        try await continuationBox.wait()
    }
    
    let sut = await ProductListViewModel(apiClient: mockClient)
    
    // Act: bắt đầu load nhưng chưa complete
    let loadTask = Task { await sut.loadProducts() }
    
    // Wait một tick để loadProducts() bắt đầu
    try await Task.sleep(for: .milliseconds(10))
    
    // Assert: đang loading
    await #expect(sut.isLoading == true)
    
    // Resolve mock
    continuationBox.resume(with: .success([]))
    await loadTask.value
    
    // Assert: hết loading
    await #expect(sut.isLoading == false)
}

// Helper
final class ContinuationBox<T>: @unchecked Sendable {
    private var continuation: CheckedContinuation<T, Error>?
    private let lock = NSLock()
    
    func wait() async throws -> T {
        try await withCheckedThrowingContinuation { cont in
            lock.lock()
            self.continuation = cont
            lock.unlock()
        }
    }
    
    func resume(with result: Result<T, Error>) {
        lock.lock()
        let cont = continuation
        continuation = nil
        lock.unlock()
        
        switch result {
        case .success(let value): cont?.resume(returning: value)
        case .failure(let error): cont?.resume(throwing: error)
        }
    }
}
```

### 5.4. Test cancellation

```swift
@Test("Khi cancel task, không update products")
func loadProducts_whenCancelled_doesNotUpdate() async throws {
    let mockClient = MockAPIClient()
    let continuationBox = ContinuationBox<[Product]>()
    mockClient.fetchProductsHandler = {
        try await continuationBox.wait()
    }
    
    let sut = await ProductListViewModel(apiClient: mockClient)
    
    let task = Task { await sut.loadProducts() }
    try await Task.sleep(for: .milliseconds(10))
    task.cancel()
    
    continuationBox.resume(with: .success([Product.fixture()]))
    await task.value
    
    // Sau cancel, products vẫn rỗng
    await #expect(sut.products.isEmpty)
}
```

ViewModel phải check `Task.isCancelled` để pattern này work:

```swift
func loadProducts() async {
    isLoading = true
    defer { isLoading = false }
    
    do {
        let products = try await apiClient.fetchProducts()
        guard !Task.isCancelled else { return }  // critical
        self.products = products
    } catch {
        guard !Task.isCancelled else { return }
        self.error = error
    }
}
```

### 5.5. Test debounce / throttle

Search-as-you-type là use case hay:

```swift
@Test("Search debounce 300ms")
func search_debounces() async throws {
    let mockClient = MockAPIClient()
    var searchQueries: [String] = []
    let lock = NSLock()
    
    mockClient.searchHandler = { query in
        lock.lock()
        searchQueries.append(query)
        lock.unlock()
        return []
    }
    
    let sut = await SearchViewModel(apiClient: mockClient)
    
    // Type nhanh
    await sut.updateQuery("a")
    await sut.updateQuery("ap")
    await sut.updateQuery("app")
    await sut.updateQuery("appl")
    await sut.updateQuery("apple")
    
    // Wait debounce
    try await Task.sleep(for: .milliseconds(400))
    
    // Chỉ "apple" được search (final value)
    lock.lock()
    let queries = searchQueries
    lock.unlock()
    
    #expect(queries == ["apple"])
}
```

### 5.6. Test với clock injection (cho deterministic time)

Dùng `Clock` protocol thay vì hardcoded `Task.sleep` — test chạy nhanh và deterministic:

```swift
final class SearchViewModel<C: Clock>: ObservableObject where C.Duration == Duration {
    private let clock: C
    private let apiClient: APIClient
    
    init(clock: C = ContinuousClock(), apiClient: APIClient) {
        self.clock = clock
        self.apiClient = apiClient
    }
    
    func search(query: String) async {
        try? await clock.sleep(for: .milliseconds(300))
        // search logic
    }
}

// Test với TestClock từ swift-clocks (Pointfree)
@Test func searchWithTestClock() async {
    let clock = TestClock()
    let sut = SearchViewModel(clock: clock, apiClient: MockAPIClient())
    
    let task = Task { await sut.search(query: "iphone") }
    
    await clock.advance(by: .milliseconds(300))
    await task.value
    
    // Assertions
}
```

---

## 6. Production Patterns

### 6.1. Test fixture / factory pattern

Tránh tạo data thủ công lặp lại:

```swift
extension Product {
    static func fixture(
        id: UUID = UUID(),
        name: String = "Sample Product",
        price: Decimal = 99.99,
        category: Category = .electronics
    ) -> Product {
        Product(id: id, name: name, price: price, category: category)
    }
}

// Test sử dụng
let product = Product.fixture(name: "iPhone 15")
let products = (1...10).map { Product.fixture(name: "Item \($0)") }
```

### 6.2. Mock với configurable handlers

```swift
final class MockAPIClient: APIClient, @unchecked Sendable {
    // Default behaviors
    var fetchProductsHandler: () async throws -> [Product] = { [] }
    var fetchProductHandler: (UUID) async throws -> Product = { _ in
        throw TestError.notConfigured("fetchProduct")
    }
    var searchHandler: (String) async throws -> [Product] = { _ in [] }
    
    // Spy state
    private(set) var fetchProductsCallCount = 0
    private(set) var capturedSearchQueries: [String] = []
    
    private let lock = NSLock()
    
    func fetchProducts() async throws -> [Product] {
        lock.lock()
        fetchProductsCallCount += 1
        lock.unlock()
        return try await fetchProductsHandler()
    }
    
    func fetchProduct(id: UUID) async throws -> Product {
        return try await fetchProductHandler(id)
    }
    
    func search(query: String) async throws -> [Product] {
        lock.lock()
        capturedSearchQueries.append(query)
        lock.unlock()
        return try await searchHandler(query)
    }
}

// TestError enum
enum TestError: Error, LocalizedError {
    case notConfigured(String)
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .notConfigured(let method):
            return "Mock method '\(method)' not configured"
        case .notImplemented:
            return "Not implemented"
        }
    }
}
```

### 6.3. Builder pattern cho complex test setup

```swift
final class ProductListViewModelTestBuilder {
    private var products: [Product] = []
    private var shouldThrow: Error?
    private var delay: Duration = .zero
    
    func withProducts(_ products: [Product]) -> Self {
        self.products = products
        return self
    }
    
    func throwingError(_ error: Error) -> Self {
        self.shouldThrow = error
        return self
    }
    
    func withDelay(_ duration: Duration) -> Self {
        self.delay = duration
        return self
    }
    
    @MainActor
    func build() -> (sut: ProductListViewModel, mock: MockAPIClient) {
        let mock = MockAPIClient()
        let products = self.products
        let shouldThrow = self.shouldThrow
        let delay = self.delay
        
        mock.fetchProductsHandler = {
            if delay > .zero {
                try await Task.sleep(for: delay)
            }
            if let error = shouldThrow {
                throw error
            }
            return products
        }
        
        let sut = ProductListViewModel(apiClient: mock)
        return (sut, mock)
    }
}

// Usage
@Test func loadProducts_withSuccess() async throws {
    let (sut, _) = await ProductListViewModelTestBuilder()
        .withProducts([.fixture(name: "iPhone")])
        .build()
    
    await sut.loadProducts()
    
    await #expect(sut.products.count == 1)
}
```

### 6.4. Test naming convention

Em follow pattern `methodName_givenCondition_expectedResult`:

```swift
test_loadProducts_whenAPIReturnsSuccess_updatesProducts
test_loadProducts_whenAPIThrows_setsError
test_loadProducts_whenCancelled_doesNotUpdateState
test_search_whenQueryEmpty_returnsEmptyResults
test_search_whenQueryChangesRapidly_debouncesAPICall
```

Hoặc với Swift Testing dùng `@Test("description")`:

```swift
@Test("Load products thành công cập nhật state đúng")
@Test("Load products thất bại set error message")
@Test("Search debounce 300ms khi user gõ liên tục")
```

---

## 7. Common Pitfalls — Em đã trả giá

### 7.1. Race condition trong Mock

```swift
// ❌ Race condition
final class BrokenMock: APIClient {
    var callCount = 0
    
    func fetchProducts() async throws -> [Product] {
        callCount += 1  // race nếu gọi concurrent
        return []
    }
}

// ✅ Lock hoặc actor
final class SafeMock: APIClient, @unchecked Sendable {
    private(set) var callCount = 0
    private let lock = NSLock()
    
    func fetchProducts() async throws -> [Product] {
        lock.lock()
        callCount += 1
        lock.unlock()
        return []
    }
}

// ✅ Hoặc actor (cleaner)
actor ActorMock: APIClient {
    private(set) var callCount = 0
    
    func fetchProducts() async throws -> [Product] {
        callCount += 1
        return []
    }
}
```

### 7.2. Test flaky vì không await đúng

```swift
// ❌ Test có thể fail random
@Test func loadProducts() async {
    let mock = MockAPIClient()
    mock.fetchProductsHandler = { [.fixture()] }
    let sut = await ViewModel(apiClient: mock)
    
    Task { await sut.loadProducts() }  // không await → race
    
    // Có thể assert trước khi loadProducts complete
    await #expect(sut.products.count == 1)  // FLAKY
}

// ✅ Await Task hoàn thành
@Test func loadProducts() async {
    let mock = MockAPIClient()
    mock.fetchProductsHandler = { [.fixture()] }
    let sut = await ViewModel(apiClient: mock)
    
    await sut.loadProducts()  // await đầy đủ
    
    await #expect(sut.products.count == 1)
}
```

### 7.3. MainActor isolation gây test phức tạp

```swift
// ViewModel
@MainActor
final class ViewModel {
    var products: [Product] = []
    func loadProducts() async { /* ... */ }
}

// ❌ Test fail compile vì không await MainActor
@Test func test() {
    let sut = ViewModel(apiClient: MockAPIClient())  // Error
}

// ✅ Đánh dấu test là MainActor
@MainActor
@Test func test() async {
    let sut = ViewModel(apiClient: MockAPIClient())
    await sut.loadProducts()
    #expect(sut.products.isEmpty == false)
}

// ✅ Hoặc await access
@Test func test() async {
    let sut = await ViewModel(apiClient: MockAPIClient())
    await sut.loadProducts()
    let products = await sut.products
    #expect(!products.isEmpty)
}
```

### 7.4. Mock không reset giữa các test

```swift
// ❌ Shared mock state leak giữa test
final class MyTests: XCTestCase {
    let mock = MockAPIClient()  // shared instance!
    
    func test_a() async {
        mock.fetchProductsHandler = { [.fixture()] }
        // ...
    }
    
    func test_b() async {
        // mock vẫn giữ handler từ test_a → test order-dependent
    }
}

// ✅ Tạo mới mỗi test
final class MyTests: XCTestCase {
    var mock: MockAPIClient!
    
    override func setUp() {
        super.setUp()
        mock = MockAPIClient()
    }
    
    override func tearDown() {
        mock = nil
        super.tearDown()
    }
}

// ✅ Hoặc với Swift Testing — mỗi test tự instance
struct MyTests {
    @Test func testA() async {
        let mock = MockAPIClient()  // fresh
    }
}
```

### 7.5. Test thực sự hit network thay vì mock

```swift
// ❌ Quên inject mock → test gọi network thật
@Test func test() async {
    let sut = ProductListViewModel()  // dùng default APIClient.shared!
    await sut.loadProducts()
    // Test pass/fail phụ thuộc internet, server uptime
}

// ✅ Force inject ở init không có default
final class ProductListViewModel {
    init(apiClient: APIClient) {  // không default
        self.apiClient = apiClient
    }
}
```

Em prefer **không có default value** ở init cho dependencies. Compiler force inject → không thể accidentally hit network.

### 7.6. Verify call count quá strict

```swift
// ❌ Brittle test
@Test func test() async {
    let mock = MockAPIClient()
    let sut = await ViewModel(apiClient: mock)
    await sut.loadProducts()
    
    #expect(mock.fetchProductsCallCount == 1)  // brittle
}

// ✅ Verify intent, không phải implementation
@Test func test() async {
    let mock = MockAPIClient()
    mock.fetchProductsHandler = { [.fixture()] }
    let sut = await ViewModel(apiClient: mock)
    await sut.loadProducts()
    
    await #expect(sut.products.count == 1)  // verify outcome
}
```

Verify call count chỉ khi nó là **business requirement** (ví dụ: phải có deduplication, không được call 2 lần).

---

## 8. Testing Pyramid — Strategy tổng thể

```
       /\
      /  \      E2E (5%)
     /----\     Integration (15%)
    /------\
   /        \   Unit Tests (80%)
  /__________\
```

### Unit Tests (80%) — Mock everything

Test ViewModel với mock APIClient:
- Nhanh (< 100ms / test).
- Deterministic.
- Test logic thuần.

### Integration Tests (15%) — Mock external boundary

Test APIClient với MockURLProtocol:
- Test serialization/deserialization.
- Test error mapping (HTTP 500 → AppError.serverError).
- Test URL construction.

### E2E Tests (5%) — Real network (staging)

- Smoke test critical paths trước release.
- Run trên CI scheduled, không per-commit.
- Tools: XCUITest + staging backend hoặc local server.

---

## 9. Decision Framework — Senior Mindset

**Khi viết feature mới:**
1. Define protocol cho dependencies trước.
2. Inject qua constructor.
3. Viết unit test với mock cho ViewModel/Service.
4. Viết integration test với URLProtocol cho APIClient.
5. Smoke test E2E nếu critical.

**Khi gặp bug production:**
1. Reproduce bằng unit test trước (red).
2. Fix code (green).
3. Refactor nếu cần (refactor).
4. Bug đó không bao giờ regress.

**Khi review PR:**
- Có dependency hardcoded? → request change.
- Test có hit network thật không? → request change.
- Test có flaky pattern (sleep, hardcoded delay)? → request change.
- Mock có spy state không có lock? → race condition risk.

---

## 10. Tóm tắt

**Core concepts:**
- **Stub** = fixed return data. **Mock** = expectations + verification. **Spy** = record calls. **Fake** = simplified real implementation.
- **Dependency Injection** là điều kiện tiên quyết cho testability.
- **Constructor injection** là pattern tốt nhất cho phần lớn cases.

**Testing async network code:**
- Layer 1 (protocol mock) cho 80% test — nhanh, focused.
- Layer 2 (URLProtocol) cho 15% — test serialization/error mapping.
- Layer 3 (real server) cho 5% — critical path validation.

**Top 3 production rules em follow:**
1. **Không bao giờ default value cho dependency** ở init — force explicit injection.
2. **Mỗi test tự build state** — không share mock instance giữa tests.
3. **Test outcome, không phải implementation** — verify state cuối, không phải call count (trừ khi call count là business requirement).

**Top 3 pitfalls cần tránh:**
1. Race condition trong mock vì không lock state.
2. Test flaky vì không await Task hoặc dùng `sleep` arbitrary.
3. Mock state leak giữa tests gây test order-dependent.

**Mental model:**
> "Test nhanh = developer test thường xuyên = bug ít. Test chậm = developer skip test = bug nhiều."

Mock layer 1 chạy < 50ms / test. Toàn bộ unit test suite < 5 giây cho 1000 tests. Đó là benchmark em hướng đến.

---

Anh Huy muốn em đi sâu thêm phần nào? Ví dụ:
- **Testing Combine pipelines** — verify publisher emit đúng sequence.
- **Snapshot testing** cho UI với mocked data.
- **Test với SwiftData / CoreData** — in-memory store strategy.
- **CI integration** — coverage enforcement, parallel test execution.
- **Fixture management** — strategy cho large test suite, JSON fixtures vs builders.
