```Swift
// ============================================================
// ALERT TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// Alert hiển thị dialog popup yêu cầu user xác nhận hoặc
// thông báo thông tin quan trọng.
//
// SwiftUI có 2 API thế hệ:
// - Legacy: Alert struct (iOS 13, DEPRECATED từ iOS 15)
// - Modern: .alert() modifier (iOS 15+, KHUYẾN KHÍCH)
//
// Liên quan:
// - ConfirmationDialog: action sheet thay thế (iOS 15+)
// - .sheet / .fullScreenCover: modal phức tạp hơn
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. MODERN ALERT — .alert() MODIFIER (iOS 15+)          ║
// ╚══════════════════════════════════════════════════════════╝

struct BasicAlertDemo: View {
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            // === 1a. Đơn giản nhất: title + dismiss ===
            Button("Alert đơn giản") {
                showAlert = true
            }
            .alert("Thông báo", isPresented: $showAlert) {
                // Không khai báo button → SwiftUI tự thêm "OK"
            }
            // Kết quả: Alert với title "Thông báo" + nút OK
            
            // isPresented = $showAlert:
            // - true → hiện alert
            // - User tap button → SwiftUI TỰ ĐỘNG set false
        }
    }
}

struct AlertWithMessageDemo: View {
    @State private var showAlert = false
    
    var body: some View {
        Button("Alert với message") {
            showAlert = true
        }
        // === 1b. Title + Message + Buttons ===
        .alert("Xác nhận xoá", isPresented: $showAlert) {
            // ACTIONS: các buttons trong alert
            Button("Huỷ", role: .cancel) {
                // Không làm gì — chỉ đóng alert
            }
            Button("Xoá", role: .destructive) {
                deleteItem()
            }
        } message: {
            // MESSAGE: mô tả chi tiết phía dưới title
            Text("Bạn có chắc muốn xoá? Hành động này không thể hoàn tác.")
        }
    }
    
    func deleteItem() { print("Deleted!") }
}

// .alert() ANATOMY:
//
// .alert(
//     "Title",                    ← Tiêu đề (String hoặc LocalizedStringKey)
//     isPresented: $bool,         ← Binding điều khiển hiện/ẩn
//     actions: { ... },           ← ViewBuilder: các Button
//     message: { ... }            ← ViewBuilder: Text mô tả (optional)
// )
//
// BUTTON RULES:
// - Button(role: .cancel)       → Luôn nằm BÊN TRÁI, font regular
// - Button(role: .destructive)  → Font đỏ, bold
// - Button() không role          → Font xanh, bold
// - Không khai báo button nào   → SwiftUI tự thêm "OK"
// - iOS TỰ ĐỘNG sắp xếp vị trí buttons theo HIG


// ╔══════════════════════════════════════════════════════════╗
// ║  2. ALERT VỚI NHIỀU BUTTONS                              ║
// ╚══════════════════════════════════════════════════════════╝

struct MultiButtonAlertDemo: View {
    @State private var showSaveAlert = false
    @State private var showChoiceAlert = false
    @State private var result = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Kết quả: \(result)").font(.headline)
            
            // === 2a. 2 buttons: Cancel + Action ===
            Button("Lưu thay đổi?") { showSaveAlert = true }
            .alert("Lưu thay đổi?", isPresented: $showSaveAlert) {
                Button("Không lưu", role: .destructive) {
                    result = "Không lưu"
                }
                Button("Lưu") {
                    result = "Đã lưu"
                }
                Button("Huỷ", role: .cancel) {
                    result = "Huỷ"
                }
            } message: {
                Text("Bạn có thay đổi chưa được lưu.")
            }
            // Kết quả: 3 buttons
            // [Không lưu (đỏ)] [Huỷ] [Lưu (xanh, bold)]
            
            // === 2b. Nhiều actions ===
            Button("Báo cáo bài viết") { showChoiceAlert = true }
            .alert("Báo cáo", isPresented: $showChoiceAlert) {
                Button("Spam") { result = "Reported: Spam" }
                Button("Nội dung xấu") { result = "Reported: Bad content" }
                Button("Sai thông tin") { result = "Reported: Misinformation" }
                Button("Huỷ", role: .cancel) { }
            } message: {
                Text("Chọn lý do báo cáo")
            }
            // ⚠️ Nhiều buttons → iOS tự chuyển thành dạng DANH SÁCH
            // (giống ActionSheet trên iPhone)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3. ALERT VỚI TEXTFIELD — NHẬP LIỆU (iOS 16+)          ║
// ╚══════════════════════════════════════════════════════════╝

struct TextFieldAlertDemo: View {
    @State private var showRename = false
    @State private var showLogin = false
    @State private var newName = ""
    @State private var username = ""
    @State private var password = ""
    @State private var displayName = "My Project"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Project: \(displayName)")
                .font(.headline)
            
            // === 3a. Single TextField ===
            Button("Đổi tên") {
                newName = displayName // Pre-fill giá trị hiện tại
                showRename = true
            }
            .alert("Đổi tên project", isPresented: $showRename) {
                // TextField TRONG alert actions
                TextField("Tên mới", text: $newName)
                    .autocorrectionDisabled()
                
                Button("Huỷ", role: .cancel) {
                    newName = "" // Reset
                }
                Button("Lưu") {
                    if !newName.isEmpty {
                        displayName = newName
                    }
                }
            } message: {
                Text("Nhập tên mới cho project")
            }
            
            // === 3b. Multiple TextFields (Login) ===
            Button("Đăng nhập") { showLogin = true }
            .alert("Đăng nhập", isPresented: $showLogin) {
                TextField("Username", text: $username)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                
                Button("Huỷ", role: .cancel) { }
                Button("Đăng nhập") {
                    login(username: username, password: password)
                }
            } message: {
                Text("Nhập thông tin tài khoản")
            }
        }
    }
    
    func login(username: String, password: String) {
        print("Login: \(username)")
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. ALERT VỚI DATA — PRESENTING ITEM                    ║
// ╚══════════════════════════════════════════════════════════╝

// Thay vì Bool, dùng Optional item → alert hiện khi item != nil
// Item tự động truyền vào actions/message closures.

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let type: AlertType
    
    enum AlertType {
        case info, warning, error
        
        var icon: String {
            switch self {
            case .info: return "info.circle"
            case .warning: return "exclamationmark.triangle"
            case .error: return "xmark.octagon"
            }
        }
    }
}

struct DataAlertDemo: View {
    @State private var activeAlert: AlertItem?
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Info") {
                activeAlert = AlertItem(
                    title: "Thông tin",
                    message: "Phiên bản mới đã sẵn sàng.",
                    type: .info
                )
            }
            
            Button("Warning") {
                activeAlert = AlertItem(
                    title: "Cảnh báo",
                    message: "Dung lượng lưu trữ sắp đầy.",
                    type: .warning
                )
            }
            
            Button("Error") {
                activeAlert = AlertItem(
                    title: "Lỗi",
                    message: "Không thể kết nối máy chủ.",
                    type: .error
                )
            }
        }
        // === presenting: Optional item ===
        .alert(
            item: $activeAlert      // Hiện khi != nil, đóng → set nil
        ) { item in                 // item: AlertItem (unwrapped)
            // Actions
            if item.type == .error {
                Button("Thử lại") { retryConnection() }
                Button("Huỷ", role: .cancel) { }
            } else {
                Button("OK") { }
            }
        } message: { item in
            Text(item.message)
        }
        // ⚠️ Syntax hơi khác: dùng .alert(item:) thay vì .alert(isPresented:)
    }
    
    func retryConnection() { }
}

// === presenting + Identifiable (cách 2) ===
struct PresentingAlertDemo: View {
    struct UserAction: Identifiable {
        let id = UUID()
        let name: String
    }
    
    @State private var actionToConfirm: UserAction?
    
    var body: some View {
        VStack(spacing: 12) {
            Button("Delete User A") {
                actionToConfirm = UserAction(name: "User A")
            }
            Button("Delete User B") {
                actionToConfirm = UserAction(name: "User B")
            }
        }
        .alert(
            "Xoá \(actionToConfirm?.name ?? "")?",
            isPresented: Binding(
                get: { actionToConfirm != nil },
                set: { if !$0 { actionToConfirm = nil } }
            ),
            presenting: actionToConfirm
        ) { action in
            Button("Xoá \(action.name)", role: .destructive) {
                deleteUser(action.name)
            }
            Button("Huỷ", role: .cancel) { }
        } message: { action in
            Text("Xoá \(action.name) và tất cả dữ liệu liên quan?")
        }
    }
    
    func deleteUser(_ name: String) { print("Deleted \(name)") }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. ERROR HANDLING — ALERT TỪ Error                      ║
// ╚══════════════════════════════════════════════════════════╝

// === 5a. LocalizedError protocol ===

enum AppError: LocalizedError {
    case networkError
    case authError(String)
    case serverError(code: Int)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Lỗi kết nối"
        case .authError(let reason):
            return "Xác thực thất bại: \(reason)"
        case .serverError(let code):
            return "Lỗi máy chủ (\(code))"
        case .unknownError:
            return "Lỗi không xác định"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Kiểm tra kết nối Internet và thử lại."
        case .authError:
            return "Vui lòng đăng nhập lại."
        case .serverError:
            return "Vui lòng thử lại sau."
        case .unknownError:
            return "Liên hệ hỗ trợ nếu lỗi tiếp tục."
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkError, .serverError: return true
        case .authError, .unknownError: return false
        }
    }
}

struct ErrorAlertDemo: View {
    @State private var currentError: AppError?
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 12) {
            Button("Network Error") {
                handleError(.networkError)
            }
            Button("Auth Error") {
                handleError(.authError("Token expired"))
            }
            Button("Server Error") {
                handleError(.serverError(code: 500))
            }
        }
        // === .alert(isPresented:error:) — iOS 15+ ===
        // Tự dùng errorDescription làm title
        // Tự dùng recoverySuggestion làm message
        .alert(isPresented: $showError, error: currentError) { error in
            if error.isRetryable {
                Button("Thử lại") { retry() }
                Button("Huỷ", role: .cancel) { }
            } else {
                Button("OK") { }
            }
        } message: { error in
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
            }
        }
    }
    
    func handleError(_ error: AppError) {
        currentError = error
        showError = true
    }
    
    func retry() { print("Retrying...") }
}


// === 5b. Generic Error Alert với async/await ===

@Observable
final class AsyncViewModel {
    var data: [String] = []
    var error: AppError?
    var showError = false
    
    func loadData() async {
        do {
            // Simulate network call
            try await Task.sleep(for: .seconds(1))
            
            if Bool.random() {
                throw AppError.networkError
            }
            
            data = (1...10).map { "Item \($0)" }
        } catch let error as AppError {
            self.error = error
            self.showError = true
        } catch {
            self.error = .unknownError
            self.showError = true
        }
    }
}

struct AsyncErrorDemo: View {
    @State private var vm = AsyncViewModel()
    
    var body: some View {
        List(vm.data, id: \.self) { item in
            Text(item)
        }
        .task { await vm.loadData() }
        .refreshable { await vm.loadData() }
        .alert(isPresented: $vm.showError, error: vm.error) { error in
            if error.isRetryable {
                Button("Thử lại") {
                    Task { await vm.loadData() }
                }
            }
            Button("OK", role: .cancel) { }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. CONFIRMATIONDIALOG — ACTION SHEET (iOS 15+)          ║
// ╚══════════════════════════════════════════════════════════╝

// ConfirmationDialog = replacement cho ActionSheet.
// iPhone: slide up từ dưới (action sheet style)
// iPad: popover tại vị trí trigger
// macOS: alert dialog

struct ConfirmationDialogDemo: View {
    @State private var showShareDialog = false
    @State private var showDeleteDialog = false
    @State private var showSortDialog = false
    @State private var sortOrder = "Mới nhất"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sắp xếp: \(sortOrder)").font(.headline)
            
            // === 6a. Basic dialog ===
            Button("Chia sẻ") { showShareDialog = true }
            .confirmationDialog("Chia sẻ qua", isPresented: $showShareDialog) {
                Button("Messages") { }
                Button("Email") { }
                Button("Copy Link") { }
                Button("Huỷ", role: .cancel) { }
            }
            
            // === 6b. Destructive action ===
            Button("Xoá bài viết", role: .destructive) {
                showDeleteDialog = true
            }
            .confirmationDialog(
                "Xoá bài viết?",
                isPresented: $showDeleteDialog,
                titleVisibility: .visible  // Hiện title (mặc định ẩn trên iPhone)
            ) {
                Button("Xoá", role: .destructive) { }
                Button("Huỷ", role: .cancel) { }
            } message: {
                Text("Bài viết sẽ bị xoá vĩnh viễn.")
            }
            
            // === 6c. Selection dialog ===
            Button("Sắp xếp") { showSortDialog = true }
            .confirmationDialog("Sắp xếp theo", isPresented: $showSortDialog) {
                Button("Mới nhất") { sortOrder = "Mới nhất" }
                Button("Cũ nhất") { sortOrder = "Cũ nhất" }
                Button("Phổ biến") { sortOrder = "Phổ biến" }
                Button("A → Z") { sortOrder = "A → Z" }
                Button("Huỷ", role: .cancel) { }
            }
        }
    }
}

// ALERT vs CONFIRMATIONDIALOG:
// ┌──────────────────────┬─────────────────┬──────────────────┐
// │                      │ Alert           │ ConfirmationDialog│
// ├──────────────────────┼─────────────────┼──────────────────┤
// │ Vị trí               │ Giữa màn hình  │ Dưới (iPhone)    │
// │ Số buttons lý tưởng  │ 2-3             │ 2-8+             │
// │ TextField support    │ ✅ (iOS 16+)   │ ❌               │
// │ Destructive actions  │ ✅              │ ✅ (phổ biến hơn)│
// │ Title visibility     │ Luôn hiện       │ Mặc định ẩn      │
// │ iPad behavior        │ Center modal    │ Popover           │
// │ Dùng cho             │ Thông báo quan  │ Chọn hành động,  │
// │                      │ trọng, confirm  │ options list      │
// └──────────────────────┴─────────────────┴──────────────────┘
//
// 📌 NGUYÊN TẮC:
// Thông báo / xác nhận đơn giản → Alert
// Chọn từ nhiều options / destructive confirm → ConfirmationDialog


// ╔══════════════════════════════════════════════════════════╗
// ║  7. NHIỀU ALERTS TRÊN CÙNG 1 VIEW                        ║
// ╚══════════════════════════════════════════════════════════╝

// ⚠️ PITFALL LỚN: Nhiều .alert() trên cùng 1 view có thể conflict.
// Chỉ 1 alert hiện tại 1 thời điểm.

struct MultipleAlertsDemo: View {
    @State private var showSave = false
    @State private var showDelete = false
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 16) {
            // === 7a. Cách 1: Nhiều .alert() modifiers ===
            // ✅ Hoạt động từ iOS 15+ (mỗi modifier độc lập)
            Button("Save") { showSave = true }
            Button("Delete") { showDelete = true }
            Button("Error") { showError = true }
        }
        .alert("Lưu?", isPresented: $showSave) {
            Button("Lưu") { }
            Button("Huỷ", role: .cancel) { }
        }
        .alert("Xoá?", isPresented: $showDelete) {
            Button("Xoá", role: .destructive) { }
            Button("Huỷ", role: .cancel) { }
        }
        .alert("Lỗi!", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text("Đã xảy ra lỗi")
        }
    }
}

// === 7b. Cách 2: Enum-based (Clean hơn, 1 .alert()) ===

enum ActiveAlert: Identifiable {
    case save
    case delete(itemName: String)
    case error(message: String)
    case success(message: String)
    
    var id: String {
        switch self {
        case .save: return "save"
        case .delete: return "delete"
        case .error: return "error"
        case .success: return "success"
        }
    }
    
    var title: String {
        switch self {
        case .save: return "Lưu thay đổi?"
        case .delete(let name): return "Xoá \(name)?"
        case .error: return "Lỗi"
        case .success: return "Thành công"
        }
    }
}

struct EnumAlertDemo: View {
    @State private var activeAlert: ActiveAlert?
    
    var body: some View {
        VStack(spacing: 12) {
            Button("Save") { activeAlert = .save }
            Button("Delete") { activeAlert = .delete(itemName: "Project X") }
            Button("Error") { activeAlert = .error(message: "Mất kết nối") }
            Button("Success") { activeAlert = .success(message: "Đã lưu thành công!") }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .save:
                Button("Lưu") { }
                Button("Không lưu", role: .destructive) { }
                Button("Huỷ", role: .cancel) { }
                
            case .delete:
                Button("Xoá", role: .destructive) { }
                Button("Huỷ", role: .cancel) { }
                
            case .error:
                Button("Thử lại") { }
                Button("OK", role: .cancel) { }
                
            case .success:
                Button("OK") { }
            }
        } message: { alert in
            switch alert {
            case .save:
                Text("Bạn có thay đổi chưa lưu.")
            case .delete(let name):
                Text("Xoá \(name) vĩnh viễn?")
            case .error(let msg):
                Text(msg)
            case .success(let msg):
                Text(msg)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. LEGACY ALERT — Alert STRUCT (iOS 13-14, DEPRECATED)  ║
// ╚══════════════════════════════════════════════════════════╝

// ⚠️ DEPRECATED từ iOS 15. Chỉ dùng nếu min deployment < iOS 15.

struct LegacyAlertDemo: View {
    @State private var showAlert = false
    
    var body: some View {
        Button("Legacy Alert") { showAlert = true }
        .alert(isPresented: $showAlert) {
            // Alert struct (old API)
            Alert(
                title: Text("Tiêu đề"),
                message: Text("Nội dung chi tiết"),
                primaryButton: .destructive(Text("Xoá")) {
                    // Action
                },
                secondaryButton: .cancel(Text("Huỷ"))
            )
            
            // Hoặc đơn giản:
            // Alert(
            //     title: Text("Thông báo"),
            //     message: Text("Nội dung"),
            //     dismissButton: .default(Text("OK"))
            // )
        }
    }
}

// MIGRATION: Legacy → Modern
//
// ❌ OLD:
// .alert(isPresented: $show) {
//     Alert(title: Text("Title"),
//           message: Text("Message"),
//           primaryButton: .destructive(Text("Delete")) { },
//           secondaryButton: .cancel())
// }
//
// ✅ NEW:
// .alert("Title", isPresented: $show) {
//     Button("Delete", role: .destructive) { }
//     Button("Cancel", role: .cancel) { }
// } message: {
//     Text("Message")
// }


// ╔══════════════════════════════════════════════════════════╗
// ║  9. PRODUCTION PATTERNS                                   ║
// ╚══════════════════════════════════════════════════════════╝

// === 9a. Delete Confirmation Pattern ===

struct DeleteConfirmation<Item: Identifiable>: ViewModifier {
    @Binding var itemToDelete: Item?
    let itemName: (Item) -> String
    let onDelete: (Item) -> Void
    
    func body(content: Content) -> some View {
        content.alert(
            "Xoá \(itemToDelete.map(itemName) ?? "")?",
            isPresented: Binding(
                get: { itemToDelete != nil },
                set: { if !$0 { itemToDelete = nil } }
            )
        ) {
            if let item = itemToDelete {
                Button("Xoá", role: .destructive) {
                    onDelete(item)
                    itemToDelete = nil
                }
            }
            Button("Huỷ", role: .cancel) {
                itemToDelete = nil
            }
        } message: {
            Text("Hành động này không thể hoàn tác.")
        }
    }
}

extension View {
    func deleteConfirmation<Item: Identifiable>(
        item: Binding<Item?>,
        itemName: @escaping (Item) -> String,
        onDelete: @escaping (Item) -> Void
    ) -> some View {
        modifier(DeleteConfirmation(
            itemToDelete: item,
            itemName: itemName,
            onDelete: onDelete
        ))
    }
}

// Sử dụng:
struct DeletePatternDemo: View {
    struct Project: Identifiable {
        let id = UUID()
        let name: String
    }
    
    @State private var projects = [
        Project(name: "iOS App"),
        Project(name: "Backend API"),
        Project(name: "Design System"),
    ]
    @State private var projectToDelete: Project?
    
    var body: some View {
        List {
            ForEach(projects) { project in
                Text(project.name)
                    .swipeActions {
                        Button("Xoá", role: .destructive) {
                            projectToDelete = project
                        }
                    }
            }
        }
        // 1 dòng modifier → reusable cho MỌI entity
        .deleteConfirmation(
            item: $projectToDelete,
            itemName: { $0.name },
            onDelete: { item in
                projects.removeAll { $0.id == item.id }
            }
        )
    }
}


// === 9b. Unsaved Changes Alert ===

struct UnsavedChangesAlert: ViewModifier {
    @Binding var hasChanges: Bool
    @Binding var showAlert: Bool
    let onDiscard: () -> Void
    let onSave: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Thay đổi chưa lưu", isPresented: $showAlert) {
                Button("Không lưu", role: .destructive) {
                    onDiscard()
                }
                Button("Lưu") {
                    onSave()
                }
                Button("Tiếp tục chỉnh sửa", role: .cancel) { }
            } message: {
                Text("Bạn có thay đổi chưa được lưu. Bạn muốn lưu trước khi rời đi?")
            }
            // Chặn dismiss khi có changes
            .interactiveDismissDisabled(hasChanges)
    }
}


// === 9c. Network Error with Retry Pattern ===

struct NetworkErrorAlert: ViewModifier {
    @Binding var error: Error?
    let retryAction: () async -> Void
    
    var isPresented: Binding<Bool> {
        Binding(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )
    }
    
    func body(content: Content) -> some View {
        content.alert(
            "Lỗi kết nối",
            isPresented: isPresented
        ) {
            Button("Thử lại") {
                Task { await retryAction() }
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text(error?.localizedDescription ?? "Đã xảy ra lỗi.")
        }
    }
}

extension View {
    func networkErrorAlert(
        error: Binding<Error?>,
        retry: @escaping () async -> Void
    ) -> some View {
        modifier(NetworkErrorAlert(error: error, retryAction: retry))
    }
}


// === 9d. Destructive Action with Timer (Auto-dismiss) ===

struct TimedAlertDemo: View {
    @State private var showUndo = false
    @State private var undoCountdown = 5
    @State private var deletedItem: String?
    
    var body: some View {
        VStack {
            Button("Delete Item") {
                deletedItem = "Important File"
                showUndo = true
                startCountdown()
            }
        }
        .alert(
            "Đã xoá",
            isPresented: $showUndo
        ) {
            Button("Hoàn tác (\(undoCountdown)s)") {
                undoDelete()
            }
            Button("OK", role: .cancel) {
                confirmDelete()
            }
        } message: {
            Text("\"\(deletedItem ?? "")\" đã được xoá.")
        }
    }
    
    func startCountdown() {
        undoCountdown = 5
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            undoCountdown -= 1
            if undoCountdown <= 0 {
                timer.invalidate()
                showUndo = false
                confirmDelete()
            }
        }
    }
    
    func undoDelete() {
        deletedItem = nil
        print("Undo!")
    }
    
    func confirmDelete() {
        print("Permanently deleted: \(deletedItem ?? "")")
        deletedItem = nil
    }
}


// === 9e. Settings-style Alert (with ConfirmationDialog) ===

struct SettingsAlertDemo: View {
    @State private var showLogout = false
    @State private var showDeleteAccount = false
    @State private var deleteConfirmText = ""
    
    var body: some View {
        Form {
            Section {
                // Logout: ConfirmationDialog (options)
                Button("Đăng xuất") { showLogout = true }
                    .foregroundStyle(.red)
                
                // Delete Account: Alert (cần nhập xác nhận)
                Button("Xoá tài khoản", role: .destructive) {
                    showDeleteAccount = true
                }
            }
        }
        .confirmationDialog(
            "Đăng xuất?",
            isPresented: $showLogout,
            titleVisibility: .visible
        ) {
            Button("Đăng xuất", role: .destructive) { }
            Button("Đăng xuất tất cả thiết bị", role: .destructive) { }
            Button("Huỷ", role: .cancel) { }
        } message: {
            Text("Bạn sẽ cần đăng nhập lại.")
        }
        .alert("Xoá tài khoản", isPresented: $showDeleteAccount) {
            TextField("Nhập DELETE để xác nhận", text: $deleteConfirmText)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            Button("Xoá vĩnh viễn", role: .destructive) {
                // Check confirmation text
            }
            .disabled(deleteConfirmText != "DELETE")
            
            Button("Huỷ", role: .cancel) {
                deleteConfirmText = ""
            }
        } message: {
            Text("Hành động này sẽ xoá tất cả dữ liệu. Nhập \"DELETE\" để xác nhận.")
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. ACCESSIBILITY                                       ║
// ╚══════════════════════════════════════════════════════════╝

// Alert tự động accessible:
// - VoiceOver đọc title → message → buttons
// - Focus tự chuyển vào alert khi hiện
// - Escape gesture (2-finger scrub) = Cancel button
// - Button roles tự announce: "destructive", "cancel"
//
// ⚠️ LƯU Ý:
// - Title ngắn gọn, rõ ràng (VoiceOver đọc đầu tiên)
// - Message mô tả đủ context (VoiceOver đọc tiếp)
// - Button text phải là VERB: "Xoá", "Lưu", "Gửi"
//   (KHÔNG: "Yes", "No" — không rõ ý nghĩa khi nghe)


// ╔══════════════════════════════════════════════════════════╗
// ║  11. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Alert không hiện
//    .alert("Title", isPresented: .constant(true)) { ... }
//    → .constant KHÔNG thay đổi → alert hiện rồi KHÔNG đóng được
//    → Hoặc: set isPresented = true TRƯỚC khi view appear
//    ✅ FIX: Dùng @State, set true trong Button action

// ❌ PITFALL 2: Nhiều .alert() conflict (iOS 13-14)
//    View().alert(...).alert(...) → Chỉ alert CUỐI hoạt động
//    ✅ FIX: iOS 15+: hoạt động đúng (mỗi modifier độc lập)
//            iOS 13-14: dùng enum single alert pattern

// ❌ PITFALL 3: Button action chạy TRƯỚC alert dismiss
//    .alert { Button("OK") { heavyWork() } }
//    → heavyWork() chạy ngay, có thể trigger state change khi alert chưa dismiss
//    ✅ FIX: DispatchQueue.main.async { heavyWork() }
//            Hoặc Task { await heavyWork() }

// ❌ PITFALL 4: Alert trong Sheet/FullScreenCover
//    .sheet { ContentView().alert(...) }
//    → Alert phải gắn trên view TRONG sheet, không phải ngoài
//    ✅ FIX: .alert() đặt trên view hiện tại (trong sheet)

// ❌ PITFALL 5: ConfirmationDialog title ẩn trên iPhone
//    .confirmationDialog("Title", isPresented: $show) { ... }
//    → Title MẶC ĐỊNH ẨN trên iPhone
//    ✅ FIX: titleVisibility: .visible nếu cần hiện

// ❌ PITFALL 6: TextField trong alert không nhận focus iOS 16 bugs
//    .alert { TextField(...) } → keyboard có thể không hiện
//    ✅ FIX: Đây là known bug một số iOS versions
//            Workaround: dùng Sheet thay Alert cho complex input

// ✅ BEST PRACTICES:
// 1. Modern .alert() modifier thay Alert struct (iOS 15+)
// 2. role: .destructive cho actions nguy hiểm (auto đỏ)
// 3. role: .cancel cho dismiss (auto vị trí + font chuẩn)
// 4. Enum-based alert cho nhiều loại alerts (clean, type-safe)
// 5. LocalizedError cho error alerts (tự map title + message)
// 6. .confirmationDialog cho chọn options (> 2 actions)
// 7. .alert cho confirm/inform (≤ 3 actions + optional TextField)
// 8. Button text = VERBS: "Xoá", "Lưu" (KHÔNG: "Yes", "No")
// 9. ViewModifier cho reusable patterns (deleteConfirmation)
// 10. presenting: item khi alert cần data context
// 11. .interactiveDismissDisabled cho unsaved changes
// 12. Test VoiceOver: title → message → buttons phải đủ rõ
```

---

Alert đã thay đổi khá nhiều qua các phiên bản iOS — từ Alert struct cũ sang `.alert` modifier mới. Mình sẽ giải thích toàn bộ bao gồm cả ConfirmationDialog và các error handling patterns.Mình đã tổng hợp toàn bộ kiến thức Alert trong 11 phần. Đây là những điểm cốt lõi:

**Alert API đã thay đổi hoàn toàn** từ iOS 15: Legacy `Alert` struct → Modern `.alert()` modifier. API mới clean hơn, hỗ trợ TextField, multiple alerts trên cùng view, và tích hợp error handling. Nếu min deployment iOS 15+ thì **luôn dùng API mới**.

**Năm phần giá trị nhất cho production:**

**Phần 3 — Alert với TextField (iOS 16+)**: Cho phép nhập liệu trực tiếp trong alert — rename, login, OTP confirm. Kết hợp `TextField` + `SecureField` trong `actions` closure. Lưu ý pre-fill giá trị hiện tại trước khi show alert.

**Phần 5 — Error Handling**: Pattern `LocalizedError` protocol + `.alert(isPresented:error:)` là cách chuẩn nhất. Define `errorDescription` → tự thành alert title, `recoverySuggestion` → tự thành message. Kết hợp computed property `isRetryable` để quyết định hiện "Thử lại" hay chỉ "OK".

**Phần 6 — Alert vs ConfirmationDialog**: Bảng so sánh quan trọng — Alert cho thông báo/xác nhận (2-3 buttons, giữa màn hình), ConfirmationDialog cho chọn options (nhiều buttons, slide từ dưới lên). Gotcha: ConfirmationDialog **title mặc định ẨN** trên iPhone, phải thêm `titleVisibility: .visible`.

**Phần 7b — Enum-based Alert**: Pattern `ActiveAlert` enum + single `.alert(item:)` thay vì nhiều `.alert()` modifiers. Mỗi case mang data riêng (`.delete(itemName:)`, `.error(message:)`), switch trong actions/message closures. Clean, type-safe, scalable.

**Phần 9a — Delete Confirmation ViewModifier**: Reusable `deleteConfirmation()` modifier — chỉ cần pass `item`, `itemName`, `onDelete` closure. Apply 1 dòng cho bất kỳ entity nào (Project, User, Task...). Đây là pattern chuẩn cho mọi app có delete functionality.

**Pitfall #4 đáng chú ý**: `.alert()` **phải gắn trên view bên trong** Sheet/FullScreenCover, không phải view ngoài. Alert hiển thị trên window hiện tại — nếu gắn ngoài sheet thì alert bị che khuất.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
