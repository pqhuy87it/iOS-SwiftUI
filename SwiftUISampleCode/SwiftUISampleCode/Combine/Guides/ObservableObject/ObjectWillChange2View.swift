import Combine
import SwiftUI

// MARK: - 2. TÁCH VIEW: Khu vực Settings (MỚI)
// View này chịu trách nhiệm lắng nghe settingsVM
struct SettingsSectionView: View {
    @ObservedObject var settingsVM: SettingsVM // Chỉ View này mới subscribe
    
    var body: some View {
        // 👉 Debug: In ra console khi View NÀY bị re-render
        let _ = Self._printChanges()
        
        VStack(spacing: 10) {
            Text("Lần Render Settings [2]: \(Date().formatted(date: .omitted, time: .standard))")
                .font(.caption2)
                .foregroundColor(.orange)
            
            Toggle("🌙 Chế độ tối", isOn: $settingsVM.isDark)
                .font(.title2).bold()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 3. DashboardView (Đã tối ưu)
struct DashboardView2: View {
    @ObservedObject var userVM: UserVM
    @ObservedObject var cartVM: CartVM
    
    // 👉 QUAN TRỌNG: Đã đổi thành 'let' thường, KHÔNG CÒN @ObservedObject.
    // DashboardView giờ đây "mù và điếc" trước sự thay đổi của settingsVM.
    let settingsVM: SettingsVM
    
    var body: some View {
        // 👉 Debug: In ra console khi DashboardView bị re-render
        let _ = Self._printChanges()
        
        VStack(spacing: 30) {
            Text("Lần Render Dashboard [2]: \(Date().formatted(date: .omitted, time: .standard))")
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
            
            // --- Khu vực Settings (Đã được bọc vào View con) ---
            // Chỉ truyền tham chiếu (pointer) xuống cho View con tự lo liệu
            SettingsSectionView(settingsVM: settingsVM)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - 4. Root View
struct ObjectWillChange2View: View {
    @StateObject private var userVM = UserVM()
    @StateObject private var cartVM = CartVM()
    @StateObject private var settingsVM = SettingsVM()
    
    var body: some View {
        DashboardView2(userVM: userVM, cartVM: cartVM, settingsVM: settingsVM)
            .preferredColorScheme(settingsVM.isDark ? .dark : .light)
    }
}

#Preview {
    ObjectWillChange2View()
}
