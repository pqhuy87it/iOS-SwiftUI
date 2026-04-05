import Combine
import Foundation

// MARK: - 3. ViewModel (SOLID: Single Responsibility)
@MainActor // Đảm bảo mọi cập nhật UI đều trên Main Thread
final class SearchUserViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var users = [User]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // Phụ thuộc vào Abstraction (Protocol), không phụ thuộc vào class cụ thể
    private let networkService: GithubServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // Inject dependency qua hàm init
    init(networkService: GithubServiceProtocol = GithubService()) {
        self.networkService = networkService
        setupSearchAutoTrigger()
    }

    private func setupSearchAutoTrigger() {
        // Tự động tìm kiếm khi user gõ phím (Debounce)
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        guard !query.isEmpty else {
            self.users = []
            self.errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil

        networkService.searchUsers(query: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.users = []
                }
            }, receiveValue: { [weak self] users in
                self?.users = users
            })
            .store(in: &cancellables)
    }
}
