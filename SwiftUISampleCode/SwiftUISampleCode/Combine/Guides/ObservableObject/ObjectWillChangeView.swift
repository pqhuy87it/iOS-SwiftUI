import Combine
import SwiftUI

// MARK: - 1. Các ViewModels (ObservableObject)
// Các class này sẽ tự động phát ra tín hiệu `objectWillChange` mỗi khi một biến @Published thay đổi.

class UserVM: ObservableObject {
    @Published var name: String = "Khách lạ"
}

class CartVM: ObservableObject {
    @Published var itemCount: Int = 0
}

class SettingsVM: ObservableObject {
    @Published var isDark: Bool = false
}

// MARK: - 2. DashboardView của bạn
struct DashboardView: View {
    @ObservedObject var userVM: UserVM
    @ObservedObject var cartVM: CartVM
    @ObservedObject var settingsVM: SettingsVM
    
    // SwiftUI tự động subscribe CẢ 3 objectWillChange
    
    var body: some View {
        // 👉 THỦ THUẬT DEBUG: Dòng này sẽ in ra Console tên của biến đã làm cho View bị re-render.
        let _ = Self._printChanges()
        
        VStack(spacing: 30) {
            // Hiển thị thời gian vẽ lại để chứng minh body vừa được chạy lại từ trên xuống dưới
            Text("Lần Render cuối: \(Date().formatted(date: .omitted, time: .standard))")
                .font(.caption)
                .foregroundColor(.red)
            
            // --- Khu vực User ---
            VStack(spacing: 10) {
                Text("👤 Xin chào: \(userVM.name)")
                    .font(.title2).bold()
                Button("Đổi tên ngẫu nhiên") {
                    let randomNames = ["Nam", "Lan", "Hải", "Tuấn"]
                    userVM.name = randomNames.randomElement() ?? "Khách"
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            
            // --- Khu vực Cart ---
            VStack(spacing: 10) {
                Text("🛒 Giỏ hàng: \(cartVM.itemCount) món")
                    .font(.title2).bold()
                Button("Thêm vào giỏ") {
                    cartVM.itemCount += 1
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            
            // --- Khu vực Settings ---
            VStack(spacing: 10) {
                Toggle("🌙 Chế độ tối", isOn: $settingsVM.isDark)
                    .font(.title2).bold()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - 3. Root View (Nơi khởi tạo các ViewModels)
struct ObjectWillChangeView: View {
    // Vì ContentView là người TẠO RA các objects này, nó phải dùng @StateObject
    @StateObject private var userVM = UserVM()
    @StateObject private var cartVM = CartVM()
    @StateObject private var settingsVM = SettingsVM()
    
    var body: some View {
        // Truyền các objects vào cho DashboardView sử dụng
        DashboardView(userVM: userVM, cartVM: cartVM, settingsVM: settingsVM)
            // Lắng nghe settingsVM để đổi màu toàn màn hình thật luôn
            .preferredColorScheme(settingsVM.isDark ? .dark : .light)
    }
}

#Preview {
    ObjectWillChangeView()
}
