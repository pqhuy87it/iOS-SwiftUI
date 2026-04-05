import Foundation
import Combine
import SwiftUI

// (Giả lập thư viện Navajo để code không báo lỗi)
enum PasswordStrength {
    case weak, reasonable, strong, veryStrong
}
struct Navajo {
    static func strength(ofPassword pass: String) -> PasswordStrength { return .strong }
    static func localizedString(forStrength: PasswordStrength) -> String { return "" }
}

// MARK: - VIEW MODEL
class UserViewModelExample1: ObservableObject {
    // Inputs
    @Published var username = ""
    @Published var password = ""
    @Published var passwordAgain = ""
    
    // Outputs
    @Published var usernameMessage = ""
    @Published var passwordMessage = ""
    @Published var isValid = false
    
    enum PasswordCheck {
        case empty, noMatch, notStrongEnough, valid
    }
    
    init() {
        // 1. Luồng Validate Username
        let isUsernameValid = $username
            .debounce(for: 0.5, scheduler: DispatchQueue.main) // Giảm xuống 0.5s cho UX mượt hơn
            .removeDuplicates()
            .map { $0.count >= 3 }
            .share() // Dùng chung kết quả cho form valid bên dưới

        // Xử lý thông báo Username (Ẩn lỗi nếu chưa nhập gì)
        $username
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .map { input in
                if input.isEmpty || input.count >= 3 { return "" }
                return "Username must at least have 3 characters"
            }
            .assign(to: &$usernameMessage) // Thay thế hoàn toàn cancellableSet
        
        // 2. GỘP Luồng Validate Password (Giải quyết Race Condition)
        let passwordValidation = Publishers.CombineLatest($password, $passwordAgain)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .map { (pass, passAgain) -> PasswordCheck in
                if pass.isEmpty { return .empty }
                if pass != passAgain { return .noMatch }
                
                let strength = Navajo.strength(ofPassword: pass)
                switch strength {
                case .reasonable, .strong, .veryStrong:
                    return .valid
                default:
                    return .notStrongEnough
                }
            }
            .share()

        // Xử lý thông báo Password
        passwordValidation
            .map { check -> String in
                switch check {
                case .empty: return "" // Không chửi người dùng khi họ chưa kịp nhập
                case .noMatch: return "Passwords don't match"
                case .notStrongEnough: return "Password not strong enough"
                case .valid: return ""
                }
            }
            .assign(to: &$passwordMessage)

        // 3. Luồng Validate toàn bộ Form
        Publishers.CombineLatest(isUsernameValid, passwordValidation)
            .map { userValid, passCheck in
                return userValid && (passCheck == .valid)
            }
            .assign(to: &$isValid)
    }
}

// MARK: - VIEW
struct Example1View: View {
    // SỬA LỖI: Dùng @StateObject để ViewModel sống xuyên suốt vòng đời của View
    @StateObject private var userViewModel = UserViewModelExample1()
    @State private var presentAlert = false
    
    var body: some View {
        Form {
            Section(footer: Text(userViewModel.usernameMessage).foregroundColor(.red)) {
                TextField("Username", text: $userViewModel.username)
                    .autocapitalization(.none)
            }
            
            Section(footer: Text(userViewModel.passwordMessage).foregroundColor(.red)) {
                SecureField("Password", text: $userViewModel.password)
                SecureField("Password again", text: $userViewModel.passwordAgain)
            }
            
            Section {
                Button("Sign up") {
                    signUp()
                }
                .disabled(!userViewModel.isValid)
            }
        }
        .sheet(isPresented: $presentAlert) {
            WelcomeView()
        }
    }
    
    private func signUp() {
        presentAlert = true
    }
}

struct WelcomeView: View {
    var body: some View {
        Text("Welcome! Great to have you on board!")
            .font(.headline)
    }
}

#Preview {
    Example1View()
}
