import SwiftUI
import Combine

// MARK: - 1. VIEW MODEL (Xử lý Asynchronous Code bằng Combine)
class LoginViewModel: ObservableObject {
    
    // NGUỒN PHÁT (Publishers): Dữ liệu nhập từ người dùng
    @Published var username = ""
    @Published var password = ""
    
    // KẾT QUẢ ĐẦU RA: Giao diện sẽ lắng nghe các biến này
    @Published var isSubmitEnabled = false
    @Published var statusMessage = ""
    @Published var isLoading = false
    
    // Túi chứa các luồng Combine, giúp giải phóng bộ nhớ tự động khi ViewModel bị huỷ
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupFormValidation()
    }
    
    // MARK: Sử dụng Combine để gộp luồng dữ liệu
    private func setupFormValidation() {
        // Publishers.CombineLatest lấy giá trị MỚI NHẤT từ cả 2 ô nhập liệu
        Publishers.CombineLatest($username, $password)
            // Toán tử map: Biến đổi 2 chuỗi thành 1 kết quả Bool (Hợp lệ hay không)
            .map { user, pass in
                return user.count >= 4 && pass.count >= 6
            }
            // Gán thẳng kết quả Bool đó vào biến isSubmitEnabled để UI tự động cập nhật
            .assign(to: &$isSubmitEnabled)
    }
    
    // MARK: Giả lập tác vụ gọi mạng bất đồng bộ (Network Request)
    func performLogin() {
        isLoading = true
        statusMessage = "Đang kết nối server..."
        
        // Dùng 'Just' để tạo một Publisher phát ra 1 giá trị duy nhất
        // Dùng 'delay' để giả lập thời gian chờ API (2 giây)
        Just("🎉 Đăng nhập thành công!\nChào mừng \(username).")
            .delay(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] message in
                // Khối lệnh này chạy khi nhận được dữ liệu trả về
                self?.isLoading = false
                self?.statusMessage = message
            }
            .store(in: &cancellables)
    }
}

// MARK: - 2. VIEW (Giao diện hiển thị)
struct CombineAsyncView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Combine Form Validation")
                .font(.title2)
                .fontWeight(.bold)
            
            // Form nhập liệu
            VStack(spacing: 15) {
                TextField("Tên đăng nhập (Tối thiểu 4 ký tự)", text: $viewModel.username)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                
                SecureField("Mật khẩu (Tối thiểu 6 ký tự)", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)
            
            // Nút Đăng nhập
            Button(action: {
                viewModel.performLogin()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Đăng nhập")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            // Combine quyết định việc nút này bị mờ hay sáng (Disabled/Enabled)
            .background(viewModel.isSubmitEnabled ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(!viewModel.isSubmitEnabled || viewModel.isLoading)
            
            // Lời nhắn kết quả
            if !viewModel.statusMessage.isEmpty {
                Text(viewModel.statusMessage)
                    .foregroundColor(viewModel.isLoading ? .gray : .green)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
            
            Spacer()
        }
        .padding(.top, 30)
        .navigationTitle("Asynchronous App")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - PREVIEW
#Preview {
    CombineAsyncView()
}
