import CoreLocation
import SwiftUI
import Foundation

struct CurrentWeatherRowViewModel: Identifiable {
    let id = UUID() // Thêm ID để dùng được với AnnotationItems của Map
    private let item: CurrentWeatherForecastResponse
    
    var temperature: String { String(format: "%.1f", item.main.temperature) }
    var maxTemperature: String { String(format: "%.1f", item.main.maxTemperature) }
    var minTemperature: String { String(format: "%.1f", item.main.minTemperature) }
    var humidity: String { String(format: "%d", item.main.humidity) }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: item.coord.lat, longitude: item.coord.lon)
    }
    
    init(item: CurrentWeatherForecastResponse) {
        self.item = item
    }
}
