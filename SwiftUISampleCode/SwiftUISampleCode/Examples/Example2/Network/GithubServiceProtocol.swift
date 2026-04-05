import Combine

// MARK: - 2. Network Layer (SOLID: Dependency Inversion & Interface Segregation)
protocol GithubServiceProtocol {
    func searchUsers(query: String) -> AnyPublisher<[User], Error>
}
