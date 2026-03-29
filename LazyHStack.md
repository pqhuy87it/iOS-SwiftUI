# SwiftUI: `LazyHStack` — Giải thích chi tiết

## 1. Bản chất — HStack chỉ tạo view khi CẦN

`LazyHStack` xếp children theo **chiều ngang** giống `HStack`, nhưng chỉ **tạo (initialize) view khi nó sắp hiển thị trên màn hình**. View ngoài vùng nhìn thấy chưa được tạo → tiết kiệm memory và CPU.

```
HStack (eager):
┌──────────────────────────────────────────────────────────┐
│ [1] [2] [3] [4] [5] [6] [7] ... [997] [998] [999] [1000]│
│  ↑   ↑   ↑   ↑   ↑   ↑   ↑       ↑     ↑     ↑     ↑  │
│ TẤT CẢ 1000 views tạo NGAY khi render                    │
└──────────────────────────────────────────────────────────┘

LazyHStack (lazy):
         ┌── visible ──┐
─ ─ ─ ─ ─│[3] [4] [5] [6]│─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
  chưa tạo│  đã tạo      │chưa tạo
          └───────────────┘
  scroll → tạo thêm view mới, view cũ có thể bị destroy
```

---

## 2. Cú pháp

```swift
LazyHStack(alignment: .center, spacing: 12) {
    // children
}

// Parameters:
// alignment: VerticalAlignment — .top, .center (default), .bottom,
//            .firstTextBaseline, .lastTextBaseline
// spacing: CGFloat? — khoảng cách giữa children (nil = system default)
// content: @ViewBuilder closure
```

---

## 3. HStack vs LazyHStack — Khi nào dùng cái nào

### HStack — Eager (tạo tất cả ngay)

```swift
ScrollView(.horizontal) {
    HStack {
        ForEach(0..<1000) { i in
            CardView(index: i)
                .onAppear { print("Created \(i)") }
        }
    }
}
// Console: Created 0, Created 1, ... Created 999
// ← 1000 views tạo NGAY LẬP TỨC dù chỉ ~4 views visible
```

### LazyHStack — Lazy (tạo khi cần)

```swift
ScrollView(.horizontal) {
    LazyHStack {
        ForEach(0..<1000) { i in
            CardView(index: i)
                .onAppear { print("Created \(i)") }
        }
    }
}
// Console: Created 0, Created 1, Created 2, Created 3
// ← Chỉ ~4 views visible → chỉ tạo ~4 views
// Scroll phải → Created 4, Created 5...
```

### Bảng so sánh

```
                    HStack                   LazyHStack
                    ──────                   ──────────
Tạo children        TẤT CẢ ngay             Chỉ visible + buffer nhỏ
Memory              O(N) — tất cả views      O(visible) — ~10-20 views
CPU lúc render      Cao (N views)            Thấp (vài views)
Scroll performance  Mượt (đã tạo sẵn)       Mượt (tạo incremental)
Layout chính xác?   ✅ Biết size tất cả      ⚠️ Ước lượng (chưa tạo = chưa biết size)
Dùng khi            Ít children (< ~50)      Nhiều children (> ~50)
BẮT BUỘC            Không cần ScrollView     BẮT BUỘC trong ScrollView(.horizontal)
```

### ⚠️ LazyHStack BẮT BUỘC trong ScrollView

```swift
// ❌ LazyHStack không có ScrollView → chỉ hiện vài view, không scroll được
LazyHStack {
    ForEach(0..<100) { i in Text("\(i)") }
}
// → Chỉ hiển thị vài items vừa màn hình, còn lại bị cắt

// ✅ Luôn wrap trong ScrollView(.horizontal)
ScrollView(.horizontal) {
    LazyHStack {
        ForEach(0..<100) { i in Text("\(i)") }
    }
}
```

---

## 4. Lifecycle — Khi nào view được tạo và huỷ

```swift
ScrollView(.horizontal) {
    LazyHStack(spacing: 16) {
        ForEach(items) { item in
            CardView(item: item)
                .onAppear { print("👀 Appear: \(item.id)") }
                .onDisappear { print("👋 Disappear: \(item.id)") }
        }
    }
}
```

```
Khởi tạo (hiện 4 cards trên màn hình):
👀 Appear: 1
👀 Appear: 2
👀 Appear: 3
👀 Appear: 4

Scroll phải → card 5 sắp hiện:
👀 Appear: 5          ← tạo card 5

Scroll tiếp → card 1 ra khỏi màn hình:
👋 Disappear: 1       ← card 1 CÓ THỂ bị destroy
👀 Appear: 6          ← tạo card 6

Scroll ngược lại ← card 1 quay lại:
👀 Appear: 1          ← card 1 được TẠO LẠI (state reset!)
```

### ⚠️ State reset khi view bị destroy rồi tạo lại

```swift
struct CardView: View {
    let item: Item
    @State private var isExpanded = false    // ← LOCAL state
    
    var body: some View {
        VStack {
            Text(item.name)
            if isExpanded {
                Text(item.detail)
            }
        }
        .onTapGesture { isExpanded.toggle() }
    }
}

// User expand card 1 → scroll xa → scroll lại
// Card 1 bị destroy rồi tạo lại → isExpanded RESET về false!
// ← State cục bộ KHÔNG ĐƯỢC bảo toàn qua destroy/recreate
```

**Giải pháp: lưu state ở parent/ViewModel thay vì @State local:**

```swift
// State lưu ở ViewModel
@Observable
class ListViewModel {
    var expandedItems: Set<UUID> = []
    
    func toggleExpand(_ id: UUID) {
        if expandedItems.contains(id) {
            expandedItems.remove(id)
        } else {
            expandedItems.insert(id)
        }
    }
}

struct CardView: View {
    let item: Item
    let isExpanded: Bool       // ← nhận từ bên ngoài
    let onToggle: () -> Void
    
    var body: some View {
        VStack {
            Text(item.name)
            if isExpanded { Text(item.detail) }
        }
        .onTapGesture { onToggle() }
    }
}

// Parent
ScrollView(.horizontal) {
    LazyHStack {
        ForEach(items) { item in
            CardView(
                item: item,
                isExpanded: vm.expandedItems.contains(item.id),
                onToggle: { vm.toggleExpand(item.id) }
            )
        }
    }
}
// ← isExpanded sống ở ViewModel → scroll xa rồi quay lại vẫn giữ trạng thái
```

---

## 5. Ứng dụng thực tế

### 5.1 Horizontal carousel — Stories / Featured items

```swift
struct StoriesBar: View {
    let stories: [Story]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(stories) { story in
                    StoryBubble(story: story)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 90)
    }
}

struct StoryBubble: View {
    let story: Story
    
    var body: some View {
        VStack(spacing: 4) {
            AsyncImage(url: story.avatarURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        story.isViewed ? .gray.opacity(0.3) :
                            .linearGradient(colors: [.purple, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 2
                    )
                    .padding(-3)
            )
            
            Text(story.username)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 64)
        }
    }
}
```

```
┌──────────────────────────────────────────┐
│  (Ava1)   (Ava2)   (Ava3)   (Ava4)  ... │  ← scroll ngang
│  alice    bob      charlie  dave         │
└──────────────────────────────────────────┘
```

### 5.2 Product cards — Horizontal scroll

```swift
struct FeaturedProducts: View {
    let products: [Product]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured")
                    .font(.title2.bold())
                Spacer()
                Button("See All") { }
                    .font(.subheadline)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(products) { product in
                        ProductCard(product: product)
                            .frame(width: 200, height: 260)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
```

### 5.3 Image gallery — Full-screen paging

```swift
struct ImageGallery: View {
    let images: [GalleryImage]
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(images) { image in
                    AsyncImage(url: image.url) { img in
                        img.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    // ↑ Mỗi ảnh full width → paging effect
                }
            }
        }
        .scrollTargetBehavior(.paging)     // iOS 17+: snap to page
        .scrollIndicators(.hidden)
    }
}
```

### 5.4 Date picker ngang — Calendar strip

```swift
struct DateStripPicker: View {
    @State private var selectedDate = Date()
    let dates: [Date]    // 30 ngày
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(dates, id: \.self) { date in
                    DateCell(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    )
                    .onTapGesture {
                        withAnimation { selectedDate = date }
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 70)
    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.caption)
                .foregroundStyle(isSelected ? .white : .secondary)
            Text(date.formatted(.dateTime.day()))
                .font(.title3.bold())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .frame(width: 44, height: 60)
        .background(isSelected ? Color.blue : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
```

```
┌─────────────────────────────────────────┐
│ Mon  Tue  [Wed]  Thu  Fri  Sat  Sun ... │
│  24   25  [26]   27   28   29   30      │
└─────────────────────────────────────────┘
              ↑ selected (blue background)
```

### 5.5 Infinite scroll — Load more khi gần cuối

```swift
struct InfiniteHScroll: View {
    @State private var items: [Item] = Array(0..<20).map { Item(id: $0) }
    @State private var isLoadingMore = false
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 12) {
                ForEach(items) { item in
                    CardView(item: item)
                        .onAppear {
                            // Khi item gần cuối xuất hiện → load thêm
                            if item.id == items.last?.id {
                                loadMore()
                            }
                        }
                }
                
                if isLoadingMore {
                    ProgressView()
                        .frame(width: 50)
                }
            }
            .padding(.horizontal)
        }
    }
    
    func loadMore() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        
        Task {
            try? await Task.sleep(for: .seconds(1))
            let newItems = (items.count..<items.count + 20).map { Item(id: $0) }
            items.append(contentsOf: newItems)
            isLoadingMore = false
        }
    }
}
```

```
Scroll gần cuối:
──[15]──[16]──[17]──[18]──[19]──[⏳]──
                              ↑ item cuối appear → loadMore()
                                       ↑ loading indicator

Sau khi load:
──[17]──[18]──[19]──[20]──[21]──[22]──...──[39]──
                     ↑ 20 items mới được thêm
```

### 5.6 Tab bar / Segmented filter — Horizontal scrollable

```swift
struct ScrollableFilterBar: View {
    let filters: [String]
    @Binding var selected: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            selected = filter
                        }
                    } label: {
                        Text(filter)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selected == filter ? Color.blue : Color.gray.opacity(0.15))
                            )
                            .foregroundStyle(selected == filter ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 44)
    }
}
```

---

## 6. Pinned Views — Sticky headers/footers

```swift
ScrollView(.horizontal) {
    LazyHStack(pinnedViews: [.sectionHeaders]) {
        Section {
            ForEach(mondayTasks) { task in
                TaskCard(task: task)
            }
        } header: {
            Text("Monday")
                .font(.headline)
                .padding(8)
                .background(.ultraThinMaterial)
            // ↑ Sticky: dính left edge khi scroll ngang
        }
        
        Section {
            ForEach(tuesdayTasks) { task in
                TaskCard(task: task)
            }
        } header: {
            Text("Tuesday")
                .font(.headline)
                .padding(8)
                .background(.ultraThinMaterial)
        }
    }
}
```

```
Scroll ngang:
┌─── pinned ──┬────────────────────────────────┐
│ [Monday]    │ [Task1] [Task2] [Task3] ...    │
│ (dính left) │                                │
└─────────────┴────────────────────────────────┘

Scroll qua hết Monday tasks:
┌─── pinned ──┬────────────────────────────────┐
│ [Tuesday]   │ [TaskA] [TaskB] [TaskC] ...    │
│ (thay thế)  │                                │
└─────────────┴────────────────────────────────┘
```

---

## 7. iOS 17+ Enhancements

### scrollTargetLayout — Snap to item

```swift
ScrollView(.horizontal) {
    LazyHStack(spacing: 16) {
        ForEach(items) { item in
            CardView(item: item)
                .frame(width: 300, height: 200)
        }
    }
    .scrollTargetLayout()
    // ↑ Đánh dấu LazyHStack là scroll target
}
.scrollTargetBehavior(.viewAligned)
// ↑ Snap: scroll dừng đúng tại mép card, không dừng giữa chừng
.scrollIndicators(.hidden)
.contentMargins(.horizontal, 20, for: .scrollContent)
// ↑ Padding cho scroll content
```

### scrollPosition — Track / Set vị trí scroll

```swift
struct HorizontalList: View {
    let items: [Item]
    @State private var scrolledID: Item.ID?
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(items) { item in
                    CardView(item: item)
                        .frame(width: 200)
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrolledID)
        // ↑ Two-way binding: đọc item hiện tại + scroll đến item
        
        Button("Go to first") {
            withAnimation {
                scrolledID = items.first?.id
                // ← Programmatic scroll đến item đầu tiên
            }
        }
    }
}
```

### scrollTransition — Animate khi scroll

```swift
ScrollView(.horizontal) {
    LazyHStack(spacing: 16) {
        ForEach(items) { item in
            CardView(item: item)
                .frame(width: 250, height: 350)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.5)
                        .scaleEffect(
                            x: phase.isIdentity ? 1 : 0.9,
                            y: phase.isIdentity ? 1 : 0.9
                        )
                        .rotationEffect(.degrees(phase.isIdentity ? 0 : phase.value * 5))
                }
        }
    }
    .scrollTargetLayout()
}
.scrollTargetBehavior(.viewAligned)
```

```
Hiệu ứng khi scroll:
     ┌─────┐   ┌───────┐   ┌─────┐
     │ 0.5 │   │  1.0  │   │ 0.5 │
     │ 90% │   │ 100%  │   │ 90% │
     │ tilt│   │ center│   │tilt │
     └─────┘   └───────┘   └─────┘
    fading in   FOCUSED    fading out
```

---

## 8. Alignment chi tiết

```swift
// .top — children căn top
LazyHStack(alignment: .top) {
    Text("Short")
    Text("Taller\ntext")
    Text("A")
}
```

```
.top:                    .center:                .bottom:
┌────┬────────┬───┐     ┌────┬────────┬───┐    ┌────┬────────┬───┐
│Shrt│ Taller │ A │     │    │ Taller │   │    │    │ Taller │   │
│    │ text   │   │     │Shrt│ text   │ A │    │    │ text   │   │
│    │        │   │     │    │        │   │    │Shrt│        │ A │
└────┴────────┴───┘     └────┴────────┴───┘    └────┴────────┴───┘
```

```swift
// .firstTextBaseline — căn theo baseline dòng đầu
LazyHStack(alignment: .firstTextBaseline) {
    Text("Title").font(.largeTitle)
    Text("Subtitle").font(.caption)
}
// "Title" và "Subtitle" căn baseline dòng đầu dù font size khác
```

---

## 9. Sai lầm thường gặp

### ❌ LazyHStack không có ScrollView

```swift
// ❌ Không scroll được, items bị cắt
LazyHStack {
    ForEach(0..<100) { i in Text("\(i)") }
}

// ✅ Bọc trong ScrollView(.horizontal)
ScrollView(.horizontal) {
    LazyHStack {
        ForEach(0..<100) { i in Text("\(i)") }
    }
}
```

### ❌ Dùng HStack cho list dài trong ScrollView

```swift
// ❌ 1000 views tạo ngay → chậm, tốn memory
ScrollView(.horizontal) {
    HStack {
        ForEach(0..<1000) { i in LargeCard(index: i) }
    }
}

// ✅ LazyHStack → tạo khi cần
ScrollView(.horizontal) {
    LazyHStack {
        ForEach(0..<1000) { i in LargeCard(index: i) }
    }
}
```

### ❌ Phụ thuộc @State local trong child views

```swift
// ❌ State bị reset khi scroll xa rồi quay lại
struct Card: View {
    @State private var liked = false    // ← reset khi recreate
    var body: some View {
        Button(liked ? "♥" : "♡") { liked.toggle() }
    }
}

// ✅ State lưu ở parent / ViewModel
struct Card: View {
    let isLiked: Bool                   // ← nhận từ ngoài
    let onToggleLike: () -> Void
    var body: some View {
        Button(isLiked ? "♥" : "♡") { onToggleLike() }
    }
}
```

### ❌ Quên set frame cho expanding children

```swift
// ❌ Color/Rectangle trong LazyHStack → width = 0 hoặc unexpected
ScrollView(.horizontal) {
    LazyHStack {
        ForEach(0..<10) { _ in
            Color.blue    // ← expanding view, width không xác định
        }
    }
}

// ✅ Set frame tường minh
ScrollView(.horizontal) {
    LazyHStack {
        ForEach(0..<10) { _ in
            Color.blue.frame(width: 200, height: 150)
        }
    }
}
```

### ❌ Nhầm vertical/horizontal axis

```swift
// ❌ LazyHStack trong ScrollView (vertical) → không scroll ngang
ScrollView {    // ← mặc định .vertical
    LazyHStack { ... }
}

// ✅ ScrollView(.horizontal) cho LazyHStack
ScrollView(.horizontal) {
    LazyHStack { ... }
}

// ✅ LazyVStack cho ScrollView vertical
ScrollView {
    LazyVStack { ... }
}
```

---

## 10. LazyHStack vs LazyHGrid

```
LazyHStack:
  → Xếp ngang 1 HÀNG duy nhất
  ──[A]──[B]──[C]──[D]──[E]──

LazyHGrid:
  → Xếp ngang NHIỀU HÀNG (grid)
  ──[A]──[C]──[E]──[G]──
  ──[B]──[D]──[F]──[H]──
```

```swift
// LazyHStack — 1 hàng
ScrollView(.horizontal) {
    LazyHStack { ForEach(items) { item in Card(item: item) } }
}

// LazyHGrid — nhiều hàng
let rows = [GridItem(.fixed(100)), GridItem(.fixed(100))]
ScrollView(.horizontal) {
    LazyHGrid(rows: rows) {
        ForEach(items) { item in Card(item: item) }
    }
}
```

---

## 11. Tóm tắt

| Khía cạnh | Chi tiết |
|---|---|
| **Là gì?** | HStack lazy — chỉ tạo view khi sắp hiển thị |
| **Khác HStack** | HStack: tạo tất cả ngay. LazyHStack: tạo khi cần |
| **BẮT BUỘC** | Phải nằm trong `ScrollView(.horizontal)` |
| **Alignment** | `.top`, `.center` (default), `.bottom`, `.firstTextBaseline`, `.lastTextBaseline` |
| **Spacing** | `spacing:` parameter, nil = system default |
| **Pinned views** | `pinnedViews: [.sectionHeaders]` → sticky section headers |
| **State trong child** | ⚠️ `@State` local bị reset khi view destroy → lưu state ở parent |
| **Expanding children** | ⚠️ Phải set `.frame(width:)` tường minh cho Color, Rectangle... |
| **iOS 17+** | `.scrollTargetLayout()`, `.scrollPosition(id:)`, `.scrollTransition` |
| **Dùng khi** | Horizontal scroll > 50 items: carousel, gallery, stories, date picker, filter bar |
| **KHÔNG dùng khi** | Ít items (< 50) → HStack đủ. Nhiều hàng → LazyHGrid |

---

`LazyHStack` là phiên bản "lazy" của HStack — chỉ tạo view khi sắp hiển thị trên màn hình, Huy. Ba điểm cốt lõi:

**Lazy = chỉ tạo khi cần.** HStack tạo TẤT CẢ 1000 views ngay khi render → tốn memory + CPU. LazyHStack chỉ tạo ~4-6 views đang visible + buffer nhỏ, scroll thêm → tạo mới, scroll qua → destroy cũ. Bắt buộc nằm trong `ScrollView(.horizontal)` — không có ScrollView thì LazyHStack không scroll được, items bị cắt.

**@State local trong child bị reset — sai lầm phổ biến nhất.** Khi user scroll xa rồi scroll lại, view bị destroy rồi tạo lại → `@State private var liked = false` reset về mặc định. Giải pháp: lưu state ở **parent/ViewModel** (ví dụ `Set<UUID>` cho liked items), truyền xuống child qua parameter. Đây là trade-off của lazy loading — tiết kiệm memory nhưng state local không bền.

**iOS 17+ nâng cấp mạnh:** `.scrollTargetLayout()` + `.scrollTargetBehavior(.viewAligned)` cho snap-to-item (carousel chuyên nghiệp). `.scrollPosition(id:)` cho programmatic scroll + track vị trí. `.scrollTransition` cho animation khi scroll (scale, fade, rotate items khi vào/ra viewport). Trước iOS 17 phải dùng GeometryReader hack rất phức tạp cho những hiệu ứng này.

Quy tắc chọn: ít items (<50) → HStack đủ. Nhiều items (>50) horizontal → LazyHStack. Nhiều items cần grid nhiều hàng → LazyHGrid.
