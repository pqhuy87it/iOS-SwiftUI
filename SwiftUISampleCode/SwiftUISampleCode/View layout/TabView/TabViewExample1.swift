import SwiftUI

// MARK: - Màn hình chính chứa TabView
struct TabViewExample1: View {
    // 1. Biến @State để lưu trữ Tab nào đang được chọn
    @State private var selectedTab: Int = 0
    
    var body: some View {
        // Khởi tạo TabView và bind với biến selectedTab
        TabView(selection: $selectedTab) {
            
            // --- TAB 1 ---
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Trang chủ", systemImage: "house.fill")
                }
                .tag(0) // Đánh dấu đây là tab số 0
            
            // --- TAB 2 ---
            SearchView()
                .tabItem {
                    Label("Tìm kiếm", systemImage: "magnifyingglass")
                }
                .tag(1) // Đánh dấu đây là tab số 1
            
            // --- TAB 3 ---
            SettingsView1()
                .tabItem {
                    Label("Cài đặt", systemImage: "gearshape.fill")
                }
                .tag(2) // Đánh dấu đây là tab số 2
        }
        // Đổi màu chủ đạo cho icon và chữ khi Tab được chọn
        .tint(.blue)
    }
}

// MARK: - Các màn hình con (Subviews)

struct HomeView: View {
    // Nhận binding từ cha để có thể điều khiển TabView từ màn hình con
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "house.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Đây là Trang Chủ")
                .font(.title).bold()
            
            // Nút bấm ví dụ về việc chuyển Tab bằng code
            Button("Chuyển sang Cài đặt") {
                selectedTab = 2 // Đổi giá trị -> TabView tự động nhảy sang Tab 2
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct SearchView: View {
    var body: some View {
        VStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Khám phá nội dung")
                .font(.title).bold()
        }
    }
}

struct SettingsView1: View {
    var body: some View {
        List {
            Section("Tài khoản") {
                Text("Hồ sơ cá nhân")
                Text("Bảo mật")
            }
            Section("Hệ thống") {
                Text("Thông báo")
                Text("Giao diện")
            }
        }
        .navigationTitle("Cài đặt")
    }
}

// MARK: - Preview để xem trước
#Preview {
    TabViewExample1()
}
