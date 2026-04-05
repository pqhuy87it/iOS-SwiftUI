import Combine
import SwiftUI

struct DailyWeatherRow: View {
    let viewModel: DailyWeatherRowViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .center) {
                Text(viewModel.day).font(.headline)
                Text(viewModel.month).font(.caption).foregroundColor(.secondary)
            }
            .frame(width: 50)
            
            VStack(alignment: .leading) {
                Text("\(viewModel.title) \(viewModel.emoji)")
                    .font(.body).bold()
                Text(viewModel.fullDescription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(viewModel.temperature)°")
                .font(.title2).bold()
        }
        .padding(.vertical, 4)
    }
}
