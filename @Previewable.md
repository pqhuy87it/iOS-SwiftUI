// ============================================================
// @Previewable TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// Introduced: WWDC 2024, Xcode 16, iOS 18+ SDK
// (Preview chạy trên simulator/device iOS 17 trở xuống vẫn OK,
//  chỉ cần BUILD bằng Xcode 16+ là dùng được @Previewable)
//
// @Previewable là một MACRO cho phép sử dụng property wrappers
// như @State, @Binding trực tiếp bên trong #Preview block
// mà KHÔNG cần tạo wrapper view phụ.
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. VẤN ĐỀ MÀ @Previewable GIẢI QUYẾT                    ║
// ╚══════════════════════════════════════════════════════════╝

// Giả sử có component nhận @Binding:
struct RatingView: View {
    @Binding var rating: Int
    let maxRating: Int
    
    var body: some View {
        HStack {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundStyle(star <= rating ? .yellow : .gray)
                    .onTapGesture { rating = star }
            }
        }
        .font(.title2)
    }
}

// ❌ TRƯỚC @Previewable (iOS 13–17): Pain point lớn
// Không thể viết @State trong #Preview vì #Preview là macro,
// không phải View struct → không có chỗ cho property wrappers.

// Cách 1: Dùng .constant() — KHÔNG interactive
#Preview("❌ Constant - Không tap được") {
    RatingView(rating: .constant(3), maxRating: 5)
    // Hiển thị 3 sao nhưng tap không đổi được!
    // .constant() tạo Binding chỉ đọc, set bị ignore.
    // → Không thể test interaction trong Preview.
}

// Cách 2: Tạo wrapper view PHỤ — Verbose, boilerplate
struct RatingPreviewWrapper: View {
    @State private var rating = 3
    var body: some View {
        RatingView(rating: $rating, maxRating: 5)
    }
}

#Preview("❌ Wrapper view - Quá verbose") {
    RatingPreviewWrapper()
    // Hoạt động, nhưng phải tạo struct riêng CHỈ cho preview.
    // 10 components cần preview = 10 wrapper structs 😩
}

// ✅ SAU @Previewable (Xcode 16+): Sạch, gọn, interactive
#Preview("✅ @Previewable - Clean & Interactive") {
    @Previewable @State var rating = 3
    RatingView(rating: $rating, maxRating: 5)
    // ✅ Tap đổi rating trực tiếp trong Preview canvas!
    // ✅ Không cần wrapper struct!
    // ✅ Two-way binding hoạt động hoàn hảo!
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. @Previewable HOẠT ĐỘNG NHƯ THẾ NÀO (UNDER THE HOOD)  ║
// ╚══════════════════════════════════════════════════════════╝

// @Previewable là một MACRO mở rộng (attached macro).
// Khi compiler gặp:
//
//   #Preview {
//       @Previewable @State var rating = 3
//       RatingView(rating: $rating, maxRating: 5)
//   }
//
// Macro tự động GENERATE wrapper view ẩn, tương đương:
//
//   #Preview {
//       struct __PreviewWrapper: View {
//           @State var rating = 3
//           var body: some View {
//               RatingView(rating: $rating, maxRating: 5)
//           }
//       }
//       return __PreviewWrapper()
//   }
//
// Bạn viết 2 dòng, compiler expand thành struct đầy đủ.
// → @Previewable chỉ là syntactic sugar, không phải runtime magic.
// → Performance và behavior GIỐNG HỆT wrapper view thủ công.


// ╔══════════════════════════════════════════════════════════╗
// ║  3. CÁC PROPERTY WRAPPERS HỖ TRỢ @Previewable            ║
// ╚══════════════════════════════════════════════════════════╝

// @Previewable hoạt động với MỌI property wrapper hợp lệ trong View.
// Dưới đây là các trường hợp phổ biến:

// === 3a. @State — Phổ biến nhất ===
#Preview("@State") {
    @Previewable @State var text = "Hello"
    @Previewable @State var isOn = false
    
    VStack(spacing: 20) {
        TextField("Nhập text", text: $text)
            .textFieldStyle(.roundedBorder)
        
        Toggle("Bật/Tắt", isOn: $isOn)
        
        Text("Text: \(text), Toggle: \(isOn ? "ON" : "OFF")")
    }
    .padding()
}

// === 3b. @State với @Observable objects (iOS 17+) ===

@Observable
final class CounterModel {
    var count = 0
    var history: [Int] = []
    
    func increment() {
        count += 1
        history.append(count)
    }
    
    func decrement() {
        count -= 1
        history.append(count)
    }
}

struct CounterView: View {
    @Bindable var model: CounterModel  // Nhận @Observable object
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(model.count)")
                .font(.system(size: 48, weight: .bold))
            
            HStack(spacing: 24) {
                Button("-") { model.decrement() }
                Button("+") { model.increment() }
            }
            .font(.title)
            
            Text("Lịch sử: \(model.history.map(String.init).joined(separator: " → "))")
                .font(.caption)
        }
    }
}

#Preview("@Observable Model") {
    // @State giữ reference stable qua re-renders
    @Previewable @State var model = CounterModel()
    CounterView(model: model)
}

// === 3c. @Environment — Inject custom environment values ===

#Preview("Custom Environment") {
    @Previewable @State var rating = 2
    
    RatingView(rating: $rating, maxRating: 5)
        .environment(\.colorScheme, .dark)
}

// === 3d. @FocusState ===
struct LoginFormView: View {
    @Binding var username: String
    @Binding var password: String
    @FocusState.Binding var focusedField: LoginField?
    
    enum LoginField {
        case username, password
    }
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Username", text: $username)
                .focused($focusedField, equals: .username)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $password)
                .focused($focusedField, equals: .password)
                .textFieldStyle(.roundedBorder)
            
            Button("Login") {}
                .disabled(username.isEmpty || password.isEmpty)
        }
        .padding()
    }
}

#Preview("@FocusState") {
    @Previewable @State var username = ""
    @Previewable @State var password = ""
    @Previewable @FocusState var focused: LoginFormView.LoginField?
    
    LoginFormView(
        username: $username,
        password: $password,
        focusedField: $focused
    )
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. MULTIPLE @Previewable TRONG 1 PREVIEW                ║
// ╚══════════════════════════════════════════════════════════╝

// Có thể khai báo NHIỀU @Previewable cùng lúc.
// Mỗi biến hoạt động độc lập.

struct TaskEditorView: View {
    @Binding var title: String
    @Binding var priority: Int
    @Binding var isUrgent: Bool
    @Binding var dueDate: Date
    
    var body: some View {
        Form {
            Section("Thông tin") {
                TextField("Tiêu đề", text: $title)
                Stepper("Ưu tiên: \(priority)", value: $priority, in: 1...5)
                Toggle("Gấp", isOn: $isUrgent)
                DatePicker("Hạn", selection: $dueDate, displayedComponents: .date)
            }
            
            Section("Tóm tắt") {
                Text("📝 \(title)")
                Text("⭐ Priority \(priority)")
                Text(isUrgent ? "🔴 URGENT" : "🟢 Normal")
                Text("📅 \(dueDate.formatted(date: .abbreviated, time: .omitted))")
            }
        }
    }
}

#Preview("Multiple @Previewable States") {
    @Previewable @State var title = "Review PR"
    @Previewable @State var priority = 3
    @Previewable @State var isUrgent = false
    @Previewable @State var dueDate = Date.now
    
    // Tất cả bindings đều interactive trong Preview canvas!
    TaskEditorView(
        title: $title,
        priority: $priority,
        isUrgent: $isUrgent,
        dueDate: $dueDate
    )
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. @Previewable VỚI CUSTOM PREVIEW SCENARIOS            ║
// ╚══════════════════════════════════════════════════════════╝

// === 5a. Nhiều Preview với states khác nhau ===
// Mỗi #Preview là independent, có state riêng.

#Preview("Empty State") {
    @Previewable @State var items: [String] = []
    ItemListView(items: $items)
}

#Preview("Populated State") {
    @Previewable @State var items = ["Mua sữa", "Code review", "Tập gym"]
    ItemListView(items: $items)
}

#Preview("Many Items - Scroll") {
    @Previewable @State var items = (1...50).map { "Item \($0)" }
    ItemListView(items: $items)
}

struct ItemListView: View {
    @Binding var items: [String]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                .onDelete { items.remove(atOffsets: $0) }
            }
            .navigationTitle("Danh sách (\(items.count))")
            .toolbar {
                Button("Thêm") {
                    items.append("Mới \(items.count + 1)")
                }
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView(
                        "Trống",
                        systemImage: "tray",
                        description: Text("Tap + để thêm item")
                    )
                }
            }
        }
    }
}

// === 5b. Preview trong NavigationStack ===
#Preview("In Navigation Context") {
    @Previewable @State var rating = 4
    
    NavigationStack {
        RatingView(rating: $rating, maxRating: 5)
            .navigationTitle("Đánh giá")
            .padding()
    }
}

// === 5c. Preview với custom size (Landscape, iPad...) ===
#Preview("iPad Layout", traits: .landscapeLeft) {
    @Previewable @State var rating = 3
    RatingView(rating: $rating, maxRating: 5)
}

#Preview("Fixed Size", traits: .fixedLayout(width: 300, height: 100)) {
    @Previewable @State var rating = 2
    RatingView(rating: $rating, maxRating: 5)
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. @Previewable + #Preview TRAITS (Xcode 16)            ║
// ╚══════════════════════════════════════════════════════════╝

// Xcode 16 mở rộng #Preview với traits để customize preview:

// --- Device traits ---
#Preview("Landscape", traits: .landscapeLeft) {
    @Previewable @State var text = ""
    TextField("Search", text: $text)
        .textFieldStyle(.roundedBorder)
        .padding()
}

// --- Fixed layout (component preview) ---
#Preview("Component Size", traits: .fixedLayout(width: 200, height: 60)) {
    @Previewable @State var isOn = true
    Toggle("WiFi", isOn: $isOn)
        .padding()
}

// --- Size class combinations ---
#Preview("Size Classes", traits: .sizeThatFitsLayout) {
    @Previewable @State var rating = 3
    RatingView(rating: $rating, maxRating: 5)
        .padding()
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. CÁC QUY TẮC VÀ GIỚI HẠN CỦA @Previewable            ║
// ╚══════════════════════════════════════════════════════════╝

// ✅ QUY TẮC 1: @Previewable phải đặt TRƯỚC property wrapper
//   @Previewable @State var x = 0        ✅
//   @State @Previewable var x = 0        ❌ Compile error

// ✅ QUY TẮC 2: CHỈ dùng được trong #Preview { } block
//   struct MyView: View {
//       @Previewable @State var x = 0    ❌ Compile error
//       // @Previewable không có ý nghĩa ngoài Preview
//   }

// ✅ QUY TẮC 3: @Previewable declarations phải ở ĐẦU closure
//   #Preview {
//       @Previewable @State var x = 0    ✅ Đầu closure
//       let y = 10                        ✅ Sau @Previewable
//       MyView(value: $x)                 ✅ Cuối cùng là View
//   }
//
//   #Preview {
//       Text("Hello")
//       @Previewable @State var x = 0    ❌ Phải ở trước View
//   }

// ✅ QUY TẮC 4: Mỗi @Previewable cần initial value
//   @Previewable @State var x: Int       ❌ Thiếu giá trị khởi tạo
//   @Previewable @State var x: Int = 0   ✅

// ⚠️ GIỚI HẠN 1: Không dùng với @StateObject (dùng @State thay)
//   @Previewable @StateObject var vm = ViewModel()  ❌
//   @Previewable @State var vm = ViewModel()         ✅ (iOS 17+ @Observable)

// ⚠️ GIỚI HẠN 2: Không dùng với @EnvironmentObject
//   @Previewable @EnvironmentObject var auth: Auth   ❌
//   // Thay bằng: inject qua .environmentObject() modifier

// ⚠️ GIỚI HẠN 3: Không dùng với @ObservedObject
//   @Previewable @ObservedObject var model = Model() ❌
//   // Thay bằng: @State + @Observable (iOS 17+)


// ╔══════════════════════════════════════════════════════════╗
// ║  8. REAL-WORLD EXAMPLES                                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 8a. Search Bar Component ===
struct SearchBarView: View {
    @Binding var query: String
    @Binding var isSearching: Bool
    var onSubmit: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                
                TextField("Tìm kiếm...", text: $query)
                    .onSubmit(onSubmit)
                
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding(8)
            .background(.gray.opacity(0.12), in: .capsule)
            
            if isSearching {
                Button("Huỷ") {
                    query = ""
                    isSearching = false
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSearching)
        .padding(.horizontal)
    }
}

#Preview("Search Bar - Empty") {
    @Previewable @State var query = ""
    @Previewable @State var isSearching = false
    
    SearchBarView(query: $query, isSearching: $isSearching) {
        print("Submitted: \(query)")
    }
}

#Preview("Search Bar - Active") {
    @Previewable @State var query = "SwiftUI"
    @Previewable @State var isSearching = true
    
    SearchBarView(query: $query, isSearching: $isSearching) {
        print("Submitted: \(query)")
    }
}


// === 8b. Settings Form ===
struct SettingsView: View {
    @Binding var notificationsEnabled: Bool
    @Binding var fontSize: Double
    @Binding var selectedTheme: Theme
    @Binding var language: String
    
    enum Theme: String, CaseIterable {
        case system = "Hệ thống"
        case light = "Sáng"
        case dark = "Tối"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Giao diện") {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Cỡ chữ: \(Int(fontSize))pt")
                        Slider(value: $fontSize, in: 12...32, step: 1)
                    }
                }
                
                Section("Thông báo") {
                    Toggle("Bật thông báo", isOn: $notificationsEnabled)
                }
                
                Section("Ngôn ngữ") {
                    Picker("Ngôn ngữ", selection: $language) {
                        Text("Tiếng Việt").tag("vi")
                        Text("English").tag("en")
                        Text("日本語").tag("ja")
                    }
                }
                
                Section("Xem trước") {
                    Text("Đây là text mẫu để xem font size")
                        .font(.system(size: fontSize))
                }
            }
            .navigationTitle("Cài đặt")
        }
    }
}

#Preview("Settings - Default") {
    @Previewable @State var notifications = true
    @Previewable @State var fontSize = 16.0
    @Previewable @State var theme = SettingsView.Theme.system
    @Previewable @State var language = "vi"
    
    SettingsView(
        notificationsEnabled: $notifications,
        fontSize: $fontSize,
        selectedTheme: $theme,
        language: $language
    )
}

#Preview("Settings - Large Font + Dark") {
    @Previewable @State var notifications = false
    @Previewable @State var fontSize = 28.0
    @Previewable @State var theme = SettingsView.Theme.dark
    @Previewable @State var language = "en"
    
    SettingsView(
        notificationsEnabled: $notifications,
        fontSize: $fontSize,
        selectedTheme: $theme,
        language: $language
    )
    .preferredColorScheme(.dark)
}


// === 8c. Multi-Step Form (Stepper/Wizard) ===
struct OnboardingStepView: View {
    @Binding var currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 24) {
            // Progress
            ProgressView(value: Double(currentStep), total: Double(totalSteps))
                .padding(.horizontal)
            
            Text("Bước \(currentStep) / \(totalSteps)")
                .font(.headline)
            
            Spacer()
            
            // Content per step
            Group {
                switch currentStep {
                case 1: Text("👋 Chào mừng!").font(.largeTitle)
                case 2: Text("📝 Nhập thông tin").font(.largeTitle)
                case 3: Text("✅ Hoàn tất!").font(.largeTitle)
                default: Text("Unknown step")
                }
            }
            
            Spacer()
            
            // Navigation
            HStack {
                if currentStep > 1 {
                    Button("Quay lại") {
                        withAnimation { currentStep -= 1 }
                    }
                }
                
                Spacer()
                
                if currentStep < totalSteps {
                    Button("Tiếp theo") {
                        withAnimation { currentStep += 1 }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
}

#Preview("Onboarding - Step 1") {
    @Previewable @State var step = 1
    OnboardingStepView(currentStep: $step, totalSteps: 3)
}

#Preview("Onboarding - Step 2") {
    @Previewable @State var step = 2
    OnboardingStepView(currentStep: $step, totalSteps: 3)
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. SO SÁNH CÁC CÁCH VIẾT PREVIEW QUA TỪNG THỜI KỲ       ║
// ╚══════════════════════════════════════════════════════════╝

// ┌─────────────────────────────────────────────────────────┐
// │ iOS 13 (2019): PreviewProvider protocol                 │
// │                                                         │
// │ struct RatingView_Previews: PreviewProvider {            │
// │     struct Wrapper: View {                              │
// │         @State var rating = 3                           │
// │         var body: some View {                           │
// │             RatingView(rating: $rating, maxRating: 5)   │
// │         }                                               │
// │     }                                                   │
// │     static var previews: some View {                    │
// │         Wrapper()                                       │
// │             .previewDisplayName("Interactive")          │
// │     }                                                   │
// │ }                                                       │
// │ → 12 dòng, 2 struct lồng nhau, verbose                  │
// └─────────────────────────────────────────────────────────┘
//
// ┌─────────────────────────────────────────────────────────┐
// │ iOS 17 (2023): #Preview macro (không có @Previewable)   │
// │                                                         │
// │ #Preview("Interactive") {                               │
// │     struct Wrapper: View {                              │
// │         @State var rating = 3                           │
// │         var body: some View {                           │
// │             RatingView(rating: $rating, maxRating: 5)   │
// │         }                                               │
// │     }                                                   │
// │     return Wrapper()                                    │
// │ }                                                       │
// │ → 9 dòng, vẫn cần wrapper struct                        │
// └─────────────────────────────────────────────────────────┘
//
// ┌─────────────────────────────────────────────────────────┐
// │ iOS 18 (2024): #Preview + @Previewable ✅               │
// │                                                         │
// │ #Preview("Interactive") {                               │
// │     @Previewable @State var rating = 3                  │
// │     RatingView(rating: $rating, maxRating: 5)           │
// │ }                                                       │
// │ → 3 dòng, không wrapper, fully interactive 🎉           │
// └─────────────────────────────────────────────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  10. BEST PRACTICES                                      ║
// ╚══════════════════════════════════════════════════════════╝

// 1. LUÔN dùng @Previewable thay vì .constant() cho @Binding
//    .constant() chỉ nên dùng khi muốn test static snapshot
//    @Previewable @State cho test tương tác thực tế

// 2. TẠO NHIỀU PREVIEW cho các states khác nhau
//    - Empty state, populated state, error state
//    - Light/Dark mode
//    - Accessibility sizes
//    - Landscape/Portrait

// 3. ĐẶT TÊN mô tả cho mỗi Preview
//    #Preview("Login - Error State") { ... }
//    #Preview("Login - Loading") { ... }
//    Giúp navigate nhanh trong Preview canvas

// 4. KẾT HỢP @Previewable với .environment() cho context đầy đủ
//    #Preview("With Theme") {
//        @Previewable @State var x = 0
//        MyView(value: $x)
//            .environment(ThemeManager())
//            .environment(\.locale, Locale(identifier: "vi"))
//    }

// 5. TÁCH PREVIEW ra file riêng cho components phức tạp
//    Tạo file RatingView+Preview.swift chứa tất cả Preview scenarios
//    → File chính sạch, Preview code dễ maintain

// 6. @Previewable KHÔNG thay thế Unit Test
//    Preview để kiểm tra visual + interaction nhanh
//    Unit Test để verify logic chính xác
//    → Dùng cả hai, bổ sung cho nhau

----

Đây là một macro khá mới mà Apple giới thiệu ở WWDC 2024, giải quyết một pain point lớn khi viết Preview. Mình sẽ giải thích từ gốc vấn đề đến cách dùng nâng cao.Mình đã tổng hợp toàn bộ kiến thức về `@Previewable` trong 10 phần. Đây là những điểm cốt lõi:

**Bản chất vấn đề:** Trước Xcode 16, khi component nhận `@Binding`, bạn chỉ có 2 lựa chọn tệ — dùng `.constant()` thì không test được interaction, hoặc tạo wrapper struct riêng thì quá verbose. Mỗi component cần preview interactive = thêm 1 boilerplate struct.

**`@Previewable` giải quyết triệt để** bằng cách cho phép viết `@State`, `@FocusState` trực tiếp trong `#Preview` block. Under the hood, nó chỉ là macro tự generate wrapper view ẩn — không có runtime magic, performance giống hệt cách viết tay.

**Hai điểm hay nhất mà mình muốn nhấn mạnh:**

Ở **Phần 4** — khả năng khai báo **nhiều `@Previewable` cùng lúc**. Ví dụ component Settings có 4 bindings (notifications, fontSize, theme, language), bạn khai báo 4 dòng `@Previewable @State` và tất cả đều interactive. Trước đây cần wrapper struct với 4 `@State` properties + body + return.

Ở **Phần 9** — bảng so sánh qua 3 thời kỳ cho thấy evolution rõ rệt: từ 12 dòng (iOS 13) → 9 dòng (iOS 17) → **3 dòng** (iOS 18). Đây là improvement đáng kể cho developer experience hàng ngày.

**Lưu ý quan trọng:** `@Previewable` chỉ hoạt động với `@State` và `@FocusState`, không dùng được với `@StateObject`, `@ObservedObject`, hay `@EnvironmentObject`. Với iOS 17+ thì không thành vấn đề vì đã chuyển sang `@Observable` + `@State`.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
