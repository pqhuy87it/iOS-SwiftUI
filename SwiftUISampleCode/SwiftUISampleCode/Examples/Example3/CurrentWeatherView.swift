import Combine
import SwiftUI

struct CurrentWeatherView: View {
    @StateObject private var viewModel: CurrentWeatherViewModel
    
    init(city: String) {
        // Khởi tạo @StateObject với tham số truyền vào
        _viewModel = StateObject(wrappedValue: CurrentWeatherViewModel(city: city))
    }
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Đang tải dữ liệu...")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let dataSource = viewModel.dataSource {
                CurrentWeatherRow(viewModel: dataSource)
            } else {
                Text("Không thể tải dữ liệu thời tiết.")
                    .foregroundColor(.red)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.city)
        .navigationBarTitleDisplayMode(.inline)
        // Kéo xuống để refresh dữ liệu
        .refreshable {
            viewModel.fetchCurrentWeather()
        }
    }
}
