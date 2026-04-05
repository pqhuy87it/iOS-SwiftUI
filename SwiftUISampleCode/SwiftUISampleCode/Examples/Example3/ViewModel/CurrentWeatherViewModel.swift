import Combine
import Foundation

@MainActor
class CurrentWeatherViewModel: ObservableObject {
    @Published private(set) var dataSource: CurrentWeatherRowViewModel?
    @Published private(set) var isLoading = false
    
    let city: String
    private let weatherService: CurrentWeatherService
    private var disposables = Set<AnyCancellable>()
    
    init(city: String, weatherService: CurrentWeatherService = WeatherFetcher()) {
        self.city = city
        self.weatherService = weatherService
        fetchCurrentWeather()
    }
    
    func fetchCurrentWeather() {
        isLoading = true
        weatherService.currentWeatherForecast(forCity: city)
            .map(CurrentWeatherRowViewModel.init)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            }, receiveValue: { [weak self] weather in
                self?.dataSource = weather
            })
            .store(in: &disposables)
    }
}
