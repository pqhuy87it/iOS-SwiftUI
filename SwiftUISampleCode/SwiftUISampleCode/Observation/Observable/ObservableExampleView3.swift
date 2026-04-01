import SwiftUI
import Observation

// MARK: - 1. CHILD MODEL (Nested Object)
// Lớp con quản lý tiến trình tải xuống
@Observable
class DownloadTask {
    var progress: Double = 0.0
    var isDownloading: Bool = false
    
    func startDownload() {
        isDownloading = true
        progress = 0.0
        
        // Giả lập tiến trình tải xuống chạy liên tục (high-frequency updates)
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.progress < 100 {
                self.progress += 2
            } else {
                self.isDownloading = false
                timer.invalidate()
            }
        }
    }
}

// MARK: - 2. PARENT VIEW MODEL
// Lớp cha chứa thông tin User và chứa luôn Lớp con bên trong
@Observable
class UserProfileViewModel {
    var username: String = "Harley Pham"
    
    // Tự động hỗ trợ Nested Object (Mô hình lồng nhau) mà không cần code phức tạp
    var downloader: DownloadTask = DownloadTask()
}

// MARK: - 3. MAIN VIEW
struct ProfileView: View {
    // Khởi tạo ViewModel cha bằng @State (Chuẩn mới từ iOS 17)
    @State private var viewModel = UserProfileViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            
            // --- HEADER ---
            // Khu vực này chỉ đọc 'username'.
            // KHI PROGRESS THAY ĐỔI, KHU VỰC NÀY SẼ KHÔNG BỊ VẼ LẠI!
            HeaderView1(username: viewModel.username)
            
            Divider()
            
            // --- FOOTER ---
            // Khu vực này đọc 'downloader'. Nó sẽ tự động vẽ lại liên tục khi tải xuống.
            FooterView(downloadTask: viewModel.downloader)
            
        }
        .padding()
    }
}

// MARK: - 4. SUB-VIEWS

struct HeaderView1: View {
    let username: String
    
    var body: some View {
        // Bạn có thể check console: Dòng này chỉ in ra 1 lần duy nhất khi View khởi tạo!
        let _ = print("✅ HeaderView đã render!")
        
        VStack(spacing: 10) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("Xin chào, \(username)!")
                .font(.title)
                .fontWeight(.bold)
        }
    }
}

struct FooterView: View {
    // Không cần @ObservedObject, chỉ cần khai báo biến bình thường!
    var downloadTask: DownloadTask
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tiến trình tải xuống: \(Int(downloadTask.progress))%")
                .font(.headline)
            
            ProgressView(value: downloadTask.progress, total: 100)
                .progressViewStyle(.linear)
                .tint(.green)
            
            Button(action: {
                downloadTask.startDownload()
            }) {
                Text(downloadTask.isDownloading ? "Đang tải..." : "Bắt đầu tải")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(downloadTask.isDownloading ? Color.gray : Color.green)
                    .cornerRadius(10)
            }
            .disabled(downloadTask.isDownloading || downloadTask.progress >= 100)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
}
