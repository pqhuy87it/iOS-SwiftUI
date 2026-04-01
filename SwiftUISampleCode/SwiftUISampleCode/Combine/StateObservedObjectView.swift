import SwiftUI
import Combine

// MARK: - 1. THE VIEW MODEL
// Phải tuân thủ ObservableObject
class CounterViewModel1: ObservableObject {
    @Published var count: Int = 0
    
    init() {
        // Dòng lệnh này giúp bạn biết chính xác khi nào ViewModel bị khởi tạo lại
        print("✅ CounterViewModel đã được tạo mới!")
    }
    
    func increment() {
        count += 1
    }
}

// MARK: - 2. PARENT VIEW (Người làm chủ)
struct StateObservedObjectView: View {
    // ĐÚNG CHUẨN: Dùng @StateObject ở nơi khởi tạo ViewModel
    // SwiftUI sẽ bảo vệ vùng nhớ của 'viewModel' này.
    @StateObject private var viewModel = CounterViewModel1()
    
    // Một state không liên quan để test việc re-render View
    @State private var isBlueBackground = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Màn Hình Cha (Parent)")
                .font(.title2)
                .fontWeight(.bold)
            
            // Nút này làm State của ParentView thay đổi -> Ép ParentView phải vẽ lại (Re-render)
            // Nếu dùng @ObservedObject ở trên, viewModel sẽ bị reset về 0 ngay lập tức!
            Button("Đổi màu nền để ép Re-render") {
                isBlueBackground.toggle()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
            
            Divider()
            
            // Truyền viewModel xuống cho View con
            ChildView(viewModel: viewModel)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isBlueBackground ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
        .animation(.easeInOut, value: isBlueBackground)
    }
}

// MARK: - 3. CHILD VIEW (Người quan sát)
struct ChildView: View {
    // ĐÚNG CHUẨN: View con chỉ nhận dữ liệu từ ngoài vào, KHÔNG KHỞI TẠO.
    // Do đó chỉ cần dùng @ObservedObject để lắng nghe.
    @ObservedObject var viewModel: CounterViewModel1
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Màn Hình Con (Child)")
                .font(.headline)
            
            Text("\(viewModel.count)")
                .font(.system(size: 60, weight: .black))
                .foregroundColor(.red)
            
            Button(action: {
                viewModel.increment()
            }) {
                Text("Tăng Biến Đếm (+)")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - PREVIEW
#Preview {
    StateObservedObjectView()
}
