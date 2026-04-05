// MARK: - 1. API Configuration & Protocols (OCP, ISP & DIP)

struct WeatherAPIConfig {
    let scheme = "https"
    let host = "api.openweathermap.org"
    let path = "/data/2.5"
    let key = "28c29099075601342f371617f43b2878" // Trong thực tế nên để ở file .env hoặc plist
}
