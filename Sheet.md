```Swift
// ============================================================
// SHEET TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// Sheet là modal presentation — view TRƯỢT LÊN TỪ DƯỚI,
// phủ lên view hiện tại. User có thể swipe xuống để dismiss.
//
// Hệ sinh thái modal presentations:
// - .sheet: modal card (phổ biến nhất)
// - .fullScreenCover: phủ full màn hình
// - .popover: popup nhỏ (iPad/Mac)
// - .inspector: side panel (iOS 17+)
//
// API evolution:
// iOS 13: .sheet(isPresented:), .fullScreenCover
// iOS 15: .interactiveDismissDisabled
// iOS 16: .presentationDetents, .presentationDragIndicator,
//         .sheet(item:), presentationBackground
// iOS 17: .presentationContentInteraction,
//         .presentationBackgroundInteraction,
//         .presentationCornerRadius, .inspector
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÚ PHÁP CƠ BẢN — .sheet()                          ║
// ╚══════════════════════════════════════════════════════════╝

struct BasicSheetDemo: View {
    @State private var showSheet = false
    
    var body: some View {
        Button("Mở Sheet") {
            showSheet = true
        }
        // === 1a. isPresented: Bool binding ===
        .sheet(isPresented: $showSheet) {
            // Content hiển thị trong sheet
            SheetContent()
            // SwiftUI TỰ ĐỘNG:
            // - Slide up từ dưới
            // - Dim background
            // - Set $showSheet = false khi dismiss
        }
    }
}

struct SheetContent: View {
    // Lấy dismiss action từ environment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Đây là Sheet content")
                    .font(.title2)
                
                Text("Swipe xuống hoặc tap Đóng để dismiss")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Sheet Title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// DISMISS SHEET — 3 cách:
// 1. User SWIPE XUỐNG (mặc định, có thể disable)
// 2. @Environment(\.dismiss) var dismiss → dismiss()
// 3. Set isPresented = false từ parent


// ╔══════════════════════════════════════════════════════════╗
// ║  2. .sheet(item:) — SHEET VỚI DATA                       ║
// ╚══════════════════════════════════════════════════════════╝

// Thay vì Bool, dùng Optional Identifiable item.
// Sheet hiện khi item != nil, dismiss → item = nil.

struct SheetItem: Identifiable {
    let id = UUID()
    let title: String
    let color: Color
}

struct ItemSheetDemo: View {
    @State private var selectedItem: SheetItem?
    
    let items = [
        SheetItem(title: "Swift", color: .orange),
        SheetItem(title: "Kotlin", color: .purple),
        SheetItem(title: "Dart", color: .blue),
    ]
    
    var body: some View {
        List(items) { item in
            Button(item.title) {
                selectedItem = item // Set item → sheet hiện
            }
        }
        .sheet(item: $selectedItem) { item in
            // item: SheetItem (unwrapped, non-optional)
            VStack(spacing: 16) {
                Circle()
                    .fill(item.color.gradient)
                    .frame(width: 80, height: 80)
                Text(item.title)
                    .font(.title.bold())
                Text("ID: \(item.id.uuidString.prefix(8))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .presentationDetents([.medium])
        }
    }
}

// .sheet(isPresented:) vs .sheet(item:):
//
// isPresented: Bool → Sheet KHÔNG CÓ DATA context
//   Dùng khi: create new, settings, static content
//
// item: Optional<T> → Sheet CÓ DATA (item truyền vào closure)
//   Dùng khi: detail view, edit specific item, dynamic content


// ╔══════════════════════════════════════════════════════════╗
// ║  3. .fullScreenCover — PHỦ FULL MÀN HÌNH                ║
// ╚══════════════════════════════════════════════════════════╝

struct FullScreenDemo: View {
    @State private var showLogin = false
    @State private var showOnboarding = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Login (Full Screen)") { showLogin = true }
            Button("Onboarding") { showOnboarding = true }
        }
        // === fullScreenCover: KHÔNG thể swipe dismiss ===
        .fullScreenCover(isPresented: $showLogin) {
            LoginScreen()
            // Phủ kín toàn bộ màn hình
            // KHÔNG có swipe-to-dismiss mặc định
            // PHẢI có button dismiss trong content
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingScreen()
        }
    }
}

struct LoginScreen: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Login Screen")
                    .font(.largeTitle)
                // ... login form
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Đóng") { dismiss() }
                }
            }
        }
    }
}

struct OnboardingScreen: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            Text("Onboarding").font(.title)
            Button("Bắt đầu") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
    }
}

// .sheet vs .fullScreenCover:
// ┌──────────────────────┬─────────────────┬──────────────────┐
// │                      │ .sheet          │ .fullScreenCover │
// ├──────────────────────┼─────────────────┼──────────────────┤
// │ Hiển thị             │ Card phía dưới  │ Full màn hình    │
// │ Background dimming   │ ✅ Parent mờ    │ ❌ Parent ẩn hẳn │
// │ Swipe dismiss        │ ✅ Mặc định    │ ❌ Không có      │
// │ Detents support      │ ✅ iOS 16+     │ ❌               │
// │ Corner radius        │ ✅ Tự động     │ ❌ Full edge     │
// │ Dùng cho             │ Detail, create, │ Login, onboarding│
// │                      │ picker, filter  │ camera, full edit│
// └──────────────────────┴─────────────────┴──────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  4. PRESENTATION DETENTS — CHIỀU CAO SHEET (iOS 16+)     ║
// ╚══════════════════════════════════════════════════════════╝

struct DetentsDemo: View {
    @State private var showSheet = false
    @State private var showCustom = false
    @State private var showMulti = false
    
    var body: some View {
        VStack(spacing: 16) {
            // === 4a. Built-in detents ===
            Button("Medium Detent") { showSheet = true }
            .sheet(isPresented: $showSheet) {
                SheetBody(title: "Medium")
                    .presentationDetents([.medium])
                // .medium: khoảng 50% màn hình
                // .large: gần full (mặc định nếu không set)
            }
            
            // === 4b. Multiple detents — User kéo chuyển đổi ===
            Button("Multi Detents") { showMulti = true }
            .sheet(isPresented: $showMulti) {
                SheetBody(title: "Kéo lên/xuống")
                    .presentationDetents([.medium, .large])
                // User có thể kéo giữa medium ↔ large
                // Sheet snap vào detent gần nhất khi thả
            }
            
            // === 4c. Fraction & Height detents ===
            Button("Custom Height") { showCustom = true }
            .sheet(isPresented: $showCustom) {
                SheetBody(title: "Custom Heights")
                    .presentationDetents([
                        .fraction(0.25),   // 25% màn hình
                        .fraction(0.5),    // 50%
                        .height(600),      // Chính xác 600pt
                        .large             // Gần full
                    ])
            }
        }
    }
}

struct SheetBody: View {
    let title: String
    var body: some View {
        VStack {
            Text(title).font(.title2.bold())
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }
}


// === 4d. Custom Detent (iOS 16+) ===

struct SmallDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        // Dynamic height dựa trên context
        return max(200, context.maxDetentValue * 0.3)
        // 30% max height, tối thiểu 200pt
    }
}

struct CustomDetentDemo: View {
    @State private var show = false
    
    var body: some View {
        Button("Custom Detent") { show = true }
        .sheet(isPresented: $show) {
            SheetBody(title: "Custom Detent")
                .presentationDetents([
                    .custom(SmallDetent.self),
                    .medium,
                    .large
                ])
        }
    }
}


// === 4e. Track current detent ===

struct DetentTrackingDemo: View {
    @State private var show = false
    @State private var selectedDetent: PresentationDetent = .medium
    
    var body: some View {
        Button("Track Detent") { show = true }
        .sheet(isPresented: $show) {
            VStack {
                Text("Current: \(detentName)")
                    .font(.headline)
                
                Text("Kéo sheet để thay đổi detent")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .presentationDetents(
                [.medium, .large],
                selection: $selectedDetent  // 2-way binding!
            )
        }
    }
    
    var detentName: String {
        switch selectedDetent {
        case .medium: return "Medium"
        case .large: return "Large"
        default: return "Unknown"
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. PRESENTATION MODIFIERS — TUỲ CHỈNH APPEARANCE       ║
// ╚══════════════════════════════════════════════════════════╝

struct PresentationModifiersDemo: View {
    @State private var showSheet = false
    
    var body: some View {
        Button("Fully Customized Sheet") { showSheet = true }
        .sheet(isPresented: $showSheet) {
            VStack(spacing: 16) {
                Text("Customized Sheet")
                    .font(.title2.bold())
                
                Text("Background, corners, drag indicator, interaction — tất cả tuỳ chỉnh")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            
            // === 5a. Drag indicator ===
            .presentationDragIndicator(.visible)
            // .visible: luôn hiện thanh kéo
            // .hidden: ẩn thanh kéo
            // .automatic: hệ thống quyết định
            
            // === 5b. Detents ===
            .presentationDetents([.medium, .large])
            
            // === 5c. Corner radius (iOS 16.4+) ===
            .presentationCornerRadius(24)
            
            // === 5d. Background (iOS 16.4+) ===
            .presentationBackground(.ultraThinMaterial)
            // .thinMaterial, .regularMaterial, .thickMaterial
            // Color.blue.opacity(0.9)
            // .clear → transparent sheet!
            
            // === 5e. Background interaction (iOS 17+) ===
            .presentationBackgroundInteraction(
                .enabled(upThrough: .medium)
            )
            // Khi sheet ở medium → parent view có thể TAP ĐƯỢC
            // Khi sheet ở large → parent bị disabled (mặc định)
            // .disabled: parent luôn bị dim + disabled
            // .enabled: parent luôn tương tác được
            // .enabled(upThrough: .medium): chỉ khi sheet ≤ medium
            
            // === 5f. Content interaction (iOS 17+) ===
            .presentationContentInteraction(.scrolls)
            // .scrolls: scroll TRONG sheet ưu tiên hơn resize
            // .resizes (default): kéo trong sheet = resize sheet
            // Quan trọng khi sheet chứa ScrollView
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. interactiveDismissDisabled — CHẶN SWIPE DISMISS      ║
// ╚══════════════════════════════════════════════════════════╝

struct DismissControlDemo: View {
    @State private var showEdit = false
    @State private var hasChanges = false
    @State private var showDiscardAlert = false
    @State private var text = ""
    
    var body: some View {
        Button("Edit (Unsaved Changes Guard)") { showEdit = true }
        .sheet(isPresented: $showEdit, onDismiss: {
            // Callback KHI sheet đã dismiss xong
            print("Sheet dismissed")
        }) {
            NavigationStack {
                Form {
                    TextField("Nhập nội dung", text: $text)
                        .onChange(of: text) { _, _ in
                            hasChanges = true
                        }
                    
                    if hasChanges {
                        Text("⚠️ Có thay đổi chưa lưu")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }
                .navigationTitle("Chỉnh sửa")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Huỷ") {
                            if hasChanges {
                                showDiscardAlert = true
                            } else {
                                showEdit = false
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Lưu") {
                            save()
                            showEdit = false
                        }
                        .bold()
                        .disabled(!hasChanges)
                    }
                }
                .alert("Huỷ thay đổi?", isPresented: $showDiscardAlert) {
                    Button("Huỷ thay đổi", role: .destructive) {
                        showEdit = false
                    }
                    Button("Tiếp tục chỉnh sửa", role: .cancel) { }
                } message: {
                    Text("Bạn có thay đổi chưa lưu. Huỷ sẽ mất dữ liệu.")
                }
            }
            // === Chặn swipe dismiss khi có changes ===
            .interactiveDismissDisabled(hasChanges)
            // true → KHÔNG cho phép swipe xuống dismiss
            // User PHẢI dùng button Huỷ/Lưu → đi qua confirmation flow
            
            // Kết hợp onDismiss attempt (iOS 17+):
            // .presentationDismissalAction { dismiss in
            //     if hasChanges { showDiscardAlert = true }
            //     else { dismiss() }
            // }
        }
    }
    
    func save() {
        print("Saved: \(text)")
        hasChanges = false
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. ENVIRONMENT & DATA PASSING                           ║
// ╚══════════════════════════════════════════════════════════╝

// ⚠️ QUAN TRỌNG: Sheet tạo WINDOW MỚI → Environment KHÔNG tự cascade!
// Phải INJECT LẠI environment vào sheet content.

@Observable
final class AppState {
    var username = "Huy"
    var theme = "dark"
}

struct EnvironmentSheetDemo: View {
    @State private var appState = AppState()
    @State private var showSheet = false
    
    var body: some View {
        VStack {
            Text("User: \(appState.username)")
            Button("Open Sheet") { showSheet = true }
        }
        .environment(appState) // Inject cho parent
        .sheet(isPresented: $showSheet) {
            SheetUsingEnvironment()
                .environment(appState) // ← BẮT BUỘC inject lại!
            // KHÔNG inject → crash hoặc nhận default value sai
        }
    }
}

struct SheetUsingEnvironment: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Text("Sheet thấy user: \(appState.username)")
    }
}

// ENVIRONMENT RULES CHO SHEET:
// ❌ .environment()        → KHÔNG tự cascade vào sheet
// ❌ .environmentObject()  → KHÔNG tự cascade vào sheet
// ✅ Phải inject LẠI trong .sheet { ... .environment(x) }
//
// Tương tự cho: .fullScreenCover, .popover
// KHÁC VỚI: NavigationDestination → TỰ ĐỘNG cascade ✅


// ╔══════════════════════════════════════════════════════════╗
// ║  8. PASSING DATA — CALLBACKS & BINDINGS                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 8a. Callback closure ===

struct CallbackSheetDemo: View {
    @State private var showCreate = false
    @State private var items: [String] = ["Item 1", "Item 2"]
    
    var body: some View {
        NavigationStack {
            List(items, id: \.self) { item in
                Text(item)
            }
            .toolbar {
                Button { showCreate = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreate) {
            CreateItemSheet { newItem in
                // Callback: nhận data từ sheet
                items.append(newItem)
            }
        }
    }
}

struct CreateItemSheet: View {
    let onCreate: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Tên item", text: $name)
            }
            .navigationTitle("Tạo mới")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Huỷ") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tạo") {
                        onCreate(name) // Gọi callback
                        dismiss()
                    }
                    .bold()
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}


// === 8b. @Binding ===

struct BindingSheetDemo: View {
    @State private var selectedColor = Color.blue
    @State private var showPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(selectedColor)
                .frame(width: 100, height: 100)
            
            Button("Chọn màu") { showPicker = true }
        }
        .sheet(isPresented: $showPicker) {
            ColorPickerSheet(color: $selectedColor)
            // Binding trực tiếp → thay đổi trong sheet = thay đổi ở parent
                .presentationDetents([.medium])
        }
    }
}

struct ColorPickerSheet: View {
    @Binding var color: Color
    @Environment(\.dismiss) private var dismiss
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var body: some View {
        NavigationStack {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(colors, id: \.self) { c in
                    Circle()
                        .fill(c.gradient)
                        .frame(width: 60, height: 60)
                        .overlay {
                            if c == color {
                                Circle().strokeBorder(.white, lineWidth: 3)
                            }
                        }
                        .onTapGesture { color = c }
                }
            }
            .padding()
            .navigationTitle("Chọn màu")
            .toolbar {
                Button("Xong") { dismiss() }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. POPOVER — POPUP NHỎ (iPad/Mac, iOS 16.4+)           ║
// ╚══════════════════════════════════════════════════════════╝

struct PopoverDemo: View {
    @State private var showPopover = false
    @State private var showInfo = false
    
    var body: some View {
        HStack(spacing: 24) {
            // === 9a. Basic popover ===
            Button("Popover") { showPopover = true }
            .popover(isPresented: $showPopover) {
                VStack(spacing: 12) {
                    Text("Popover Content")
                        .font(.headline)
                    Text("iPad: hiện popup mũi tên\niPhone: hiện như sheet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .presentationCompactAdaptation(.popover)
                // iOS 16.4+: force popover style ngay cả trên iPhone
                // .sheet: fallback về sheet trên iPhone (mặc định)
                // .popover: luôn hiện popover
                // .none: không adapt
            }
            
            // === 9b. Info popover ===
            Button { showInfo = true } label: {
                Image(systemName: "info.circle")
            }
            .popover(isPresented: $showInfo, arrowEdge: .bottom) {
                Text("Đây là thông tin bổ sung giải thích tính năng.")
                    .font(.subheadline)
                    .padding()
                    .frame(width: 250)
                    .presentationCompactAdaptation(.popover)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. NESTED SHEETS & NAVIGATION TRONG SHEET              ║
// ╚══════════════════════════════════════════════════════════╝

struct NestedSheetDemo: View {
    @State private var showFirst = false
    
    var body: some View {
        Button("Open First Sheet") { showFirst = true }
        .sheet(isPresented: $showFirst) {
            FirstSheet()
        }
    }
}

struct FirstSheet: View {
    @State private var showSecond = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("First Sheet")
                    .font(.title2)
                
                // Sheet trong sheet → chồng lên
                Button("Open Second Sheet") { showSecond = true }
                    .buttonStyle(.borderedProminent)
                
                // Navigation trong sheet → push trong cùng sheet
                NavigationLink("Push Detail") {
                    Text("Detail trong First Sheet")
                        .navigationTitle("Detail")
                }
            }
            .navigationTitle("First")
            .toolbar {
                Button("Đóng") { dismiss() }
            }
        }
        .sheet(isPresented: $showSecond) {
            SecondSheet()
                .presentationDetents([.medium])
        }
    }
}

struct SecondSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Second Sheet (chồng lên First)")
            Button("Đóng") { dismiss() }
                .buttonStyle(.bordered)
        }
    }
}

// NESTED SHEETS RULES:
// - Sheet CÓ THỂ mở sheet khác → chồng lên (stack)
// - dismiss() chỉ đóng sheet HIỆN TẠI (trên cùng)
// - NavigationStack TRONG sheet → push/pop BÊN TRONG sheet
// - Tránh nest quá 2-3 levels → UX phức tạp


// ╔══════════════════════════════════════════════════════════╗
// ║  11. PRODUCTION PATTERNS                                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 11a. Multi-purpose Sheet Router ===

enum SheetDestination: Identifiable {
    case createTask
    case editTask(TaskModel)
    case filter
    case settings
    case profile(userId: String)
    
    var id: String {
        switch self {
        case .createTask: return "create"
        case .editTask(let t): return "edit-\(t.id)"
        case .filter: return "filter"
        case .settings: return "settings"
        case .profile(let id): return "profile-\(id)"
        }
    }
}

struct TaskModel: Identifiable {
    let id: String
    var title: String
}

struct SheetRouterDemo: View {
    @State private var activeSheet: SheetDestination?
    
    var body: some View {
        VStack(spacing: 12) {
            Button("Create Task") { activeSheet = .createTask }
            Button("Edit Task") {
                activeSheet = .editTask(TaskModel(id: "1", title: "Review PR"))
            }
            Button("Filter") { activeSheet = .filter }
            Button("Settings") { activeSheet = .settings }
        }
        // MỘT .sheet duy nhất xử lý TẤT CẢ destinations
        .sheet(item: $activeSheet) { destination in
            switch destination {
            case .createTask:
                Text("Create Task Sheet")
                    .presentationDetents([.medium, .large])
                
            case .editTask(let task):
                Text("Edit: \(task.title)")
                    .presentationDetents([.large])
                
            case .filter:
                Text("Filter Sheet")
                    .presentationDetents([.fraction(0.4)])
                    .presentationDragIndicator(.visible)
                
            case .settings:
                Text("Settings")
                    .presentationDetents([.large])
                
            case .profile(let userId):
                Text("Profile: \(userId)")
            }
        }
    }
}


// === 11b. Bottom Sheet Picker ===

struct BottomSheetPicker<T: Hashable & Identifiable, Content: View>: View {
    let title: String
    let items: [T]
    @Binding var selection: T
    @ViewBuilder let rowContent: (T, Bool) -> Content
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(items) { item in
                Button {
                    selection = item
                    dismiss()
                } label: {
                    rowContent(item, item == selection)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Xong") { dismiss() }
            }
        }
    }
}


// === 11c. Share Sheet / Action Menu ===

struct ShareSheetDemo: View {
    @State private var showActions = false
    
    var body: some View {
        Button("Chia sẻ") { showActions = true }
        .sheet(isPresented: $showActions) {
            VStack(spacing: 0) {
                // Drag indicator
                Capsule()
                    .fill(.gray.opacity(0.4))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                
                // Title
                Text("Chia sẻ bài viết")
                    .font(.headline)
                    .padding(.bottom, 16)
                
                // Quick share row (horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ShareTarget(icon: "message.fill", name: "Messages", color: .green)
                        ShareTarget(icon: "paperplane.fill", name: "Telegram", color: .blue)
                        ShareTarget(icon: "envelope.fill", name: "Email", color: .orange)
                        ShareTarget(icon: "doc.on.doc", name: "Copy", color: .gray)
                        ShareTarget(icon: "bookmark.fill", name: "Save", color: .purple)
                    }
                    .padding(.horizontal)
                }
                
                Divider().padding(.vertical, 16)
                
                // Action list
                VStack(spacing: 0) {
                    ActionRow(icon: "link", title: "Sao chép liên kết")
                    ActionRow(icon: "qrcode", title: "Tạo QR Code")
                    ActionRow(icon: "flag", title: "Báo cáo")
                }
                
                Spacer()
            }
            .presentationDetents([.fraction(0.45)])
            .presentationDragIndicator(.hidden) // Ẩn vì tự có drag bar
        }
    }
}

struct ShareTarget: View {
    let icon: String
    let name: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(color.gradient, in: .circle)
            Text(name)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct ActionRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button {
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundStyle(.primary)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}


// === 11d. Image Viewer (Full Screen) ===

struct ImageViewerDemo: View {
    @State private var showViewer = false
    
    var body: some View {
        Button {
            showViewer = true
        } label: {
            Image(systemName: "photo.artframe")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 150)
                .background(.gray.opacity(0.1))
                .clipShape(.rect(cornerRadius: 12))
        }
        .fullScreenCover(isPresented: $showViewer) {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(systemName: "photo.artframe")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                
                // Close button
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            showViewer = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(.white.opacity(0.2), in: .circle)
                        }
                    }
                    .padding()
                    Spacer()
                }
            }
        }
    }
}


// === 11e. Floating Bottom Sheet (Maps-style) ===

struct MapsStyleSheet: View {
    @State private var detent: PresentationDetent = .fraction(0.15)
    @State private var searchText = ""
    
    var body: some View {
        // Main content (Map)
        ZStack {
            Color.green.opacity(0.1).ignoresSafeArea()
            Text("🗺️ Map View")
                .font(.largeTitle)
        }
        // Persistent bottom sheet (luôn hiện)
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Tìm kiếm địa điểm...", text: $searchText)
                    }
                    .padding(12)
                    .background(.gray.opacity(0.1), in: .rect(cornerRadius: 10))
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    
                    if detent != .fraction(0.15) {
                        // Content hiện khi mở rộng
                        List {
                            ForEach(0..<10) { i in
                                Label("Địa điểm \(i + 1)", systemImage: "mappin")
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .presentationDetents(
                [.fraction(0.15), .medium, .large],
                selection: $detent
            )
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            // Map tương tác được khi sheet ở mini/medium
            .presentationCornerRadius(20)
            .interactiveDismissDisabled() // Không cho dismiss hoàn toàn
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  12. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Environment không cascade vào sheet
//    .environment(myObject)
//    .sheet { SheetView() } // SheetView KHÔNG nhận myObject!
//    ✅ FIX: .sheet { SheetView().environment(myObject) }

// ❌ PITFALL 2: Nhiều .sheet trên CÙNG 1 view (iOS 13-14)
//    View().sheet(A).sheet(B) → Chỉ sheet CUỐI hoạt động
//    ✅ FIX: iOS 15+: hoạt động đúng
//            iOS 13-14: dùng enum .sheet(item:) pattern

// ❌ PITFALL 3: Sheet content bị re-create mỗi lần mở
//    .sheet { HeavyView() } → HeavyView() init lại mỗi lần
//    → Đúng behavior (sheet là transient presentation)
//    ✅ FIX: Nếu cần giữ state → @State ở PARENT, pass vào sheet

// ❌ PITFALL 4: onDismiss không fire khi set isPresented = false
//    onDismiss CHỈ fire khi user SWIPE dismiss hoặc dismiss() gọi
//    Nếu set isPresented = false programmatically → onDismiss VẪN fire
//    ⚠️ Nhưng timing có thể khác nhau — tránh rely on timing

// ❌ PITFALL 5: ScrollView trong sheet kéo = resize sheet
//    Sheet medium + ScrollView bên trong → kéo scroll = resize sheet
//    ✅ FIX: .presentationContentInteraction(.scrolls) (iOS 17+)
//            Ưu tiên scroll content thay vì resize sheet

// ❌ PITFALL 6: fullScreenCover không có swipe dismiss
//    User bị "mắc kẹt" nếu không có button dismiss
//    ✅ FIX: LUÔN thêm close/dismiss button trong fullScreenCover

// ❌ PITFALL 7: Detent .fraction(0) hoặc quá nhỏ
//    .presentationDetents([.fraction(0.05)]) → sheet gần như ẩn
//    ✅ FIX: Tối thiểu .fraction(0.1) hoặc .height(100)

// ❌ PITFALL 8: Sheet item set nil trước khi sheet render
//    activeSheet = .create; activeSheet = nil // Quá nhanh
//    → Sheet flash hoặc không hiện
//    ✅ FIX: Tránh set nil ngay sau set non-nil cùng run loop

// ✅ BEST PRACTICES:
// 1. .sheet cho modals thường, .fullScreenCover cho immersive
// 2. NavigationStack BÊN TRONG sheet (không share với parent)
// 3. .environment() PHẢI inject lại cho sheet content
// 4. .presentationDetents cho half-sheet, quarter-sheet
// 5. .interactiveDismissDisabled khi có unsaved changes
// 6. .sheet(item:) + enum cho multi-type sheet routing
// 7. Callback closures hoặc @Binding cho data passing
// 8. .presentationContentInteraction(.scrolls) khi có ScrollView
// 9. .presentationBackgroundInteraction cho Maps-style persistent sheet
// 10. .presentationDragIndicator(.visible) khi có multiple detents
// 11. .presentationBackground(.ultraThinMaterial) cho blur effect
// 12. @Environment(\.dismiss) trong SHEET content, không phải parent
```

---

Sheet là cơ chế modal presentation chính của SwiftUI — đã tiến hoá rất nhiều qua các iOS versions với detents, dismiss control, và presentation customization. Mình sẽ giải thích toàn bộ.Mình đã tổng hợp toàn bộ kiến thức Sheet trong 12 phần. Đây là những điểm cốt lõi:

**Sheet là modal presentation phức tạp nhất trong SwiftUI** vì kết hợp nhiều behaviors: detents (chiều cao), dismiss control, background interaction, content interaction, environment handling, và data passing patterns.

**Năm phần giá trị nhất cho production:**

**Phần 4 — Presentation Detents (iOS 16+)**: Đây là game-changer — trước đây phải dùng UIKit hack cho half-sheet, giờ chỉ cần `.presentationDetents([.medium, .large])`. Đặc biệt `.fraction(0.25)` cho quarter-sheet, `.custom(SmallDetent.self)` cho dynamic height dựa trên context, và `selection: $detent` binding để track/control detent hiện tại.

**Phần 5 — Presentation Modifiers**: Bộ combo iOS 16.4/17+ cực mạnh — `.presentationBackground(.ultraThinMaterial)` cho blur sheet, `.presentationBackgroundInteraction(.enabled(upThrough: .medium))` cho phép tap parent khi sheet ở medium (Maps-style), `.presentationContentInteraction(.scrolls)` giải quyết xung đột scroll vs resize sheet.

**Phần 6 — interactiveDismissDisabled**: Pattern "unsaved changes guard" hoàn chỉnh — chặn swipe dismiss khi có thay đổi, force user đi qua confirmation alert. Kết hợp `.interactiveDismissDisabled(hasChanges)` + alert "Huỷ thay đổi?"

**Phần 7 — Environment cascade**: **Gotcha lớn nhất** — Sheet tạo window mới nên environment **KHÔNG tự cascade**. Phải inject lại `.environment(appState)` bên trong `.sheet { }`. Quên inject → crash runtime hoặc nhận default value sai. Rule này áp dụng cho cả `.fullScreenCover` và `.popover`.

**Phần 11e — Maps-style Persistent Sheet**: Pattern `.sheet(isPresented: .constant(true))` + `.interactiveDismissDisabled()` + `.presentationBackgroundInteraction(.enabled(upThrough: .medium))` tạo bottom sheet luôn hiện, 3 detents (mini/medium/large), parent tương tác được — y hệt Apple Maps.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
