```
// ============================================================
// BUTTON TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// Button là interactive control cơ bản nhất — user tap → action.
// SwiftUI cung cấp hệ thống ButtonStyle phong phú + khả năng
// custom hoàn toàn, cùng các biến thể: Menu, Link,
// ShareLink, EditButton, RenameButton...
// ============================================================
```
```Swift
import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÚ PHÁP & CÁC INITIALIZER                           ║
// ╚══════════════════════════════════════════════════════════╝

struct BasicButtonDemo: View {
    @State private var count = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(count)").font(.title)
            
            // === 1a. String label + action ===
            Button("Tăng") {
                count += 1
            }
            
            // === 1b. Action + Label view builder ===
            Button {
                count -= 1
            } label: {
                Label("Giảm", systemImage: "minus.circle")
            }
            
            // === 1c. Label phức tạp ===
            Button {
                count = 0
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset")
                        .font(.headline)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.red, in: .capsule)
                .foregroundStyle(.white)
            }
            
            // === 1d. Role-based buttons (iOS 15+) ===
            // role ảnh hưởng style + accessibility
            Button("Xoá", role: .destructive) {
                count = 0
            }
            // role: .destructive → text đỏ, VoiceOver báo "destructive"
            // role: .cancel → style cancel trong alert/dialog
            // role: nil → mặc định
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. BUILT-IN BUTTON STYLES                               ║
// ╚══════════════════════════════════════════════════════════╝

struct ButtonStylesShowcase: View {
    var body: some View {
        VStack(spacing: 16) {
            
            // === 2a. .automatic (Default) ===
            // Platform tự chọn style phù hợp theo context
            Button("Automatic") { }
                .buttonStyle(.automatic)
            
            // === 2b. .plain ===
            // Không có highlight effect khi tap
            // Chỉ text thuần tuý, không background
            Button("Plain") { }
                .buttonStyle(.plain)
            
            // === 2c. .borderless (iOS 15+) ===
            // Text có tint color, không border
            // Giống link style — default trong nhiều context
            Button("Borderless") { }
                .buttonStyle(.borderless)
            
            // === 2d. .bordered (iOS 15+) ===
            // Rounded rect background mờ nhạt
            // Phổ biến nhất cho secondary actions
            Button("Bordered") { }
                .buttonStyle(.bordered)
            
            // === 2e. .borderedProminent (iOS 15+) ===
            // Background đậm (filled), text trắng
            // Dùng cho PRIMARY action (CTA)
            Button("Bordered Prominent") { }
                .buttonStyle(.borderedProminent)
            
            // === Role + Style kết hợp ===
            HStack(spacing: 12) {
                Button("Delete", role: .destructive) { }
                    .buttonStyle(.bordered)
                // → background đỏ nhạt
                
                Button("Delete", role: .destructive) { }
                    .buttonStyle(.borderedProminent)
                // → background đỏ đậm, text trắng
                
                Button("Cancel", role: .cancel) { }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

// ┌──────────────────────┬──────────┬───────────────────────────┐
// │ Style                │ Min iOS  │ Mô tả                    │
// ├──────────────────────┼──────────┼───────────────────────────┤
// │ .automatic           │ 13       │ Platform tự chọn          │
// │ .plain               │ 13       │ Không effect, text thuần  │
// │ .borderless          │ 15       │ Text + tint, không border │
// │ .bordered            │ 15       │ Background mờ, có border  │
// │ .borderedProminent   │ 15       │ Background đậm (Primary) │
// └──────────────────────┴──────────┴───────────────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  3. TINT, SIZE & SHAPE CUSTOMIZATION                     ║
// ╚══════════════════════════════════════════════════════════╝

struct ButtonCustomizationDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            
            // === 3a. .tint() — Đổi màu ===
            HStack(spacing: 12) {
                Button("Mặc định") { }
                    .buttonStyle(.borderedProminent)
                
                Button("Tím") { }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                
                Button("Cam") { }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                
                Button("Xanh lá") { }
                    .buttonStyle(.bordered)
                    .tint(.green)
            }
            
            // === 3b. .controlSize — Kích thước ===
            VStack(spacing: 10) {
                Button("Mini") { }
                    .controlSize(.mini)
                    .buttonStyle(.bordered)
                
                Button("Small") { }
                    .controlSize(.small)
                    .buttonStyle(.bordered)
                
                Button("Regular (Default)") { }
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                
                Button("Large") { }
                    .controlSize(.large)
                    .buttonStyle(.bordered)
                
                Button("Extra Large") { }
                    .controlSize(.extraLarge) // iOS 17+
                    .buttonStyle(.borderedProminent)
            }
            
            // === 3c. .buttonBorderShape — Hình dạng ===
            HStack(spacing: 12) {
                Button("Auto") { }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.automatic)
                
                Button("Capsule") { }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                
                Button("RoundedRect") { }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: 8))
                
                // iOS 17+
                Button { } label: {
                    Image(systemName: "circle")
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
            }
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. DISABLED, HIDDEN & CONDITIONAL BUTTONS               ║
// ╚══════════════════════════════════════════════════════════╝

struct ButtonStatesDemo: View {
    @State private var text = ""
    @State private var agreed = false
    @State private var isLoading = false
    
    var isFormValid: Bool {
        !text.isEmpty && agreed
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Nhập tên", text: $text)
                Toggle("Đồng ý điều khoản", isOn: $agreed)
            }
            
            Section {
                // === 4a. .disabled — Mờ + không tap được ===
                Button("Gửi") { }
                    .disabled(!isFormValid)
                    // Khi disabled: mờ đi, tap không trigger action
                    // VoiceOver: "dimmed"
                
                // === 4b. Conditional visibility ===
                if isFormValid {
                    Button("Xác nhận nâng cao") { }
                        .buttonStyle(.borderedProminent)
                }
                
                // === 4c. Loading state ===
                Button {
                    isLoading = true
                    // Simulate async work
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .controlSize(.small)
                        }
                        Text(isLoading ? "Đang xử lý..." : "Bắt đầu")
                    }
                }
                .disabled(isLoading)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. BUTTON TRONG CÁC CONTEXT KHÁC NHAU                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 5a. Toolbar ===
struct ToolbarButtonsDemo: View {
    var body: some View {
        NavigationStack {
            Text("Content")
                .navigationTitle("Trang chủ")
                .toolbar {
                    // Trailing
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { } label: {
                            Image(systemName: "plus")
                        }
                    }
                    
                    // Leading
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Sửa") { }
                    }
                    
                    // Bottom bar
                    ToolbarItem(placement: .bottomBar) {
                        Button { } label: {
                            Label("Chia sẻ", systemImage: "square.and.arrow.up")
                        }
                    }
                }
        }
    }
}

// === 5b. Swipe Actions (List) ===
struct SwipeActionDemo: View {
    @State private var items = ["Item 1", "Item 2", "Item 3"]
    
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button("Xoá", role: .destructive) {
                            items.removeAll { $0 == item }
                        }
                        
                        Button("Ghim") { }
                            .tint(.orange)
                    }
                    .swipeActions(edge: .leading) {
                        Button("Đã đọc") { }
                            .tint(.blue)
                    }
            }
        }
    }
}

// === 5c. Context Menu ===
struct ContextMenuDemo: View {
    @State private var isFavorite = false
    
    var body: some View {
        Text("Long press me")
            .padding()
            .background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
            .contextMenu {
                Button { } label: {
                    Label("Sao chép", systemImage: "doc.on.doc")
                }
                
                Button {
                    isFavorite.toggle()
                } label: {
                    Label(
                        isFavorite ? "Bỏ yêu thích" : "Yêu thích",
                        systemImage: isFavorite ? "heart.fill" : "heart"
                    )
                }
                
                Divider()
                
                Button(role: .destructive) { } label: {
                    Label("Xoá", systemImage: "trash")
                }
            }
    }
}

// === 5d. Alert & ConfirmationDialog ===
struct AlertButtonDemo: View {
    @State private var showAlert = false
    @State private var showDialog = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Alert
            Button("Xoá tài khoản") { showAlert = true }
                .foregroundStyle(.red)
            
            // Confirmation Dialog (Action Sheet replacement)
            Button("Tuỳ chọn") { showDialog = true }
        }
        .alert("Xác nhận xoá?", isPresented: $showAlert) {
            Button("Huỷ", role: .cancel) { }
            Button("Xoá", role: .destructive) {
                // Perform delete
            }
        } message: {
            Text("Hành động này không thể hoàn tác.")
        }
        .confirmationDialog("Chọn hành động", isPresented: $showDialog) {
            Button("Chụp ảnh") { }
            Button("Chọn từ thư viện") { }
            Button("Huỷ", role: .cancel) { }
        }
    }
}

// === 5e. Menu Button (Dropdown) ===
struct MenuButtonDemo: View {
    var body: some View {
        // Menu: tap → popup nhiều options
        Menu {
            Button { } label: {
                Label("Mới nhất", systemImage: "clock")
            }
            Button { } label: {
                Label("Phổ biến", systemImage: "flame")
            }
            
            // Nested menu
            Menu("Sắp xếp theo") {
                Button("Tên A-Z") { }
                Button("Ngày tạo") { }
                Button("Kích thước") { }
            }
            
            Divider()
            
            Button(role: .destructive) { } label: {
                Label("Xoá bộ lọc", systemImage: "trash")
            }
        } label: {
            // Trigger button
            Label("Bộ lọc", systemImage: "line.3.horizontal.decrease.circle")
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. SPECIAL BUTTON TYPES                                 ║
// ╚══════════════════════════════════════════════════════════╝

struct SpecialButtonsDemo: View {
    @State private var url = URL(string: "https://apple.com")!
    
    var body: some View {
        VStack(spacing: 16) {
            
            // === 6a. Link — Mở URL ===
            Link("Mở Apple.com", destination: url)
            
            Link(destination: url) {
                Label("Trang web", systemImage: "safari")
            }
            
            // === 6b. ShareLink (iOS 16+) ===
            ShareLink(item: url) {
                Label("Chia sẻ", systemImage: "square.and.arrow.up")
            }
            
            // ShareLink với preview
            ShareLink(
                item: url,
                subject: Text("Bài viết hay"),
                message: Text("Xem bài này đi!")
            ) {
                Label("Chia sẻ bài viết", systemImage: "paperplane")
            }
            
            // === 6c. EditButton — Toggle List edit mode ===
            // Tự động toggle editMode trong environment
            EditButton()
            
            // === 6d. RenameButton (iOS 16+) ===
            // Trigger rename action trong .renameAction context
            // RenameButton()
            
            // === 6e. NavigationLink — Navigate ===
            NavigationStack {
                NavigationLink("Chi tiết") {
                    Text("Detail Screen")
                }
                
                // Value-based navigation (iOS 16+)
                NavigationLink(value: "detail") {
                    Text("Navigate with value")
                }
            }
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. CUSTOM BUTTON STYLE — TẠO STYLE RIÊNG               ║
// ╚══════════════════════════════════════════════════════════╝

// ButtonStyle protocol:
// - makeBody(configuration:) → some View
// - configuration.label: Button content
// - configuration.isPressed: Bool (đang nhấn?)
// - configuration.role: ButtonRole? (destructive, cancel)

// === 7a. Scale Effect Style ===

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ScaleButtonStyle {
    static var scale: ScaleButtonStyle { ScaleButtonStyle() }
}


// === 7b. Primary CTA Style ===

struct PrimaryCTAStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isEnabled
                            ? (configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
                            : Color.gray.opacity(0.4)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryCTAStyle {
    static var primaryCTA: PrimaryCTAStyle { PrimaryCTAStyle() }
}


// === 7c. Ghost / Outline Style ===

struct GhostButtonStyle: ButtonStyle {
    var color: Color = .blue
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .strokeBorder(color, lineWidth: 1.5)
                    .background(
                        Capsule()
                            .fill(configuration.isPressed ? color.opacity(0.1) : .clear)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GhostButtonStyle {
    static var ghost: GhostButtonStyle { GhostButtonStyle() }
    static func ghost(_ color: Color) -> GhostButtonStyle { GhostButtonStyle(color: color) }
}


// === 7d. Card Button Style ===

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
                    .shadow(
                        color: .black.opacity(configuration.isPressed ? 0.15 : 0.08),
                        radius: configuration.isPressed ? 2 : 8,
                        y: configuration.isPressed ? 1 : 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == CardButtonStyle {
    static var card: CardButtonStyle { CardButtonStyle() }
}


// === 7e. Role-Aware Style (kiểm tra destructive) ===

struct RoleAwareStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        let isDestructive = configuration.role == .destructive
        let baseColor: Color = isDestructive ? .red : .blue
        
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(
                    isEnabled
                        ? (configuration.isPressed ? baseColor.opacity(0.8) : baseColor)
                        : .gray.opacity(0.3)
                )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}


// === Demo tất cả custom styles ===
#Preview("Custom Styles") {
    VStack(spacing: 16) {
        Button("Scale Effect") { }
            .buttonStyle(.scale)
        
        Button("Primary CTA") { }
            .buttonStyle(.primaryCTA)
            .padding(.horizontal)
        
        Button("Primary Disabled") { }
            .buttonStyle(.primaryCTA)
            .disabled(true)
            .padding(.horizontal)
        
        HStack(spacing: 12) {
            Button("Ghost Blue") { }
                .buttonStyle(.ghost)
            Button("Ghost Red") { }
                .buttonStyle(.ghost(.red))
        }
        
        Button {
        } label: {
            HStack {
                Image(systemName: "creditcard")
                    .font(.title3)
                VStack(alignment: .leading) {
                    Text("Visa •••• 4242").font(.headline)
                    Text("Hết hạn 12/26").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.card)
        .padding(.horizontal)
    }
    .padding()
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. PrimitiveButtonStyle — KIỂM SOÁT TRIGGER ACTION     ║
// ╚══════════════════════════════════════════════════════════╝

// ButtonStyle: chỉ custom GIAO DIỆN, tap vẫn trigger action tự động
// PrimitiveButtonStyle: kiểm soát KHI NÀO action được trigger
// → Dùng cho: long press, double tap, swipe-to-confirm...

// === 8a. Long Press Button ===

struct LongPressButtonStyle: PrimitiveButtonStyle {
    var minimumDuration: Double = 0.5
    
    func makeBody(configuration: Configuration) -> some View {
        LongPressButtonView(
            configuration: configuration,
            minimumDuration: minimumDuration
        )
    }
}

private struct LongPressButtonView: View {
    let configuration: PrimitiveButtonStyle.Configuration
    let minimumDuration: Double
    
    @State private var isPressed = false
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    
    var body: some View {
        configuration.label
            .opacity(isPressed ? 0.8 : 1.0)
            .overlay(alignment: .bottom) {
                // Progress bar khi đang nhấn giữ
                GeometryReader { geo in
                    Rectangle()
                        .fill(.blue)
                        .frame(width: geo.size.width * progress, height: 3)
                }
                .frame(height: 3)
            }
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isPressed else { return }
                        isPressed = true
                        startTimer()
                    }
                    .onEnded { _ in
                        cancelTimer()
                        isPressed = false
                        withAnimation { progress = 0 }
                    }
            )
            .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    private func startTimer() {
        let interval = 0.02
        let steps = minimumDuration / interval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { t in
            progress += 1.0 / steps
            if progress >= 1.0 {
                cancelTimer()
                isPressed = false
                progress = 0
                configuration.trigger() // ← Trigger action thủ công
            }
        }
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview("Long Press Button") {
    @Previewable @State var message = "Nhấn giữ để xoá"
    
    VStack(spacing: 20) {
        Text(message)
        Button("Xoá dữ liệu") {
            message = "Đã xoá! ✅"
        }
        .buttonStyle(LongPressButtonStyle(minimumDuration: 1.0))
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
        .background(.red.opacity(0.1), in: .rect(cornerRadius: 12))
    }
    .padding()
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. ASYNC BUTTON — XỬ LÝ BẤT ĐỒNG BỘ                   ║
// ╚══════════════════════════════════════════════════════════╝

// === 9a. Reusable AsyncButton Component ===

struct AsyncButton<Label: View>: View {
    let action: () async -> Void
    @ViewBuilder let label: () -> Label
    
    @State private var isRunning = false
    
    var body: some View {
        Button {
            guard !isRunning else { return }
            isRunning = true
            Task {
                await action()
                isRunning = false
            }
        } label: {
            // Swap label ↔ ProgressView
            ZStack {
                label()
                    .opacity(isRunning ? 0 : 1)
                
                ProgressView()
                    .controlSize(.small)
                    .opacity(isRunning ? 1 : 0)
            }
        }
        .disabled(isRunning)
        .animation(.easeInOut(duration: 0.2), value: isRunning)
    }
}

// === 9b. AsyncButton với Result handling ===

struct AsyncResultButton<Label: View>: View {
    let action: () async throws -> Void
    @ViewBuilder let label: () -> Label
    
    enum ButtonState {
        case idle, loading, success, error
    }
    
    @State private var state: ButtonState = .idle
    
    var body: some View {
        Button {
            guard state == .idle || state == .error else { return }
            state = .loading
            Task {
                do {
                    try await action()
                    state = .success
                    // Reset sau 2 giây
                    try? await Task.sleep(for: .seconds(2))
                    state = .idle
                } catch {
                    state = .error
                    try? await Task.sleep(for: .seconds(2))
                    state = .idle
                }
            }
        } label: {
            ZStack {
                label().opacity(state == .idle ? 1 : 0)
                
                switch state {
                case .loading:
                    ProgressView().controlSize(.small)
                case .success:
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                case .error:
                    Image(systemName: "xmark")
                        .foregroundStyle(.red)
                        .transition(.scale.combined(with: .opacity))
                case .idle:
                    EmptyView()
                }
            }
            .animation(.spring(duration: 0.3), value: state)
        }
        .disabled(state == .loading)
    }
}

#Preview("Async Buttons") {
    VStack(spacing: 20) {
        // Basic async
        AsyncButton {
            try? await Task.sleep(for: .seconds(2))
        } label: {
            Text("Lưu")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        
        // With result
        AsyncResultButton {
            try await Task.sleep(for: .seconds(1.5))
            if Bool.random() { throw URLError(.badServerResponse) }
        } label: {
            Text("Gửi yêu cầu")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
    .padding()
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. SENSORY FEEDBACK & HAPTICS                          ║
// ╚══════════════════════════════════════════════════════════╝

struct HapticButtonDemo: View {
    @State private var liked = false
    @State private var count = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // === iOS 17+: .sensoryFeedback ===
            Button {
                liked.toggle()
            } label: {
                Image(systemName: liked ? "heart.fill" : "heart")
                    .font(.title)
                    .foregroundStyle(liked ? .red : .gray)
                    .contentTransition(.symbolEffect(.replace))
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: liked)
            // Haptic "thump" mỗi lần tap
            
            // Các loại haptic:
            Button("Selection") { count += 1 }
                .sensoryFeedback(.selection, trigger: count)
            // .selection → nhẹ, picker-like
            
            Button("Success") { count += 1 }
                .sensoryFeedback(.success, trigger: count)
            // .success → pattern thành công
            
            Button("Warning") { count += 1 }
                .sensoryFeedback(.warning, trigger: count)
            // .warning → pattern cảnh báo
            
            Button("Error") { count += 1 }
                .sensoryFeedback(.error, trigger: count)
            // .error → pattern lỗi
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. BUTTON REPEAT BEHAVIOR (iOS 17+)                    ║
// ╚══════════════════════════════════════════════════════════╝

struct RepeatButtonDemo: View {
    @State private var value = 0
    
    var body: some View {
        HStack(spacing: 24) {
            // Nhấn GIỮ → action fire liên tục (stepper-like)
            Button {
                value -= 1
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title)
            }
            .buttonRepeatBehavior(.enabled)
            // Nhấn giữ → value giảm liên tục!
            
            Text("\(value)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .frame(minWidth: 60)
            
            Button {
                value += 1
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
            }
            .buttonRepeatBehavior(.enabled)
        }
        .sensoryFeedback(.selection, trigger: value)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  12. keyboardShortcut — PHÍM TẮT (iPadOS / macOS)       ║
// ╚══════════════════════════════════════════════════════════╝

struct KeyboardShortcutDemo: View {
    var body: some View {
        VStack(spacing: 12) {
            // ⌘S → Save
            Button("Lưu") { }
                .keyboardShortcut("s", modifiers: .command)
            
            // ⌘⇧N → New
            Button("Tạo mới") { }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            
            // Return/Enter → Primary action
            Button("Gửi") { }
                .keyboardShortcut(.defaultAction) // Return key
            
            // Escape → Cancel
            Button("Huỷ", role: .cancel) { }
                .keyboardShortcut(.cancelAction) // Escape key
            
            // ⌘⌫ → Delete
            Button("Xoá", role: .destructive) { }
                .keyboardShortcut(.delete, modifiers: .command)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  13. PRODUCTION PATTERNS                                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 13a. Button Group — Primary + Secondary ===

struct ButtonGroup: View {
    let primaryTitle: String
    let secondaryTitle: String
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: primaryAction) {
                HStack {
                    if isLoading { ProgressView().controlSize(.small) }
                    Text(primaryTitle)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.primaryCTA)
            .disabled(isLoading)
            
            Button(secondaryTitle, action: secondaryAction)
                .font(.subheadline)
                .foregroundStyle(.blue)
        }
    }
}


// === 13b. Floating Action Button (FAB) ===

struct FABButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(.blue.gradient, in: .circle)
                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
        }
        .buttonStyle(.scale)
        .sensoryFeedback(.impact(weight: .medium), trigger: UUID())
    }
}

struct FABDemo: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack { ForEach(0..<30) { i in Text("Row \(i)").padding() } }
            }
            
            FABButton(icon: "plus") { }
                .padding(20)
        }
    }
}


// === 13c. Destructive Confirmation Pattern ===

struct DestructiveButton: View {
    let title: String
    let message: String
    let action: () -> Void
    
    @State private var showConfirmation = false
    
    var body: some View {
        Button(title, role: .destructive) {
            showConfirmation = true
        }
        .confirmationDialog(
            "Xác nhận",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button(title, role: .destructive, action: action)
            Button("Huỷ", role: .cancel) { }
        } message: {
            Text(message)
        }
    }
}


// === 13d. Social Action Bar ===

struct SocialActionBar: View {
    @State private var isLiked = false
    @State private var likeCount = 42
    @State private var isBookmarked = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Like
            Button {
                isLiked.toggle()
                likeCount += isLiked ? 1 : -1
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(isLiked ? .red : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                    Text("\(likeCount)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText(value: Double(likeCount)))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .sensoryFeedback(.impact(weight: .light), trigger: isLiked)
            
            // Comment
            Button { } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                    Text("12")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            
            // Share
            ShareLink(item: URL(string: "https://example.com")!) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Chia sẻ")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            
            // Bookmark
            Button {
                isBookmarked.toggle()
            } label: {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundStyle(isBookmarked ? .blue : .secondary)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .sensoryFeedback(.selection, trigger: isBookmarked)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isLiked)
        .animation(.easeInOut(duration: 0.2), value: isBookmarked)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  14. ACCESSIBILITY                                       ║
// ╚══════════════════════════════════════════════════════════╝

struct AccessibleButtonDemo: View {
    @State private var isMuted = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Built-in: Button đã accessible (focusable, activatable)
            Button("Đơn giản") { }
            // VoiceOver: "Đơn giản, button"
            
            // Custom label cho icon-only buttons
            Button { isMuted.toggle() } label: {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.title2)
            }
            .accessibilityLabel(isMuted ? "Bật âm thanh" : "Tắt âm thanh")
            .accessibilityHint("Tap đôi để thay đổi")
            // ⚠️ Icon-only buttons BẮT BUỘC cần accessibilityLabel
            // Không có label → VoiceOver đọc: "button" (vô nghĩa!)
            
            // Grouping nhiều elements thành 1 button
            Button { } label: {
                HStack {
                    Image(systemName: "person.fill")
                    VStack(alignment: .leading) {
                        Text("Huy Nguyen")
                        Text("Online").font(.caption)
                    }
                }
            }
            .accessibilityElement(children: .combine)
            // VoiceOver đọc gộp: "Huy Nguyen, Online, button"
            
            // Minimum tap target: Apple yêu cầu 44x44pt
            Button { } label: {
                Image(systemName: "xmark")
                    .font(.caption) // Icon nhỏ...
            }
            .frame(minWidth: 44, minHeight: 44) // ...nhưng vùng tap đủ lớn
        }
    }
}
```

```
// ╔══════════════════════════════════════════════════════════╗
// ║  15. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Tap area quá nhỏ
//    Button { } label: { Image(systemName: "xmark").font(.system(size: 10)) }
//    → Rất khó tap trên device thật
//    ✅ FIX: .frame(minWidth: 44, minHeight: 44)
//            hoặc .padding() mở rộng vùng tap

// ❌ PITFALL 2: Nhiều Button trong List row → chỉ 1 hoạt động
//    List { HStack { Button("A"); Button("B") } }
//    → Tap bất kỳ đâu trên row → chỉ trigger button đầu tiên
//    ✅ FIX: .buttonStyle(.borderless) hoặc .plain cho TỪNG button
//            → SwiftUI tách vùng tap riêng biệt

// ❌ PITFALL 3: Button trong NavigationLink
//    NavigationLink { DetailView() } label: {
//        HStack { Text("Row"); Button("Action") { } }
//    }
//    → Tap Button cũng trigger navigation
//    ✅ FIX: Dùng .swipeActions hoặc tách Button ra khỏi NavigationLink

// ❌ PITFALL 4: Async work block main thread
//    Button("Load") { let data = syncNetworkCall() }
//    ✅ FIX: Task { await asyncCall() } trong action
//            Hoặc dùng AsyncButton component (Phần 9)

// ❌ PITFALL 5: Quên disabled state cho form validation
//    Button("Submit") { ... } // Luôn bấm được dù form rỗng!
//    ✅ FIX: .disabled(!isFormValid) + visual feedback rõ ràng

// ❌ PITFALL 6: Icon-only button thiếu accessibility label
//    Button { } label: { Image(systemName: "gear") }
//    → VoiceOver: "button" (không biết là gì)
//    ✅ FIX: .accessibilityLabel("Cài đặt")

// ✅ BEST PRACTICES:
// 1. .borderedProminent cho CTA chính, .bordered cho secondary
// 2. role: .destructive cho actions nguy hiểm (auto đỏ + accessible)
// 3. .controlSize + .buttonBorderShape cho consistent sizing
// 4. Custom ButtonStyle cho design system — TÁI SỬ DỤNG khắp app
// 5. PrimitiveButtonStyle khi cần custom trigger (long press, etc.)
// 6. AsyncButton pattern cho network calls + loading states
// 7. .sensoryFeedback cho actions quan trọng (like, delete, confirm)
// 8. .keyboardShortcut cho iPad/Mac (⌘S save, ⌘N new)
// 9. .buttonRepeatBehavior(.enabled) cho stepper-like buttons
// 10. Minimum 44x44pt tap target — Apple HIG requirement
// 11. confirmationDialog cho destructive actions (không xoá thẳng)
// 12. .buttonStyle(.borderless) khi nhiều buttons trong List row
```
--- 

Button là component dùng nhiều nhất trong SwiftUI nhưng hệ thống ButtonStyle và các patterns nâng cao rất phong phú. Mình sẽ giải thích toàn bộ.Mình đã tổng hợp toàn bộ kiến thức Button trong 15 phần. Đây là những điểm cốt lõi:

**Hệ thống Button của SwiftUI** phong phú hơn nhiều so với UIKit — không chỉ là tap → action, mà bao gồm cả `ButtonStyle` protocol, `PrimitiveButtonStyle`, `role`, `.controlSize`, `.buttonBorderShape`, `.buttonRepeatBehavior`, `.keyboardShortcut`, cùng các biến thể như `Menu`, `Link`, `ShareLink`, `EditButton`.

**Bốn phần giá trị nhất cho production:**

**Phần 7 — Custom ButtonStyle**: Đây là cách xây dựng design system. `configuration.isPressed` cho phép tạo press animation (scale, opacity, shadow), `configuration.role` phân biệt destructive vs normal. Pattern hay nhất: đọc `@Environment(\.isEnabled)` trong style để thay đổi giao diện khi disabled — một chỗ define, apply khắp app.

**Phần 8 — PrimitiveButtonStyle**: Khác biệt then chốt với `ButtonStyle` là **kiểm soát khi nào action được trigger** thay vì chỉ custom giao diện. Long press button với progress bar là ví dụ điển hình — action chỉ fire sau khi nhấn giữ đủ thời gian, gọi `configuration.trigger()` thủ công.

**Phần 9 — AsyncButton**: Hai reusable components `AsyncButton` (loading spinner) và `AsyncResultButton` (loading → success/error → reset) giải quyết pattern phổ biến nhất trong production. Dùng `ZStack` + opacity swap giữ layout stable khi chuyển state.

**Pitfall #2 ở Phần 15** là gotcha lớn nhất: **nhiều Button trong List row** — mặc định SwiftUI chỉ cho 1 button hoạt động. Fix bằng `.buttonStyle(.borderless)` hoặc `.plain` cho từng button để tách vùng tap riêng biệt.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
