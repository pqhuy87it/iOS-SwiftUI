```Swift
// ============================================================
// ZSTACK TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// ZStack (Z-axis Stack) CHỒNG child views lên nhau theo trục Z
// (depth axis — từ SAU ra TRƯỚC màn hình).
//
// Child KHAI BÁO TRƯỚC → nằm DƯỚI (phía sau)
// Child KHAI BÁO SAU  → nằm TRÊN (phía trước)
//
// Khác biệt cốt lõi:
// - HStack: sắp xếp NGANG, children KHÔNG đè nhau
// - VStack: sắp xếp DỌC, children KHÔNG đè nhau
// - ZStack: CHỒNG LÊN NHAU, children CÓ THỂ đè nhau hoàn toàn
//
// Use cases: overlays, badges, backgrounds, cards, popups,
// loading states, onboarding, parallax, floating UI...
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÚ PHÁP & CƠ CHẾ LAYER                             ║
// ╚══════════════════════════════════════════════════════════╝

// ZStack(
//     alignment: Alignment = .center,
//     @ViewBuilder content: () -> Content
// )

struct BasicZStackDemo: View {
    var body: some View {
        VStack(spacing: 30) {
            
            // === 1a. Cơ bản: layers từ sau ra trước ===
            ZStack {
                // Layer 1 (SAU CÙNG — khai báo đầu tiên)
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue)
                    .frame(width: 160, height: 100)
                
                // Layer 2 (GIỮA)
                RoundedRectangle(cornerRadius: 12)
                    .fill(.green)
                    .frame(width: 120, height: 80)
                
                // Layer 3 (TRƯỚC NHẤT — khai báo cuối cùng)
                RoundedRectangle(cornerRadius: 12)
                    .fill(.orange)
                    .frame(width: 80, height: 60)
            }
            
            // === 1b. Thứ tự khai báo = Thứ tự layer ===
            ZStack {
                Color.gray.opacity(0.1)     // Layer 0: background
                
                Text("Giữa")               // Layer 1: content
                    .font(.title2.bold())
                
                // Layer 2: badge góc trên phải
                VStack {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(.red)
                            .frame(width: 20, height: 20)
                            .overlay(Text("3").font(.caption2).foregroundStyle(.white))
                    }
                    Spacer()
                }
                .padding(8)
            }
            .frame(width: 150, height: 80)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
}

// THỨ TỰ LAYER (Z-ORDER):
//
// ┌─────────────────────────────┐  ← Màn hình (user nhìn)
// │  Child cuối (layer trên)    │  ← Khai báo SAU → hiện TRÊN
// │  ┌───────────────────────┐  │
// │  │  Child giữa           │  │
// │  │  ┌─────────────────┐  │  │
// │  │  │  Child đầu      │  │  │  ← Khai báo TRƯỚC → hiện DƯỚI
// │  │  │  (layer dưới)   │  │  │
// │  │  └─────────────────┘  │  │
// │  └───────────────────────┘  │
// └─────────────────────────────┘
//
// Giống Photoshop layers: layer dưới cùng trong panel = nền


// ╔══════════════════════════════════════════════════════════╗
// ║  2. ALIGNMENT — CĂNG CHỈNH 2 CHIỀU                       ║
// ╚══════════════════════════════════════════════════════════╝

// ZStack alignment là Alignment (2D), KHÁC với:
// - HStack: VerticalAlignment (1 chiều dọc)
// - VStack: HorizontalAlignment (1 chiều ngang)
// - ZStack: Alignment (2 chiều: ngang + dọc)

struct AlignmentDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            let alignments: [(String, Alignment)] = [
                ("topLeading", .topLeading),
                ("top", .top),
                ("topTrailing", .topTrailing),
                ("leading", .leading),
                ("center", .center),
                ("trailing", .trailing),
                ("bottomLeading", .bottomLeading),
                ("bottom", .bottom),
                ("bottomTrailing", .bottomTrailing),
            ]
            
            // Grid 3x3 hiển thị tất cả alignments
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3),
                      spacing: 8) {
                ForEach(alignments, id: \.0) { name, alignment in
                    ZStack(alignment: alignment) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.gray.opacity(0.1))
                            .frame(width: 100, height: 70)
                        
                        // Content: nhỏ hơn background → thấy rõ alignment
                        Circle()
                            .fill(.blue)
                            .frame(width: 20, height: 20)
                    }
                    .overlay(alignment: .bottom) {
                        Text(name)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .offset(y: 12)
                    }
                }
            }
            .padding()
        }
    }
}

// 9 ALIGNMENT OPTIONS:
// ┌─────────────┬─────────────┬──────────────┐
// │ .topLeading │    .top     │ .topTrailing │
// ├─────────────┼─────────────┼──────────────┤
// │  .leading   │   .center   │  .trailing   │
// ├─────────────┼─────────────┼──────────────┤
// │.bottomLeading│  .bottom   │.bottomTrailing│
// └─────────────┴─────────────┴──────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  3. SIZING — CÁCH ZStack XÁC ĐỊNH KÍCH THƯỚC            ║
// ╚══════════════════════════════════════════════════════════╝

// ZStack sizing rule: kích thước = CHILD LỚN NHẤT
// (union bounding box của tất cả children)

struct SizingDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // === 3a. ZStack size = child lớn nhất ===
            ZStack {
                Color.red.opacity(0.2)          // Greedy: chiếm MỌI không gian
                    .frame(width: 200, height: 120)
                
                Text("Nhỏ hơn")                 // Nhỏ hơn
                    .padding()
                    .background(.blue.opacity(0.2))
            }
            .border(.gray)
            // ZStack rộng 200x120 (theo Color frame)
            
            // === 3b. Khi có greedy child (Color, Spacer...) ===
            ZStack {
                Color.green.opacity(0.1)
                // Color KHÔNG có intrinsic size → chiếm TOÀN BỘ available space
                // → ZStack mở rộng max
                
                Text("ZStack fills parent")
            }
            .frame(height: 60)
            .border(.gray)
            
            // === 3c. Giới hạn ZStack size ===
            ZStack {
                Color.orange.opacity(0.2)
                Text("Constrained")
            }
            .frame(width: 150, height: 80) // Giới hạn ZStack
            .clipShape(.rect(cornerRadius: 12))
            
            // === 3d. Khi TẤT CẢ children có fixed size ===
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.blue.opacity(0.2))
                    .frame(width: 120, height: 60)
                
                Text("OK")
                    .bold()
            }
            .border(.gray)
            // ZStack size = 120x60 (child lớn nhất)
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. ZStack vs .overlay vs .background                    ║
// ╚══════════════════════════════════════════════════════════╝

// 3 cách chồng views, KHÁC NHAU về sizing behavior:

struct OverlayVsZStack: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // === 4a. ZStack: size = child LỚN NHẤT ===
            ZStack {
                Rectangle().fill(.blue.opacity(0.2))
                    .frame(width: 200, height: 80)
                Text("ZStack")
            }
            .border(.red)
            // Kết quả: ZStack rộng 200x80 (theo Rectangle)
            
            // === 4b. .overlay: size = BASE VIEW ===
            Text("Base View")
                .padding()
                .background(.blue.opacity(0.2))
                .overlay(alignment: .topTrailing) {
                    Circle().fill(.red)
                        .frame(width: 20, height: 20)
                        .offset(x: 8, y: -8)
                }
            // Kết quả: size theo Text, Circle chồng lên nhưng
            // KHÔNG ảnh hưởng sizing → có thể tràn ra ngoài
            
            // === 4c. .background: size = BASE VIEW ===
            Text("Content")
                .padding(24)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green.opacity(0.2))
                    // Background tự co/dãn theo Text
                }
            // Kết quả: size theo Text, background co dãn theo
        }
    }
}

// ┌──────────────────┬──────────────────────────────────────┐
// │ Cách dùng        │ Sizing behavior                      │
// ├──────────────────┼──────────────────────────────────────┤
// │ ZStack           │ Size = CHILD LỚN NHẤT               │
// │                  │ Tất cả children ĐỀU ảnh hưởng size  │
// ├──────────────────┼──────────────────────────────────────┤
// │ .overlay         │ Size = BASE VIEW (view được overlay) │
// │                  │ Overlay content KHÔNG ảnh hưởng size │
// │                  │ → Dùng cho: badges, indicators       │
// ├──────────────────┼──────────────────────────────────────┤
// │ .background      │ Size = BASE VIEW (view phía trước)   │
// │                  │ Background KHÔNG ảnh hưởng size      │
// │                  │ → Dùng cho: fill, gradient, image    │
// └──────────────────┴──────────────────────────────────────┘
//
// 📌 NGUYÊN TẮC CHỌN:
// Cần layers ĐỒNG ĐẲNG (không ai là chính)    → ZStack
// Có BASE VIEW + thêm lớp TRÊN               → .overlay
// Có CONTENT + thêm lớp DƯỚI (nền)           → .background


// ╔══════════════════════════════════════════════════════════╗
// ║  5. zIndex — THAY ĐỔI THỨ TỰ LAYER RUNTIME             ║
// ╚══════════════════════════════════════════════════════════╝

// Mặc định: thứ tự layer = thứ tự khai báo.
// .zIndex() override thứ tự này tại runtime.
// Giá trị CAO hơn → hiển thị TRÊN.

struct ZIndexDemo: View {
    @State private var frontCardIndex = 2
    let colors: [Color] = [.red, .green, .blue]
    
    var body: some View {
        VStack(spacing: 30) {
            // Cards chồng nhau, tap để đưa lên trước
            ZStack {
                ForEach(0..<3) { i in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colors[i].gradient)
                        .frame(width: 160, height: 100)
                        .offset(x: CGFloat(i - 1) * 30,
                                y: CGFloat(i - 1) * 20)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        .zIndex(i == frontCardIndex ? 10 : Double(i))
                        // Card được chọn → zIndex 10 → lên TRÊN CÙNG
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3)) {
                                frontCardIndex = i
                            }
                        }
                        .overlay {
                            Text("Card \(i + 1)")
                                .foregroundStyle(.white)
                                .font(.headline)
                        }
                }
            }
            .frame(height: 180)
            
            Text("Tap card để đưa lên trước")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// zIndex RULES:
// - Mặc định tất cả children có zIndex = 0
// - Trong cùng zIndex → thứ tự khai báo quyết định (sau = trên)
// - zIndex CAO hơn LUÔN trên zIndex thấp hơn
// - Hữu ích khi cần dynamic reorder (card decks, drag&drop)
// - zIndex KHÔNG ảnh hưởng hit testing — view trên vẫn nhận tap trước


// ╔══════════════════════════════════════════════════════════╗
// ║  6. CONDITIONAL LAYERS & TRANSITIONS                     ║
// ╚══════════════════════════════════════════════════════════╝

struct ConditionalLayerDemo: View {
    @State private var showOverlay = false
    @State private var showBanner = false
    
    var body: some View {
        ZStack {
            // === Layer 0: Main content ===
            VStack(spacing: 20) {
                Text("Nội dung chính")
                    .font(.title2)
                
                Button("Toggle Overlay") {
                    withAnimation(.spring) { showOverlay.toggle() }
                }
                
                Button("Toggle Banner") {
                    withAnimation(.easeInOut) { showBanner.toggle() }
                }
            }
            
            // === Layer 1: Dimming overlay (conditional) ===
            if showOverlay {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring) { showOverlay = false }
                    }
                    .transition(.opacity)
                
                // === Layer 2: Modal card ===
                VStack(spacing: 16) {
                    Text("Modal Content")
                        .font(.headline)
                    Text("Tap nền tối để đóng")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("Đóng") {
                        withAnimation(.spring) { showOverlay = false }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(24)
                .background(.background, in: .rect(cornerRadius: 20))
                .shadow(radius: 20)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
                .padding(32)
            }
            
            // === Top banner (conditional) ===
            if showBanner {
                VStack {
                    Text("✅ Thao tác thành công!")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.green.gradient, in: .rect(cornerRadius: 12))
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. PRODUCTION PATTERNS                                   ║
// ╚══════════════════════════════════════════════════════════╝

// === 7a. Badge / Notification Indicator ===

struct BadgeOverlay: View {
    let count: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Base icon
            Image(systemName: "bell.fill")
                .font(.title2)
                .foregroundStyle(.primary)
            
            // Badge
            if count > 0 {
                Text(count > 99 ? "99+" : "\(count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(.red, in: .capsule)
                    .offset(x: 10, y: -8)
            }
        }
    }
}

#Preview("Badge") {
    HStack(spacing: 30) {
        BadgeOverlay(count: 3)
        BadgeOverlay(count: 42)
        BadgeOverlay(count: 150)
        BadgeOverlay(count: 0)
    }
    .padding()
}


// === 7b. Loading Overlay ===

struct LoadingOverlay<Content: View>: View {
    let isLoading: Bool
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            content()
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)
            
            if isLoading {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    ProgressView()
                        .controlSize(.large)
                    Text("Đang tải...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(24)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isLoading)
    }
}

#Preview("Loading") {
    @Previewable @State var loading = true
    
    LoadingOverlay(isLoading: loading) {
        List(0..<10) { i in Text("Row \(i)") }
    }
    .onTapGesture { loading.toggle() }
}


// === 7c. Image with Gradient Overlay (Hero Card) ===

struct HeroCard: View {
    let title: String
    let subtitle: String
    let category: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Layer 0: Background image
            Image(systemName: "photo.artframe")
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .background(.blue.gradient)
            
            // Layer 1: Gradient scrim cho text readability
            LinearGradient(
                colors: [.black.opacity(0.7), .clear],
                startPoint: .bottom,
                endPoint: .center
            )
            
            // Layer 2: Content
            VStack(alignment: .leading, spacing: 6) {
                Text(category.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.8))
                
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(20)
        }
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
    }
}

#Preview("Hero Card") {
    HeroCard(
        title: "SwiftUI Deep Dive",
        subtitle: "Khám phá layout system chi tiết",
        category: "iOS Development"
    )
    .padding()
}


// === 7d. Floating Action Button (FAB) ===

struct FABLayout: View {
    @State private var items = (1...20).map { "Item \($0)" }
    
    var body: some View {
        // ZStack đặt FAB TRÊN List
        ZStack(alignment: .bottomTrailing) {
            // Layer 0: Main content
            List(items, id: \.self) { item in
                Text(item)
            }
            
            // Layer 1: Floating button
            Button {
                items.append("Item \(items.count + 1)")
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.blue.gradient, in: .circle)
                    .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
            }
            .padding(20)
        }
    }
}


// === 7e. Toast / Snackbar ===

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let icon: String
    let style: ToastStyle
    
    enum ToastStyle {
        case success, error, info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if isPresented {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .foregroundStyle(style.color)
                    Text(message)
                        .font(.subheadline.weight(.medium))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: .capsule)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut) { isPresented = false }
                    }
                }
            }
        }
        .animation(.spring(duration: 0.4), value: isPresented)
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, message: String,
               icon: String = "checkmark.circle.fill",
               style: ToastModifier.ToastStyle = .success) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message,
                               icon: icon, style: style))
    }
}

#Preview("Toast") {
    @Previewable @State var showToast = true
    
    VStack {
        Button("Show Toast") {
            withAnimation { showToast = true }
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .toast(isPresented: $showToast, message: "Đã lưu thành công!")
}


// === 7f. Skeleton / Shimmer Loading ===

struct SkeletonCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Base skeleton shapes
            VStack(alignment: .leading, spacing: 12) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.15))
                    .frame(height: 160)
                
                // Title
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.15))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Subtitle
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.15))
                    .frame(width: 180, height: 12)
            }
            
            // Shimmer layer (gradient di chuyển)
            LinearGradient(
                colors: [.clear, .white.opacity(0.4), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: isAnimating ? 300 : -300)
            .mask(
                VStack(alignment: .leading, spacing: 12) {
                    RoundedRectangle(cornerRadius: 12).frame(height: 160)
                    RoundedRectangle(cornerRadius: 4).frame(height: 16)
                    RoundedRectangle(cornerRadius: 4).frame(width: 180, height: 12)
                }
            )
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
        .padding()
    }
}


// === 7g. Onboarding / Walkthrough Spotlight ===

struct SpotlightOverlay: View {
    let targetFrame: CGRect
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Layer 0: Dark overlay với "lỗ" spotlight
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .mask {
                    // Dùng eoFill để tạo cutout
                    Rectangle()
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(
                                    width: targetFrame.width + 16,
                                    height: targetFrame.height + 16
                                )
                                .position(
                                    x: targetFrame.midX,
                                    y: targetFrame.midY
                                )
                                .blendMode(.destinationOut)
                        }
                }
                .compositingGroup()
            
            // Layer 1: Tooltip
            VStack(spacing: 12) {
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                
                Button("Hiểu rồi", action: onDismiss)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
            .padding()
            .frame(maxWidth: 250)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
            .position(
                x: targetFrame.midX,
                y: targetFrame.maxY + 80
            )
        }
    }
}


// === 7h. Tab Content with Transition ===

struct TabTransitionDemo: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // Tab content
            ZStack {
                // Tất cả tab content nằm trong ZStack
                // Chỉ tab ĐƯỢC CHỌN mới hiện (opacity/transition)
                
                TabContentView(title: "Home", color: .blue)
                    .opacity(selectedTab == 0 ? 1 : 0)
                
                TabContentView(title: "Search", color: .green)
                    .opacity(selectedTab == 1 ? 1 : 0)
                
                TabContentView(title: "Profile", color: .orange)
                    .opacity(selectedTab == 2 ? 1 : 0)
            }
            .animation(.easeInOut(duration: 0.25), value: selectedTab)
            
            // Custom tab bar
            HStack(spacing: 0) {
                ForEach(0..<3) { i in
                    let icons = ["house.fill", "magnifyingglass", "person.fill"]
                    let labels = ["Home", "Search", "Profile"]
                    
                    Button {
                        selectedTab = i
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: icons[i])
                                .font(.title3)
                            Text(labels[i])
                                .font(.caption2)
                        }
                        .foregroundStyle(selectedTab == i ? .blue : .gray)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
    }
}

struct TabContentView: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.largeTitle.bold())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color.opacity(0.1))
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. GEOMETRY & COORDINATE SPACES                         ║
// ╚══════════════════════════════════════════════════════════╝

// ZStack kết hợp GeometryReader cho responsive layouts
// và custom positioning.

struct GeometryZStackDemo: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background pattern
                Color.gray.opacity(0.05).ignoresSafeArea()
                
                // Positioned elements dựa trên container size
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: geo.size.width * 0.6)
                    .offset(
                        x: -geo.size.width * 0.2,
                        y: -geo.size.height * 0.15
                    )
                
                Circle()
                    .fill(.purple.opacity(0.1))
                    .frame(width: geo.size.width * 0.4)
                    .offset(
                        x: geo.size.width * 0.25,
                        y: geo.size.height * 0.2
                    )
                
                // Main content
                VStack(spacing: 16) {
                    Text("Responsive ZStack")
                        .font(.title.bold())
                    Text("Width: \(Int(geo.size.width)) × Height: \(Int(geo.size.height))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 250)
        .clipShape(.rect(cornerRadius: 20))
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. ANIMATION PATTERNS VỚI ZStack                        ║
// ╚══════════════════════════════════════════════════════════╝

// === 9a. View Transitions (if/else) ===

struct ViewTransitionDemo: View {
    @State private var showDetail = false
    
    var body: some View {
        ZStack {
            // Cả 2 views nằm trong ZStack
            // SwiftUI animate transition khi chuyển đổi
            
            if !showDetail {
                VStack {
                    Text("Master View")
                        .font(.title)
                    Button("Show Detail") {
                        withAnimation(.spring(duration: 0.5)) {
                            showDetail = true
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                VStack {
                    Text("Detail View")
                        .font(.title)
                    Button("Back") {
                        withAnimation(.spring(duration: 0.5)) {
                            showDetail = false
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
    }
}


// === 9b. Expandable Card ===

struct ExpandableCard: View {
    @State private var isExpanded = false
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            if !isExpanded {
                // Compact state
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.blue.gradient)
                        .matchedGeometryEffect(id: "image", in: animation)
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading) {
                        Text("SwiftUI Guide")
                            .font(.headline)
                            .matchedGeometryEffect(id: "title", in: animation)
                        Text("Tap to expand")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(.background, in: .rect(cornerRadius: 16))
                .shadow(radius: 5)
                
            } else {
                // Expanded state
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.blue.gradient)
                        .matchedGeometryEffect(id: "image", in: animation)
                        .frame(height: 200)
                    
                    Text("SwiftUI Guide")
                        .font(.title.bold())
                        .matchedGeometryEffect(id: "title", in: animation)
                    
                    Text("ZStack cho phép chồng views lên nhau, tạo ra các layouts phức tạp, overlays, modals, và animated transitions.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding()
                .background(.background)
            }
        }
        .onTapGesture {
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                isExpanded.toggle()
            }
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. ignoresSafeArea & FULL-SCREEN PATTERNS              ║
// ╚══════════════════════════════════════════════════════════╝

struct FullScreenZStack: View {
    var body: some View {
        ZStack {
            // Layer 0: Full-screen background (kể cả safe area)
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()   // Phủ kín màn hình kể cả notch, home bar
            
            // Layer 1: Content (TÔN TRỌNG safe area)
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
                
                Text("Full Screen")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                Text("Background tràn safe area\nContent tôn trọng safe area")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))
                
                Spacer()
                Spacer()
            }
            // KHÔNG .ignoresSafeArea() → content nằm trong safe area
        }
    }
}

// NGUYÊN TẮC ignoresSafeArea TRONG ZStack:
//
// Background layer: .ignoresSafeArea()     ← Phủ kín
// Content layers: KHÔNG ignoresSafeArea    ← Trong safe area
//
// Đây là pattern chuẩn cho:
// - Splash screen
// - Onboarding
// - Login / Welcome screen
// - Image viewers


// ╔══════════════════════════════════════════════════════════╗
// ║  11. PERFORMANCE & NOTES                                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 11a. Hit Testing ===
// Trong ZStack, layer TRÊN CÙNG nhận tap gestures TRƯỚC.
// Layer dưới chỉ nhận tap nếu layer trên:
// - Transparent ở vị trí tap
// - Có .allowsHitTesting(false)
// - Có .disabled(true)

struct HitTestingDemo: View {
    var body: some View {
        ZStack {
            // Layer dưới — button
            Button("Background Button") {
                print("Background tapped")
            }
            .padding()
            .background(.blue.opacity(0.2), in: .rect(cornerRadius: 8))
            
            // Layer trên — chặn tap nếu KHÔNG allowsHitTesting(false)
            Color.red.opacity(0.1)
                .frame(width: 100, height: 100)
                .allowsHitTesting(false)
            // false → tap xuyên qua, button dưới nhận tap
            // true (mặc định) → chặn tap, button dưới KHÔNG nhận
        }
    }
}

// === 11b. Performance ===
// - ZStack render TẤT CẢ children, kể cả bị che khuất
//   → Tránh chồng quá nhiều heavy views (images, animations)
// - Conditional views (if/else) TỐT HƠN opacity(0)
//   vì views bị remove hoàn toàn khỏi render tree
// - Dùng .drawingGroup() cho complex layered graphics
//   → Flatten vào Metal texture, giảm compositing passes


// ╔══════════════════════════════════════════════════════════╗
// ║  12. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: ZStack lớn bất thường vì Color/Spacer
//    ZStack { Color.red; Text("Hello") }
//    → Color chiếm MỌI available space → ZStack mở rộng max
//    ✅ FIX: .frame(width:height:) giới hạn ZStack
//            Hoặc dùng .background(.red) trên Text thay vì ZStack

// ❌ PITFALL 2: Tap gesture bị chặn bởi layer trên
//    ZStack { Button("Tap me"); Color.clear }
//    → Color.clear vẫn chặn tap! (clear ≠ không có)
//    ✅ FIX: .allowsHitTesting(false) trên layer trên
//            Hoặc .contentShape(Rectangle()) chỉ cho layer cần tap

// ❌ PITFALL 3: Animation identity bị mất
//    ZStack { if showA { ViewA() } else { ViewB() } }
//    → Chuyển đổi: state RESET hoàn toàn (destroy + create)
//    ✅ FIX: .id() ổn định, hoặc .matchedGeometryEffect
//            Hoặc dùng .opacity thay if/else để GIỮ state

// ❌ PITFALL 4: .overlay thay vì ZStack cho badge
//    ZStack(alignment: .topTrailing) { Image(...); Badge() }
//    → Badge ảnh hưởng sizing của ZStack
//    ✅ FIX: Image(...).overlay(alignment: .topTrailing) { Badge() }
//            → Badge KHÔNG ảnh hưởng sizing

// ❌ PITFALL 5: Quá nhiều layers gây chậm
//    ZStack chồng 10+ images + blur + shadows
//    → GPU compositing nặng, drop frames
//    ✅ FIX: .drawingGroup() flatten layers
//            Hoặc giảm blur radius, shadow complexity

// ❌ PITFALL 6: ignoresSafeArea sai layer
//    ZStack { content; background.ignoresSafeArea() }
//    → background khai báo SAU → phủ lên content!
//    ✅ FIX: Đặt background TRƯỚC content trong ZStack
//            Hoặc dùng .background { ... .ignoresSafeArea() }

// ✅ BEST PRACTICES:
// 1. Background layer khai báo TRƯỚC, content layer SAU
// 2. .overlay cho badge/indicator (KHÔNG ảnh hưởng sizing)
// 3. .background cho nền (KHÔNG ảnh hưởng sizing)
// 4. ZStack chỉ khi cần layers ĐỒNG ĐẲNG
// 5. .zIndex() cho dynamic reordering (cards, drag&drop)
// 6. .allowsHitTesting(false) cho decorative overlay layers
// 7. .ignoresSafeArea() CHỈ cho background, KHÔNG cho content
// 8. Conditional views (if) tốt hơn opacity(0) cho performance
// 9. .transition() kết hợp withAnimation cho layer animation
// 10. .drawingGroup() khi có nhiều overlapping layers phức tạp
// 11. .compositingGroup() khi cần blend modes hoạt động đúng
// 12. ViewModifier cho reusable overlay patterns (toast, loading)
```

---

ZStack là container hoàn thành bộ ba layout cùng HStack/VStack, nhưng có cơ chế hoạt động và use cases hoàn toàn khác — trục Z (chồng lớp) thay vì ngang/dọc. Mình sẽ giải thích toàn bộ từ cơ chế layer đến các production patterns nâng cao.Mình đã tổng hợp toàn bộ kiến thức ZStack trong 12 phần. Đây là những điểm cốt lõi:

**Hiểu đúng ZStack** bắt đầu từ quy tắc: child khai báo **trước → nằm dưới** (background), khai báo **sau → nằm trên** (foreground). Giống Photoshop layers — layer cuối trong panel code = nền.

**Điểm quan trọng nhất — Phần 4: ZStack vs .overlay vs .background**. Đây là quyết định thiết kế gặp hàng ngày:

- **ZStack**: size = child lớn nhất, tất cả children đều ảnh hưởng sizing. Dùng khi layers **đồng đẳng**.
- **.overlay**: size = base view, overlay content **không ảnh hưởng sizing** → dùng cho badge, indicator.
- **.background**: size = content view, background **không ảnh hưởng sizing** → dùng cho nền, gradient.

Chọn sai → layout bị vỡ khó debug. Rule: có base view rõ ràng → dùng overlay/background; layers đồng đẳng → ZStack.

**Ba production patterns hay nhất:**

**Phần 7e — Toast/Snackbar**: ViewModifier wrap ZStack(alignment: .top) cho toast message tự biến mất sau 2.5 giây, dùng `.toast()` modifier — cực kỳ reusable, chỉ cần 1 dòng code ở call site.

**Phần 7b — Loading Overlay**: Generic `LoadingOverlay<Content>` component dùng ZStack chồng blur + material + ProgressView lên bất kỳ content nào. Pattern này dùng khắp mọi app.

**Phần 10 — ignoresSafeArea pattern**: Background layer `.ignoresSafeArea()` phủ kín màn hình, content layer tôn trọng safe area — đây là pattern chuẩn cho splash screen, onboarding, login. Pitfall #6 nhắc: **background phải khai báo TRƯỚC content**, nếu không sẽ đè lên content.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
