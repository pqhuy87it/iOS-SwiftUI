import Combine
import SwiftUI

// MARK: - 2. Network Layer (SRP)

class WeatherFetcher: WeeklyWeatherService, CurrentWeatherService {
    private let session: URLSession
    private let config: WeatherAPIConfig
    
    init(session: URLSession = .shared, config: WeatherAPIConfig = WeatherAPIConfig()) {
        self.session = session
        self.config = config
    }
    
    func weeklyWeatherForecast(forCity city: String) -> AnyPublisher<WeeklyForecastResponse, WeatherError> {
        let components = makeComponents(endpoint: "/forecast", city: city)
        return fetch(with: components)
    }
    
    func currentWeatherForecast(forCity city: String) -> AnyPublisher<CurrentWeatherForecastResponse, WeatherError> {
        let components = makeComponents(endpoint: "/weather", city: city)
        return fetch(with: components)
    }
    
    private func makeComponents(endpoint: String, city: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = config.scheme
        components.host = config.host
        components.path = config.path + endpoint
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "mode", value: "json"),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "APPID", value: config.key)
        ]
        return components
    }
    
    private func fetch<T: Decodable>(with components: URLComponents) -> AnyPublisher<T, WeatherError> {
        guard let url = components.url else {
            return Fail(error: WeatherError.network(description: "Invalid URL")).eraseToAnyPublisher()
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { WeatherError.network(description: $0.localizedDescription) }
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .mapError { WeatherError.parsing(description: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
}
