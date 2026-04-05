
import Foundation

struct CurrentWeatherForecastResponse: Decodable {
    let coord: Coord
    let main: Main
    struct Main: Codable {
        let temperature: Double, humidity: Int, maxTemperature: Double, minTemperature: Double
        enum CodingKeys: String, CodingKey {
            case temperature = "temp", humidity, maxTemperature = "temp_max", minTemperature = "temp_min"
        }
    }
    struct Coord: Codable { let lon: Double; let lat: Double }
}
