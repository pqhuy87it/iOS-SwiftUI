import SwiftUI

struct SettingsView: View {
    @State private var airplaneMode = false
    @State private var searchText = ""
    
    var body: some View {
        List {
            // MARK: - Section 1: Hồ sơ người dùng
            Section {
                NavigationLink(destination: Text("Profile Detail")) {
                    HStack(spacing: 15) {
                        // Avatar giả lập
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Huy Pham Quang")
                                .font(.title2)
                                .fontWeight(.medium)
                            Text("Apple Account, iCloud, and more")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                NavigationLink(destination: Text("Services")) {
                    HStack {
                        Text("Services Included with Purchase")
                        Spacer()
                        Text("2")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                }
            }
            
            // MARK: - Section 2: Kết nối & Pin
            Section {
                // Dòng này đặc biệt vì dùng Toggle thay vì NavigationLink
                HStack {
                    IconView(icon: "airplane", color: .orange)
                    Toggle("Airplane Mode", isOn: $airplaneMode)
                }
                
                SettingsRow(icon: "wifi", color: .blue, title: "Wi-Fi", trailingText: "MyHome1stFloor_5G")
                SettingsRow(icon: "bluetooth", color: .blue, title: "Bluetooth", trailingText: "On")
                SettingsRow(icon: "antenna.radiowaves.left.and.right", color: .green, title: "Cellular")
                SettingsRow(icon: "personalhotspot", color: .green, title: "Personal Hotspot", trailingText: "Off")
                SettingsRow(icon: "battery.100", color: .green, title: "Battery")
            }
            
            // MARK: - Section 3: Cài đặt chung
            Section {
                SettingsRow(icon: "gear", color: .gray, title: "General")
                SettingsRow(icon: "accessibility", color: .blue, title: "Accessibility")
                SettingsRow(icon: "camera.fill", color: .gray, title: "Camera")
            }
            
            // MARK: - Section 4: Âm thanh & Tập trung
            Section {
                SettingsRow(icon: "speaker.wave.3.fill", color: .pink, title: "Sounds & Haptics")
                SettingsRow(icon: "moon.fill", color: .indigo, title: "Focus")
                SettingsRow(icon: "hourglass", color: .indigo, title: "Screen Time")
            }
            
            // MARK: - Section 5: Bảo mật
            Section {
                SettingsRow(icon: "faceid", color: .green, title: "Face ID & Passcode")
                SettingsRow(icon: "sos", color: .red, title: "Emergency SOS")
                SettingsRow(icon: "hand.raised.fill", color: .blue, title: "Privacy & Security")
            }
            
            // MARK: - Section 6: Dịch vụ
            Section {
                // Mặc định Game Center icon có nhiều màu, ở đây dùng màu có sẵn cho gọn
                SettingsRow(icon: "gamecontroller.fill", color: .blue, title: "Game Center")
                SettingsRow(icon: "cloud.fill", color: .blue, title: "iCloud")
                SettingsRow(icon: "creditcard.fill", color: .black, title: "Wallet & Apple Pay")
            }
            
            // MARK: - Section 7: Ứng dụng & Nhà phát triển
            Section {
                SettingsRow(icon: "square.grid.3x3.fill", color: .purple, title: "Apps")
            }
            
            Section {
                SettingsRow(icon: "hammer.fill", color: .gray, title: "Developer")
            }
        }
        .navigationTitle("Settings")
        .listStyle(.insetGrouped)
        
        // MARK: - Thanh Search nổi ở dưới cùng (Floating Search Bar)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 18))
                
                Text("Search")
                    .foregroundColor(.gray)
                    .font(.system(size: 17))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGroupedBackground)) // Nền sáng nhẹ
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Component hỗ trợ vẽ Icon
struct IconView: View {
    var icon: String
    var color: Color
    
    var body: some View {
        ZStack {
            color
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .semibold))
        }
        .frame(width: 28, height: 28)
        .cornerRadius(6)
    }
}

// MARK: - Component hỗ trợ vẽ từng hàng (Row) trong Settings
struct SettingsRow: View {
    var icon: String
    var color: Color
    var title: String
    var trailingText: String? = nil
    
    var body: some View {
        NavigationLink(destination: Text("\(title) Settings")) {
            HStack {
                IconView(icon: icon, color: color)
                
                Text(title)
                
                Spacer()
                
                // Hiển thị text mờ ở đuôi nếu có (ví dụ: "On", "Off", tên Wifi)
                if let trailingText = trailingText {
                    Text(trailingText)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
