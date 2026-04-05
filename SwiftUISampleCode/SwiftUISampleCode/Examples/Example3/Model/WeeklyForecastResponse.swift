
import Foundation

// Data Models
struct WeeklyForecastResponse: Codable {
    let list: [Item]
    struct Item: Codable {
        let date: Date
        let main: MainClass
        let weather: [Weather]
        enum CodingKeys: String, CodingKey { case date = "dt", main, weather }
    }
    struct MainClass: Codable { let temp: Double }
    struct Weather: Codable {
        let main: MainEnum
        let weatherDescription: String
        enum CodingKeys: String, CodingKey { case main, weatherDescription = "description" }
    }
    enum MainEnum: String, Codable { case clear = "Clear", clouds = "Clouds", rain = "Rain" }
}
