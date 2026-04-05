import Combine
import SwiftUI

final class GithubService: GithubServiceProtocol {
    func searchUsers(query: String) -> AnyPublisher<[User], Error> {
        var urlComponents = URLComponents(string: "https://api.github.com/search/users")!
        urlComponents.queryItems = [URLQueryItem(name: "q", value: query)]
        
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SearchUserResponse.self, decoder: JSONDecoder())
            .map(\.items)
            .eraseToAnyPublisher()
    }
}
