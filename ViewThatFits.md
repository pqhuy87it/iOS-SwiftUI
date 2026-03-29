# SwiftUI: `ViewThatFits` — Giải thích chi tiết

## 1. Bản chất — Tự chọn view VỪA không gian

`ViewThatFits` (iOS 16+) nhận **nhiều view thay thế**, kiểm tra từng view theo thứ tự, và hiển thị **view đầu tiên vừa vặn** trong không gian có sẵn. View nào không vừa → bỏ qua, thử view tiếp theo.

```swift
ViewThatFits {
    // Ưu tiên 1: layout rộng nhất
    HStack { Image(systemName: "star"); Text("Favorites"); Spacer(); Text("42 items") }
    
    // Ưu tiên 2: layout trung bình
    HStack { Image(systemName: "star"); Text("Favorites") }
    
    // Ưu tiên 3: layout nhỏ nhất (fallback)
    Image(systemName: "star")
}
```

```
Không gian rộng (iPad):
┌────────────────────────────────────────────┐
│ ★ Favorites                      42 items  │  ← view 1 VỪA → hiển thị
└────────────────────────────────────────────┘

Không gian trung bình (iPhone portrait):
┌────────────────────────┐
│ ★ Favorites            │  ← view 1 KHÔNG VỪA, view 2 VỪA → hiển thị
└────────────────────────┘

Không gian hẹp (widget / sidebar nhỏ):
┌────────┐
│   ★    │  ← view 1, 2 KHÔNG VỪA, view 3 VỪA → hiển thị
└────────┘
```

Hình dung: **thử giày từ size lớn nhất** — không vừa thì thử size nhỏ hơn, cho đến khi vừa.

---

## 2. Cú pháp

```swift
ViewThatFits(in: .horizontal) {
    // View 1 — thử đầu tiên (ưu tiên cao nhất)
    // View 2 — thử nếu view 1 không vừa
    // View 3 — thử nếu view 2 không vừa
    // ...
    // View cuối — fallback
}
```

### Parameter `in:` — Trục nào kiểm tra?

```swift
ViewThatFits(in: .horizontal) { ... }
// Chỉ kiểm tra chiều NGANG — "view có vừa width không?"

ViewThatFits(in: .vertical) { ... }
// Chỉ kiểm tra chiều DỌC — "view có vừa height không?"

ViewThatFits { ... }
// Mặc định: kiểm tra CẢ HAI chiều — vừa width VÀ height
```

---

## 3. Cách hoạt động bên trong

### Thuật toán

```
1. Đo ideal size của View 1 (sizeThatFits)
2. So sánh với proposed size (không gian có sẵn)
3. Nếu ideal size ≤ proposed size → ✅ HIỂN THỊ view 1, DỪNG
4. Nếu ideal size > proposed size → ❌ BỎ QUA, sang View 2
5. Lặp lại bước 1-4 cho View 2, 3, ...
6. Nếu KHÔNG view nào vừa → hiển thị VIEW CUỐI CÙNG (dù không vừa)
```

### Minh hoạ chi tiết

```swift
ViewThatFits(in: .horizontal) {
    Text("Show All Favorites")    // ideal width: 180pt
    Text("Favorites")              // ideal width: 80pt
    Text("Fav")                    // ideal width: 30pt
}
```

```
Proposed width = 200pt:
  "Show All Favorites" (180pt) ≤ 200pt → ✅ hiển thị

Proposed width = 100pt:
  "Show All Favorites" (180pt) > 100pt → ❌ skip
  "Favorites" (80pt) ≤ 100pt → ✅ hiển thị

Proposed width = 20pt:
  "Show All Favorites" (180pt) > 20pt → ❌ skip
  "Favorites" (80pt) > 20pt → ❌ skip
  "Fav" (30pt) > 20pt → ❌ KHÔNG VỪA nhưng là view CUỐI → hiển thị (truncate)
```

### View cuối là fallback — luôn hiển thị nếu không gì vừa

```swift
ViewThatFits {
    LargeLayout()      // 400pt
    MediumLayout()     // 250pt
    SmallLayout()      // 100pt ← LUÔN hiển thị nếu 2 cái trên không vừa
}
// SmallLayout là "safety net" — dù không gian chỉ 50pt, SwiftUI vẫn render nó
```

---

## 4. Ứng dụng thực tế

### 4.1 Responsive button — Adapt theo width

```swift
struct AdaptiveButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ViewThatFits(in: .horizontal) {
                // Rộng: icon + text
                Label("Add to Favorites", systemImage: "heart.fill")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                
                // Vừa: text ngắn
                Label("Favorite", systemImage: "heart.fill")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                
                // Hẹp: chỉ icon
                Image(systemName: "heart.fill")
                    .padding(12)
            }
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
        }
    }
}
```

```
Rộng:    [ ♥ Add to Favorites ]
Vừa:     [ ♥ Favorite ]
Hẹp:     [ ♥ ]
```

### 4.2 HStack ↔ VStack — Đổi layout theo space

```swift
struct AdaptiveStack: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            // Rộng: ngang
            HStack(spacing: 12) {
                Text(title).font(.headline)
                Text(subtitle).foregroundStyle(.secondary)
            }
            
            // Hẹp: dọc
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle).foregroundStyle(.secondary)
            }
        }
    }
}
```

```
Rộng:   [Title  Subtitle text here]

Hẹp:    [Title           ]
         [Subtitle text   ]
```

### 4.3 Profile header — Responsive layout

```swift
struct ProfileHeader: View {
    let user: User
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            // Layout rộng: avatar + info + stats ngang
            HStack(spacing: 16) {
                avatar
                VStack(alignment: .leading) {
                    Text(user.name).font(.title2.bold())
                    Text("@\(user.username)").foregroundStyle(.secondary)
                }
                Spacer()
                statsRow
            }
            
            // Layout hẹp: avatar + info dọc, stats bên dưới
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    avatar
                    VStack(alignment: .leading) {
                        Text(user.name).font(.title2.bold())
                        Text("@\(user.username)").foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                statsRow
            }
            
            // Layout rất hẹp: stack hoàn toàn dọc
            VStack(spacing: 8) {
                avatar
                Text(user.name).font(.title3.bold())
                statsRow
            }
        }
    }
    
    private var avatar: some View {
        Circle().fill(.gray.opacity(0.3))
            .frame(width: 60, height: 60)
    }
    
    private var statsRow: some View {
        HStack(spacing: 16) {
            stat(value: user.posts, label: "Posts")
            stat(value: user.followers, label: "Followers")
            stat(value: user.following, label: "Following")
        }
    }
    
    private func stat(value: Int, label: String) -> some View {
        VStack {
            Text("\(value)").font(.headline)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}
```

### 4.4 Navigation bar items — Collapse khi hẹp

```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        ViewThatFits(in: .horizontal) {
            // Rộng: tất cả buttons hiện
            HStack(spacing: 12) {
                Button { } label: { Label("Search", systemImage: "magnifyingglass") }
                Button { } label: { Label("Filter", systemImage: "line.3.horizontal.decrease") }
                Button { } label: { Label("Sort", systemImage: "arrow.up.arrow.down") }
            }
            
            // Hẹp: gom vào menu
            Menu {
                Button { } label: { Label("Search", systemImage: "magnifyingglass") }
                Button { } label: { Label("Filter", systemImage: "line.3.horizontal.decrease") }
                Button { } label: { Label("Sort", systemImage: "arrow.up.arrow.down") }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}
```

```
Rộng:   [...  🔍  ≡  ↕]
Hẹp:    [...  ⋯]  (menu chứa tất cả)
```

### 4.5 Card content — Text truncation graceful

```swift
struct NewsCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
            
            ViewThatFits(in: .vertical) {
                // Đủ cao: hiện đoạn mô tả
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Text(article.author)
                        Spacer()
                        Text(article.date, style: .date)
                    }
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                }
                
                // Không đủ cao: chỉ author + date
                HStack {
                    Text(article.author)
                    Spacer()
                    Text(article.date, style: .date)
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
                
                // Rất hẹp: chỉ date
                Text(article.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
    }
}
```

### 4.6 Price display — Responsive formatting

```swift
struct PriceTag: View {
    let price: Double
    let originalPrice: Double?
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            // Rộng: giá gốc + giá giảm + badge
            HStack(spacing: 8) {
                if let original = originalPrice {
                    Text(original, format: .currency(code: "USD"))
                        .strikethrough()
                        .foregroundStyle(.secondary)
                }
                Text(price, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundStyle(.red)
                if originalPrice != nil {
                    Text("SALE")
                        .font(.caption.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.red)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            
            // Vừa: chỉ giá gốc + giá giảm
            HStack(spacing: 4) {
                if let original = originalPrice {
                    Text(original, format: .currency(code: "USD"))
                        .strikethrough()
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(price, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundStyle(.red)
            }
            
            // Hẹp: chỉ giá giảm
            Text(price, format: .currency(code: "USD"))
                .font(.subheadline.bold())
                .foregroundStyle(.red)
        }
    }
}
```

### 4.7 Multi-platform adaptive — iPhone/iPad/Watch

```swift
struct ActionBar: View {
    var body: some View {
        ViewThatFits {
            // iPad / large iPhone landscape
            HStack(spacing: 16) {
                Button { } label: { Label("Share", systemImage: "square.and.arrow.up") }
                Button { } label: { Label("Save", systemImage: "bookmark") }
                Button { } label: { Label("Print", systemImage: "printer") }
                Button { } label: { Label("Delete", systemImage: "trash") }
            }
            .buttonStyle(.bordered)
            
            // iPhone portrait
            HStack(spacing: 12) {
                Button { } label: { Image(systemName: "square.and.arrow.up") }
                Button { } label: { Image(systemName: "bookmark") }
                Button { } label: { Image(systemName: "printer") }
                Button { } label: { Image(systemName: "trash") }
            }
            
            // Apple Watch / very small
            HStack(spacing: 8) {
                Button { } label: { Image(systemName: "square.and.arrow.up") }
                Button { } label: { Image(systemName: "bookmark") }
                Menu {
                    Button { } label: { Label("Print", systemImage: "printer") }
                    Button { } label: { Label("Delete", systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}
```

---

## 5. `in:` Parameter — Kiểm tra trục nào

### `.horizontal` — Chỉ kiểm tra width

```swift
ViewThatFits(in: .horizontal) {
    Text("A very long label for wide screens")    // ideal width: 280pt
    Text("Short label")                            // ideal width: 90pt
}
// proposed width = 100pt
// View 1: 280 > 100 → skip
// View 2: 90 ≤ 100 → ✅

// Chiều CAO không ảnh hưởng — dù view cao hơn proposed height vẫn được chọn
```

### `.vertical` — Chỉ kiểm tra height

```swift
ViewThatFits(in: .vertical) {
    // Layout cao
    VStack {
        Image(systemName: "star.fill").font(.largeTitle)
        Text("Title").font(.title)
        Text("Description that takes multiple lines...")
    }
    
    // Layout thấp
    HStack {
        Image(systemName: "star.fill")
        Text("Title")
    }
}
// Dùng khi height giới hạn (widget, compact notification)
```

### Không chỉ định (cả hai chiều)

```swift
ViewThatFits {
    // Phải vừa CẢ width VÀ height
    LargeView()     // 400 × 300
    MediumView()    // 200 × 150
    SmallView()     // 100 × 80
}
// Proposed: 250 × 200
// LargeView: 400 > 250 (width) → ❌
// MediumView: 200 ≤ 250 AND 150 ≤ 200 → ✅
```

---

## 6. ViewThatFits vs alternatives

### vs `GeometryReader` + if/else

```swift
// ❌ Verbose: GeometryReader + manual breakpoints
GeometryReader { proxy in
    if proxy.size.width > 400 {
        WideLayout()
    } else if proxy.size.width > 200 {
        MediumLayout()
    } else {
        NarrowLayout()
    }
}
// Phải đoán breakpoint (400, 200)
// GeometryReader chiếm hết space, phá layout
// Magic numbers khó maintain

// ✅ ViewThatFits: tự đo, không cần breakpoint
ViewThatFits(in: .horizontal) {
    WideLayout()
    MediumLayout()
    NarrowLayout()
}
// SwiftUI tự đo ideal size mỗi view
// Không cần magic number
// Không phá layout
```

### vs `AnyLayout` (iOS 16+)

```swift
// AnyLayout: thay đổi LAYOUT CONTAINER (VStack ↔ HStack)
// nhưng giữ CÙNG children

let layout = isWide ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())
layout {
    Image(systemName: "star")
    Text("Favorites")
}

// ViewThatFits: thay đổi TOÀN BỘ view tree
// Mỗi variant có thể hoàn toàn khác nhau
ViewThatFits {
    HStack { Image(...); Text("Favorites"); Spacer(); Badge() }
    VStack { Image(...); Text("Fav") }
    Image(...)
}
```

```
                    ViewThatFits              AnyLayout
                    ─────────────             ─────────
Thay đổi gì?        Toàn bộ view tree        Chỉ layout container
Children?            Mỗi variant khác nhau    CÙNG children
Quyết định bằng?    Automatic (size fitting)  Manual (condition)
Animation?           Không (switch view)       ✅ Animate layout change
Dùng khi?            Content khác nhau hoàn    Cùng content, khác arrangement
                     toàn giữa các breakpoint
```

### vs `containerRelativeFrame` (iOS 17+)

```swift
// containerRelativeFrame: scale SIZE theo container
Image("photo")
    .containerRelativeFrame(.horizontal) { width, _ in width * 0.8 }

// ViewThatFits: chọn VARIANT khác nhau theo container
// Mạnh hơn khi cần thay đổi cấu trúc, không chỉ scale
```

---

## 7. Kết hợp ViewThatFits với Modifiers

### Modifier chung cho tất cả variants

```swift
ViewThatFits(in: .horizontal) {
    Text("Long version of the text")
    Text("Short")
}
.font(.headline)           // apply cho CẢ HAI variants
.foregroundStyle(.blue)    // apply cho CẢ HAI variants
```

### Modifier riêng mỗi variant

```swift
ViewThatFits(in: .horizontal) {
    Text("Detailed Label")
        .font(.body)              // font riêng variant 1
        .foregroundStyle(.primary)
    
    Text("Label")
        .font(.caption)           // font riêng variant 2
        .foregroundStyle(.secondary)
}
```

---

## 8. Dynamic Type support

`ViewThatFits` đặc biệt hữu ích cho **Dynamic Type** — khi user tăng font size, layout tự adapt:

```swift
struct SettingsRow: View {
    let title: String
    let value: String
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            // Font bình thường: ngang
            HStack {
                Text(title)
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
            }
            
            // Font lớn (accessibility): dọc
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                Text(value)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

```
Font size bình thường:
┌─────────────────────────────┐
│ Language              English│
│ Region               Vietnam│
└─────────────────────────────┘

Font size accessibility XXL:
┌─────────────────────────────┐
│ Language                    │
│ English                     │
│ Region                      │
│ Vietnam                     │
└─────────────────────────────┘
```

---

## 9. Sai lầm thường gặp

### ❌ Variants không theo thứ tự lớn → nhỏ

```swift
// ❌ View nhỏ nhất ở đầu → luôn vừa → variants sau không bao giờ dùng
ViewThatFits {
    Text("Hi")                        // 20pt — luôn vừa!
    Text("Hello World!")              // 100pt — không bao giờ được chọn
    Text("Hello World! Welcome!")     // 200pt — không bao giờ được chọn
}

// ✅ Sắp xếp LỚN → NHỎ
ViewThatFits {
    Text("Hello World! Welcome!")     // thử lớn nhất trước
    Text("Hello World!")              // rồi nhỏ hơn
    Text("Hi")                        // fallback nhỏ nhất
}
```

### ❌ Tất cả variants cùng kích thước

```swift
// ❌ Tất cả views cùng size → luôn chọn view đầu tiên
ViewThatFits {
    Text("Version A").frame(width: 200)
    Text("Version B").frame(width: 200)    // cùng width → không bao giờ chọn
}

// ViewThatFits đo IDEAL size, không phải rendered size
// Nếu dùng .frame() cố định → tất cả cùng size → luôn chọn view 1
```

### ❌ Dùng ViewThatFits cho content dynamic (state-dependent)

```swift
// ⚠️ ViewThatFits đo size tại thời điểm layout
// Nếu content thay đổi sau (async load) → có thể chọn sai variant

ViewThatFits {
    Text(dynamicText)        // text chưa load → ngắn → vừa
    Text("Fallback")         // không bao giờ dùng
}
// Khi dynamicText load xong → dài hơn → nhưng đã chọn variant rồi
// SwiftUI SẼ re-evaluate khi text thay đổi, nhưng có thể gây layout jump
```

### ❌ Quá nhiều variants → khó maintain

```swift
// ❌ 6 variants → phức tạp, khó debug
ViewThatFits {
    VariantA()
    VariantB()
    VariantC()
    VariantD()
    VariantE()
    VariantF()
}

// ✅ Thường 2-3 variants là đủ
ViewThatFits(in: .horizontal) {
    FullLayout()       // rộng
    CompactLayout()    // hẹp
    MinimalLayout()    // rất hẹp (fallback)
}
```

### ❌ Nhầm ViewThatFits với responsive breakpoint

```swift
// ViewThatFits KHÔNG dùng breakpoint cố định
// Nó đo IDEAL SIZE của mỗi view và so sánh với PROPOSED SIZE
// → Kết quả phụ thuộc vào NỘI DUNG, không phải screen width

// Nếu cần breakpoint cố định (iPhone vs iPad):
// → Dùng horizontalSizeClass environment value
@Environment(\.horizontalSizeClass) var sizeClass
if sizeClass == .regular { WideLayout() } else { NarrowLayout() }
```

---

## 10. ViewThatFits + `horizontalSizeClass` — Kết hợp

```swift
struct AdaptiveDashboard: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        if sizeClass == .regular {
            // iPad: dùng ViewThatFits cho fine-tuning trong vùng rộng
            ViewThatFits(in: .horizontal) {
                ThreeColumnLayout()
                TwoColumnLayout()
            }
        } else {
            // iPhone: dùng ViewThatFits cho single-column variants
            ViewThatFits(in: .vertical) {
                DetailedSingleColumn()
                CompactSingleColumn()
            }
        }
    }
}
// sizeClass cho broad breakpoint (iPhone vs iPad)
// ViewThatFits cho fine-tuning trong mỗi breakpoint
```

---

## 11. Tóm tắt

| Khía cạnh | Chi tiết |
|---|---|
| **Là gì?** | Container tự chọn view đầu tiên VỪA không gian có sẵn |
| **iOS** | 16+ |
| **Thuật toán** | Thử từng view theo thứ tự → view đầu tiên vừa → hiển thị |
| **`in:` parameter** | `.horizontal` (chỉ width), `.vertical` (chỉ height), không chỉ định (cả hai) |
| **Thứ tự** | LỚN → NHỎ (view lớn nhất trước, fallback nhỏ nhất cuối) |
| **View cuối** | Fallback — LUÔN hiển thị nếu không gì vừa |
| **Không cần** | Breakpoint, magic number, GeometryReader |
| **Dùng khi** | Responsive button/label, HStack↔VStack, Dynamic Type, toolbar collapse, widget |
| **KHÔNG dùng khi** | Cần animate transition giữa layouts (dùng AnyLayout), breakpoint cố định (dùng sizeClass) |
| **Best practice** | 2-3 variants, lớn→nhỏ, modifier chung bên ngoài |

----

`ViewThatFits` là công cụ responsive layout mạnh nhất trong SwiftUI kể từ iOS 16, Huy. Ba điểm cốt lõi:

**Thuật toán "thử giày":** Thử từng view theo thứ tự — đo ideal size → so sánh với proposed size → view đầu tiên vừa thì hiển thị, không vừa thì skip. View cuối cùng là **fallback luôn hiển thị** dù không vừa. Quan trọng: phải sắp xếp **lớn → nhỏ** — nếu view nhỏ nhất ở đầu, nó luôn vừa → variants sau không bao giờ được dùng.

**Không cần breakpoint hay magic number.** Đây là ưu điểm lớn nhất so với GeometryReader + if/else. SwiftUI tự đo ideal size mỗi variant → tự quyết định variant nào phù hợp. Đặc biệt hữu ích cho **Dynamic Type**: font size bình thường → HStack layout; font accessibility XXL → text quá rộng → tự đổi sang VStack layout. Không cần đoán breakpoint 400pt hay 600pt.

**Parameter `in:` quyết định trục kiểm tra.** `.horizontal` chỉ check width (phổ biến nhất — responsive toolbar, button, label). `.vertical` chỉ check height (widget, compact notification). Không chỉ định → check cả hai (strict nhất). Chọn đúng trục tránh view bị reject vì trục không quan trọng.

**Phân biệt với AnyLayout:** `ViewThatFits` thay đổi **toàn bộ view tree** (mỗi variant có thể khác hoàn toàn). `AnyLayout` thay đổi **chỉ layout container** (VStack ↔ HStack) giữ nguyên children + animate transition. Cần animate → AnyLayout. Cần content khác nhau hoàn toàn → ViewThatFits.
