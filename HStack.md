// ============================================================
// HSTACK TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// HStack (Horizontal Stack) sắp xếp child views theo chiều NGANG
// từ TRÁI → PHẢI (hoặc phải→trái với RTL languages).
//
// Đây là 1 trong 3 layout containers nền tảng:
// - HStack: ngang
// - VStack: dọc
// - ZStack: chồng (z-axis)
//
// HStack đơn giản về concept nhưng hệ thống layout bên trong
// rất tinh vi: spacing, alignment, layout priority, flexible vs
// fixed sizing, GeometryReader, adaptive breakpoints...
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÚ PHÁP & INITIALIZER                               ║
// ╚══════════════════════════════════════════════════════════╝

// HStack(
//     alignment: VerticalAlignment = .center,
//     spacing: CGFloat? = nil,
//     @ViewBuilder content: () -> Content
// )

struct BasicHStackDemo: View {
    var body: some View {
        VStack(spacing: 30) {
            
            // === 1a. Mặc định: alignment .center, spacing hệ thống ===
            HStack {
                Text("A")
                Text("B")
                Text("C")
            }
            .border(.gray)
            // spacing mặc định ≈ 8pt (tuỳ platform, Apple không document chính xác)
            // alignment mặc định: .center (căn giữa theo chiều dọc)
            
            // === 1b. Custom spacing ===
            HStack(spacing: 20) {
                Text("Cách")
                Text("nhau")
                Text("20pt")
            }
            .border(.gray)
            
            // === 1c. Spacing = 0 ===
            HStack(spacing: 0) {
                Text("Không")
                    .padding(8).background(.blue.opacity(0.2))
                Text("có")
                    .padding(8).background(.green.opacity(0.2))
                Text("khoảng cách")
                    .padding(8).background(.orange.opacity(0.2))
            }
            
            // === 1d. Custom alignment ===
            HStack(alignment: .top) {
                Text("Ngắn")
                    .padding().background(.blue.opacity(0.2))
                Text("Dòng\nnày\ncao\nhơn")
                    .padding().background(.green.opacity(0.2))
                Text("Vừa")
                    .padding().background(.orange.opacity(0.2))
            }
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. VERTICAL ALIGNMENT — CĂN CHỈNH THEO CHIỀU DỌC      ║
// ╚══════════════════════════════════════════════════════════╝

// Khi children có CHIỀU CAO KHÁC NHAU,
// alignment quyết định chúng căn theo đâu.

struct AlignmentDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // .top — căn theo cạnh TRÊN
            DemoRow(title: ".top", alignment: .top)
            
            // .center — căn GIỮA (default)
            DemoRow(title: ".center", alignment: .center)
            
            // .bottom — căn theo cạnh DƯỚI
            DemoRow(title: ".bottom", alignment: .bottom)
            
            // .firstTextBaseline — căn theo baseline dòng TEXT ĐẦU TIÊN
            // Quan trọng khi mix font sizes
            DemoRow(title: ".firstTextBaseline", alignment: .firstTextBaseline)
            
            // .lastTextBaseline — căn theo baseline dòng TEXT CUỐI
            DemoRow(title: ".lastTextBaseline", alignment: .lastTextBaseline)
        }
        .padding()
    }
}

struct DemoRow: View {
    let title: String
    let alignment: VerticalAlignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            
            HStack(alignment: alignment, spacing: 12) {
                Text("A").font(.caption)
                    .padding(8).background(.blue.opacity(0.2), in: .rect(cornerRadius: 4))
                
                Text("B").font(.title)
                    .padding(8).background(.green.opacity(0.2), in: .rect(cornerRadius: 4))
                
                Text("C\nLine2").font(.body)
                    .padding(8).background(.orange.opacity(0.2), in: .rect(cornerRadius: 4))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(.gray.opacity(0.08), in: .rect(cornerRadius: 8))
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2b. firstTextBaseline vs lastTextBaseline CHI TIẾT      ║
// ╚══════════════════════════════════════════════════════════╝

// Khi views có text với FONT SIZE KHÁC NHAU,
// .firstTextBaseline đảm bảo text đọc trên cùng 1 "dòng kẻ".
// Đây là chuẩn typography mà Apple khuyến khích.

struct BaselineDemo: View {
    var body: some View {
        VStack(spacing: 32) {
            // ❌ .center: text lệch, đọc khó
            HStack(alignment: .center, spacing: 4) {
                Text("$")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Text("99")
                    .font(.system(size: 48, weight: .bold))
                Text(".99")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("/tháng")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.gray.opacity(0.1), in: .rect(cornerRadius: 12))
            
            // ✅ .firstTextBaseline: text thẳng hàng hoàn hảo
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Text("99")
                    .font(.system(size: 48, weight: .bold))
                Text(".99")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("/tháng")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.gray.opacity(0.1), in: .rect(cornerRadius: 12))
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3. CUSTOM ALIGNMENT GUIDE                               ║
// ╚══════════════════════════════════════════════════════════╝

// Khi built-in alignments không đủ, tạo custom alignment
// để căn chỉnh tại bất kỳ vị trí nào trong child views.

// Bước 1: Định nghĩa custom VerticalAlignment
extension VerticalAlignment {
    // Custom alignment ID
    private enum IconCenterAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center] // Fallback về center
        }
    }
    
    // Public alignment value
    static let iconCenter = VerticalAlignment(IconCenterAlignment.self)
}

// Bước 2: Sử dụng
struct CustomAlignmentDemo: View {
    var body: some View {
        HStack(alignment: .iconCenter, spacing: 16) {
            // Icon — đánh dấu điểm căn chỉnh ở GIỮA icon
            Image(systemName: "bell.fill")
                .font(.title)
                .foregroundStyle(.blue)
                .alignmentGuide(.iconCenter) { d in
                    d[VerticalAlignment.center] // Giữa icon
                }
            
            // Text block — căn dòng ĐẦU TIÊN với giữa icon
            VStack(alignment: .leading, spacing: 4) {
                Text("Thông báo mới")
                    .font(.headline)
                    .alignmentGuide(.iconCenter) { d in
                        d[VerticalAlignment.center] // Giữa dòng này
                    }
                Text("Bạn có 3 tin nhắn chưa đọc")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("2 phút trước")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. LAYOUT SYSTEM — CÁCH HStack PHÂN BỔ KHÔNG GIAN      ║
// ╚══════════════════════════════════════════════════════════╝

// HStack phân bổ không gian theo 3 bước:
//
// Bước 1: Hỏi mỗi child "bạn cần bao nhiêu không gian?"
//         (intrinsic content size / ideal size)
//
// Bước 2: Trừ đi spacing giữa các children
//
// Bước 3: Chia không gian CÒN LẠI cho flexible children
//         theo layoutPriority (cao → được chia trước)
//
// ┌──────────────────────── HStack width ─────────────────────┐
// │ [Fixed A] [spacing] [Flexible B ←→] [spacing] [Fixed C]  │
// └───────────────────────────────────────────────────────────┘
//         ↑                    ↑                       ↑
//    Lấy đúng size       Chiếm phần còn lại      Lấy đúng size
//    mình cần             sau khi A, C xong       mình cần

struct LayoutSystemDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 4a. Fixed vs Fixed: chia đều khoảng trống ===
            HStack {
                Text("Fixed")
                    .padding(8).background(.blue.opacity(0.2))
                Text("Fixed")
                    .padding(8).background(.green.opacity(0.2))
            }
            .frame(maxWidth: .infinity)
            .border(.gray)
            
            // === 4b. Fixed + Spacer (flexible): Spacer chiếm hết ===
            HStack {
                Text("Trái")
                    .padding(8).background(.blue.opacity(0.2))
                Spacer() // ← Flexible: chiếm toàn bộ còn lại
                Text("Phải")
                    .padding(8).background(.green.opacity(0.2))
            }
            .border(.gray)
            
            // === 4c. Nhiều flexible children: chia ĐỀU ===
            HStack {
                Text("A")
                    .frame(maxWidth: .infinity) // Flexible
                    .padding(8).background(.blue.opacity(0.2))
                Text("B")
                    .frame(maxWidth: .infinity) // Flexible
                    .padding(8).background(.green.opacity(0.2))
                Text("CCCCC")
                    .frame(maxWidth: .infinity) // Flexible
                    .padding(8).background(.orange.opacity(0.2))
            }
            .border(.gray)
            // Mỗi child cùng maxWidth: .infinity → chia BẰNG NHAU
            
            // === 4d. Fixed width children ===
            HStack {
                Text("80pt")
                    .frame(width: 80)
                    .padding(8).background(.blue.opacity(0.2))
                Text("Còn lại")
                    .frame(maxWidth: .infinity)
                    .padding(8).background(.green.opacity(0.2))
                Text("60pt")
                    .frame(width: 60)
                    .padding(8).background(.orange.opacity(0.2))
            }
            .border(.gray)
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. SPACER — ĐIỀU KHIỂN KHOẢNG TRỐNG                    ║
// ╚══════════════════════════════════════════════════════════╝

struct SpacerDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 5a. 1 Spacer: đẩy sang 2 bên ===
            HStack {
                Text("Trái")
                Spacer()
                Text("Phải")
            }
            .padding().background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
            
            // === 5b. 2 Spacers: căn giữa phần tử giữa ===
            HStack {
                Spacer()
                Text("Giữa")
                Spacer()
            }
            .padding().background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
            
            // === 5c. Spacers không đều ===
            HStack {
                Text("1/3")
                Spacer()
                Text("2/3")
                Spacer()
                Spacer() // 2 Spacers bên phải → phần tử giữa lệch trái
            }
            .padding().background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
            
            // === 5d. Spacer(minLength:) — khoảng cách tối thiểu ===
            HStack {
                Text("Text dài dài dài")
                Spacer(minLength: 20) // Tối thiểu 20pt, có thể co hơn
                Text("Phải")
            }
            .padding().background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
            
            // === 5e. Spacer(minLength: 0) — có thể co hoàn toàn ===
            HStack {
                Text("Có thể")
                Spacer(minLength: 0) // Cho phép co về 0pt
                Text("sát nhau")
            }
            .padding().background(.gray.opacity(0.1), in: .rect(cornerRadius: 8))
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. layoutPriority — ƯU TIÊN PHÂN BỔ KHÔNG GIAN         ║
// ╚══════════════════════════════════════════════════════════╝

// Khi không đủ chỗ, HStack cần quyết định child nào bị CẮT.
// .layoutPriority() quyết định thứ tự ưu tiên:
// - Priority CAO → được không gian TRƯỚC, ít bị cắt
// - Priority THẤP → bị cắt trước
// - Mặc định: tất cả children có priority = 0

struct LayoutPriorityDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // ❌ Không có priority: text dài bị cắt ngẫu nhiên
            HStack {
                Text("Tiêu đề rất dài có thể bị cắt")
                    .lineLimit(1)
                    .background(.blue.opacity(0.1))
                Text("Button")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.blue, in: .capsule)
                    .foregroundStyle(.white)
            }
            .padding()
            
            // ✅ Button có priority cao → KHÔNG bao giờ bị cắt
            HStack {
                Text("Tiêu đề rất dài sẽ bị truncate nếu không đủ chỗ")
                    .lineLimit(1)
                    .background(.blue.opacity(0.1))
                    .layoutPriority(0) // Mặc định, bị cắt trước
                
                Text("Button")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.blue, in: .capsule)
                    .foregroundStyle(.white)
                    .layoutPriority(1) // Cao hơn → được giữ nguyên
            }
            .padding()
            
            // Priority nhiều levels
            HStack {
                // Priority 0: bị cắt đầu tiên
                Text("Mô tả phụ dài dòng")
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                    .layoutPriority(0)
                
                // Priority 1: bị cắt thứ hai
                Text("Tiêu đề chính của item")
                    .lineLimit(1)
                    .layoutPriority(1)
                
                // Priority 2: KHÔNG BAO GIỜ bị cắt
                Image(systemName: "chevron.right")
                    .layoutPriority(2)
            }
            .padding()
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. fixedSize — CHỐNG CO LẠI                             ║
// ╚══════════════════════════════════════════════════════════╝

// .fixedSize() ngăn view bị co nhỏ hơn ideal size.
// Hữu ích khi muốn text KHÔNG bao giờ bị truncate.

struct FixedSizeDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // ❌ Không fixedSize: text bị wrap/truncate
            HStack {
                Text("Username rất dài sẽ bị cắt ở đây")
                    .lineLimit(1)
                    .background(.blue.opacity(0.1))
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.blue)
            }
            .frame(width: 200)
            .border(.gray)
            
            // ✅ fixedSize(horizontal:vertical:)
            HStack {
                Text("Không bị cắt")
                    .fixedSize(horizontal: true, vertical: false)
                    // horizontal: true → không bị co ngang (có thể tràn ra ngoài)
                    // vertical: false → vẫn có thể co dọc bình thường
                    .background(.green.opacity(0.1))
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.blue)
            }
            .frame(width: 200)
            .border(.gray)
            
            // fixedSize trên TOÀN BỘ HStack
            HStack {
                Text("Fixed")
                Text("Size")
                Text("HStack")
            }
            .fixedSize() // Toàn bộ HStack không bị co
            .padding(8).background(.orange.opacity(0.1))
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. HSTACK VỚI FOREACH — DYNAMIC CHILDREN                ║
// ╚══════════════════════════════════════════════════════════╝

struct DynamicHStackDemo: View {
    let tags = ["SwiftUI", "iOS", "Xcode", "WWDC", "Swift"]
    @State private var selectedTags: Set<String> = ["SwiftUI"]
    
    var body: some View {
        VStack(spacing: 24) {
            
            // === 8a. ForEach trong HStack ===
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    let isSelected = selectedTags.contains(tag)
                    Button {
                        if isSelected { selectedTags.remove(tag) }
                        else { selectedTags.insert(tag) }
                    } label: {
                        Text(tag)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isSelected ? .blue : .gray.opacity(0.15), in: .capsule)
                            .foregroundStyle(isSelected ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // === 8b. ForEach + Divider ===
            HStack {
                ForEach(Array(["🏠 Home", "🔍 Search", "👤 Profile"].enumerated()),
                        id: \.offset) { index, item in
                    if index > 0 {
                        Divider().frame(height: 20)
                    }
                    Text(item)
                        .font(.subheadline)
                }
            }
            .padding()
            .background(.gray.opacity(0.1), in: .rect(cornerRadius: 12))
            
            // === 8c. Conditional children ===
            HStack {
                Image(systemName: "person.circle")
                Text("Huy")
                
                if !selectedTags.isEmpty {
                    Spacer()
                    Text("\(selectedTags.count) tags")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. LAZYHSTACK — PHIÊN BẢN LAZY CHO DANH SÁCH NGANG     ║
// ╚══════════════════════════════════════════════════════════╝

// HStack: tạo TẤT CẢ children ngay lập tức (eager)
// LazyHStack: chỉ tạo children khi SẮP HIỂN THỊ (lazy)
// → Dùng LazyHStack trong ScrollView ngang với nhiều items

struct LazyHStackComparison: View {
    var body: some View {
        VStack(spacing: 24) {
            // === HStack: OK cho ít items (< 50) ===
            Text("HStack (eager)").font(.caption.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<20) { i in
                        CardView(index: i, color: .blue)
                    }
                }
                .padding(.horizontal)
            }
            
            // === LazyHStack: cho nhiều items (100+) ===
            Text("LazyHStack (lazy)").font(.caption.bold())
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(0..<1000) { i in
                        CardView(index: i, color: .green)
                        // Chỉ ~5-8 cards được init ban đầu
                        // Scroll → tạo thêm on-demand
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CardView: View {
    let index: Int
    let color: Color
    
    init(index: Int, color: Color) {
        self.index = index
        self.color = color
        // print("Init card \(index)") // Bỏ comment để thấy lazy behavior
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(color.gradient)
            .frame(width: 120, height: 80)
            .overlay(
                Text("\(index)")
                    .foregroundStyle(.white)
                    .font(.headline)
            )
    }
}

// ┌──────────────────┬───────────────────┬───────────────────┐
// │                  │ HStack            │ LazyHStack        │
// ├──────────────────┼───────────────────┼───────────────────┤
// │ Init children    │ TẤT CẢ ngay      │ Khi sắp hiển thị │
// │ Tốt cho          │ < 50 items       │ 50+ items         │
// │ Cần ScrollView   │ Không bắt buộc   │ BẮT BUỘC         │
// │ Cell reuse       │ ❌               │ ❌ (giữ lại)      │
// │ pinnedViews      │ ❌               │ ✅                │
// │ Spacing behavior │ Giống nhau       │ Giống nhau        │
// └──────────────────┴───────────────────┴───────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  10. PRODUCTION PATTERNS                                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 10a. Navigation Bar Style ===

struct NavBarRow: View {
    var body: some View {
        HStack {
            Button { } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
            }
            
            Spacer()
            
            Text("Chi tiết")
                .font(.headline)
            
            Spacer()
            
            Button { } label: {
                Image(systemName: "ellipsis")
                    .font(.title3)
            }
        }
        .padding(.horizontal)
        .frame(height: 44) // Apple minimum tap target
    }
}


// === 10b. List Row — Icon + Text + Accessory ===

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var detail: String? = nil
    var showChevron: Bool = true
    
    var body: some View {
        HStack(spacing: 14) {
            // Fixed: Icon box
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(iconColor, in: .rect(cornerRadius: 6))
            
            // Flexible: Title (được ưu tiên, co nếu cần)
            Text(title)
                .lineLimit(1)
                .layoutPriority(1)
            
            Spacer(minLength: 4)
            
            // Fixed: Detail text
            if let detail {
                Text(detail)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            
            // Fixed: Chevron
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview("Settings Rows") {
    List {
        SettingsRow(icon: "wifi", iconColor: .blue, title: "Wi-Fi", detail: "Home Network")
        SettingsRow(icon: "bluetooth", iconColor: .blue, title: "Bluetooth", detail: "On")
        SettingsRow(icon: "bell.badge.fill", iconColor: .red, title: "Notifications")
        SettingsRow(icon: "battery.100", iconColor: .green, title: "Battery", detail: "85%")
    }
}


// === 10c. Price Display — Baseline Alignment ===

struct PriceDisplay: View {
    let currency: String
    let amount: String
    let decimal: String
    let period: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(currency)
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Text(amount)
                .font(.system(size: 56, weight: .bold, design: .rounded))
            
            Text(decimal)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Text(period)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .padding(.leading, 2)
        }
    }
}

#Preview("Price") {
    PriceDisplay(currency: "$", amount: "9", decimal: ".99", period: "/mo")
        .padding()
}


// === 10d. User Avatar + Info Row ===

struct UserRow: View {
    let name: String
    let subtitle: String
    let isOnline: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar + online indicator
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                    )
                
                if isOnline {
                    Circle()
                        .fill(.green)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .offset(x: 2, y: 2)
                }
            }
            
            // User info (flexible)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .layoutPriority(1)
            
            Spacer(minLength: 0)
            
            // Timestamp
            Text("2 phút")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}


// === 10e. Stat Bar — Chia đều cột ===

struct StatBar: View {
    let stats: [(label: String, value: String)]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                if index > 0 {
                    Divider().frame(height: 30)
                }
                
                VStack(spacing: 4) {
                    Text(stat.value)
                        .font(.headline)
                    Text(stat.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity) // Chia BẰNG NHAU
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }
}

#Preview("Stat Bar") {
    StatBar(stats: [
        ("Bài viết", "128"),
        ("Followers", "1.2K"),
        ("Following", "345"),
    ])
    .padding()
}


// === 10f. Horizontal Scroll Cards (Carousel) ===

struct CarouselView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Xu hướng")
                    .font(.title3.bold())
                Spacer()
                Button("Xem tất cả") { }
                    .font(.subheadline)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                // LazyHStack cho performance
                LazyHStack(spacing: 14) {
                    ForEach(0..<20) { i in
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue.gradient)
                                .frame(width: 200, height: 130)
                            
                            Text("Card \(i + 1)")
                                .font(.subheadline.weight(.medium))
                            Text("Mô tả ngắn")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 200)
                    }
                }
                .padding(.horizontal)
                .scrollTargetLayout() // iOS 17+: snap to card
            }
            .scrollTargetBehavior(.viewAligned) // iOS 17+: snap
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. ADAPTIVE LAYOUT — RESPONSIVE DESIGN                 ║
// ╚══════════════════════════════════════════════════════════╝

// === 11a. ViewThatFits — Tự chọn layout phù hợp (iOS 16+) ===

struct AdaptiveRow: View {
    var body: some View {
        ViewThatFits {
            // Thử HStack trước (nếu đủ chỗ)
            HStack(spacing: 16) {
                Image(systemName: "star.fill").font(.title)
                Text("Tiêu đề chính")
                    .font(.headline)
                Text("Mô tả dài cho phiên bản ngang khi màn hình đủ rộng")
                    .foregroundStyle(.secondary)
            }
            
            // Nếu HStack không vừa → fallback VStack
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "star.fill").font(.title)
                    Text("Tiêu đề chính").font(.headline)
                }
                Text("Mô tả dài cho phiên bản dọc khi màn hình hẹp")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}


// === 11b. AnyLayout — Chuyển đổi HStack ↔ VStack (iOS 16+) ===

struct AnyLayoutDemo: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        let layout = sizeClass == .compact
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(spacing: 20))
        
        layout {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Nguyễn Văn Huy")
                    .font(.title2.bold())
                Text("Senior iOS Developer")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button("Follow") { }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        // Compact (iPhone Portrait): VStack layout
        // Regular (iPad, Landscape): HStack layout
        // Transition animated tự động!
    }
}


// === 11c. GeometryReader — Responsive breakpoint ===

struct GeometryAdaptiveDemo: View {
    var body: some View {
        GeometryReader { geo in
            let isWide = geo.size.width > 500
            
            if isWide {
                HStack(spacing: 20) {
                    sidePanel
                    mainContent
                }
            } else {
                VStack(spacing: 16) {
                    mainContent
                    sidePanel
                }
            }
        }
    }
    
    private var sidePanel: some View {
        VStack { Text("Side Panel").font(.headline) }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.blue.opacity(0.1), in: .rect(cornerRadius: 12))
    }
    
    private var mainContent: some View {
        VStack { Text("Main Content").font(.headline) }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.green.opacity(0.1), in: .rect(cornerRadius: 12))
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  12. HSTACK vs ALTERNATIVES — KHI NÀO DÙNG CÁI NÀO?    ║
// ╚══════════════════════════════════════════════════════════╝

// ┌────────────────────┬────────────────────────────────────┐
// │ Container          │ Dùng khi                           │
// ├────────────────────┼────────────────────────────────────┤
// │ HStack             │ Ít items (< 50), layout cố định    │
// │ LazyHStack         │ Nhiều items, trong ScrollView ngang│
// │ Grid (iOS 16+)     │ Cần alignment CÙNG LÚC ngang + dọc│
// │ HStack + ForEach   │ Dynamic children, tag chips        │
// │ ViewThatFits       │ Adaptive: HStack hoặc VStack       │
// │ AnyLayout          │ Chuyển đổi layout animated         │
// │ Layout protocol    │ Hoàn toàn custom layout algorithm  │
// └────────────────────┴────────────────────────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  13. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Text bị truncate không kiểm soát
//    HStack { Text("Rất dài..."); Text("Cũng dài...") }
//    → Cả 2 bị cắt ngẫu nhiên
//    ✅ FIX: .layoutPriority(1) cho text quan trọng
//            .lineLimit(1) + .truncationMode(.tail) cho text phụ

// ❌ PITFALL 2: HStack content tràn ra ngoài màn hình
//    HStack { /* 20 buttons */ } → tràn, không scroll được
//    ✅ FIX: Wrap trong ScrollView(.horizontal)
//            Hoặc dùng Flow Layout / LazyVGrid

// ❌ PITFALL 3: Spacing không nhất quán
//    HStack { Text("A"); Divider(); Text("B") }
//    → Spacing mặc định GIỮA text và Divider → khoảng cách lạ
//    ✅ FIX: HStack(spacing: 0) rồi thêm .padding() thủ công

// ❌ PITFALL 4: Mix font sizes mà không dùng baseline alignment
//    HStack { Text("$").font(.body); Text("99").font(.largeTitle) }
//    → Lệch dòng, đọc khó
//    ✅ FIX: HStack(alignment: .firstTextBaseline)

// ❌ PITFALL 5: GeometryReader trong HStack child
//    HStack { GeometryReader { ... } } → chiếm toàn bộ available space
//    → Các children khác bị đẩy ra
//    ✅ FIX: .frame(width:height:) cố định cho GeometryReader
//            Hoặc dùng overlay/background thay vì child trực tiếp

// ❌ PITFALL 6: LazyHStack ngoài ScrollView
//    LazyHStack { ... } // Không lazy vì tất cả đều "visible"
//    ✅ FIX: Luôn wrap trong ScrollView(.horizontal)

// ✅ BEST PRACTICES:
// 1. .firstTextBaseline cho mix font sizes (typography chuẩn)
// 2. .layoutPriority cho text quan trọng (chống truncate)
// 3. Spacer + minLength để kiểm soát khoảng trống tối thiểu
// 4. LazyHStack cho horizontal scroll > 50 items
// 5. frame(maxWidth: .infinity) để chia đều columns
// 6. ViewThatFits / AnyLayout cho responsive (iOS 16+)
// 7. spacing: 0 + padding thủ công khi cần pixel-perfect
// 8. .fixedSize() cho text KHÔNG BAO GIỜ được truncate
// 9. Minimum tap target: .frame(minWidth: 44, minHeight: 44)
// 10. Test RTL layout: .environment(\.layoutDirection, .rightToLeft)

---

HStack tưởng đơn giản nhưng hệ thống layout của nó rất sâu — đặc biệt khi kết hợp với alignment guides, spacing, priority, và adaptive layouts. Mình sẽ giải thích toàn bộ.Mình đã tổng hợp toàn bộ kiến thức HStack trong 13 phần. Đây là những điểm cốt lõi:

**Điều quan trọng nhất** mà nhiều developer không nắm rõ là **Phần 4 — Layout System**: HStack phân bổ không gian theo 3 bước — hỏi children cần bao nhiêu, trừ spacing, rồi chia phần còn lại cho flexible children theo `layoutPriority`. Hiểu cơ chế này giúp debug được mọi vấn đề layout.

**Ba phần giá trị nhất cho production:**

**Phần 2b — firstTextBaseline**: Khi mix font sizes (ví dụ pricing display `$99.99/tháng`), `.center` alignment làm text lệch dòng rất khó đọc. `.firstTextBaseline` căn tất cả text theo cùng một baseline — đây là chuẩn typography mà Apple tuân thủ trong toàn bộ iOS.

**Phần 6 — layoutPriority**: Khi không đủ chỗ, child nào có priority cao hơn được giữ nguyên, priority thấp bị truncate trước. Pattern kinh điển: title có `.layoutPriority(1)`, button/icon có `.layoutPriority(2)` (không bao giờ bị cắt), description có `.layoutPriority(0)` (bị cắt đầu tiên).

**Phần 11 — Adaptive Layout**: Ba cách responsive design từ đơn giản đến linh hoạt — `ViewThatFits` tự chọn layout vừa vặn nhất, `AnyLayout` chuyển đổi HStack↔VStack có animation theo size class, và `GeometryReader` cho breakpoint thủ công. iOS 16+ nên dùng `ViewThatFits` hoặc `AnyLayout` thay vì GeometryReader.

**Production patterns ở Phần 10** bao gồm các components dùng hàng ngày: Settings row (icon + title + detail + chevron), price display với baseline alignment, stat bar chia đều cột, và carousel với `LazyHStack` + `.scrollTargetBehavior(.viewAligned)`.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
