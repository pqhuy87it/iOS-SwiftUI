```
// ============================================================
// VSTACK TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// VStack (Vertical Stack) sắp xếp child views theo chiều DỌC
// từ TRÊN → DƯỚI.
//
// Là layout container phổ biến nhất trong SwiftUI — gần như
// mọi screen đều bắt đầu bằng VStack hoặc nesting VStacks.
//
// Khác biệt cốt lõi với HStack:
// - HStack: alignment theo chiều DỌC (VerticalAlignment)
// - VStack: alignment theo chiều NGANG (HorizontalAlignment)
// - HStack: phân bổ width cho children
// - VStack: phân bổ height cho children
// ============================================================
```
```Swift
import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÚ PHÁP & INITIALIZER                               ║
// ╚══════════════════════════════════════════════════════════╝

// VStack(
//     alignment: HorizontalAlignment = .center,
//     spacing: CGFloat? = nil,
//     @ViewBuilder content: () -> Content
// )

struct BasicVStackDemo: View {
    var body: some View {
        HStack(spacing: 30) {
            
            // === 1a. Mặc định: alignment .center, spacing hệ thống ===
            VStack {
                Text("Dòng 1")
                Text("Dòng 2 dài hơn")
                Text("Dòng 3")
            }
            .border(.gray)
            // spacing mặc định ≈ 8pt
            // alignment mặc định: .center (căn giữa ngang)
            
            // === 1b. Custom spacing ===
            VStack(spacing: 20) {
                Text("Cách")
                Text("nhau")
                Text("20pt")
            }
            .border(.gray)
            
            // === 1c. Spacing = 0 ===
            VStack(spacing: 0) {
                Text("Sát").padding(8).background(.blue.opacity(0.2))
                Text("nhau").padding(8).background(.green.opacity(0.2))
                Text("hoàn toàn").padding(8).background(.orange.opacity(0.2))
            }
            
            // === 1d. Custom alignment ===
            VStack(alignment: .leading) {
                Text("Leading")
                Text("Căn trái")
                Text("Tất cả")
            }
            .border(.gray)
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. HORIZONTAL ALIGNMENT — CĂN CHỈNH THEO CHIỀU NGANG  ║
// ╚══════════════════════════════════════════════════════════╝

// Khi children có WIDTH KHÁC NHAU,
// alignment quyết định chúng căn theo cạnh nào.

struct AlignmentDemo: View {
    var body: some View {
        HStack(spacing: 24) {
            
            // .leading — căn TRÁI
            AlignmentColumn(title: ".leading", alignment: .leading)
            
            // .center — căn GIỮA (default)
            AlignmentColumn(title: ".center", alignment: .center)
            
            // .trailing — căn PHẢI
            AlignmentColumn(title: ".trailing", alignment: .trailing)
        }
        .padding()
    }
}

struct AlignmentColumn: View {
    let title: String
    let alignment: HorizontalAlignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            
            VStack(alignment: alignment, spacing: 6) {
                Text("Ngắn")
                    .padding(6).background(.blue.opacity(0.2), in: .rect(cornerRadius: 4))
                Text("Dài hơn nhiều")
                    .padding(6).background(.green.opacity(0.2), in: .rect(cornerRadius: 4))
                Text("Vừa")
                    .padding(6).background(.orange.opacity(0.2), in: .rect(cornerRadius: 4))
            }
            .frame(width: 110)
            .padding(8)
            .background(.gray.opacity(0.08), in: .rect(cornerRadius: 8))
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3. CUSTOM ALIGNMENT GUIDE — CĂN CHỈNH TẠI VỊ TRÍ TUỲ Ý║
// ╚══════════════════════════════════════════════════════════╝

// Built-in chỉ có .leading, .center, .trailing.
// Custom AlignmentGuide cho phép căn tại BẤT KỲ điểm nào.

// === 3a. alignmentGuide modifier — Dịch chuyển alignment point ===

struct AlignmentGuideDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Dòng này căn bình thường
            Text("Tiêu đề chính")
                .font(.headline)
            
            // Dòng này THỤT VÀO 24pt so với leading edge
            Text("• Mục con thứ nhất")
                .alignmentGuide(.leading) { d in
                    d[.leading] - 24
                    // Trả về giá trị NHỎ HƠN .leading thực tế
                    // → SwiftUI đặt view SANG PHẢI 24pt để "căn leading"
                }
            
            Text("• Mục con thứ hai")
                .alignmentGuide(.leading) { d in
                    d[.leading] - 24
                }
            
            Text("Đoạn kết")
                .font(.headline)
        }
        .padding()
    }
}


// === 3b. Custom HorizontalAlignment — Form label alignment ===

// Bài toán: căn dấu ":" của label form thẳng hàng
// Label dài ngắn khác nhau nhưng ":" luôn thẳng cột

extension HorizontalAlignment {
    private enum FormLabelAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }
    
    static let formLabel = HorizontalAlignment(FormLabelAlignment.self)
}

struct FormAlignmentDemo: View {
    var body: some View {
        VStack(alignment: .formLabel, spacing: 12) {
            HStack(spacing: 0) {
                Text("Tên")
                    .frame(minWidth: 0, alignment: .trailing)
                Text(" : ")
                    .alignmentGuide(.formLabel) { d in d[HorizontalAlignment.center] }
                Text("Nguyễn Văn Huy")
                    .frame(minWidth: 0, alignment: .leading)
            }
            
            HStack(spacing: 0) {
                Text("Email")
                    .frame(minWidth: 0, alignment: .trailing)
                Text(" : ")
                    .alignmentGuide(.formLabel) { d in d[HorizontalAlignment.center] }
                Text("huy@example.com")
                    .frame(minWidth: 0, alignment: .leading)
            }
            
            HStack(spacing: 0) {
                Text("Số điện thoại")
                    .frame(minWidth: 0, alignment: .trailing)
                Text(" : ")
                    .alignmentGuide(.formLabel) { d in d[HorizontalAlignment.center] }
                Text("0912 345 678")
                    .frame(minWidth: 0, alignment: .leading)
            }
        }
        .padding()
    }
    // Kết quả:
    //           Tên : Nguyễn Văn Huy
    //         Email : huy@example.com
    // Số điện thoại : 0912 345 678
    //                ↑ dấu ":" thẳng cột!
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. LAYOUT SYSTEM — CÁCH VStack PHÂN BỔ KHÔNG GIAN       ║
// ╚══════════════════════════════════════════════════════════╝

// VStack phân bổ HEIGHT cho children theo quy tắc:
//
// 1. Hỏi mỗi child ideal height
// 2. Trừ spacing giữa các children
// 3. Children CỐ ĐỊNH (Text, Image...) lấy đúng size cần
// 4. Children LINH HOẠT (Spacer, frame(maxHeight:)) chia phần còn lại
// 5. layoutPriority cao → được chia trước
//
// ┌────────────────── VStack height ──────────────────┐
// │ [ Fixed Header  ]                                 │
// │ [ spacing       ]                                 │
// │ [ Flexible Body ↕ chiếm phần còn lại            ]│
// │ [ spacing       ]                                 │
// │ [ Fixed Footer  ]                                 │
// └───────────────────────────────────────────────────┘

struct LayoutSystemDemo: View {
    var body: some View {
        VStack(spacing: 0) {
            
            // Fixed: lấy đúng intrinsic height
            Text("Header cố định")
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.opacity(0.15))
            
            // Flexible: chiếm TẤT CẢ height còn lại
            Color.green.opacity(0.1)
                .overlay(Text("Body linh hoạt\n(chiếm phần còn lại)"))
            
            // Fixed
            Text("Footer cố định")
                .frame(maxWidth: .infinity)
                .padding()
                .background(.orange.opacity(0.15))
        }
        .frame(height: 350)
        .border(.gray)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. SPACER, layoutPriority & fixedSize                   ║
// ╚══════════════════════════════════════════════════════════╝

// Cơ chế giống HStack nhưng hoạt động theo chiều DỌC.

struct SpacerAndPriorityDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 5a. Spacer đẩy content lên trên ===
            VStack {
                Text("Nằm trên cùng")
                    .padding()
                    .background(.blue.opacity(0.2))
                Spacer() // Đẩy tất cả lên trên
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .border(.gray)
            
            // === 5b. Spacer kẹp giữa ===
            VStack {
                Text("Trên")
                Spacer()         // Đẩy "Trên" lên, "Dưới" xuống
                Text("Dưới")
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .border(.gray)
            
            // === 5c. Spacer căn giữa ===
            VStack {
                Spacer()
                Text("Giữa theo chiều dọc")
                Spacer()
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .border(.gray)
            
            // === 5d. layoutPriority ===
            VStack {
                // Priority 1: text này được giữ nguyên
                Text("Tiêu đề quan trọng")
                    .font(.headline)
                    .layoutPriority(1)
                
                // Priority 0 (default): bị truncate trước nếu thiếu chỗ
                Text("Mô tả dài có thể bị cắt khi không đủ chiều cao cho VStack, dòng này sẽ bị ảnh hưởng đầu tiên")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .border(.gray)
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. VStack TRONG SCROLLVIEW                              ║
// ╚══════════════════════════════════════════════════════════╝

// VStack + ScrollView = scrollable vertical content.
// KHÁC với LazyVStack: VStack tạo TẤT CẢ children ngay lập tức.

struct VStackInScrollViewDemo: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header banner
                RoundedRectangle(cornerRadius: 16)
                    .fill(.blue.gradient)
                    .frame(height: 200)
                    .overlay(Text("Banner").foregroundStyle(.white).font(.title))
                
                // Content sections
                ForEach(0..<20) { i in
                    HStack {
                        Circle()
                            .fill(.gray.opacity(0.2))
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text("Item \(i + 1)").font(.headline)
                            Text("Mô tả ngắn").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(.background, in: .rect(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                }
            }
            .padding()
        }
    }
}

// ⚠️ KHI NÀO DÙNG VStack vs LazyVStack TRONG SCROLLVIEW?
//
// VStack trong ScrollView:
// ✅ Ít items (< 30-50)
// ✅ Cần measure TOÀN BỘ content height ngay (scroll indicator chính xác)
// ✅ Mixed content types (banner + cards + sections)
// ✅ Cần animation trên toàn bộ list
//
// LazyVStack trong ScrollView:
// ✅ Nhiều items (50+)
// ✅ Items đồng nhất (homogeneous rows)
// ✅ Cần onAppear/onDisappear cho từng row
// ✅ Pagination / infinite scroll
//
// List:
// ✅ Cần cell reuse (100K+ items, memory ổn định)
// ✅ Cần swipe actions, edit mode, selection built-in


// ╔══════════════════════════════════════════════════════════╗
// ║  7. NESTED VStacks — COMPOSITION PATTERNS                ║
// ╚══════════════════════════════════════════════════════════╝

// Nesting VStacks với SPACING KHÁC NHAU tạo visual hierarchy.
// Đây là pattern cốt lõi để build mọi screen trong SwiftUI.

struct NestedVStackDemo: View {
    var body: some View {
        // Outer VStack: spacing LỚN giữa các SECTIONS
        VStack(spacing: 24) {
            
            // Section 1: spacing NHỎ giữa các elements
            VStack(alignment: .leading, spacing: 8) {
                Text("Thông tin cá nhân")
                    .font(.title3.bold())
                Text("Cập nhật thông tin tài khoản của bạn")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Section 2
            VStack(spacing: 12) {
                InfoRow(label: "Họ tên", value: "Nguyễn Văn Huy")
                Divider()
                InfoRow(label: "Email", value: "huy@example.com")
                Divider()
                InfoRow(label: "SĐT", value: "0912 345 678")
            }
            .padding()
            .background(.gray.opacity(0.06), in: .rect(cornerRadius: 12))
            
            // Section 3
            VStack(spacing: 12) {
                InfoRow(label: "Vai trò", value: "Senior iOS Developer")
                Divider()
                InfoRow(label: "Team", value: "Mobile Engineering")
            }
            .padding()
            .background(.gray.opacity(0.06), in: .rect(cornerRadius: 12))
        }
        .padding()
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

// NGUYÊN TẮC SPACING HIERARCHY:
//
// Outer spacing (giữa sections): 24-32pt
// Inner spacing (giữa elements trong section): 8-12pt
// Tight spacing (label + value, icon + text): 4-6pt
//
// Tạo ra "nhịp thở" visual rõ ràng cho người dùng,
// giúp phân biệt đâu là group, đâu là item riêng lẻ.


// ╔══════════════════════════════════════════════════════════╗
// ║  8. VSTACK vs GROUP vs SECTION                           ║
// ╚══════════════════════════════════════════════════════════╝

struct ContainerComparison: View {
    var body: some View {
        Form {
            // === VStack trong Form: KHÔNG tạo row riêng ===
            // Tất cả children nằm CÙNG 1 row
            VStack(alignment: .leading) {
                Text("Title").font(.headline)
                Text("Subtitle").font(.caption).foregroundStyle(.secondary)
            }
            // → 1 row duy nhất chứa cả Title + Subtitle
            
            // === Group: KHÔNG ảnh hưởng layout ===
            // Chỉ nhóm views logic, mỗi child là 1 row riêng
            Group {
                Text("Row A") // → Row riêng
                Text("Row B") // → Row riêng
                Text("Row C") // → Row riêng
            }
            .font(.subheadline) // Modifier apply cho TẤT CẢ children
            
            // === Section: Tạo group có header/footer ===
            Section("Mục 1") {
                Text("Item 1") // → Row riêng trong section
                Text("Item 2") // → Row riêng trong section
            }
            
            // === VStack trong Section: khi cần custom layout trong row ===
            Section("Mục 2") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Phức tạp").font(.headline)
                    Text("Layout custom trong 1 row")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        Image(systemName: "star.fill").foregroundStyle(.yellow)
                        Text("4.8")
                    }
                }
            }
        }
    }
}

// TÓM TẮT:
// ┌──────────────┬──────────────────────────────────────────┐
// │ Container    │ Vai trò trong Form/List                  │
// ├──────────────┼──────────────────────────────────────────┤
// │ VStack       │ Gom nhiều views thành 1 ROW              │
// │ Group        │ Nhóm logic, mỗi child vẫn là ROW RIÊNG  │
// │ Section      │ Tạo grouped section có header/footer      │
// │ ForEach      │ Mỗi iteration là 1 ROW RIÊNG             │
// └──────────────┴──────────────────────────────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  9. PRODUCTION PATTERNS                                   ║
// ╚══════════════════════════════════════════════════════════╝

// === 9a. Full Screen Layout — Header / Body / Footer ===

struct FullScreenLayout: View {
    var body: some View {
        VStack(spacing: 0) {
            // HEADER: cố định trên cùng
            HStack {
                Text("Ứng dụng").font(.title3.bold())
                Spacer()
                Image(systemName: "bell.badge")
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // BODY: chiếm toàn bộ còn lại, scrollable
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<30) { i in
                        Text("Content \(i)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.gray.opacity(0.05), in: .rect(cornerRadius: 8))
                    }
                }
                .padding()
            }
            
            Divider()
            
            // FOOTER: cố định dưới cùng
            HStack(spacing: 0) {
                ForEach(["house", "magnifyingglass", "person"], id: \.self) { icon in
                    Button { } label: {
                        Image(systemName: icon)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
    }
}


// === 9b. Onboarding / CTA Screen ===

struct OnboardingScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer() // Đẩy content xuống giữa-trên
            
            // Illustration
            Image(systemName: "sparkles")
                .font(.system(size: 72))
                .foregroundStyle(.blue.gradient)
                .padding(.bottom, 24)
            
            // Title + Description (spacing chặt)
            VStack(spacing: 12) {
                Text("Chào mừng đến với App")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text("Khám phá những tính năng tuyệt vời giúp bạn làm việc hiệu quả hơn mỗi ngày.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer() // 2 Spacers dưới > 1 Spacer trên → content lệch TRÊN
            
            // CTA Buttons (spacing riêng)
            VStack(spacing: 12) {
                Button { } label: {
                    Text("Bắt đầu ngay")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue, in: .rect(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                
                Button("Đã có tài khoản? Đăng nhập") { }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}


// === 9c. Card Component ===

struct ArticleCard: View {
    let title: String
    let excerpt: String
    let author: String
    let readTime: String
    let category: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 0)
                .fill(.gray.opacity(0.15))
                .frame(height: 180)
                .overlay(Image(systemName: "photo").font(.largeTitle).foregroundStyle(.gray))
            
            // Content area (spacing chặt hơn)
            VStack(alignment: .leading, spacing: 10) {
                // Category tag
                Text(category.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.blue)
                    .tracking(1)
                
                // Title
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                
                // Excerpt
                Text(excerpt)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                
                // Meta info
                HStack(spacing: 8) {
                    Text(author)
                        .font(.caption.weight(.medium))
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text(readTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "bookmark")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
        .background(.background, in: .rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }
}

#Preview("Article Card") {
    ArticleCard(
        title: "SwiftUI Layout System: Hiểu sâu để code nhanh",
        excerpt: "Bài viết giải thích chi tiết cách SwiftUI phân bổ không gian cho views, từ intrinsic size đến layout priority.",
        author: "Huy Nguyen",
        readTime: "5 phút đọc",
        category: "iOS Development"
    )
    .padding()
}


// === 9d. Profile Header ===

struct ProfileHeader: View {
    let name: String
    let title: String
    let stats: [(String, String)]
    
    var body: some View {
        // Outer: spacing lớn giữa avatar block và stats
        VStack(spacing: 20) {
            // Avatar + Name block: spacing nhỏ
            VStack(spacing: 10) {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                    )
                
                // Name + title: spacing rất nhỏ
                VStack(spacing: 4) {
                    Text(name)
                        .font(.title2.bold())
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Stats bar
            HStack(spacing: 0) {
                ForEach(Array(stats.enumerated()), id: \.offset) { idx, stat in
                    if idx > 0 { Divider().frame(height: 28) }
                    VStack(spacing: 4) {
                        Text(stat.1)
                            .font(.headline)
                        Text(stat.0)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button { } label: {
                    Text("Follow")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.blue, in: .rect(cornerRadius: 10))
                        .foregroundStyle(.white)
                }
                Button { } label: {
                    Text("Message")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.gray.opacity(0.12), in: .rect(cornerRadius: 10))
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding()
    }
}

#Preview("Profile Header") {
    ProfileHeader(
        name: "Huy Nguyen",
        title: "Senior iOS Developer",
        stats: [("Bài viết", "128"), ("Followers", "1.2K"), ("Following", "345")]
    )
}


// === 9e. Empty State / Error State ===

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.bold())
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
            }
            
            Spacer()
            Spacer() // Lệch trên 1/3 thay vì giữa hoàn toàn
        }
    }
}

#Preview("Empty State") {
    EmptyStateView(
        icon: "tray",
        title: "Chưa có dữ liệu",
        message: "Bắt đầu bằng cách thêm mục mới vào danh sách của bạn.",
        actionTitle: "Thêm mới"
    ) { }
}


// === 9f. Bottom Sheet Content ===

struct BottomSheetContent: View {
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(.gray.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Title section
            VStack(alignment: .leading, spacing: 4) {
                Text("Chia sẻ").font(.title3.bold())
                Text("Chọn cách chia sẻ nội dung")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            Divider()
            
            // Options
            VStack(spacing: 0) {
                ShareOption(icon: "doc.on.doc", title: "Sao chép liên kết", color: .gray)
                ShareOption(icon: "square.and.arrow.up", title: "Chia sẻ qua...", color: .blue)
                ShareOption(icon: "bookmark", title: "Lưu bài viết", color: .orange)
                ShareOption(icon: "flag", title: "Báo cáo", color: .red)
            }
        }
    }
}

struct ShareOption: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button { } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                    .frame(width: 28)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 14)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. ADAPTIVE VStack ↔ HStack                            ║
// ╚══════════════════════════════════════════════════════════╝

// === 10a. ViewThatFits (iOS 16+) ===

struct AdaptiveLayout: View {
    let items = ["SwiftUI", "Combine", "Swift Data", "Swift Testing"]
    
    var body: some View {
        ViewThatFits {
            // Thử HStack trước
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    TagChip(text: item)
                }
            }
            
            // Không vừa → VStack
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    TagChip(text: item)
                }
            }
        }
        .padding()
    }
}

struct TagChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.blue.opacity(0.1), in: .capsule)
    }
}


// === 10b. AnyLayout — Animated transition (iOS 16+) ===

struct AnimatedLayoutSwitch: View {
    @State private var isVertical = true
    
    var body: some View {
        VStack(spacing: 24) {
            // Toggle layout
            Toggle("Vertical Layout", isOn: $isVertical.animation(.spring))
            
            let layout = isVertical
                ? AnyLayout(VStackLayout(spacing: 12))
                : AnyLayout(HStackLayout(spacing: 12))
            
            layout {
                ForEach(0..<3) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .fill([Color.blue, .green, .orange][i].gradient)
                        .frame(width: isVertical ? nil : 80,
                               height: isVertical ? 60 : 80)
                        .frame(maxWidth: isVertical ? .infinity : nil)
                        .overlay(Text("\(i + 1)").foregroundStyle(.white).font(.headline))
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding()
    }
}


// === 10c. Dynamic Type / Size Class Adaptation ===

struct SizeClassAdaptive: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.dynamicTypeSize) private var typeSize
    
    var body: some View {
        // Compact + large text → VStack
        // Regular hoặc normal text → HStack
        let useVertical = hSizeClass == .compact || typeSize >= .accessibility1
        
        let layout = useVertical
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(spacing: 20))
        
        layout {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Nguyễn Văn Huy").font(.headline)
                Text("Senior iOS Developer").foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. @ViewBuilder — TẠO CUSTOM VSTACK-LIKE CONTAINERS    ║
// ╚══════════════════════════════════════════════════════════╝

// Tạo reusable container components dùng @ViewBuilder
// để nhận nội dung giống như VStack nhận children.

// === 11a. Section Card Container ===

struct SectionCard<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Content (nhận views giống VStack)
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray.opacity(0.06), in: .rect(cornerRadius: 16))
    }
}

// === 11b. Error Boundary Container ===

struct ErrorBoundary<Content: View>: View {
    let isError: Bool
    let errorMessage: String
    var retryAction: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        if isError {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title)
                    .foregroundStyle(.orange)
                Text(errorMessage)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                if let retryAction {
                    Button("Thử lại", action: retryAction)
                        .buttonStyle(.bordered)
                }
            }
            .padding()
        } else {
            content()
        }
    }
}

// Sử dụng:
#Preview("Custom Containers") {
    ScrollView {
        VStack(spacing: 16) {
            SectionCard(title: "Thông tin", subtitle: "Chi tiết tài khoản") {
                Text("Tên: Huy Nguyen")
                Text("Role: iOS Developer")
                Text("Team: Mobile")
            }
            
            SectionCard(title: "Kỹ năng") {
                HStack {
                    TagChip(text: "Swift")
                    TagChip(text: "SwiftUI")
                    TagChip(text: "Combine")
                }
            }
            
            ErrorBoundary(
                isError: true,
                errorMessage: "Không thể tải dữ liệu"
            ) { }
        }
        .padding()
    }
}
```
```
// ╔══════════════════════════════════════════════════════════╗
// ║  12. PERFORMANCE & RENDER BEHAVIOR                       ║
// ╚══════════════════════════════════════════════════════════╝

// === 12a. VStack re-render rules ===
//
// Khi 1 child thay đổi @State:
// - VStack KHÔNG re-render tất cả children
// - Chỉ child bị ảnh hưởng + VStack tính lại layout NẾU size thay đổi
// - SwiftUI dùng structural identity (vị trí trong code) để track children
//
// Conditional content thay đổi identity:
//
// ❌ PITFALL: if/else tạo 2 branches khác identity
// VStack {
//     if isLoggedIn {
//         HomeView()     // identity: _ConditionalContent.TrueContent
//     } else {
//         LoginView()    // identity: _ConditionalContent.FalseContent
//     }
// }
// → Chuyển đổi: state bị RESET hoàn toàn (view destroyed + created)
//
// Nếu muốn GIỮ state khi toggle → dùng .opacity thay if/else:
// HomeView().opacity(isLoggedIn ? 1 : 0)
// LoginView().opacity(isLoggedIn ? 0 : 1)

// === 12b. Tránh deep nesting ===
//
// ❌ BAD: nesting 10+ levels VStack
// VStack { VStack { VStack { VStack { ... } } } }
// → Mỗi level thêm layout pass, performance giảm
//
// ✅ GOOD: flatten structure, dùng extracted sub-views
// VStack {
//     HeaderSection()    // Tự chứa VStack riêng nếu cần
//     ContentSection()
//     FooterSection()
// }


// ╔══════════════════════════════════════════════════════════╗
// ║  13. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: VStack không full width
//    VStack { Text("Hello") } // Width chỉ bằng text
//    ✅ FIX: .frame(maxWidth: .infinity) hoặc
//            .frame(maxWidth: .infinity, alignment: .leading)

// ❌ PITFALL 2: Spacer không hoạt động
//    VStack { Text("A"); Spacer(); Text("B") }
//    // Nếu VStack KHÔNG có height constraint → Spacer co về 0
//    ✅ FIX: Đảm bảo VStack có bounded height:
//            .frame(maxHeight: .infinity) hoặc nằm trong container có height

// ❌ PITFALL 3: VStack trong ScrollView + Spacer
//    ScrollView { VStack { Text("A"); Spacer(); Text("B") } }
//    // ScrollView cho VStack height VÔ HẠN → Spacer mở rộng vô tận
//    ✅ FIX: Dùng .frame(minHeight: geo.size.height) bên trong GeometryReader
//            Hoặc bỏ Spacer, dùng .frame(maxHeight: .infinity)

// ❌ PITFALL 4: VStack trong Form/List tạo layout không mong muốn
//    Form { VStack { Text("A"); Text("B") } }
//    → A và B nằm CÙNG 1 row (VStack gom lại)
//    ✅ FIX: Bỏ VStack nếu muốn mỗi text là 1 row riêng
//            Hoặc dùng Group { } thay VStack

// ❌ PITFALL 5: Spacing không nhất quán giữa các sections
//    VStack { section1; section2; section3 }
//    // Default spacing cho MỌI child giống nhau
//    ✅ FIX: VStack(spacing: 0) + .padding(.top, X) thủ công
//            Hoặc nested VStacks với spacing khác nhau

// ❌ PITFALL 6: Quên alignment cho text-heavy layouts
//    VStack { Text("Title"); Text("Long description...") }
//    // Mặc định .center → description căn giữa, đọc khó
//    ✅ FIX: VStack(alignment: .leading) cho text content

// ✅ BEST PRACTICES:
// 1. .leading alignment cho text-heavy content (đọc tự nhiên)
// 2. Nested VStacks với spacing hierarchy: 24-32 / 12-16 / 4-8
// 3. .frame(maxWidth: .infinity) khi cần full-width
// 4. Spacer() cho push layout (top/bottom/center)
// 5. Extract sub-views thay vì nesting sâu > 3-4 levels
// 6. Group thay VStack trong Form/List khi muốn multi-row
// 7. ViewThatFits / AnyLayout cho adaptive VStack↔HStack
// 8. @ViewBuilder cho reusable container components
// 9. spacing: 0 + manual padding khi cần pixel-perfect control
// 10. Test với Dynamic Type lớn — layout có thể vỡ bất ngờ
```
---

VStack chia sẻ nhiều concepts với HStack nhưng có những khác biệt quan trọng về alignment (ngang thay vì dọc), và đặc biệt là các production patterns hoàn toàn khác. Mình sẽ giải thích toàn bộ, đi sâu vào những phần riêng biệt của VStack.Mình đã tổng hợp toàn bộ kiến thức VStack trong 13 phần. Đây là những điểm cốt lõi:

**Khác biệt nền tảng với HStack**: VStack dùng `HorizontalAlignment` (.leading, .center, .trailing) thay vì `VerticalAlignment`, và phân bổ **height** thay vì width cho children. Nghe đơn giản nhưng implications rất khác — đặc biệt khi kết hợp với ScrollView.

**Bốn phần giá trị nhất:**

**Phần 3 — Custom Alignment Guide**: Pattern căn dấu ":" thẳng cột trong form (Tên : giá trị / Email : giá trị / Số điện thoại : giá trị) bằng custom `HorizontalAlignment`. Đây là kỹ thuật ít developer biết nhưng tạo ra UI cực kỳ chuyên nghiệp.

**Phần 7 — Nested VStacks & Spacing Hierarchy**: Nguyên tắc then chốt để build mọi screen — outer spacing 24-32pt giữa sections, inner spacing 8-12pt giữa elements, tight spacing 4-6pt cho label+value. Ba tầng spacing này tạo ra "nhịp thở" visual rõ ràng, giúp user phân biệt groups và items.

**Phần 8 — VStack vs Group vs Section**: Đây là gotcha lớn trong Form/List — VStack **gom children thành 1 row**, Group giữ children là **rows riêng biệt**, Section tạo grouped header/footer. Chọn sai container trong Form sẽ cho layout hoàn toàn khác mong đợi.

**Phần 9 — Production Patterns**: Từ full screen layout (Header/Body/Footer), onboarding screen, article card, profile header đến bottom sheet — tất cả đều xây dựng trên VStack với spacing hierarchy phù hợp. Trick hay: dùng **2 Spacer dưới + 1 Spacer trên** để content nằm ở vị trí 1/3 trên thay vì giữa hoàn toàn — đây là golden ratio mà Apple dùng rất nhiều.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
