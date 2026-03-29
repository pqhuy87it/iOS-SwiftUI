# SwiftUI: Layout System — Giải thích chi tiết

## 1. Nguyên tắc cốt lõi — 3 bước Layout

SwiftUI layout hoạt động theo **3 bước đàm phán** giữa parent và child:

```
Bước 1: Parent ĐỀ XUẤT kích thước cho child
         "Con ơi, con có 300×500 pt để dùng"

Bước 2: Child TỰ QUYẾT ĐỊNH kích thước của mình
         "Con chỉ cần 200×44 pt thôi" (Text, Image...)
         HOẶC "Con lấy hết 300×500 pt" (Color, Spacer...)

Bước 3: Parent ĐẶT child vào vị trí trong không gian đã cho
         (thường là CENTER của vùng đề xuất)
```

```
Parent (300 × 500)
┌─────────────────────────────────┐
│                                 │
│         ┌───────────┐           │
│         │ Text      │           │  ← Child tự chọn size
│         │ "Hello"   │           │     Parent đặt ở CENTER
│         │ (65 × 20) │           │
│         └───────────┘           │
│                                 │
└─────────────────────────────────┘
```

### View phân loại theo cách chọn kích thước

```
"Tôi chỉ lấy vừa đủ" (hugging):
  Text, Image, Label, Button, Toggle, Slider
  → Kích thước phụ thuộc NỘI DUNG

"Tôi lấy hết" (expanding/greedy):
  Color, Rectangle, Spacer, GeometryReader, Divider (1 chiều)
  → Mở rộng hết không gian parent đề xuất

"Tôi tuỳ theo children" (container):
  VStack, HStack, ZStack, List, ScrollView
  → Kích thước phụ thuộc CHILDREN bên trong
```

---

## 2. Stack Layout — VStack, HStack, ZStack

### 2.1 `VStack` — Xếp dọc

```swift
VStack(alignment: .leading, spacing: 12) {
    Text("Title")           // child 1
    Text("Subtitle")        // child 2
    Button("Action") { }    // child 3
}
```

```
┌─── VStack (alignment: .leading) ───┐
│ Title                               │
│                    ← spacing: 12    │
│ Subtitle                            │
│                    ← spacing: 12    │
│ [Action]                            │
└─────────────────────────────────────┘
```

**VStack layout algorithm:**

```
1. Nhận proposed size từ parent (ví dụ 300 × 500)
2. Trừ spacing giữa các children (2 khoảng × 12 = 24)
   → Còn 300 × 476 cho children
3. Chia đều phần còn lại cho children CHƯA BIẾT size
   → Hỏi từng child: "Con cần bao nhiêu?"
4. Child có priority cao hơn được hỏi trước
5. Sau khi tất cả children báo size → VStack tính tổng height
6. VStack size = (max child width) × (tổng heights + spacings)
```

### Alignment

```swift
VStack(alignment: .leading) { ... }    // children căn trái
VStack(alignment: .center) { ... }     // children căn giữa (default)
VStack(alignment: .trailing) { ... }   // children căn phải
```

```
.leading          .center           .trailing
┌──────────┐     ┌──────────┐     ┌──────────┐
│ Hello    │     │  Hello   │     │    Hello │
│ World!!  │     │ World!!  │     │  World!! │
│ Hi       │     │    Hi    │     │       Hi │
└──────────┘     └──────────┘     └──────────┘
```

### 2.2 `HStack` — Xếp ngang

```swift
HStack(alignment: .center, spacing: 8) {
    Image(systemName: "star.fill")
    Text("Favorites")
    Spacer()
    Text("42")
}
```

```
┌─── HStack ──────────────────────────┐
│ ★ ← 8 → Favorites ←── Spacer ──→ 42│
└─────────────────────────────────────┘
```

### HStack alignment

```swift
HStack(alignment: .top) { ... }
HStack(alignment: .center) { ... }      // default
HStack(alignment: .bottom) { ... }
HStack(alignment: .firstTextBaseline) { ... }  // căn theo baseline text đầu
HStack(alignment: .lastTextBaseline) { ... }   // căn theo baseline text cuối
```

```
.top              .center           .firstTextBaseline
┌──────────┐     ┌──────────┐     ┌──────────┐
│ A  BIG   │     │     BIG  │     │ A  BIG   │
│    text  │     │ A  text  │     │    text  │
└──────────┘     └──────────┘     └──────────┘
  A ở top         A ở center        A căn baseline với B
```

### 2.3 `ZStack` — Xếp chồng (trục Z)

```swift
ZStack(alignment: .bottomTrailing) {
    Image("background")        // dưới cùng
    Text("Overlay")            // giữa
    Badge()                    // trên cùng
}
```

```
┌─── ZStack ───────────────┐
│ ┌── Image (bottom) ────┐ │
│ │                       │ │
│ │    ┌── Text ─┐        │ │
│ │    │ Overlay │        │ │
│ │    └─────────┘        │ │
│ │              ┌Badge┐  │ │  ← bottomTrailing
│ └──────────────└─────┘──┘ │
└───────────────────────────┘
```

**ZStack không xếp dọc hay ngang** — tất cả children chồng lên nhau. Size = child lớn nhất. Alignment quyết định children nhỏ hơn nằm ở đâu.

---

## 3. `Spacer` và `Divider`

### Spacer — Expanding invisible view

```swift
HStack {
    Text("Left")
    Spacer()           // đẩy "Right" sang phải
    Text("Right")
}
// [Left ←── Spacer mở rộng ──→ Right]

VStack {
    Text("Top")
    Spacer()           // đẩy "Bottom" xuống dưới
    Text("Bottom")
}
```

```swift
Spacer(minLength: 20)    // tối thiểu 20pt, mở rộng nếu có chỗ
Spacer()                  // minLength mặc định ≈ 8pt
```

### Nhiều Spacer chia đều

```swift
HStack {
    Spacer()
    Text("Center")
    Spacer()
}
// Hai Spacer chia đều → Text nằm chính giữa

HStack {
    Text("A")
    Spacer()
    Text("B")
    Spacer()
    Text("C")
}
// [A ←── equal ──→ B ←── equal ──→ C]
```

### Divider — Đường kẻ phân cách

```swift
VStack {
    Text("Section 1")
    Divider()              // đường ngang full width
    Text("Section 2")
}

HStack {
    Text("Left")
    Divider()              // đường dọc full height
    Text("Right")
}
```

---

## 4. `frame` Modifier — Kiểm soát kích thước

### Fixed frame

```swift
Text("Hello")
    .frame(width: 200, height: 50)
// Text container = 200 × 50, Text content căn giữa bên trong
```

### Flexible frame

```swift
Text("Hello")
    .frame(maxWidth: .infinity)
// Mở rộng hết chiều ngang

Text("Hello")
    .frame(minWidth: 100, maxWidth: 300, minHeight: 44)
// Tối thiểu 100, tối đa 300, chiều cao tối thiểu 44

Text("Hello")
    .frame(maxWidth: .infinity, maxHeight: .infinity)
// Mở rộng hết cả hai chiều (giống Color)
```

### frame + alignment

```swift
Text("Hello")
    .frame(width: 200, height: 100, alignment: .topLeading)
// Text nằm ở góc top-left của frame 200×100

// Alignment options:
// .topLeading    .top        .topTrailing
// .leading       .center     .trailing
// .bottomLeading .bottom     .bottomTrailing
```

```
.frame(alignment: .topLeading)     .frame(alignment: .center)
┌──────────────────┐               ┌──────────────────┐
│ Hello            │               │                  │
│                  │               │      Hello       │
│                  │               │                  │
└──────────────────┘               └──────────────────┘
```

### fixedSize — Bỏ qua proposed size

```swift
// Text mặc định co lại theo proposed width → xuống dòng hoặc truncate
Text("This is a very long text that might truncate")
    .frame(width: 100)
// → Truncate hoặc wrap

Text("This is a very long text that might truncate")
    .fixedSize()
// → Hiển thị TOÀN BỘ, bỏ qua giới hạn width từ parent
// ⚠️ Có thể tràn ra ngoài bounds

Text("Long text...")
    .fixedSize(horizontal: true, vertical: false)
// Chỉ bỏ qua giới hạn horizontal, vertical vẫn tuân theo
```

---

## 5. `padding` — Khoảng đệm

```swift
Text("Hello")
    .padding()                      // padding đều 4 cạnh (~16pt)
    .padding(20)                    // padding đều 20pt
    .padding(.horizontal, 16)      // padding trái + phải 16pt
    .padding(.vertical, 8)         // padding trên + dưới 8pt
    .padding(.top, 12)             // padding chỉ trên 12pt
    .padding(.leading, 10)         // padding chỉ leading
    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
```

```
Không padding:           Có .padding(16):
┌──────────────┐        ┌──────────────────────┐
│Hello World   │        │  ┌──────────────┐    │
└──────────────┘        │  │Hello World   │    │
                        │  └──────────────┘    │
                        └──────────────────────┘
                           ← 16 →        ← 16 →
```

---

## 6. Lazy Stacks — LazyVStack / LazyHStack

### VStack vs LazyVStack

```swift
// VStack: tạo TẤT CẢ children NGAY LẬP TỨC
ScrollView {
    VStack {
        ForEach(0..<10000) { i in
            Text("Row \(i)")
            // ← 10000 Text được tạo ngay → tốn memory + CPU
        }
    }
}

// LazyVStack: chỉ tạo children KHI CẦN (visible trên màn hình)
ScrollView {
    LazyVStack {
        ForEach(0..<10000) { i in
            Text("Row \(i)")
            // ← Chỉ ~20 Text hiển thị → tạo ~20 Text
            // Scroll → tạo thêm, destroy cái cũ
        }
    }
}
```

```
              VStack              LazyVStack
              ──────              ──────────
Tạo children  TẤT CẢ ngay        Chỉ visible
Memory        O(N)                O(visible)
Scroll perf   Chậm (N lớn)       Mượt
Layout        Chính xác           Ước lượng (chiều scroll)
Dùng khi      Ít children (<50)   Nhiều children (>50)
```

### LazyVStack alignment + spacing

```swift
ScrollView {
    LazyVStack(alignment: .leading, spacing: 0) {
        ForEach(items) { item in
            ItemRow(item: item)
            Divider()
        }
    }
}
```

### Pinned headers — Sticky section headers

```swift
ScrollView {
    LazyVStack(pinnedViews: [.sectionHeaders]) {
        ForEach(sections) { section in
            Section {
                ForEach(section.items) { item in
                    ItemRow(item: item)
                }
            } header: {
                Text(section.title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.ultraThinMaterial)
                // ↑ Header dính top khi scroll
            }
        }
    }
}
```

---

## 7. Grid Layout

### 7.1 `Grid` (iOS 16+) — Static grid, căn chỉnh chính xác

```swift
Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
    GridRow {
        Text("Name:")
            .gridColumnAlignment(.trailing)    // cột 1 căn phải
        Text("Huy Nguyen")
    }
    GridRow {
        Text("Email:")
        Text("huy@example.com")
    }
    GridRow {
        Text("Role:")
        Text("iOS Developer")
    }
    
    Divider()
        .gridCellColumns(2)    // span 2 cột
    
    GridRow {
        Color.clear
            .gridCellUnsizedAxes(.horizontal)    // cell trống
        Button("Edit Profile") { }
    }
}
```

```
┌───────────┬──────────────────┐
│     Name: │ Huy Nguyen       │
│    Email: │ huy@example.com  │
│     Role: │ iOS Developer    │
├───────────┴──────────────────┤
│                [Edit Profile]│
└──────────────────────────────┘
```

### 7.2 `LazyVGrid` / `LazyHGrid` — Scrollable grid

```swift
let columns = [
    GridItem(.flexible()),                      // cột linh hoạt
    GridItem(.flexible()),                      // cột linh hoạt
    GridItem(.flexible()),                      // cột linh hoạt
]

ScrollView {
    LazyVGrid(columns: columns, spacing: 16) {
        ForEach(items) { item in
            ItemCard(item: item)
        }
    }
    .padding()
}
```

```
┌────────┬────────┬────────┐
│ Item 1 │ Item 2 │ Item 3 │
├────────┼────────┼────────┤
│ Item 4 │ Item 5 │ Item 6 │
├────────┼────────┼────────┤
│ Item 7 │ Item 8 │        │
└────────┴────────┴────────┘
```

### GridItem types

```swift
// .flexible(minimum:maximum:) — co giãn trong khoảng
GridItem(.flexible())                      // co giãn tự do
GridItem(.flexible(minimum: 100, maximum: 200))

// .fixed(CGFloat) — kích thước cố định
GridItem(.fixed(120))

// .adaptive(minimum:maximum:) — TỰ ĐỘNG tính số cột
GridItem(.adaptive(minimum: 150))
// → Bao nhiêu cột vừa, mỗi cột tối thiểu 150pt
// iPhone portrait: 2 cột, iPad landscape: 5+ cột
```

```swift
// Adaptive — responsive tự động
let columns = [GridItem(.adaptive(minimum: 160))]

ScrollView {
    LazyVGrid(columns: columns, spacing: 16) {
        ForEach(products) { product in
            ProductCard(product: product)
        }
    }
}
// iPhone portrait:  ██  ██
// iPhone landscape: ██  ██  ██  ██
// iPad:             ██  ██  ██  ██  ██
```

### Kết hợp các GridItem types

```swift
let columns = [
    GridItem(.fixed(60)),        // avatar cố định
    GridItem(.flexible()),        // name co giãn
    GridItem(.fixed(80)),         // price cố định
]
// [Avatar 60pt] [Name ~~flexible~~] [Price 80pt]
```

---

## 8. `List` — Scrollable list với platform styling

```swift
List {
    Section("Favorites") {
        ForEach(favorites) { item in
            Text(item.name)
        }
        .onDelete { indexSet in
            favorites.remove(atOffsets: indexSet)
        }
        .onMove { from, to in
            favorites.move(fromOffsets: from, toOffset: to)
        }
    }
    
    Section("All Items") {
        ForEach(allItems) { item in
            NavigationLink(value: item) {
                ItemRow(item: item)
            }
        }
    }
}
.listStyle(.insetGrouped)     // iOS grouped style
.searchable(text: $searchText) // search bar tích hợp
```

### List styles

```swift
.listStyle(.automatic)        // platform default
.listStyle(.plain)            // không decoration
.listStyle(.inset)            // inset edges
.listStyle(.grouped)          // grouped sections
.listStyle(.insetGrouped)     // grouped + inset (iOS Settings style)
.listStyle(.sidebar)          // sidebar style (macOS/iPad)
```

### List row customization

```swift
List {
    ForEach(items) { item in
        Text(item.name)
            .listRowBackground(Color.yellow)      // background row
            .listRowSeparator(.hidden)             // ẩn separator
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
            .swipeActions(edge: .trailing) {        // swipe actions
                Button("Delete", role: .destructive) { delete(item) }
                Button("Flag") { flag(item) }
                    .tint(.orange)
            }
    }
}
```

---

## 9. `ScrollView`

```swift
// Dọc (default)
ScrollView {
    VStack { ... }
}

// Ngang
ScrollView(.horizontal, showsIndicators: false) {
    HStack { ... }
}

// Cả hai chiều
ScrollView([.horizontal, .vertical]) {
    // content
}
```

### ScrollView + LazyVStack — Pattern chuẩn cho long list

```swift
ScrollView {
    LazyVStack(spacing: 0) {
        ForEach(items) { item in
            ItemRow(item: item)
                .padding(.horizontal)
            Divider()
        }
    }
}
```

### iOS 17+: ScrollView enhancements

```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemCard(item: item)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.3)
                        .scaleEffect(phase.isIdentity ? 1 : 0.8)
                }
        }
    }
}
.scrollTargetBehavior(.paging)          // snap to page
.scrollPosition(id: $scrolledID)        // track scroll position
.scrollIndicators(.hidden)
.contentMargins(16, for: .scrollContent)
```

---

## 10. `overlay` và `background`

### background — Đặt view PHÍA SAU

```swift
Text("Hello")
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(.blue)
    )
// RoundedRectangle nằm DƯỚI Text, kích thước = Text + padding
```

### overlay — Đặt view PHÍA TRƯỚC

```swift
Image("photo")
    .overlay(alignment: .bottomTrailing) {
        Text("NEW")
            .font(.caption)
            .padding(4)
            .background(.red)
            .clipShape(Capsule())
    }
// Badge "NEW" nằm TRÊN Image, ở góc bottomTrailing
```

### background vs overlay vs ZStack

```swift
// background: secondary view KÍCH THƯỚC THEO primary
Text("Primary")
    .background(Color.blue)
// Color.blue kích thước = Text

// overlay: secondary view KÍCH THƯỚC THEO primary
Text("Primary")
    .overlay(Badge())
// Badge limited bởi kích thước Text

// ZStack: kích thước = child LỚN NHẤT
ZStack {
    Color.blue       // expanding → chiếm hết
    Text("Primary")  // hugging → nhỏ
}
// ZStack kích thước = Color.blue = expanding
```

---

## 11. `layoutPriority` — Ưu tiên phân chia không gian

Khi không gian **không đủ** cho tất cả children, `layoutPriority` quyết định ai được **ưu tiên**:

```swift
HStack {
    Text("Very long text that should take priority")
        .layoutPriority(1)    // ưu tiên CAO → lấy nhiều chỗ hơn
    
    Text("Secondary")
        .layoutPriority(0)    // ưu tiên THẤP (default) → co lại trước
}
```

```
Đủ chỗ:
[Very long text that should take priority | Secondary]

Thiếu chỗ (priority hoạt động):
[Very long text that should take priority | Sec...  ]
 ↑ priority 1 → giữ full text              ↑ priority 0 → truncate
```

---

## 12. Custom Alignment

### Custom alignment guide

```swift
extension VerticalAlignment {
    struct CustomCenter: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }
    static let customCenter = VerticalAlignment(CustomCenter.self)
}

HStack(alignment: .customCenter) {
    Text("Label")
        .alignmentGuide(.customCenter) { d in d[VerticalAlignment.center] }
    
    VStack {
        Text("Top")
        Text("Aligned Here")
            .alignmentGuide(.customCenter) { d in d[VerticalAlignment.center] }
        Text("Bottom")
    }
}
// "Label" căn ngang với "Aligned Here" thay vì center VStack
```

---

## 13. `Layout` Protocol (iOS 16+) — Custom Layout Container

```swift
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalSize: CGSize = .zero
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalSize.width = max(totalSize.width, x - spacing)
            totalSize.height = max(totalSize.height, y + rowHeight)
        }
        
        return (totalSize, positions)
    }
}

// Sử dụng:
FlowLayout(spacing: 8) {
    ForEach(tags) { tag in
        Text(tag.name)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(.blue.opacity(0.1)))
    }
}
```

```
┌──────────────────────────────────────┐
│ [Swift] [iOS] [SwiftUI] [Combine]   │
│ [UIKit] [MVVM] [Clean Architecture] │
│ [Testing] [CI/CD]                    │
└──────────────────────────────────────┘
  ↑ Tags tự xuống dòng khi hết chỗ (flow layout)
```

---

## 14. Safe Area

```swift
// Mặc định: content nằm TRONG safe area
Text("Hello")
// → Không bị che bởi notch, home indicator

// Bỏ qua safe area
Color.blue
    .ignoresSafeArea()             // phủ TOÀN BỘ màn hình
    .ignoresSafeArea(.keyboard)    // bỏ qua keyboard safe area
    .ignoresSafeArea(edges: .top)  // chỉ bỏ qua top (status bar area)
```

```
Có safe area:              Bỏ qua safe area:
┌────────────────┐        ┌────────────────┐
│ (notch)        │        │████(notch)█████│
├────────────────┤        │████████████████│
│                │        │████████████████│
│   Content      │        │████Content█████│
│                │        │████████████████│
├────────────────┤        │████████████████│
│ (home bar)     │        │███(home bar)███│
└────────────────┘        └────────────────┘
```

### `safeAreaInset` — Thêm content vào safe area

```swift
ScrollView {
    LazyVStack { ... }
}
.safeAreaInset(edge: .bottom) {
    // Floating bottom bar — scroll content tự co lại
    HStack {
        TextField("Message", text: $text)
        Button("Send") { }
    }
    .padding()
    .background(.ultraThinMaterial)
}
```

---

## 15. Cheat Sheet — Chọn Layout nào?

```
Xếp dọc?                  → VStack / LazyVStack
Xếp ngang?                → HStack / LazyHStack
Xếp chồng?                → ZStack
Grid đều?                  → LazyVGrid / LazyHGrid
Grid căn chỉnh chính xác? → Grid (iOS 16+)
Flow layout (tag cloud)?   → Custom Layout protocol
List platform-native?      → List
Scrollable?                → ScrollView + Lazy*
Form/Settings?             → Form

Ít children (<50)?         → VStack/HStack
Nhiều children (>50)?      → LazyVStack/LazyHStack (trong ScrollView)
Dynamic số cột?            → GridItem(.adaptive(minimum:))
```

---

## 16. Sai lầm thường gặp

### ❌ VStack trong ScrollView cho list dài

```swift
// ❌ 10000 views tạo ngay → lag, memory
ScrollView {
    VStack {
        ForEach(0..<10000) { i in Text("Row \(i)") }
    }
}

// ✅ LazyVStack → tạo khi cần
ScrollView {
    LazyVStack {
        ForEach(0..<10000) { i in Text("Row \(i)") }
    }
}
```

### ❌ Quên frame(maxWidth: .infinity) cho button full-width

```swift
// ❌ Button chỉ rộng bằng label
Button("Submit") { }
    .padding()
    .background(.blue)
// → [  Submit  ] (nhỏ)

// ✅ frame trước background
Button("Submit") { }
    .frame(maxWidth: .infinity)
    .padding()
    .background(.blue)
    .clipShape(RoundedRectangle(cornerRadius: 12))
// → [          Submit          ] (full width)
```

### ❌ Nhầm padding + background order

```swift
// ❌ Background chỉ phủ text, padding trong suốt
Text("Hello").background(.blue).padding()

// ✅ Padding trước → background phủ cả padding
Text("Hello").padding().background(.blue)
```

### ❌ ScrollView không co lại children expanding

```swift
// ❌ Color trong ScrollView → chiều cao 0 (không có intrinsic size)
ScrollView {
    Color.blue    // height = 0, không thấy gì
}

// ✅ Đặt frame cho expanding views trong ScrollView
ScrollView {
    Color.blue.frame(height: 200)
}
```

---

## 17. Tóm tắt

| Layout | Xếp | Lazy | Dùng khi |
|---|---|---|---|
| VStack | Dọc | ❌ | Ít children, cần layout chính xác |
| HStack | Ngang | ❌ | Toolbar, row, inline elements |
| ZStack | Chồng | ❌ | Overlay, background, badge |
| LazyVStack | Dọc | ✅ | List dài trong ScrollView |
| LazyHStack | Ngang | ✅ | Horizontal scroll dài |
| LazyVGrid | Grid dọc | ✅ | Photo grid, product grid |
| LazyHGrid | Grid ngang | ✅ | Calendar, timeline |
| Grid | Grid tĩnh | ❌ | Form layout, table căn chỉnh |
| List | Dọc + native | ✅ | Settings, data list, swipe actions |
| ScrollView | Wrapper | — | Bọc ngoài Lazy* hoặc content overflow |
| Form | Dọc + form | — | Settings, input forms |

| Concept | Ý nghĩa |
|---|---|
| **3 bước layout** | Parent propose → child choose → parent place |
| **Hugging vs Expanding** | Text/Image lấy vừa đủ, Color/Spacer lấy hết |
| **Spacer** | Expanding invisible → đẩy views ra xa |
| **frame** | Fixed hoặc flexible constraints |
| **padding** | Khoảng đệm giữa content và edge |
| **layoutPriority** | Ai được ưu tiên khi thiếu chỗ |
| **Safe area** | Vùng không bị che bởi notch/home bar |
| **Layout protocol** | Custom layout container (iOS 16+) |

----

Layout là hệ thống nền tảng của SwiftUI, Huy. Ba điểm cốt lõi:

**Nguyên tắc 3 bước đàm phán:** Parent **đề xuất** kích thước → Child **tự quyết định** kích thước (Text lấy vừa đủ, Color/Spacer lấy hết) → Parent **đặt** child vào vị trí (thường center). Hiểu 3 bước này giải thích được mọi behavior bất ngờ trong layout.

**Stack là nền tảng — VStack/HStack/ZStack + Lazy variants.** VStack/HStack tạo TẤT CẢ children ngay → chỉ dùng cho ít children (<50). LazyVStack/LazyHStack tạo children **khi cần** (visible on screen) → bắt buộc cho list dài trong ScrollView. Sai lầm phổ biến nhất: `ScrollView { VStack { ForEach(10000 items) } }` → lag nghiêm trọng → đổi thành `LazyVStack`.

**Grid: 3 cấp độ.** `LazyVGrid` + `GridItem(.adaptive(minimum: 160))` cho responsive grid tự tính số cột (phổ biến nhất). `Grid` (iOS 16+) cho static grid cần căn chỉnh chính xác kiểu form/table. `Layout` protocol (iOS 16+) cho custom layout hoàn toàn (flow layout, masonry, circular...).

**Modifier order ảnh hưởng layout:** `.padding().background(.blue)` (padding có nền) khác `.background(.blue).padding()` (padding trong suốt). Nguyên tắc: modifier nào ở trên áp dụng trước (gần view gốc), modifier dưới wrap bên ngoài.
