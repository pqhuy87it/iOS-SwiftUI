import SwiftUI
import Foundation

// MARK: - 5. Models & ViewModels Data (Giữ nguyên logic Format, cải thiện cách viết)

struct DailyWeatherRowViewModel: Identifiable, Hashable {
    private let item: WeeklyForecastResponse.Item
    
    var id: String { day + temperature + title }
    
    var emoji: String {
        switch item.weather.first?.main {
        case .clear: return "☀️"
        case .clouds: return "🌥"
        case .rain: return "☔️"
        case .none: return "❓"
        }
    }
    
    var day: String { dayFormatter.string(from: item.date) }
    var month: String { monthFormatter.string(from: item.date) }
    var temperature: String { String(format: "%.1f", item.main.temp) }
    var title: String { item.weather.first?.main.rawValue ?? "" }
    var fullDescription: String { item.weather.first?.weatherDescription.capitalized ?? "" }
    
    init(item: WeeklyForecastResponse.Item) {
        self.item = item
    }
    
    static func == (lhs: DailyWeatherRowViewModel, rhs: DailyWeatherRowViewModel) -> Bool {
        lhs.day == rhs.day
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(day)
    }
}
