// ============================================================
// LAZYVSTACK TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// LazyVStack là vertical stack CHỈ TẠO (initialize) child views
// khi chúng SẮP XUẤT HIỆN trên màn hình (on-demand rendering).
//
// Khác với VStack tạo TẤT CẢ children ngay lập tức (eagerly),
// LazyVStack trì hoãn việc tạo view cho đến khi user scroll
// đến vùng hiển thị → tiết kiệm memory + CPU đáng kể.
//
// Introduced: iOS 14 / WWDC 2020
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. VStack vs LazyVStack — KHÁC BIỆT CỐT LÕI           ║
// ╚══════════════════════════════════════════════════════════╝

// === VStack: EAGER — Tạo TẤT CẢ views ngay lập tức ===
struct EagerExample: View {
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<10_000) { i in
                    // ⚠️ TẤT CẢ 10,000 RowView được init NGAY LẬP TỨC
                    // dù user chỉ nhìn thấy ~15 rows trên màn hình!
                    // → Chậm khởi tạo, tốn memory, có thể gây lag/freeze
                    RowView(index: i)
                }
            }
        }
    }
}

// === LazyVStack: LAZY — Chỉ tạo views khi cần hiển thị ===
struct LazyExample: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<10_000) { i in
                    // ✅ Chỉ ~15-20 RowView được init (visible + buffer)
                    // Scroll đến đâu → tạo đến đó
                    // → Khởi tạo nhanh, tiết kiệm memory
                    RowView(index: i)
                }
            }
        }
    }
}

struct RowView: View {
    let index: Int
    
    init(index: Int) {
        self.index = index
        // Dùng print để chứng minh thời điểm init
        print("🔨 RowView init: \(index)")
    }
    
    var body: some View {
        Text("Row \(index)")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(index % 2 == 0 ? Color.gray.opacity(0.1) : Color.clear)
    }
}

// KẾT QUẢ CHẠY THỬ:
//
// VStack:     "🔨 RowView init: 0" ... "🔨 RowView init: 9999"
//             → 10,000 prints NGAY LẬP TỨC khi view appear
//
// LazyVStack: "🔨 RowView init: 0" ... "🔨 RowView init: ~18"
//             → Chỉ ~18 prints ban đầu
//             → Scroll xuống → thêm prints cho rows mới xuất hiện


// ╔══════════════════════════════════════════════════════════╗
// ║  2. CƠ CHẾ HOẠT ĐỘNG BÊN TRONG (UNDER THE HOOD)        ║
// ╚══════════════════════════════════════════════════════════╝

// LazyVStack hoạt động theo cơ chế sau:
//
// ┌─────────────────────────────────────────────────────┐
// │                  ScrollView                         │
// │  ┌───────────────────────────────────────────────┐  │
// │  │              LazyVStack                       │  │
// │  │                                               │  │
// │  │  [ ] [ ] [ ]     ← Đã scroll qua (GIỮA LẠI  │  │
// │  │                     trong memory, KHÔNG huỷ)  │  │
// │  │  ─────────── Viewport top ───────────         │  │
// │  │  [■] [■] [■]     ← VISIBLE → đang hiển thị   │  │
// │  │  [■] [■] [■]                                  │  │
// │  │  [■] [■] [■]                                  │  │
// │  │  ─────────── Viewport bottom ─────────        │  │
// │  │  [+] [+]         ← BUFFER: pre-created       │  │
// │  │                     trước khi scroll tới      │  │
// │  │  [ ] [ ] ...      ← CHƯA TẠO (not init yet)  │  │
// │  └───────────────────────────────────────────────┘  │
// └─────────────────────────────────────────────────────┘
//
// QUAN TRỌNG — Khác với UITableView/UICollectionView:
//
// 1. KHÔNG CÓ CELL REUSE: Views đã tạo sẽ GIỮ LẠI trong memory
//    khi scroll qua. Scroll ngược lại → dùng lại instance cũ.
//    → Memory tăng dần khi scroll (nhưng chậm hơn VStack rất nhiều)
//
// 2. KHÔNG CÓ prepareForReuse(): Mỗi row là 1 unique View instance,
//    không bao giờ bị recycle cho row khác.
//
// 3. KÍCH THƯỚC TÍNH DẦN: LazyVStack không biết trước total height.
//    Scroll indicator có thể "nhảy" vì height được tính on-the-fly
//    khi rows mới được tạo.


// ╔══════════════════════════════════════════════════════════╗
// ║  3. INITIALIZER VÀ CÁC PARAMETERS                       ║
// ╚══════════════════════════════════════════════════════════╝

// LazyVStack(
//     alignment: HorizontalAlignment = .center,
//     spacing: CGFloat? = nil,
//     pinnedViews: PinnedScrollableViews = .init(),
//     @ViewBuilder content: () -> Content
// )

struct InitializerDemo: View {
    var body: some View {
        ScrollView {
            LazyVStack(
                alignment: .leading,       // Căn lề trái (mặc định: .center)
                spacing: 12,               // Khoảng cách giữa các items
                pinnedViews: [.sectionHeaders, .sectionFooters] // Pin headers/footers
            ) {
                ForEach(0..<100) { i in
                    Text("Item \(i)")
                        .padding(.horizontal)
                }
            }
        }
    }
}

// ALIGNMENT OPTIONS:
// .leading      → căn trái
// .center       → căn giữa (default)
// .trailing     → căn phải
//
// Alignment ảnh hưởng khi children có WIDTH KHÁC NHAU.
// Nếu tất cả children có cùng width (maxWidth: .infinity),
// alignment không tạo ra khác biệt thị giác.

struct AlignmentDemo: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                Text("Dòng ngắn")
                    .background(.blue.opacity(0.2))
                
                Text("Dòng dài hơn nhiều để thấy alignment")
                    .background(.green.opacity(0.2))
                
                Text("Trung bình")
                    .background(.orange.opacity(0.2))
            }
            .padding()
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. PINNED VIEWS — STICKY HEADERS/FOOTERS               ║
// ╚══════════════════════════════════════════════════════════╝

// pinnedViews cho phép "ghim" Section headers/footers lại
// khi scroll — giống UITableView section header behavior.
// → Chỉ hoạt động khi có Section bên trong LazyVStack.

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let initial: String
}

struct PinnedHeaderDemo: View {
    let sections: [(letter: String, contacts: [Contact])] = [
        ("A", [Contact(name: "An", initial: "A"), Contact(name: "Anh", initial: "A")]),
        ("B", [Contact(name: "Bình", initial: "B"), Contact(name: "Bảo", initial: "B")]),
        ("C", [Contact(name: "Cường", initial: "C")]),
        ("D", [Contact(name: "Dũng", initial: "D"), Contact(name: "Duy", initial: "D")]),
        ("H", [Contact(name: "Huy", initial: "H"), Contact(name: "Hùng", initial: "H")]),
        ("T", [Contact(name: "Tuấn", initial: "T"), Contact(name: "Thắng", initial: "T")])
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(
                    spacing: 0,
                    pinnedViews: [.sectionHeaders] // ← Ghim headers
                ) {
                    ForEach(sections, id: \.letter) { section in
                        Section {
                            // Content
                            ForEach(section.contacts) { contact in
                                ContactRow(contact: contact)
                            }
                        } header: {
                            // Header này sẽ "dính" ở top khi scroll
                            SectionHeader(title: section.letter)
                        }
                    }
                }
            }
            .navigationTitle("Danh bạ")
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial) // Blur effect khi pin
    }
}

struct ContactRow: View {
    let contact: Contact
    
    var body: some View {
        HStack {
            Circle()
                .fill(.blue.gradient)
                .frame(width: 40, height: 40)
                .overlay(Text(contact.initial).foregroundStyle(.white))
            
            Text(contact.name)
                .font(.body)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// PINNED FOOTERS (ít phổ biến hơn):
// pinnedViews: [.sectionFooters]
// pinnedViews: [.sectionHeaders, .sectionFooters] // cả hai


// ╔══════════════════════════════════════════════════════════╗
// ║  5. LAZYVSTACK + SCROLLVIEW — BỘ ĐÔI KHÔNG THỂ THIẾU    ║
// ╚══════════════════════════════════════════════════════════╝

// ⚠️ LazyVStack PHẢI nằm trong ScrollView (hoặc container scrollable)
// mới phát huy tính "lazy". Nếu không có ScrollView, LazyVStack
// hoạt động giống VStack vì tất cả children đều "visible".

// ❌ Không có scroll → không lazy
struct NoScrollBad: View {
    var body: some View {
        LazyVStack { // Hoạt động như VStack thường!
            ForEach(0..<1000) { i in
                Text("Row \(i)")
            }
        }
    }
}

// ✅ Đúng cách: luôn wrap trong ScrollView
struct WithScrollCorrect: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<1000) { i in
                    Text("Row \(i)")
                }
            }
        }
    }
}

// === ScrollView options ===
struct ScrollViewOptions: View {
    var body: some View {
        // Vertical scroll (default)
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack { /* ... */ }
        }
        
        // Cả vertical + horizontal
        // ScrollView([.vertical, .horizontal]) {
        //     LazyVStack { /* ... */ }
        // }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. LazyVStack vs LIST — KHI NÀO DÙNG CÁI NÀO?         ║
// ╚══════════════════════════════════════════════════════════╝

// ┌──────────────────────┬───────────────────┬───────────────────┐
// │     Tiêu chí         │    List           │ ScrollView +      │
// │                      │                   │ LazyVStack        │
// ├──────────────────────┼───────────────────┼───────────────────┤
// │ Cell reuse           │ ✅ CÓ (tương tự   │ ❌ KHÔNG (giữ lại │
// │                      │ UITableView)      │ views đã tạo)     │
// │ Memory (10K items)   │ Thấp & ổn định    │ Tăng dần khi scroll│
// │ Swipe actions        │ ✅ Built-in        │ ❌ Tự implement    │
// │ Separator lines      │ ✅ Built-in        │ ❌ Tự thêm         │
// │ Pull-to-refresh      │ ✅ .refreshable    │ ✅ .refreshable    │
// │ Edit mode / Delete   │ ✅ .onDelete       │ ❌ Tự implement    │
// │ Section headers      │ ✅ Built-in        │ ✅ pinnedViews     │
// │ Custom layout        │ Hạn chế           │ ✅ Tự do 100%      │
// │ Selection            │ ✅ Built-in        │ ❌ Tự implement    │
// │ Scroll position      │ .scrollPosition    │ .scrollPosition    │
// │ Custom styling       │ Bị giới hạn bởi   │ ✅ Không bị ràng   │
// │                      │ ListStyle          │ buộc bởi style nào │
// │ Background           │ Phức tạp để custom │ ✅ Dễ dàng         │
// │ Performance (100K+)  │ ✅ Tốt hơn (reuse) │ ⚠️ Memory tăng dần│
// └──────────────────────┴───────────────────┴───────────────────┘
//
// 📌 NGUYÊN TẮC CHỌN:
// → Dạng settings/form/danh sách chuẩn → List
// → UI custom, card layout, mixed content → LazyVStack
// → Dữ liệu cực lớn (100K+) + cần memory ổn định → List
// → Cần swipe-to-delete, edit mode → List (hoặc tự build)


// ╔══════════════════════════════════════════════════════════╗
// ║  7. INFINITE SCROLL / PAGINATION                         ║
// ╚══════════════════════════════════════════════════════════╝

// LazyVStack + onAppear trên phần tử cuối → trigger load thêm data.
// Đây là pattern phổ biến nhất cho infinite scrolling.

@Observable
final class PaginationViewModel {
    var items: [String] = []
    var currentPage = 0
    var isLoading = false
    var hasMore = true
    
    private let pageSize = 20
    
    func loadInitial() async {
        guard items.isEmpty else { return }
        await loadNextPage()
    }
    
    func loadNextPage() async {
        guard !isLoading, hasMore else { return }
        isLoading = true
        defer { isLoading = false }
        
        // Simulate network delay
        try? await Task.sleep(for: .seconds(0.8))
        
        let start = currentPage * pageSize
        let newItems = (start..<start + pageSize).map { "Item \($0 + 1)" }
        
        items.append(contentsOf: newItems)
        currentPage += 1
        hasMore = currentPage < 10 // Giả sử max 10 pages
    }
    
    // Kiểm tra item có gần cuối danh sách không
    func shouldLoadMore(currentItem: String) -> Bool {
        guard let index = items.firstIndex(of: currentItem) else { return false }
        // Load khi còn cách cuối 5 items (threshold)
        return index >= items.count - 5
    }
}

struct InfiniteScrollView: View {
    @State private var viewModel = PaginationViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.items, id: \.self) { item in
                        ItemRow(title: item)
                            .onAppear {
                                // Khi row XUẤT HIỆN trên màn hình
                                // → check nếu gần cuối → load thêm
                                if viewModel.shouldLoadMore(currentItem: item) {
                                    Task {
                                        await viewModel.loadNextPage()
                                    }
                                }
                            }
                    }
                    
                    // Loading indicator ở cuối danh sách
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(20)
                    }
                    
                    // Hết data
                    if !viewModel.hasMore {
                        Text("— Đã hiển thị tất cả —")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
            }
            .navigationTitle("Feed (\(viewModel.items.count))")
            .task {
                await viewModel.loadInitial()
            }
        }
    }
}

struct ItemRow: View {
    let title: String
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.blue.gradient)
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text("Mô tả chi tiết cho \(title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. SCROLL POSITION TRACKING (iOS 17+)                   ║
// ╚══════════════════════════════════════════════════════════╝

struct ScrollPositionDemo: View {
    @State private var scrollPosition: Int?
    let items = Array(0..<200)
    
    var body: some View {
        VStack {
            // Hiển thị vị trí hiện tại
            Text("Đang xem: \(scrollPosition.map(String.init) ?? "—")")
                .font(.headline)
                .padding()
            
            // Nút scroll nhanh
            HStack {
                Button("Đầu") { scrollToItem(0) }
                Button("Giữa") { scrollToItem(100) }
                Button("Cuối") { scrollToItem(199) }
            }
            .buttonStyle(.bordered)
            
            ScrollView {
                LazyVStack {
                    ForEach(items, id: \.self) { item in
                        Text("Row \(item)")
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(
                                scrollPosition == item
                                    ? Color.blue.opacity(0.2)
                                    : Color.clear
                            )
                    }
                }
                .scrollTargetLayout() // Cần cho scrollPosition hoạt động
            }
            .scrollPosition(id: $scrollPosition) // Track vị trí scroll
        }
    }
    
    private func scrollToItem(_ id: Int) {
        withAnimation(.smooth) {
            scrollPosition = id
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. SCROLLTO VỚI SCROLLVIEWREADER (iOS 14+)             ║
// ╚══════════════════════════════════════════════════════════╝

// Trước iOS 17, dùng ScrollViewReader + scrollTo:

struct ScrollViewReaderDemo: View {
    let items = Array(0..<500)
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                HStack {
                    Button("⬆️ Lên đầu") {
                        withAnimation {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                    Button("⬇️ Xuống cuối") {
                        withAnimation {
                            proxy.scrollTo(499, anchor: .bottom)
                        }
                    }
                }
                .buttonStyle(.bordered)
                .padding()
                
                ScrollView {
                    LazyVStack {
                        ForEach(items, id: \.self) { item in
                            Text("Item \(item)")
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .id(item) // ← BẮT BUỘC: gán id để scrollTo nhận diện
                        }
                    }
                }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. ONAPPEAR / ONDISAPPEAR LIFECYCLE                    ║
// ╚══════════════════════════════════════════════════════════╝

// Trong LazyVStack, onAppear/onDisappear fire theo visibility:
// - onAppear: view XUẤT HIỆN trên viewport (hoặc buffer gần viewport)
// - onDisappear: view BIẾN MẤT khỏi viewport (scroll qua)
//
// ⚠️ KHÁC với VStack nơi onAppear fire CHO TẤT CẢ ngay lập tức.

struct LifecycleDemo: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<100) { i in
                    Text("Row \(i)")
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .onAppear {
                            print("👁️ APPEAR: Row \(i)")
                            // Dùng cho:
                            // → Prefetch images/data
                            // → Track impression analytics
                            // → Trigger pagination
                        }
                        .onDisappear {
                            print("👻 DISAPPEAR: Row \(i)")
                            // Dùng cho:
                            // → Cancel ongoing downloads
                            // → Pause video playback
                            // → Stop animations
                        }
                }
            }
        }
    }
}

// ⚠️ GHI NHỚ: onAppear có thể fire NHIỀU LẦN cho cùng 1 view
// khi user scroll đi scroll lại. Nếu action chỉ nên chạy 1 lần
// (như analytics tracking), cần guard:

struct OneTimeAppearView: View {
    let index: Int
    @State private var hasAppeared = false
    
    var body: some View {
        Text("Row \(index)")
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                // Analytics, fetch... chỉ 1 lần
                print("📊 First impression: Row \(index)")
            }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. MIXED CONTENT — KẾT HỢP NHIỀU LOẠI VIEW            ║
// ╚══════════════════════════════════════════════════════════╝

// LazyVStack linh hoạt hơn List — cho phép mix bất kỳ view nào.

struct MixedContentFeed: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // --- Hero Banner ---
                Image(systemName: "photo.artframe")
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fit)
                    .background(.blue.gradient)
                    .clipShape(.rect(cornerRadius: 16))
                    .padding(.horizontal)
                
                // --- Section: Trending ---
                VStack(alignment: .leading) {
                    Text("🔥 Xu hướng")
                        .font(.title2.bold())
                        .padding(.horizontal)
                    
                    // Horizontal scroll TRONG LazyVStack
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(0..<20) { i in
                                TrendingCard(index: i)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 160)
                }
                
                // --- Divider ---
                Divider().padding(.horizontal)
                
                // --- Section: Feed Items (lazy loaded) ---
                Text("📰 Bài viết mới")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ForEach(0..<50) { i in
                    FeedCardView(index: i)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

struct TrendingCard: View {
    let index: Int
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.orange.gradient)
            .frame(width: 140, height: 160)
            .overlay(
                Text("Trend \(index + 1)")
                    .foregroundStyle(.white)
                    .font(.headline)
            )
    }
}

struct FeedCardView: View {
    let index: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.opacity(0.15))
                .frame(height: 200)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray)
                )
            
            Text("Bài viết #\(index + 1)")
                .font(.headline)
            
            Text("Mô tả ngắn gọn cho bài viết này. Nội dung thú vị...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(.background, in: .rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  12. PERFORMANCE OPTIMIZATION PATTERNS                   ║
// ╚══════════════════════════════════════════════════════════╝

// === 12a. Equatable Views — tránh re-render không cần thiết ===

struct OptimizedRow: View, Equatable {
    let id: Int
    let title: String
    let subtitle: String
    
    // Chỉ re-render khi data THỰC SỰ thay đổi
    static func == (lhs: OptimizedRow, rhs: OptimizedRow) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct OptimizedList: View {
    let items: [(id: Int, title: String, subtitle: String)]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(items, id: \.id) { item in
                    // .equatable() hint cho SwiftUI dùng == để check
                    OptimizedRow(
                        id: item.id,
                        title: item.title,
                        subtitle: item.subtitle
                    )
                    .equatable()
                }
            }
        }
    }
}

// === 12b. Identifiable + Stable IDs ===

// ❌ Dùng index làm id → performance kém
// ForEach(0..<items.count, id: \.self) { i in
//     Text(items[i]) // Thay đổi mảng → toàn bộ bị re-render
// }

// ✅ Dùng stable Identifiable id
struct TodoItem: Identifiable {
    let id: UUID  // Stable, unique
    var title: String
}

struct StableIDList: View {
    @State private var todos = (0..<100).map {
        TodoItem(id: UUID(), title: "Todo \($0)")
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                // ForEach tự dùng item.id vì TodoItem: Identifiable
                ForEach(todos) { todo in
                    Text(todo.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
        }
    }
}

// === 12c. Tránh heavy computation trong body ===

// ❌ BAD: Compute trong body → chạy mỗi lần re-render
// var body: some View {
//     let filtered = hugeArray.filter { ... }.sorted { ... }
//     LazyVStack {
//         ForEach(filtered) { ... }
//     }
// }

// ✅ GOOD: Compute trước, cache trong @State hoặc ViewModel
struct PreComputedView: View {
    @State private var processedItems: [String] = []
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(processedItems, id: \.self) { item in
                    Text(item)
                }
            }
        }
        .task {
            // Compute 1 lần khi view appear
            processedItems = await heavyComputation()
        }
    }
    
    func heavyComputation() async -> [String] {
        (0..<1000).map { "Processed \($0)" }
    }
}

// === 12d. Image Loading Pattern ===

struct LazyImageRow: View {
    let imageURL: URL?
    @State private var loadedImage: Image?
    
    var body: some View {
        Group {
            if let loadedImage {
                loadedImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .overlay(ProgressView())
            }
        }
        .frame(height: 200)
        .clipShape(.rect(cornerRadius: 12))
        .onAppear {
            // Load ảnh khi row xuất hiện
            loadImageIfNeeded()
        }
    }
    
    private func loadImageIfNeeded() {
        guard loadedImage == nil, let imageURL else { return }
        // In production: dùng AsyncImage hoặc Kingfisher/SDWebImage
        Task {
            // Simulate loading...
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  13. LAZYVSTACK vs LAZYHSTACK vs LAZYVGRID               ║
// ╚══════════════════════════════════════════════════════════╝

// ┌─────────────────┬──────────────┬──────────────┬──────────────┐
// │                 │ LazyVStack   │ LazyHStack   │ LazyVGrid    │
// ├─────────────────┼──────────────┼──────────────┼──────────────┤
// │ Layout          │ Dọc 1 cột   │ Ngang 1 hàng │ Grid nhiều cột│
// │ ScrollView      │ Vertical     │ Horizontal   │ Vertical     │
// │ Pinned Views    │ ✅           │ ✅           │ ✅           │
// │ Phổ biến cho    │ Feed, list   │ Carousel     │ Photo grid   │
// │ Eager version   │ VStack       │ HStack       │ N/A          │
// └─────────────────┴──────────────┴──────────────┴──────────────┘

struct AllLazyContainersDemo: View {
    var body: some View {
        ScrollView {
            // Vertical lazy
            LazyVStack {
                Text("Section 1: Carousel")
                    .font(.headline)
                
                // Horizontal lazy INSIDE vertical
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 10) {
                        ForEach(0..<50) { i in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.gradient)
                                .frame(width: 120, height: 80)
                                .overlay(Text("\(i)").foregroundStyle(.white))
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 100)
                
                Text("Section 2: Grid")
                    .font(.headline)
                
                // Grid INSIDE vertical lazy stack
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 8
                ) {
                    ForEach(0..<30) { i in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.green.gradient)
                            .frame(height: 100)
                            .overlay(Text("\(i)").foregroundStyle(.white))
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  14. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: LazyVStack KHÔNG có ScrollView
//    → Không lazy, tất cả views init ngay lập tức
//    ✅ FIX: Luôn wrap trong ScrollView

// ❌ PITFALL 2: GeometryReader bên trong LazyVStack
//    → Mỗi item dùng GeometryReader có thể gây layout thrashing
//    ✅ FIX: Dùng .frame(height:) cố định nếu có thể
//            Hoặc dùng onGeometryChange (iOS 18+)

// ❌ PITFALL 3: id thay đổi liên tục
//    ForEach(items, id: \.self) // Nếu items thay đổi thứ tự → toàn bộ re-create
//    ✅ FIX: Dùng stable Identifiable id (UUID, database ID)

// ❌ PITFALL 4: Quá nhiều .onAppear side effects
//    → Mỗi onAppear trigger network call → DDoS server
//    ✅ FIX: Debounce, guard hasAppeared, dùng threshold-based pagination

// ❌ PITFALL 5: Scroll indicator nhảy lung tung
//    → Vì LazyVStack tính height dần, rows khác chiều cao → indicator không chính xác
//    ✅ FIX: Cho mỗi row CÙNG chiều cao cố định .frame(height: 80)
//            Hoặc chấp nhận và ẩn indicator: showsIndicators: false

// ❌ PITFALL 6: Memory tăng mãi khi scroll dataset cực lớn (100K+)
//    → LazyVStack KHÔNG tái sử dụng cell, views cũ giữ trong memory
//    ✅ FIX: Dùng List cho datasets cực lớn (có cell reuse)
//            Hoặc implement custom recycling (hiếm khi cần)

// ✅ BEST PRACTICE CHECKLIST:
// 1. Luôn dùng trong ScrollView
// 2. Identifiable models với stable ID
// 3. Cố định height cho rows nếu có thể (performance + indicator)
// 4. Dùng .task {} thay vì .onAppear cho async work (auto-cancel)
// 5. Threshold-based pagination (load trước 5-10 items)
// 6. pinnedViews cho section headers thay vì tự implement sticky
// 7. Test với dataset lớn (1K-10K items) trên device thật
// 8. Profile bằng Instruments → Time Profiler + Allocations

---

Đây là một component quan trọng cho performance khi làm việc với danh sách lớn. Mình sẽ giải thích từ cơ chế hoạt động bên trong đến các production patterns nâng cao.Mình đã tổng hợp toàn bộ kiến thức LazyVStack trong 14 phần. Đây là những điểm cốt lõi:

**Bản chất hoạt động** (Phần 2) là điểm quan trọng nhất cần hiểu: LazyVStack chỉ init views khi chúng sắp xuất hiện trên viewport. Tuy nhiên, **khác hoàn toàn với UITableView** — nó **không có cell reuse**. Views đã tạo sẽ được giữ lại trong memory khi scroll qua, nghĩa là memory tăng dần theo lượng content đã scroll. Đây là trade-off cần cân nhắc khi chọn giữa LazyVStack và List.

**Ba patterns production quan trọng nhất:**

**Phần 4 — Pinned Views**: Cho phép "ghim" section headers giống UITableView sticky headers. Chỉ cần thêm `pinnedViews: [.sectionHeaders]` và wrap content trong `Section`. Rất hữu ích cho danh bạ, grouped settings.

**Phần 7 — Infinite Scroll**: Pattern `onAppear` + threshold-based pagination — load thêm data khi user còn cách cuối danh sách 5 items thay vì đợi đến item cuối cùng. Tránh được cảm giác "chờ đợi" cho user.

**Phần 8 — Scroll Position** (iOS 17+): API `.scrollPosition(id:)` kết hợp `.scrollTargetLayout()` cho phép vừa track vừa programmatically scroll đến item bất kỳ — thay thế `ScrollViewReader` cũ với API sạch hơn nhiều.

**Decision rule ở Phần 6** cho việc chọn List vs LazyVStack: nếu cần swipe actions, edit mode, hoặc dataset cực lớn (100K+) → dùng List vì có cell reuse. Nếu cần UI tự do, mixed content, card layout → LazyVStack là lựa chọn đúng.

Huy muốn mình đi sâu thêm vào phần nào — ví dụ custom pull-to-refresh, hoặc kết hợp LazyVStack với SwiftData `@Query`?
