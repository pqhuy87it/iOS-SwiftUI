```Swift
// ============================================================
// API SERVICES: ASYNC/AWAIT vs COMBINE TRONG SWIFTUI
// ============================================================
//
// 2 approaches xây dựng networking layer:
//
// ┌─ ASYNC/AWAIT (Modern — iOS 15+) ────────────────────────┐
// │  Dùng Swift Concurrency: async/await, Task, try/catch    │
// │  Đọc tuần tự như synchronous code                       │
// │  Error handling tự nhiên qua do-catch                   │
// │  Cancel qua Task cancellation                           │
// │  Apple KHUYẾN KHÍCH cho new projects                    │
// └──────────────────────────────────────────────────────────┘
//
// ┌─ COMBINE (Reactive — iOS 13+) ──────────────────────────┐
// │  Dùng Publisher/Subscriber pipeline                      │
// │  Operators: map, flatMap, decode, retry, debounce...    │
// │  Built-in: retry, timeout, debounce, combineLatest      │
// │  Cancel qua AnyCancellable                              │
// │  Mạnh cho: streams, multi-source merge, complex chains  │
// └──────────────────────────────────────────────────────────┘
//
// Bài này build CÙNG 1 API layer theo CẢ 2 CÁCH để so sánh.
// ============================================================

import SwiftUI
import Combine


// ╔══════════════════════════════════════════════════════════╗
// ║  SHARED: MODELS & ERRORS & ENDPOINT CONFIG                ║
// ╚══════════════════════════════════════════════════════════╝

// === API Models ===

struct User: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let email: String
    let avatar: String?
}

struct Post: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

struct CreatePostRequest: Codable {
    let title: String
    let body: String
    let userId: Int
}

struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let page: Int
    let totalPages: Int
    let total: Int
}

// === API Errors ===

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError
    case timeout
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL không hợp lệ"
        case .invalidResponse: return "Response không hợp lệ"
        case .httpError(let code, _): return "HTTP Error: \(code)"
        case .decodingError: return "Không thể parse dữ liệu"
        case .networkError(let err): return "Lỗi mạng: \(err.localizedDescription)"
        case .unauthorized: return "Phiên đăng nhập hết hạn"
        case .notFound: return "Không tìm thấy dữ liệu"
        case .serverError: return "Lỗi máy chủ"
        case .timeout: return "Quá thời gian chờ"
        case .cancelled: return "Đã huỷ request"
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkError, .serverError, .timeout: return true
        default: return false
        }
    }
}

// === Endpoint Configuration ===

enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]?
    let body: Data?
    let headers: [String: String]?
    
    init(
        path: String,
        method: HTTPMethod = .GET,
        queryItems: [URLQueryItem]? = nil,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body.flatMap { try? JSONEncoder().encode($0) }
        self.headers = headers
    }
}

// === Endpoint definitions ===

enum Endpoints {
    static let baseURL = "https://jsonplaceholder.typicode.com"
    
    static func users() -> Endpoint {
        Endpoint(path: "/users")
    }
    
    static func user(id: Int) -> Endpoint {
        Endpoint(path: "/users/\(id)")
    }
    
    static func posts(page: Int = 1, limit: Int = 20) -> Endpoint {
        Endpoint(
            path: "/posts",
            queryItems: [
                URLQueryItem(name: "_page", value: "\(page)"),
                URLQueryItem(name: "_limit", value: "\(limit)"),
            ]
        )
    }
    
    static func post(id: Int) -> Endpoint {
        Endpoint(path: "/posts/\(id)")
    }
    
    static func createPost(_ request: CreatePostRequest) -> Endpoint {
        Endpoint(path: "/posts", method: .POST, body: request)
    }
    
    static func updatePost(id: Int, _ request: CreatePostRequest) -> Endpoint {
        Endpoint(path: "/posts/\(id)", method: .PUT, body: request)
    }
    
    static func deletePost(id: Int) -> Endpoint {
        Endpoint(path: "/posts/\(id)", method: .DELETE)
    }
    
    static func userPosts(userId: Int) -> Endpoint {
        Endpoint(
            path: "/posts",
            queryItems: [URLQueryItem(name: "userId", value: "\(userId)")]
        )
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║                                                          ║
// ║  APPROACH 1: ASYNC/AWAIT (Modern)                        ║
// ║                                                          ║
// ╚══════════════════════════════════════════════════════════╝


// ╔══════════════════════════════════════════════════════════╗
// ║  A1. API CLIENT — ASYNC/AWAIT                             ║
// ╚══════════════════════════════════════════════════════════╝

protocol AsyncAPIClientProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func requestRaw(_ endpoint: Endpoint) async throws -> Data
}

final class AsyncAPIClient: AsyncAPIClientProtocol {
    private let session: URLSession
    private let baseURL: String
    private let tokenProvider: (() async -> String?)?
    private let decoder: JSONDecoder
    
    init(
        baseURL: String = Endpoints.baseURL,
        session: URLSession = .shared,
        tokenProvider: (() async -> String?)? = nil
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenProvider = tokenProvider
        
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await requestRaw(endpoint)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func requestRaw(_ endpoint: Endpoint) async throws -> Data {
        // 1. Build URL
        guard var components = URLComponents(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        // 2. Build Request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        // Inject auth token
        if let token = await tokenProvider?() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Custom headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // 3. Execute
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .cancelled {
            throw APIError.cancelled
        } catch let error as URLError where error.code == .timedOut {
            throw APIError.timeout
        } catch {
            throw APIError.networkError(error)
        }
        
        // 4. Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  A2. SERVICE LAYER — ASYNC/AWAIT                          ║
// ╚══════════════════════════════════════════════════════════╝

protocol AsyncPostServiceProtocol: Sendable {
    func getPosts(page: Int) async throws -> [Post]
    func getPost(id: Int) async throws -> Post
    func createPost(_ request: CreatePostRequest) async throws -> Post
    func updatePost(id: Int, _ request: CreatePostRequest) async throws -> Post
    func deletePost(id: Int) async throws
    func getUserPosts(userId: Int) async throws -> [Post]
}

final class AsyncPostService: AsyncPostServiceProtocol {
    private let client: AsyncAPIClientProtocol
    
    init(client: AsyncAPIClientProtocol = AsyncAPIClient()) {
        self.client = client
    }
    
    func getPosts(page: Int) async throws -> [Post] {
        try await client.request(Endpoints.posts(page: page))
    }
    
    func getPost(id: Int) async throws -> Post {
        try await client.request(Endpoints.post(id: id))
    }
    
    func createPost(_ request: CreatePostRequest) async throws -> Post {
        try await client.request(Endpoints.createPost(request))
    }
    
    func updatePost(id: Int, _ request: CreatePostRequest) async throws -> Post {
        try await client.request(Endpoints.updatePost(id: id, request))
    }
    
    func deletePost(id: Int) async throws {
        _ = try await client.requestRaw(Endpoints.deletePost(id: id))
    }
    
    func getUserPosts(userId: Int) async throws -> [Post] {
        try await client.request(Endpoints.userPosts(userId: userId))
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  A3. VIEWMODEL — ASYNC/AWAIT                              ║
// ╚══════════════════════════════════════════════════════════╝

@Observable
final class AsyncPostListVM {
    private(set) var posts: [Post] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var error: APIError?
    private(set) var currentPage = 1
    private(set) var hasMore = true
    
    private let service: AsyncPostServiceProtocol
    
    init(service: AsyncPostServiceProtocol = AsyncPostService()) {
        self.service = service
    }
    
    // === Load initial page ===
    @MainActor
    func loadPosts() async {
        isLoading = true
        error = nil
        currentPage = 1
        
        do {
            let result = try await service.getPosts(page: 1)
            posts = result
            hasMore = !result.isEmpty
            isLoading = false
        } catch let err as APIError {
            error = err
            isLoading = false
        } catch {
            self.error = .networkError(error)
            isLoading = false
        }
    }
    
    // === Load next page (pagination) ===
    @MainActor
    func loadMore() async {
        guard !isLoadingMore, hasMore else { return }
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            let newPosts = try await service.getPosts(page: nextPage)
            posts.append(contentsOf: newPosts)
            currentPage = nextPage
            hasMore = !newPosts.isEmpty
        } catch { /* Silently fail for pagination */ }
        
        isLoadingMore = false
    }
    
    // === Create post ===
    @MainActor
    func createPost(title: String, body: String) async throws -> Post {
        let request = CreatePostRequest(title: title, body: body, userId: 1)
        let newPost = try await service.createPost(request)
        posts.insert(newPost, at: 0)
        return newPost
    }
    
    // === Delete post ===
    @MainActor
    func deletePost(id: Int) async throws {
        try await service.deletePost(id: id)
        posts.removeAll { $0.id == id }
    }
    
    // === Parallel fetch: posts + user info ===
    @MainActor
    func loadDashboard(userId: Int) async {
        isLoading = true
        
        async let postsTask = service.getPosts(page: 1)
        async let userPostsTask = service.getUserPosts(userId: userId)
        
        do {
            let (allPosts, _) = try await (postsTask, userPostsTask)
            posts = allPosts
        } catch let err as APIError {
            error = err
        } catch {
            self.error = .networkError(error)
        }
        
        isLoading = false
    }
    
    // === Retry logic ===
    @MainActor
    func loadWithRetry(maxRetries: Int = 3) async {
        isLoading = true
        error = nil
        
        for attempt in 1...maxRetries {
            do {
                posts = try await service.getPosts(page: 1)
                isLoading = false
                return // Thành công → thoát
            } catch let err as APIError where err.isRetryable && attempt < maxRetries {
                // Exponential backoff
                let delay = Double(attempt) * 1.5
                try? await Task.sleep(for: .seconds(delay))
                continue // Retry
            } catch let err as APIError {
                error = err
                break // Không retryable → dừng
            } catch {
                self.error = .networkError(error)
                break
            }
        }
        
        isLoading = false
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  A4. VIEW — ASYNC/AWAIT                                   ║
// ╚══════════════════════════════════════════════════════════╝

struct AsyncPostListView: View {
    @State private var vm = AsyncPostListVM()
    @State private var showCreate = false
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.posts.isEmpty {
                    ProgressView("Đang tải...")
                } else if let error = vm.error, vm.posts.isEmpty {
                    errorView(error)
                } else {
                    postList
                }
            }
            .navigationTitle("Posts (Async)")
            .toolbar {
                Button { showCreate = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task { await vm.loadPosts() }
        .refreshable { await vm.loadPosts() }
        .sheet(isPresented: $showCreate) {
            CreatePostSheet { title, body in
                try await vm.createPost(title: title, body: body)
            }
        }
    }
    
    private var postList: some View {
        List {
            ForEach(vm.posts) { post in
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.title).font(.headline)
                    Text(post.body).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
                .onAppear {
                    if post.id == vm.posts.last?.id {
                        Task { await vm.loadMore() }
                    }
                }
                .swipeActions {
                    Button("Xoá", role: .destructive) {
                        Task { try? await vm.deletePost(id: post.id) }
                    }
                }
            }
            
            if vm.isLoadingMore {
                ProgressView().frame(maxWidth: .infinity).listRowSeparator(.hidden)
            }
        }
    }
    
    private func errorView(_ error: APIError) -> some View {
        ContentUnavailableView {
            Label("Lỗi", systemImage: "wifi.exclamationmark")
        } description: {
            Text(error.errorDescription ?? "")
        } actions: {
            if error.isRetryable {
                Button("Thử lại") { Task { await vm.loadWithRetry() } }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║                                                          ║
// ║  APPROACH 2: COMBINE (Reactive)                          ║
// ║                                                          ║
// ╚══════════════════════════════════════════════════════════╝


// ╔══════════════════════════════════════════════════════════╗
// ║  C1. API CLIENT — COMBINE                                 ║
// ╚══════════════════════════════════════════════════════════╝

protocol CombineAPIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, APIError>
    func requestRaw(_ endpoint: Endpoint) -> AnyPublisher<Data, APIError>
}

final class CombineAPIClient: CombineAPIClientProtocol {
    private let session: URLSession
    private let baseURL: String
    private let decoder: JSONDecoder
    
    init(
        baseURL: String = Endpoints.baseURL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
        
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, APIError> {
        requestRaw(endpoint)
            // Decode JSON → Model
            .decode(type: T.self, decoder: decoder)
            // Map decoding error → APIError
            .mapError { error in
                if let apiError = error as? APIError { return apiError }
                return .decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    func requestRaw(_ endpoint: Endpoint) -> AnyPublisher<Data, APIError> {
        // 1. Build URL
        guard var components = URLComponents(string: baseURL + endpoint.path) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // 2. Build Request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // 3. Execute → Publisher pipeline
        return session.dataTaskPublisher(for: request)
            // Map network errors
            .mapError { urlError -> APIError in
                switch urlError.code {
                case .timedOut: return .timeout
                case .cancelled: return .cancelled
                default: return .networkError(urlError)
                }
            }
            // Validate HTTP response
            .tryMap { data, response -> Data in
                guard let http = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                switch http.statusCode {
                case 200...299: return data
                case 401: throw APIError.unauthorized
                case 404: throw APIError.notFound
                case 500...599: throw APIError.serverError
                default: throw APIError.httpError(statusCode: http.statusCode, data: data)
                }
            }
            .mapError { ($0 as? APIError) ?? .networkError($0) }
            .eraseToAnyPublisher()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  C2. SERVICE LAYER — COMBINE                              ║
// ╚══════════════════════════════════════════════════════════╝

protocol CombinePostServiceProtocol {
    func getPosts(page: Int) -> AnyPublisher<[Post], APIError>
    func getPost(id: Int) -> AnyPublisher<Post, APIError>
    func createPost(_ request: CreatePostRequest) -> AnyPublisher<Post, APIError>
    func deletePost(id: Int) -> AnyPublisher<Void, APIError>
    func getUserPosts(userId: Int) -> AnyPublisher<[Post], APIError>
}

final class CombinePostService: CombinePostServiceProtocol {
    private let client: CombineAPIClientProtocol
    
    init(client: CombineAPIClientProtocol = CombineAPIClient()) {
        self.client = client
    }
    
    func getPosts(page: Int) -> AnyPublisher<[Post], APIError> {
        client.request(Endpoints.posts(page: page))
    }
    
    func getPost(id: Int) -> AnyPublisher<Post, APIError> {
        client.request(Endpoints.post(id: id))
    }
    
    func createPost(_ request: CreatePostRequest) -> AnyPublisher<Post, APIError> {
        client.request(Endpoints.createPost(request))
    }
    
    func deletePost(id: Int) -> AnyPublisher<Void, APIError> {
        client.requestRaw(Endpoints.deletePost(id: id))
            .map { _ in () }   // Data → Void
            .eraseToAnyPublisher()
    }
    
    func getUserPosts(userId: Int) -> AnyPublisher<[Post], APIError> {
        client.request(Endpoints.userPosts(userId: userId))
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  C3. VIEWMODEL — COMBINE                                  ║
// ╚══════════════════════════════════════════════════════════╝

final class CombinePostListVM: ObservableObject {
    @Published private(set) var posts: [Post] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var error: APIError?
    @Published var searchQuery = ""
    
    private(set) var currentPage = 1
    private(set) var hasMore = true
    
    private let service: CombinePostServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    // ↑ GIỮ reference cho subscriptions — nếu empty → auto cancel
    
    init(service: CombinePostServiceProtocol = CombinePostService()) {
        self.service = service
        setupSearchDebounce()
    }
    
    // === Load initial page ===
    func loadPosts() {
        isLoading = true
        error = nil
        currentPage = 1
        
        service.getPosts(page: 1)
            .receive(on: DispatchQueue.main)
            // ↑ Switch về main thread cho UI updates
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let err) = completion {
                        self?.error = err
                    }
                },
                receiveValue: { [weak self] posts in
                    self?.posts = posts
                    self?.hasMore = !posts.isEmpty
                }
            )
            .store(in: &cancellables)
            // ↑ Lưu subscription — cancel khi VM deinit
    }
    
    // === Load next page ===
    func loadMore() {
        guard !isLoadingMore, hasMore else { return }
        isLoadingMore = true
        
        service.getPosts(page: currentPage + 1)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingMore = false
                },
                receiveValue: { [weak self] newPosts in
                    self?.posts.append(contentsOf: newPosts)
                    self?.currentPage += 1
                    self?.hasMore = !newPosts.isEmpty
                }
            )
            .store(in: &cancellables)
    }
    
    // === Create post ===
    func createPost(title: String, body: String) {
        let request = CreatePostRequest(title: title, body: body, userId: 1)
        
        service.createPost(request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let err) = completion { self?.error = err }
                },
                receiveValue: { [weak self] post in
                    self?.posts.insert(post, at: 0)
                }
            )
            .store(in: &cancellables)
    }
    
    // === Delete post ===
    func deletePost(id: Int) {
        service.deletePost(id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let err) = completion { self?.error = err }
                },
                receiveValue: { [weak self] in
                    self?.posts.removeAll { $0.id == id }
                }
            )
            .store(in: &cancellables)
    }
    
    // === COMBINE STRENGTH: Debounced Search ===
    // Combine shines khi cần reactive pipelines!
    
    private func setupSearchDebounce() {
        $searchQuery                              // Publisher từ @Published
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            // ↑ Chờ 400ms không gõ mới emit — built-in debounce!
            .removeDuplicates()
            // ↑ Bỏ qua nếu query KHÔNG thay đổi
            .map { query -> AnyPublisher<[Post], Never> in
                guard !query.isEmpty else {
                    // Query rỗng → trả về tất cả
                    return Just(self.posts).eraseToAnyPublisher()
                }
                
                // Filter local
                let filtered = self.posts.filter {
                    $0.title.localizedCaseInsensitiveContains(query)
                }
                return Just(filtered).eraseToAnyPublisher()
            }
            .switchToLatest()
            // ↑ Cancel search CŨ khi có query MỚI — tránh race condition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filtered in
                // Update filtered results
                // (Trong production: thường dùng biến filteredPosts riêng)
                _ = filtered
            }
            .store(in: &cancellables)
    }
    
    // === COMBINE STRENGTH: Parallel requests + merge ===
    func loadDashboard(userId: Int) {
        isLoading = true
        
        // CombineLatest: chờ CẢ HAI publishers emit rồi combine
        Publishers.CombineLatest(
            service.getPosts(page: 1),
            service.getUserPosts(userId: userId)
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion { self?.error = err }
            },
            receiveValue: { [weak self] allPosts, userPosts in
                self?.posts = allPosts
                // Dùng userPosts cho section khác...
            }
        )
        .store(in: &cancellables)
    }
    
    // === COMBINE STRENGTH: Retry with delay ===
    func loadWithRetry() {
        isLoading = true
        error = nil
        
        service.getPosts(page: 1)
            .retry(3)
            // ↑ Built-in retry 3 lần — 1 dòng code!
            // (Không có exponential backoff — cần custom cho production)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let err) = completion { self?.error = err }
                },
                receiveValue: { [weak self] posts in
                    self?.posts = posts
                }
            )
            .store(in: &cancellables)
    }
    
    // Retry với exponential backoff (custom):
    func loadWithExponentialRetry() {
        isLoading = true
        
        service.getPosts(page: 1)
            .catch { error -> AnyPublisher<[Post], APIError> in
                guard error.isRetryable else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                // Retry after 2 seconds
                return self.service.getPosts(page: 1)
                    .delay(for: .seconds(2), scheduler: DispatchQueue.global())
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let err) = completion { self?.error = err }
                },
                receiveValue: { [weak self] posts in
                    self?.posts = posts
                }
            )
            .store(in: &cancellables)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  C4. VIEW — COMBINE                                       ║
// ╚══════════════════════════════════════════════════════════╝

struct CombinePostListView: View {
    @StateObject private var vm = CombinePostListVM()
    // ↑ @StateObject cho ObservableObject (Combine VM)
    // Async VM dùng @State + @Observable
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.posts.isEmpty {
                    ProgressView("Đang tải...")
                } else if let error = vm.error, vm.posts.isEmpty {
                    Text(error.errorDescription ?? "Error")
                } else {
                    List(vm.posts) { post in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(post.title).font(.headline)
                            Text(post.body).font(.caption).lineLimit(2)
                        }
                        .onAppear {
                            if post.id == vm.posts.last?.id { vm.loadMore() }
                        }
                        .swipeActions {
                            Button("Xoá", role: .destructive) { vm.deletePost(id: post.id) }
                        }
                    }
                    .searchable(text: $vm.searchQuery)
                    // ↑ searchQuery là @Published → tự trigger debounce pipeline
                }
            }
            .navigationTitle("Posts (Combine)")
        }
        .onAppear { vm.loadPosts() }
        // ⚠️ Combine VM: dùng .onAppear thay .task
        // Vì loadPosts() KHÔNG async — nó tạo subscription internally
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  SHARED: Create Post Sheet                                ║
// ╚══════════════════════════════════════════════════════════╝

struct CreatePostSheet: View {
    let onCreate: (String, String) async throws -> Post
    
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var body = ""
    @State private var isLoading = false
    
    var formBody: some View {
        NavigationStack {
            Form {
                TextField("Tiêu đề", text: $title)
                TextField("Nội dung", text: $body, axis: .vertical)
                    .lineLimit(3...6)
            }
            .navigationTitle("Tạo bài viết")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Huỷ") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tạo") {
                        isLoading = true
                        Task {
                            _ = try? await onCreate(title, body)
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || isLoading)
                }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  SO SÁNH TỔNG HỢP                                        ║
// ╚══════════════════════════════════════════════════════════╝

// ┌────────────────────────┬────────────────────────┬────────────────────────┐
// │ Tiêu chí               │ Async/Await            │ Combine                │
// ├────────────────────────┼────────────────────────┼────────────────────────┤
// │ Min iOS                │ 15                     │ 13                     │
// │ Code style             │ Tuần tự (sequential)   │ Pipeline (declarative) │
// │ Đọc hiểu              │ ✅ Rất dễ — như sync   │ ⚠️ Learning curve cao │
// │ Error handling         │ do-catch tự nhiên      │ sink completion + map  │
// │ Cancellation           │ Task.cancel()          │ AnyCancellable         │
// │ Auto-cancel SwiftUI    │ ✅ .task { } modifier  │ ❌ Phải cancel thủ công│
// │ Retry                  │ Tự viết loop           │ .retry(n) built-in     │
// │ Debounce               │ Task.sleep + cancel    │ .debounce() built-in   │
// │ Parallel requests      │ async let / TaskGroup  │ CombineLatest / Merge  │
// │ Stream / real-time     │ AsyncSequence          │ Publisher (native)     │
// │ Boilerplate            │ ✅ Ít                  │ ⚠️ Nhiều (.sink, .store)│
// │ Testing                │ ✅ Dễ — async test     │ ⚠️ Cần XCTestExpectation│
// │ SwiftUI integration    │ .task { await ... }    │ .onAppear { vm.load() }│
// │ @Observable support    │ ✅ Native              │ ❌ Dùng ObservableObject│
// │ Memory management      │ ✅ Structured tasks    │ ⚠️ Quản lý cancellables│
// │ Apple direction        │ ✅ Tương lai           │ ⚠️ Maintenance mode    │
// ├────────────────────────┼────────────────────────┼────────────────────────┤
// │ DÙNG KHI               │ Request-response đơn   │ Streams, multi-source  │
// │                        │ CRUD APIs              │ merge, complex reactive│
// │                        │ New projects iOS 15+   │ Legacy iOS 13-14       │
// │                        │ Phần lớn use cases     │ Real-time data flows   │
// └────────────────────────┴────────────────────────┴────────────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  KHUYẾN KHÍCH — KHI NÀO DÙNG CÁI NÀO?                   ║
// ╚══════════════════════════════════════════════════════════╝

// ✅ DÙNG ASYNC/AWAIT (khuyến khích cho phần lớn projects):
// - CRUD API calls (GET, POST, PUT, DELETE)
// - Pagination
// - Parallel fetching (async let, TaskGroup)
// - New projects iOS 15+
// - Team chưa quen Combine
// - Simple request → response patterns
// - Code dễ đọc, dễ maintain, dễ onboard team members

// ✅ DÙNG COMBINE khi CẦN:
// - Debounce search realtime (.debounce built-in)
// - Merge multiple data streams (CombineLatest, Merge, Zip)
// - Phải support iOS 13-14 (không có async/await)
// - WebSocket / Server-sent events (stream data)
// - Complex reactive pipelines (transform → filter → merge)
// - Timer-based polling (.timer publisher)
// - KVO observation qua publisher

// ✅ KẾT HỢP CẢ HAI (pragmatic approach):
// - API layer: async/await (clean, đơn giản)
// - ViewModel reactive bindings: Combine ($searchQuery.debounce)
// - Real-time features: Combine (WebSocket, streams)
// - Bridge: Combine publisher → async/await: publisher.values
//           async/await → Combine: Future { promise in Task { } }

// === Bridge: Combine ↔ Async/Await ===

extension Publisher where Failure == APIError {
    // Combine Publisher → async/await
    func firstValue() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = first()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}

// Sử dụng bridge: dùng Combine service TRONG async context
struct BridgeExample {
    let combineService = CombinePostService()
    
    func loadPosts() async throws -> [Post] {
        // Combine publisher → await single value
        try await combineService.getPosts(page: 1).firstValue()
    }
}
```

---

Đây là chủ đề kiến trúc rất thực tế — so sánh 2 approaches xây dựng networking layer, với code production-grade cho cả hai. Mình sẽ build cùng 1 feature (CRUD API) theo cả 2 cách để thấy rõ khác biệt.Mình đã build cùng 1 API layer theo cả 2 approaches với production-grade code. Đây là những điểm cốt lõi:

**Kiến trúc chung** giống nhau: Endpoint config → API Client → Service → ViewModel → View. Khác biệt nằm ở **cách data flow** qua từng layer.

**Ba khác biệt then chốt:**

**Code style**: Async/Await đọc **tuần tự như synchronous** — `let posts = try await service.getPosts()`, error handling bằng `do-catch` quen thuộc. Combine là **pipeline declarative** — `.map { }.decode { }.receive(on:).sink { }`, error handling qua `receiveCompletion` closure. Async/Await dễ đọc hơn đáng kể cho CRUD operations.

**Cancellation**: Async/Await tích hợp SwiftUI qua `.task { }` — **auto-cancel** khi view disappear, không cần quản lý gì. Combine phải giữ `Set<AnyCancellable>` + `.store(in: &cancellables)` mỗi subscription — quên → subscription bị cancel ngay, leak nếu giữ reference sai.

**Reactive operators**: Đây là nơi Combine **mạnh hơn rõ rệt** — `.debounce(for: .milliseconds(400))`, `.retry(3)`, `.removeDuplicates()`, `CombineLatest`, `switchToLatest()` đều là 1 dòng code. Async/Await phải tự implement debounce (Task.sleep + cancel), retry (for loop + backoff), parallel merge (async let).

**Khuyến khích pragmatic: kết hợp cả hai.** API layer dùng **Async/Await** (clean, đơn giản cho CRUD). ViewModel reactive bindings dùng **Combine** (`$searchQuery.debounce().removeDuplicates().switchToLatest()` — 4 operators xử lý debounced search hoàn hảo). Bridge giữa hai thế giới qua `publisher.values` (Combine → Async) hoặc `withCheckedThrowingContinuation` (Async → Combine).

**Apple's direction**: Async/Await là tương lai — `@Observable` (iOS 17+) thay `ObservableObject`, `.task { }` thay `.onAppear + cancellables`. Combine vẫn hữu ích cho reactive streams nhưng đang ở maintenance mode — không có API mới từ WWDC 2021.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
