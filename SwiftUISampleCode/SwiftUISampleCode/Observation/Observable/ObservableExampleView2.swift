
import SwiftUI
import Combine

// MARK: - 1. THE VIEW MODEL (Data Source)
// Sử dụng ObservableObject và Combine (Kiến trúc chuẩn trước iOS 17)
class DataSource: ObservableObject {
    // @Published sẽ tự động gọi objectWillChange mỗi khi giá trị thay đổi
    @Published var currentValue = "Dữ liệu khởi tạo (Initial)"
    
    // Ví dụ về quản lý bộ nhớ (Tránh retain cycle)
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("✅ DataSource đã được khởi tạo!")
    }
    
    func updateValue() {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let timeString = formatter.string(from: Date())
        
        currentValue = "Đã cập nhật lúc: \(timeString)"
    }
    
    deinit {
        // Dọn dẹp bộ nhớ khi ViewModel bị hủy
        cancellables.removeAll()
        print("❌ DataSource đã bị hủy khỏi bộ nhớ!")
    }
}

// MARK: - 2. PARENT VIEW (View Cha)
struct DataFlowExample: View {
    // LƯU Ý QUAN TRỌNG: Ở View khởi tạo ViewModel, BẮT BUỘC dùng @StateObject.
    // SwiftUI sẽ giữ cho dataSource này sống sót xuyên suốt vòng đời của DataFlowExample.
     @StateObject private var dataSource = DataSource()
//    @ObservedObject private var dataSource = DataSource()
    
    @State private var toggleState = false // Biến này dùng để test việc re-render View cha
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Khối Hiển thị
                DisplayView(dataSource: dataSource)
                
                // Khối Chỉnh sửa
                ModificationView(dataSource: dataSource)
                
                Divider()
                
                // Nút này để test cạm bẫy vòng đời:
                // Khi bấm, toggleState đổi -> View Cha vẽ lại.
                // Nhờ dùng @StateObject, dataSource sẽ KHÔNG bị reset.
                // (Nếu bạn đổi @StateObject ở trên thành @ObservedObject, bạn sẽ thấy DataSource bị reset liên tục)
                Button(action: {
                    toggleState.toggle()
                }) {
                    Text("Re-render View Cha (Trạng thái: \(toggleState ? "ON" : "OFF"))")
                        .padding()
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("Luồng Dữ Liệu MVVM")
        }
    }
}

// MARK: - 3. CHILD VIEWS (Các View Con)

// View con thứ nhất: Chỉ làm nhiệm vụ HIỂN THỊ
struct DisplayView: View {
    // LƯU Ý: View con chỉ NHẬN dữ liệu từ ngoài truyền vào, nên dùng @ObservedObject
    @ObservedObject var dataSource: DataSource
    
    var body: some View {
        VStack {
            Text("Dữ liệu hiện tại:")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(dataSource.currentValue)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

// View con thứ hai: Làm nhiệm vụ CHỈNH SỬA / CẬP NHẬT
struct ModificationView: View {
    // Tương tự, dùng @ObservedObject để tham chiếu tới ViewModel của View cha
    @ObservedObject var dataSource: DataSource
    
    var body: some View {
        Button(action: {
            dataSource.updateValue()
        }) {
            Text("Cập Nhật Dữ Liệu Mới")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
        }
    }
}

// MARK: - PREVIEW
#Preview {
    DataFlowExample()
}
