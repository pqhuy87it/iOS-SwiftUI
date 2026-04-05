import Combine
import Foundation

// MARK: - 3. ViewModels (SRP)

@MainActor
class WeeklyWeatherViewModel: ObservableObject {
    @Published var city: String = ""
    @Published private(set) var todaysWeatherEmoji: String = ""
    @Published private(set) var dataSource: [DailyWeatherRowViewModel] = []
    @Published private(set) var isLoading: Bool = false
    
    private let weatherService: WeeklyWeatherService
    private var disposables = Set<AnyCancellable>()
    
    init(weatherService: WeeklyWeatherService = WeatherFetcher()) {
        self.weatherService = weatherService
        setupSearch()
    }
    
    private func setupSearch() {
        $city
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] city in
                guard let self = self else { return }
                if city.isEmpty {
                    self.dataSource = []
                    self.todaysWeatherEmoji = ""
                } else {
                    self.fetchWeather(for: city)
                }
            }
            .store(in: &disposables)
    }
    
    private func fetchWeather(for city: String) {
        isLoading = true
        weatherService.weeklyWeatherForecast(forCity: city)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure = completion {
                    self?.dataSource = []
                    self?.todaysWeatherEmoji = ""
                }
            }, receiveValue: { [weak self] response in
                let uniqueItems = Array.removeDuplicates(response.list.map(DailyWeatherRowViewModel.init))
                self?.dataSource = uniqueItems
                self?.todaysWeatherEmoji = uniqueItems.first?.emoji ?? ""
            })
            .store(in: &disposables)
    }
}
