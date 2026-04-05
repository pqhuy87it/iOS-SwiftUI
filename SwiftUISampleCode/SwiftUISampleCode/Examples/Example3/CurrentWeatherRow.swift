import Combine
import SwiftUI
import MapKit

struct CurrentWeatherRow: View {
    let viewModel: CurrentWeatherRowViewModel
    
    // Sử dụng @State để quản lý vùng hiển thị bản đồ thay vì UIViewRepresentable
    @State private var region: MKCoordinateRegion
    
    init(viewModel: CurrentWeatherRowViewModel) {
        self.viewModel = viewModel
        _region = State(initialValue: MKCoordinateRegion(
            center: viewModel.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Cải tiến: Sử dụng Map Native của SwiftUI
            Map(coordinateRegion: $region, annotationItems: [viewModel]) { location in
                MapMarker(coordinate: location.coordinate, tint: .blue)
            }
            .frame(height: 250)
            .cornerRadius(16)
            .disabled(true)
            
            VStack(alignment: .leading, spacing: 12) {
                weatherDetailRow(icon: "thermometer.sun", title: "Nhiệt độ", value: "\(viewModel.temperature)°", color: .orange)
                weatherDetailRow(icon: "arrow.up.right.circle", title: "Cao nhất", value: "\(viewModel.maxTemperature)°", color: .red)
                weatherDetailRow(icon: "arrow.down.right.circle", title: "Thấp nhất", value: "\(viewModel.minTemperature)°", color: .blue)
                weatherDetailRow(icon: "humidity", title: "Độ ẩm", value: "\(viewModel.humidity)%", color: .cyan)
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical)
    }
    
    private func weatherDetailRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
        .font(.body)
    }
}
