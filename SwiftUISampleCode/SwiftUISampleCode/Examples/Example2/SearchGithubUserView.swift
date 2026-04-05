import Combine
import SwiftUI

// MARK: - 4. UI: Main View
struct SearchGithubUserView: View {
    // Dùng @StateObject cho View khởi tạo ViewModel
    @StateObject private var viewModel = SearchUserViewModel()

    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Đang tìm kiếm...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else if let errorMessage = viewModel.errorMessage {
                Text("Lỗi: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                ForEach(viewModel.users) { user in
                    SearchUserRow(user: user)
                }
            }
        }
        .navigationTitle("Github Users")
        // Sử dụng SearchBar native của iOS cực kỳ xịn sò và mượt mà
        .searchable(text: $viewModel.searchText, prompt: "Nhập tên user cần tìm...")
    }
}

// MARK: - 5. UI: Row View
struct SearchUserRow: View {
    // Row chỉ cần nhận model User, KHÔNG NÊN truyền cả ViewModel cồng kềnh vào đây
    let user: User

    var body: some View {
        HStack(spacing: 16) {
            // Sử dụng AsyncImage có sẵn từ iOS 15: Tự động tải, tự động cache, không cần code rườm rà
            AsyncImage(url: user.avatarUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 50, height: 50)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                case .failure:
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 50, height: 50)
                @unknown default:
                    EmptyView()
                }
            }

            Text(user.login)
                .font(.system(size: 18, weight: .semibold))

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SearchGithubUserView()
}
