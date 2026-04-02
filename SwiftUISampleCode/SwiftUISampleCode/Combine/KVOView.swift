import SwiftUI
import Foundation
import Combine

// MARK: - 1. Định nghĩa Class chứa dữ liệu cần theo dõi
// Bắt buộc kế thừa NSObject
class UserSettings: NSObject {
    // Bắt buộc thêm @objc dynamic trước biến muốn theo dõi
    @objc dynamic var username: String
    @objc dynamic var volumeLevel: Float
    
    init(username: String, volumeLevel: Float) {
        self.username = username
        self.volumeLevel = volumeLevel
        super.init()
    }
}

// MARK: - 2. Class Quản lý và Lắng nghe (Observer)
class SettingsObserver {
    var userSettings: UserSettings
    
    // Túi chứa các "đăng ký" (subscriptions) để không bị huỷ giữa chừng
    private var cancellables = Set<AnyCancellable>()
    
    init(settings: UserSettings) {
        self.userSettings = settings
        setupBindings()
    }
    
    private func setupBindings() {
        // Theo dõi sự thay đổi của biến 'username'
        userSettings.publisher(for: \.username)
            .sink { newName in
                print("👤 [Username Changed]: Tên người dùng mới là '\(newName)'")
            }
            .store(in: &cancellables)
        
        // Theo dõi sự thay đổi của biến 'volumeLevel'
        userSettings.publisher(for: \.volumeLevel)
            .filter { $0 > 0.0 } // Chỉ in ra nếu âm lượng > 0
            .sink { newVolume in
                print("🔊 [Volume Changed]: Âm lượng đang ở mức \(newVolume * 100)%")
            }
            .store(in: &cancellables)
    }
}

// MARK: - 3. Giao diện (SwiftUI View)
struct KVOView: View {
    // Sử dụng @State để đảm bảo observer không bị khởi tạo lại khi View re-render
    @State private var observer = SettingsObserver(settings: UserSettings(username: "Guest", volumeLevel: 0.5))
    
    // Thêm một State nhỏ để thử nghiệm việc View vẽ lại
    @State private var isBlueBackground = true
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Thử nghiệm Combine KVO")
                .font(.title2)
                .fontWeight(.bold)
            
            Button("Bấm để thay đổi dữ liệu KVO") {
                print("\n--- Bắt đầu thay đổi dữ liệu ---\n")
                
                // Thay đổi dữ liệu - Combine sẽ tự động bắt được và in ra log console
                observer.userSettings.username = "HuyPham"
                observer.userSettings.volumeLevel = 0.8
                observer.userSettings.volumeLevel = 0.0 // Sẽ không in ra vì bị filter chặn
                observer.userSettings.username = "Admin"
                observer.userSettings.volumeLevel = 1.0
                
                // Đổi màu nền
                isBlueBackground.toggle()
            }
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(10)
            .shadow(radius: 2)
            
            Divider()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isBlueBackground ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
        .animation(.easeInOut, value: isBlueBackground)
    }
}

#Preview {
    KVOView()
}
