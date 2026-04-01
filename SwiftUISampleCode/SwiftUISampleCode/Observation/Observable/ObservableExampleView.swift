import SwiftUI
import Observation // Bắt buộc phải import thư viện này cho macro @Observable

// MARK: - 1. The Model
// Model chứa dữ liệu thuần túy, không chứa logic UI.
struct Counter {
    var value: Int = 0
}

// MARK: - 2. The ViewModel
// Chỉ cần đánh dấu @Observable ở đầu Class.
// KHÔNG cần kế thừa ObservableObject, KHÔNG cần @Published.
@Observable
class CounterViewModel {
    // Thuộc tính private model
    private var counter = Counter()
    
    // Mọi thuộc tính công khai tự động trở thành "observable"
    var displayText: String {
        if counter.value > 10 {
            return "Count is large: \(counter.value)!"
        }
        return "Count is \(counter.value)"
    }
    
    var tapCount: Int {
        return counter.value
    }
    
    // Logic nghiệp vụ nằm ở ViewModel
    func increment() {
        counter.value += 1
    }
    
    func reset() {
        counter.value = 0
    }
}

// MARK: - 3. The View
struct ObservableExampleView: View {
    // Thay thế @StateObject bằng @State cho ViewModel (từ iOS 17)
    @State private var viewModel = CounterViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("MVVM with @Observable")
                .font(.headline)
                .foregroundColor(.gray)
            
            // View chỉ lấy dữ liệu đã được xử lý từ ViewModel
            Text(viewModel.displayText)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(viewModel.tapCount > 10 ? .red : .blue)
            
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.increment()
                }) {
                    Text("Tăng (+)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.reset()
                }) {
                    Text("Làm Lại")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    ObservableExampleView()
}
