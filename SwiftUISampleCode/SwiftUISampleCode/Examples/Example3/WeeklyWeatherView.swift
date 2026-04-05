import SwiftUI
import Combine

// MARK: - 4. Views (UI Tối ưu với NavigationStack, Searchable và Map native)

struct WeeklyWeatherView: View {
    @StateObject private var viewModel = WeeklyWeatherViewModel()
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Đang tải dữ liệu...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else if viewModel.dataSource.isEmpty {
                Text("Không có dữ liệu. Vui lòng thử tìm kiếm thành phố khác.")
                    .foregroundColor(.gray)
            } else {
                cityHourlyWeatherSection
                forecastSection
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.city.isEmpty ? "Weather" : "Weather \(viewModel.todaysWeatherEmoji)")
        // Cải tiến: Sử dụng Searchable UI native của iOS
        .searchable(text: $viewModel.city, prompt: "Ví dụ: Cupertino, Hanoi...")
    }
    
    private var cityHourlyWeatherSection: some View {
        Section {
            // SRP: NavigationLink trực tiếp khởi tạo màn hình con, không nhờ ViewModel
            NavigationLink(destination: CurrentWeatherView(city: viewModel.city)) {
                VStack(alignment: .leading) {
                    Text(viewModel.city)
                        .font(.headline)
                    Text("Thời tiết hôm nay")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var forecastSection: some View {
        Section(header: Text("Dự báo 7 ngày")) {
            ForEach(viewModel.dataSource) { rowViewModel in
                DailyWeatherRow(viewModel: rowViewModel)
            }
        }
    }
}
