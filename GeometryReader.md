# SwiftUI: `GeometryReader` — Giải thích chi tiết

## 1. Bản chất — Đọc kích thước và vị trí của View

SwiftUI là declarative — ta mô tả **muốn gì**, không phải **ở đâu, bao lớn**. Nhưng đôi khi cần biết chính xác kích thước, vị trí của view để tạo layout tuỳ chỉnh. `GeometryReader` cung cấp thông tin đó.

```swift
GeometryReader { geometry in
//               ↑ GeometryProxy — chứa size, position, safe area
    Text("Hello")
        .frame(width: geometry.size.width * 0.5)
        //                    ↑ 50% chiều rộng container
}
```

`GeometryReader` là một **container view** — nó nhận closure chứa `GeometryProxy`, từ đó đọc được kích thước và vị trí của không gian mà nó chiếm.

---

## 2. `GeometryProxy` — Thông tin gì có sẵn?

```swift
GeometryReader { proxy in
    // 1. SIZE — kích thước không gian có sẵn
    let width = proxy.size.width      // CGFloat
    let height = proxy.size.height    // CGFloat
    
    // 2. SAFE AREA INSETS
    let topInset = proxy.safeAreaInsets.top
    let bottomInset = proxy.safeAreaInsets.bottom
    
    // 3. FRAME — vị trí trong coordinate space
    let globalFrame = proxy.frame(in: .global)
    //   ↑ CGRect — vị trí so với MÀN HÌNH
    
    let localFrame = proxy.frame(in: .local)
    //   ↑ CGRect — origin luôn (0, 0), size = proxy.size
    
    let namedFrame = proxy.frame(in: .named("scroll"))
    //   ↑ CGRect — vị trí so với coordinate space tên "scroll"
}
```

### 2.1 `proxy.size` — Kích thước

```swift
GeometryReader { proxy in
    // proxy.size = kích thước KHÔNG GIAN mà GeometryReader chiếm
    // KHÔNG phải kích thước content bên trong
    
    Text("Width: \(proxy.size.width), Height: \(proxy.size.height)")
}
.frame(width: 300, height: 200)
// proxy.size = (300, 200)
```

### 2.2 `proxy.frame(in:)` — Vị trí trong coordinate space

```swift
// .global — so với toàn màn hình (gốc: top-left màn hình)
proxy.frame(in: .global)
// → CGRect(x: 20, y: 100, width: 300, height: 200)
//          ↑ cách left 20pt, cách top 100pt

// .local — so với chính GeometryReader (gốc luôn 0,0)
proxy.frame(in: .local)
// → CGRect(x: 0, y: 0, width: 300, height: 200)

// .named("id") — so với ancestor có coordinateSpace đặt tên
ScrollView {
    // ...
    GeometryReader { proxy in
        let scrollFrame = proxy.frame(in: .named("scroll"))
        // → vị trí so với ScrollView
    }
}
.coordinateSpace(name: "scroll")
//                ↑ đặt tên coordinate space
```

### 2.3 `proxy.safeAreaInsets`

```swift
GeometryReader { proxy in
    VStack {
        Text("Top inset: \(proxy.safeAreaInsets.top)")
        // iPhone 15 Pro: ~59pt (Dynamic Island)
        // iPhone SE: ~20pt (status bar)
        
        Text("Bottom inset: \(proxy.safeAreaInsets.bottom)")
        // iPhone 15 Pro: ~34pt (home indicator)
        // iPhone SE: 0pt
    }
}
```

---

## 3. Đặc điểm quan trọng — GeometryReader chiếm toàn bộ không gian

### GeometryReader là GREEDY

```swift
VStack {
    Text("Header")
        .background(.blue)
    
    GeometryReader { proxy in
        Text("Inside GeometryReader")
            .background(.red)
    }
    .background(.green)
    
    Text("Footer")
        .background(.blue)
}
```

```
┌───────────────────────────┐
│ Header (blue, nhỏ gọn)   │
├───────────────────────────┤
│                           │
│  Inside GeometryReader    │
│  (red, nhỏ gọn)          │
│                           │  ← GeometryReader chiếm
│  (green, TOÀN BỘ         │     TOÀN BỘ không gian còn lại
│   còn lại)                │
│                           │
├───────────────────────────┤
│ Footer (blue, nhỏ gọn)   │
└───────────────────────────┘
```

GeometryReader **mở rộng hết mức có thể** (giống `Color.clear` hay `Spacer`). Content bên trong được **đặt ở góc top-left** (không phải center như `VStack`/`ZStack`).

### Content bị đẩy về top-left

```swift
GeometryReader { proxy in
    Text("Hello")
    // ← Nằm ở góc TOP-LEFT, không phải center
}

// Muốn center → tự căn chỉnh:
GeometryReader { proxy in
    Text("Hello")
        .frame(width: proxy.size.width, height: proxy.size.height)
        // ← frame full size → Text center tự nhiên
}

// Hoặc dùng position:
GeometryReader { proxy in
    Text("Hello")
        .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
}
```

---

## 4. Ứng dụng thực tế

### 4.1 Responsive Layout — Proportional sizing

```swift
struct ResponsiveCard: View {
    var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height
            
            if isLandscape {
                // Ngang: image bên trái, text bên phải
                HStack(spacing: 0) {
                    Image("cover")
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width * 0.4)
                        .clipped()
                    
                    VStack(alignment: .leading) {
                        Text("Title").font(.title)
                        Text("Description").font(.body)
                    }
                    .frame(width: proxy.size.width * 0.6)
                    .padding()
                }
            } else {
                // Dọc: image trên, text dưới
                VStack(spacing: 0) {
                    Image("cover")
                        .resizable()
                        .scaledToFill()
                        .frame(height: proxy.size.height * 0.5)
                        .clipped()
                    
                    VStack(alignment: .leading) {
                        Text("Title").font(.title)
                        Text("Description").font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
```

### 4.2 Scroll-based Animation — Parallax Header

```swift
struct ParallaxHeader: View {
    let imageURL: URL
    let height: CGFloat = 300
    
    var body: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named("scroll")).minY
            // ↑ Vị trí Y so với ScrollView
            // Khi scroll xuống: minY giảm (âm)
            // Khi scroll lên (overscroll): minY tăng (dương)
            
            let isOverscrolling = minY > 0
            
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray
            }
            .frame(
                width: proxy.size.width,
                height: height + (isOverscrolling ? minY : 0)
                //      ↑ kéo xuống → ảnh to ra (stretch effect)
            )
            .offset(y: isOverscrolling ? -minY : 0)
            //         ↑ bù offset để ảnh dính top
            .clipped()
        }
        .frame(height: height)
    }
}

// Sử dụng
ScrollView {
    VStack(spacing: 0) {
        ParallaxHeader(imageURL: url)
        
        // Content
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
.coordinateSpace(name: "scroll")
```

```
Overscroll (kéo xuống):
┌─────────────────────┐
│    ▓▓▓▓▓▓▓▓▓▓▓      │ ← ảnh PHÓNG TO, dính top
│    ▓▓ IMAGE ▓▓▓      │
│    ▓▓▓▓▓▓▓▓▓▓▓      │
├─────────────────────┤
│    Content           │

Scroll bình thường:
┌─────────────────────┐
│    ▓▓ IMAGE ▓▓▓      │ ← ảnh kích thước bình thường
│    ▓▓▓▓▓▓▓▓▓▓▓      │
├─────────────────────┤
│    Content           │
│    Content           │

Scroll lên:
├─────────────────────┤
│    Content           │ ← ảnh đã trượt ra ngoài
│    Content           │
│    Content           │
```

### 4.3 Sticky Header / Scroll Detection

```swift
struct StickyHeaderList: View {
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    // Invisible tracker
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: ScrollOffsetKey.self,
                                value: proxy.frame(in: .named("scroll")).minY
                            )
                    }
                    .frame(height: 0)
                    
                    // Content
                    LazyVStack {
                        ForEach(0..<50) { i in
                            Text("Row \(i)")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                scrollOffset = value
            }
            
            // Sticky header — hiện khi scroll xuống
            if scrollOffset < -50 {
                HeaderBar()
                    .transition(.move(edge: .top))
                    .animation(.easeInOut, value: scrollOffset < -50)
            }
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
```

### 4.4 Custom Progress Bar

```swift
struct CustomProgressBar: View {
    let progress: Double  // 0.0 ... 1.0
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: proxy.size.height / 2)
                    .fill(Color.gray.opacity(0.2))
                
                // Fill
                RoundedRectangle(cornerRadius: proxy.size.height / 2)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: proxy.size.width * CGFloat(progress))
                    .animation(.spring, value: progress)
            }
        }
        .frame(height: 8)
    }
}
```

### 4.5 Adaptive Grid — Tự tính số cột

```swift
struct AdaptiveGrid<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let minItemWidth: CGFloat
    let spacing: CGFloat
    @ViewBuilder let content: (Item) -> Content
    
    var body: some View {
        GeometryReader { proxy in
            let columns = max(1, Int(proxy.size.width / minItemWidth))
            let itemWidth = (proxy.size.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
            
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(itemWidth), spacing: spacing), count: columns),
                    spacing: spacing
                ) {
                    ForEach(items) { item in
                        content(item)
                    }
                }
            }
        }
    }
}

// Sử dụng
AdaptiveGrid(items: products, minItemWidth: 160, spacing: 12) { product in
    ProductCard(product: product)
}
```

### 4.6 Aspect Ratio Container

```swift
struct AspectRatioContainer<Content: View>: View {
    let aspectRatio: CGFloat  // width / height
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = width / aspectRatio
            
            content()
                .frame(width: width, height: height)
                .position(x: width / 2, y: proxy.size.height / 2)
        }
    }
}

// 16:9 video container
AspectRatioContainer(aspectRatio: 16/9) {
    VideoPlayer(url: videoURL)
}
```

---

## 5. GeometryReader + PreferenceKey — Đọc size con mà không chiếm layout

### Vấn đề: GeometryReader chiếm toàn bộ space

```swift
// ❌ GeometryReader phá layout vì chiếm toàn bộ không gian
HStack {
    Text("Label")
    GeometryReader { proxy in    // ← chiếm hết HStack
        Text("Value: \(proxy.size.width)")
    }
}
```

### Giải pháp: `.background` + PreferenceKey

Dùng GeometryReader trong `.background` — nó đọc kích thước **mà không ảnh hưởng layout**:

```swift
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func readSize(_ onChange: @escaping (CGSize) -> Void) -> some View {
        self.background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

// Sử dụng — KHÔNG phá layout
struct TagCloud: View {
    @State private var containerWidth: CGFloat = 0
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            // Đọc width mà không phá layout
            Color.clear
                .frame(height: 0)
                .readSize { size in
                    containerWidth = size.width
                }
            
            // Flow layout dựa trên width đã đọc
            FlowLayout(width: containerWidth, tags: tags)
        }
    }
}
```

---

## 6. iOS 17+: Thay thế GeometryReader trong nhiều trường hợp

### 6.1 `.containerRelativeFrame()` — Proportional sizing không cần GeometryReader

```swift
// CŨ: GeometryReader
GeometryReader { proxy in
    Image("hero")
        .resizable()
        .frame(width: proxy.size.width * 0.8)
}

// MỚI: containerRelativeFrame (iOS 17+)
Image("hero")
    .resizable()
    .containerRelativeFrame(.horizontal) { width, _ in
        width * 0.8
    }
// ← Không cần GeometryReader, không phá layout
```

### 6.2 `.visualEffect` — Scroll-based animation

```swift
// CŨ: GeometryReader trong mỗi row
// MỚI: visualEffect (iOS 17+)
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemCard(item: item)
                .visualEffect { content, proxy in
                    content
                        .scaleEffect(scaleForProxy(proxy))
                        .opacity(opacityForProxy(proxy))
                }
        }
    }
}

func scaleForProxy(_ proxy: GeometryProxy) -> CGFloat {
    let frame = proxy.frame(in: .scrollView)
    let distance = abs(frame.midY - UIScreen.main.bounds.midY)
    return max(0.8, 1 - distance / 1000)
}
```

### 6.3 `.onGeometryChange` (iOS 18+)

```swift
// Đọc size thay đổi mà không cần GeometryReader hay PreferenceKey
Text("Dynamic Content")
    .onGeometryChange(for: CGSize.self) { proxy in
        proxy.size
    } action: { newSize in
        self.contentSize = newSize
    }
```

### Khi nào VẪN cần GeometryReader?

```
containerRelativeFrame → proportional sizing đơn giản
visualEffect           → scroll animation
onGeometryChange       → đọc size/position reactively

GeometryReader VẪN cần khi:
  - Hỗ trợ iOS 16 trở xuống
  - Layout phức tạp phụ thuộc nhiều giá trị geometry cùng lúc
  - Custom coordinate space calculations
  - Layout children dựa trên parent size (adaptive grid)
```

---

## 7. Sai lầm thường gặp

### ❌ Sai lầm 1: Dùng GeometryReader khi không cần

```swift
// ❌ Thừa: SwiftUI có sẵn modifier cho việc này
GeometryReader { proxy in
    Image("photo")
        .resizable()
        .frame(width: proxy.size.width, height: proxy.size.width * 0.75)
}

// ✅ Dùng aspectRatio
Image("photo")
    .resizable()
    .aspectRatio(4/3, contentMode: .fit)
```

### ❌ Sai lầm 2: GeometryReader phá layout không mong muốn

```swift
// ❌ GeometryReader trong HStack/VStack chiếm hết space
VStack {
    Text("Title")
    GeometryReader { proxy in    // ← chiếm toàn bộ space còn lại
        Text("Width: \(proxy.size.width)")
    }
    Text("Footer")               // ← bị đẩy xuống cuối
}

// ✅ Giới hạn frame hoặc dùng .background/.overlay
VStack {
    Text("Title")
    Text("Content")
        .background(
            GeometryReader { proxy in
                Color.clear.onAppear { print(proxy.size) }
            }
        )
    Text("Footer")
}
```

### ❌ Sai lầm 3: Infinite layout loop

```swift
// ❌ NGUY HIỂM: đọc size → thay đổi state → layout lại → size khác → ...
GeometryReader { proxy in
    Text("Hello")
        .frame(width: proxy.size.width)
        .onAppear {
            self.width = proxy.size.width   // thay đổi state
            // → re-render → GeometryReader tính lại
            // → có thể loop vô hạn
        }
}

// ✅ Dùng preference hoặc onChange cẩn thận
// Đảm bảo state change KHÔNG trigger layout change
```

### ❌ Sai lầm 4: Lồng GeometryReader không cần thiết

```swift
// ❌ Nested GeometryReader — phức tạp, khó debug
GeometryReader { outerProxy in
    VStack {
        GeometryReader { innerProxy in
            // outerProxy vs innerProxy ???
        }
    }
}

// ✅ Thường chỉ cần 1 GeometryReader ở level phù hợp
// Hoặc dùng .background cho inner size
```

---

## 8. Best Practices

### Nguyên tắc 1: Dùng GeometryReader ở ngoài cùng, truyền size vào trong

```swift
// ✅ GeometryReader wrap ngoài, con nhận size qua parameter
struct CardView: View {
    let availableWidth: CGFloat    // nhận size từ bên ngoài
    
    var body: some View {
        // Layout dựa trên availableWidth
        // Không cần GeometryReader ở đây
    }
}

struct ParentView: View {
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(items) { item in
                        CardView(availableWidth: proxy.size.width)
                        // ← truyền size, không lồng GeometryReader
                    }
                }
            }
        }
    }
}
```

### Nguyên tắc 2: Ưu tiên `.background` / `.overlay` để đọc size mà không phá layout

```swift
// ✅ Đọc size của Text mà không ảnh hưởng layout
Text("Dynamic text that might be long")
    .background(
        GeometryReader { proxy in
            Color.clear
                .onAppear { textSize = proxy.size }
        }
    )
```

### Nguyên tắc 3: Dùng API mới khi có thể (iOS 17+)

```swift
// Trước khi dùng GeometryReader, kiểm tra:
// 1. containerRelativeFrame → proportional sizing?
// 2. visualEffect → scroll-based transforms?
// 3. onGeometryChange → reactive size reading?
// 4. Nếu không → GeometryReader
```

---

## 9. Tóm tắt

| Khía cạnh | Chi tiết |
|---|---|
| **Là gì?** | Container view cung cấp `GeometryProxy` — size, position, safe area |
| **proxy.size** | Kích thước không gian GeometryReader chiếm |
| **proxy.frame(in:)** | Vị trí trong coordinate space (.global, .local, .named) |
| **proxy.safeAreaInsets** | Safe area insets |
| **Behavior** | Chiếm TOÀN BỘ không gian có sẵn (greedy), content đặt top-left |
| **Dùng khi** | Responsive layout, scroll animation, proportional sizing, custom positioning |
| **KHÔNG dùng khi** | Có modifier sẵn (aspectRatio, frame), iOS 17+ có API thay thế |
| **Best practice** | Wrap ngoài truyền size vào, dùng `.background` để không phá layout |
| **iOS 17+** | `containerRelativeFrame`, `visualEffect`, `onGeometryChange` thay thế nhiều use case |

-----

`GeometryReader` cho phép đọc kích thước và vị trí của view tại runtime — thứ mà SwiftUI declarative thường giấu đi, Huy. Ba điểm cốt lõi:

**`GeometryProxy`** cung cấp ba thông tin: `size` (kích thước không gian chiếm), `frame(in:)` (vị trí trong coordinate space — `.global` so với màn hình, `.named("scroll")` so với ancestor), và `safeAreaInsets`. Đây là nền tảng cho mọi layout tuỳ chỉnh.

**Đặc điểm "greedy"** — GeometryReader chiếm **toàn bộ không gian** có sẵn và đặt content ở **góc top-left** (không phải center). Đây là nguồn gốc nhiều bug layout. Giải pháp: dùng GeometryReader trong `.background` / `.overlay` để đọc size **mà không phá layout**, hoặc giới hạn frame tường minh.

**iOS 17+ có nhiều API thay thế** tốt hơn: `containerRelativeFrame` cho proportional sizing, `visualEffect` cho scroll animation, `onGeometryChange` (iOS 18) cho reactive size reading. GeometryReader vẫn cần khi hỗ trợ iOS cũ hoặc layout phức tạp phụ thuộc nhiều giá trị geometry cùng lúc.

Best practice quan trọng nhất: **dùng GeometryReader ở level ngoài cùng**, truyền size vào subview qua parameter — tránh lồng GeometryReader trong từng cell/row, vừa tốn performance vừa khó debug.
