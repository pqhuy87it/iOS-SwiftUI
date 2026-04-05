import Combine

// ISP: Tách nhỏ Protocol thay vì gộp chung
protocol WeeklyWeatherService {
    func weeklyWeatherForecast(forCity city: String) -> AnyPublisher<WeeklyForecastResponse, WeatherError>
}

protocol CurrentWeatherService {
    func currentWeatherForecast(forCity city: String) -> AnyPublisher<CurrentWeatherForecastResponse, WeatherError>
}
