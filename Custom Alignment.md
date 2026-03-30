# SwiftUI: Custom Alignment — Giải thích chi tiết

## 1. Ôn lại — Alignment mặc định hoạt động thế nào?

Khi dùng Stack, alignment quyết định **children căn theo đường nào**:

```swift
VStack(alignment: .leading) {
    Text("Hello")        // ← căn left edge
    Text("World!!!")     // ← căn left edge
}
```

```
Alignment guide (đường vô hình):
│
│ Hello
│ World!!!
│
↑ .leading = left edge của mỗi child
```

SwiftUI có sẵn các alignment:

```
HorizontalAlignment: .leading, .center, .trailing
VerticalAlignment:   .top, .center, .bottom, .firstTextBaseline, .lastTextBaseline
```

**Vấn đề:** Các alignment mặc định căn theo **edge hoặc center** của view. Nếu cần căn theo **một điểm tuỳ ý bên trong view** (ví dụ: căn icon trong view A với text trong view B), alignment mặc định không đủ.

---

## 2. `alignmentGuide` Modifier — Tuỳ chỉnh alignment trên built-in alignment

Trước khi tạo custom alignment, hiểu cách **override** alignment mặc định:

```swift
VStack(alignment: .leading) {
    Text("Normal")
    // ← căn theo .leading mặc định (left edge)
    
    Text("Indented")
        .alignmentGuide(.leading) { dimension in
            dimension[.leading] - 20
            // ↑ Dịch alignment guide sang TRÁI 20pt
            // → Text bị đẩy sang PHẢI 20pt (vì guide dịch trái)
        }
}
```

```
│ Normal
│     Indented          ← indent 20pt
│
↑ .leading guide
```

### `ViewDimensions` — Thông tin trong closure

```swift
.alignmentGuide(.leading) { dimension in
    dimension.width             // chiều rộng view
    dimension.height            // chiều cao view
    dimension[.leading]         // vị trí leading edge (thường = 0)
    dimension[.trailing]        // vị trí trailing edge (= width)
    dimension[.top]             // vị trí top (= 0)
    dimension[.bottom]          // vị trí bottom (= height)
    dimension[HorizontalAlignment.center]  // center ngang
    dimension[VerticalAlignment.center]    // center dọc
    dimension[.firstTextBaseline]          // baseline text đầu
}
```

### Ví dụ: Căn label phải, value trái

```swift
VStack(alignment: .trailing) {
    HStack {
        Text("Name:")
        Text("Huy")
            .alignmentGuide(.trailing) { d in d[.leading] }
            //               ↑ với .trailing alignment, dùng .leading edge của Text này
            //                 → "Huy" căn left edge tại đường trailing
    }
    HStack {
        Text("Email:")
        Text("huy@example.com")
            .alignmentGuide(.trailing) { d in d[.leading] }
    }
}
```

```
Không có alignmentGuide:          Có alignmentGuide:
     Name: Huy                         Name: Huy
Email: huy@example.com             Email: huy@example.com
       ↑ trailing edge                      ↑ values căn trái TẠI trailing guide
```

---

## 3. Tại sao cần Custom Alignment?

### Vấn đề: Căn hai view KHÔNG liên quan trực tiếp

```swift
HStack {
    // Cột trái: icon ở giữa
    VStack {
        Text("Title")
        Image(systemName: "star.fill")    // ← muốn căn ngang với...
        Text("Subtitle")
    }
    
    // Cột phải: label ở giữa
    VStack {
        Text("Header")
        Text("Aligned Text")              // ← ...text này
        Text("Footer")
    }
}
```

```
Mặc định (.center):
┌─────────────┬─────────────┐
│   Title     │   Header    │
│     ★       │ Aligned Text│   ← ★ và "Aligned Text" KHÔNG căn ngang
│  Subtitle   │   Footer    │     vì .center căn theo CENTER của mỗi VStack
└─────────────┴─────────────┘

Mong muốn:
┌─────────────┬─────────────┐
│   Title     │   Header    │
│     ★ ──────── Aligned Text│  ← căn ngang cùng 1 đường
│  Subtitle   │   Footer    │
└─────────────┴─────────────┘
```

Built-in alignment (`.top`, `.center`, `.bottom`) **không thể** căn hai phần tử nằm ở vị trí tuỳ ý bên trong hai VStack khác nhau. → Cần **Custom Alignment**.

---

## 4. Tạo Custom Alignment — 3 bước

### Bước 1: Định nghĩa AlignmentID

```swift
struct StarAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[VerticalAlignment.center]
        // ↑ Giá trị MẶC ĐỊNH nếu view KHÔNG dùng .alignmentGuide
        //   Thường là .center để behavior hợp lý
    }
}
```

### Bước 2: Tạo alignment value

```swift
extension VerticalAlignment {
    static let starCenter = VerticalAlignment(StarAlignment.self)
    //         ↑ tên tuỳ ý, đây là alignment mới dùng trong HStack
}
```

### Bước 3: Dùng trong Stack + đánh dấu views

```swift
HStack(alignment: .starCenter) {
    //              ↑ dùng custom alignment
    
    VStack {
        Text("Title")
        Image(systemName: "star.fill")
            .alignmentGuide(.starCenter) { d in d[VerticalAlignment.center] }
            // ↑ "Đường starCenter nằm TẠI center của icon này"
        Text("Subtitle")
    }
    
    VStack {
        Text("Header")
        Text("Aligned Text")
            .alignmentGuide(.starCenter) { d in d[VerticalAlignment.center] }
            // ↑ "Đường starCenter nằm TẠI center của text này"
        Text("Footer")
    }
}
```

### Kết quả

```
┌─────────────┬─────────────┐
│   Title     │   Header    │
│     ★ ══════╤═ Aligned Text│  ← cùng nằm trên đường .starCenter
│  Subtitle   │   Footer    │
└─────────────┴─────────────┘
```

**Cơ chế:** HStack dùng `.starCenter` làm đường căn ngang. Views có `.alignmentGuide(.starCenter)` báo "đường starCenter nằm ở đây trong tôi". HStack dịch các children sao cho tất cả điểm đó thẳng hàng.

---

## 5. Custom Horizontal Alignment

Tương tự nhưng cho `HorizontalAlignment` — dùng trong `VStack`:

```swift
// Bước 1 + 2: Định nghĩa
struct ValueColumnAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[HorizontalAlignment.center]
    }
}

extension HorizontalAlignment {
    static let valueColumn = HorizontalAlignment(ValueColumnAlignment.self)
}

// Bước 3: Sử dụng
VStack(alignment: .valueColumn) {
    HStack {
        Text("Name:")
        Text("Huy Nguyen")
            .alignmentGuide(.valueColumn) { d in d[.leading] }
    }
    HStack {
        Text("Email:")
        Text("huy@example.com")
            .alignmentGuide(.valueColumn) { d in d[.leading] }
    }
    HStack {
        Text("Role:")
        Text("iOS Developer")
            .alignmentGuide(.valueColumn) { d in d[.leading] }
    }
}
```

```
Không custom alignment:           Có custom alignment:
   Name: Huy Nguyen                    Name: Huy Nguyen
 Email: huy@example.com              Email: huy@example.com
  Role: iOS Developer                 Role: iOS Developer
  ↑ center VStack                          ↑ values căn leading tại .valueColumn
```

---

## 6. Ứng dụng thực tế

### 6.1 Form layout — Label : Value căn thẳng

```swift
struct FormAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[HorizontalAlignment.center]
    }
}

extension HorizontalAlignment {
    static let formLabel = HorizontalAlignment(FormAlignment.self)
}

struct AlignedForm: View {
    var body: some View {
        VStack(alignment: .formLabel, spacing: 12) {
            formRow(label: "Name", value: "Huy Nguyen")
            formRow(label: "Email", value: "huy@example.com")
            formRow(label: "Phone", value: "+84 123 456 789")
            formRow(label: "Location", value: "Hanoi, Vietnam")
        }
        .padding()
    }
    
    private func formRow(label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text("\(label):")
                .foregroundStyle(.secondary)
                .alignmentGuide(.formLabel) { d in d[.trailing] }
                // ↑ trailing edge của label nằm trên đường .formLabel
            
            Text(value)
                .alignmentGuide(.formLabel) { d in d[.leading] }
                // ↑ leading edge của value cũng nằm trên đường .formLabel
                // → tất cả labels căn phải, values căn trái TẠI CÙNG ĐƯỜNG
        }
    }
}
```

```
     Name: Huy Nguyen
    Email: huy@example.com
    Phone: +84 123 456 789
 Location: Hanoi, Vietnam
          ↑ formLabel guide — labels căn phải, values căn trái
```

### 6.2 Icon + Text alignment trong menu

```swift
struct IconCenter: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[HorizontalAlignment.center]
    }
}

extension HorizontalAlignment {
    static let iconCenter = HorizontalAlignment(IconCenter.self)
}

struct IconMenu: View {
    var body: some View {
        VStack(alignment: .iconCenter, spacing: 16) {
            menuItem(icon: "house.fill", title: "Home", badge: nil)
            menuItem(icon: "magnifyingglass", title: "Search", badge: nil)
            menuItem(icon: "heart.fill", title: "Favorites", badge: "3")
            menuItem(icon: "person.fill", title: "Profile", badge: nil)
        }
    }
    
    private func menuItem(icon: String, title: String, badge: String?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .alignmentGuide(.iconCenter) { d in d[HorizontalAlignment.center] }
                // ↑ icon centers căn thẳng dọc
            
            Text(title)
            
            if let badge {
                Text(badge)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
    }
}
```

```
        🏠  Home
        🔍  Search
        ♥   Favorites  ③
        👤  Profile
        ↑
   iconCenter — tất cả icons căn center dọc cùng đường
```

### 6.3 Timeline / Activity feed

```swift
struct TimelineDot: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[HorizontalAlignment.center]
    }
}

extension HorizontalAlignment {
    static let timelineDot = HorizontalAlignment(TimelineDot.self)
}

struct TimelineView: View {
    let events: [Event]
    
    var body: some View {
        VStack(alignment: .timelineDot, spacing: 0) {
            ForEach(events) { event in
                HStack(alignment: .top, spacing: 12) {
                    Text(event.time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .trailing)
                    
                    Circle()
                        .fill(event.color)
                        .frame(width: 12, height: 12)
                        .alignmentGuide(.timelineDot) { d in
                            d[HorizontalAlignment.center]
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title).font(.headline)
                        Text(event.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
                
                // Vertical line connecting dots
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 2, height: 20)
                    .alignmentGuide(.timelineDot) { d in
                        d[HorizontalAlignment.center]
                    }
            }
        }
    }
}
```

```
 09:00  ● Meeting with team
        │ Discussed Q2 roadmap
        │
 10:30  ● Code review
        │ Reviewed PR #142
        │
 14:00  ● Deploy v2.1
          Released to TestFlight
        
        ↑ timelineDot — dots và lines căn thẳng
```

### 6.4 Chart — Label căn với data point

```swift
struct DataPointCenter: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[VerticalAlignment.center]
    }
}

extension VerticalAlignment {
    static let dataPoint = VerticalAlignment(DataPointCenter.self)
}

struct BarChartRow: View {
    let label: String
    let value: Double
    let maxValue: Double
    
    var body: some View {
        HStack(alignment: .dataPoint) {
            Text(label)
                .frame(width: 80, alignment: .trailing)
                .alignmentGuide(.dataPoint) { d in d[VerticalAlignment.center] }
            
            RoundedRectangle(cornerRadius: 4)
                .fill(.blue)
                .frame(width: CGFloat(value / maxValue) * 200, height: 24)
                .alignmentGuide(.dataPoint) { d in d[VerticalAlignment.center] }
            
            Text("\(Int(value))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .alignmentGuide(.dataPoint) { d in d[VerticalAlignment.center] }
        }
    }
}
```

```
 Revenue ████████████████████ 850
   Costs ████████████ 520
  Profit ████████ 330
          ↑ labels, bars, numbers căn center ngang cùng đường .dataPoint
```

### 6.5 Two-column layout — Alignment giữa cột

```swift
struct ColumnDivider: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[HorizontalAlignment.center]
    }
}

extension HorizontalAlignment {
    static let columnDivider = HorizontalAlignment(ColumnDivider.self)
}

struct TwoColumnView: View {
    var body: some View {
        VStack(alignment: .columnDivider, spacing: 16) {
            // Row 1
            HStack {
                Text("Temperature")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Text("|")
                    .foregroundStyle(.gray)
                    .alignmentGuide(.columnDivider) { d in d[HorizontalAlignment.center] }
                
                Text("28°C")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Row 2
            HStack {
                Text("Humidity")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                Text("|")
                    .foregroundStyle(.gray)
                    .alignmentGuide(.columnDivider) { d in d[HorizontalAlignment.center] }
                
                Text("75%")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
```

```
 Temperature │ 28°C
    Humidity │ 75%
        Wind │ 12 km/h
             ↑ columnDivider — dividers căn thẳng
```

---

## 7. Default Value — Ảnh hưởng views KHÔNG có alignmentGuide

```swift
struct MyAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        // View KHÔNG có .alignmentGuide(.myAlignment) → dùng giá trị này
        context[VerticalAlignment.center]    // mặc định: center
    }
}
```

```swift
HStack(alignment: .starCenter) {
    // View 1: CÓ alignmentGuide → dùng giá trị chỉ định
    VStack {
        Text("A")
        Image(systemName: "star")
            .alignmentGuide(.starCenter) { d in d[VerticalAlignment.center] }
        Text("B")
    }
    
    // View 2: KHÔNG có alignmentGuide → dùng defaultValue (center)
    Text("No guide")
    // ↑ Căn center mặc định vì defaultValue = center
}
```

### Chọn defaultValue phù hợp

```swift
// Nếu alignment liên quan đến top
static func defaultValue(in context: ViewDimensions) -> CGFloat {
    context[VerticalAlignment.top]
}

// Nếu alignment liên quan đến center (phổ biến nhất)
static func defaultValue(in context: ViewDimensions) -> CGFloat {
    context[VerticalAlignment.center]
}

// Nếu alignment liên quan đến baseline
static func defaultValue(in context: ViewDimensions) -> CGFloat {
    context[VerticalAlignment.firstTextBaseline]
}

// Giá trị cố định
static func defaultValue(in context: ViewDimensions) -> CGFloat {
    0    // top/leading edge
}
```

---

## 8. Alignment Guide trong ZStack

Custom alignment cũng hoạt động trong `ZStack` — căn chồng views theo điểm tuỳ ý:

```swift
struct BadgeAnchor: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[.trailing]    // mặc định trailing
    }
}
// Tạo cả horizontal VÀ vertical cho 2D alignment
extension HorizontalAlignment {
    static let badgeX = HorizontalAlignment(BadgeAnchor.self)
}

struct BadgeAnchorV: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[.top]
    }
}
extension VerticalAlignment {
    static let badgeY = VerticalAlignment(BadgeAnchorV.self)
}

// Combine thành Alignment 2D
extension Alignment {
    static let badgePosition = Alignment(horizontal: .badgeX, vertical: .badgeY)
}

// Sử dụng
ZStack(alignment: .badgePosition) {
    // Main content
    RoundedRectangle(cornerRadius: 12)
        .fill(.blue)
        .frame(width: 200, height: 100)
        .alignmentGuide(.badgeX) { d in d.width * 0.85 }
        //                                 ↑ badge nằm tại 85% width
        .alignmentGuide(.badgeY) { d in d.height * 0.1 }
        //                                 ↑ badge nằm tại 10% height
    
    // Badge
    Circle()
        .fill(.red)
        .frame(width: 24, height: 24)
        .overlay(Text("3").font(.caption2).foregroundStyle(.white))
        .alignmentGuide(.badgeX) { d in d[HorizontalAlignment.center] }
        .alignmentGuide(.badgeY) { d in d[VerticalAlignment.center] }
}
```

```
┌──────────────────────────────────┐
│                          ●③      │  ← badge tại (85%, 10%)
│         Blue Card                │
│                                  │
└──────────────────────────────────┘
```

---

## 9. Alignment Guide với Dynamic Values

```swift
struct DynamicFormRow: View {
    let label: String
    let value: String
    @Binding var editMode: Bool
    
    var body: some View {
        HStack {
            Text("\(label):")
                .alignmentGuide(.formLabel) { d in d[.trailing] }
            
            if editMode {
                TextField(label, text: .constant(value))
                    .alignmentGuide(.formLabel) { d in d[.leading] }
            } else {
                Text(value)
                    .alignmentGuide(.formLabel) { d in d[.leading] }
            }
        }
    }
}
// Dù switch giữa TextField và Text,
// alignment guide giữ columns căn thẳng
```

---

## 10. Sai lầm thường gặp

### ❌ alignmentGuide cho alignment KHÔNG dùng trong parent Stack

```swift
VStack(alignment: .leading) {
    Text("Hello")
        .alignmentGuide(.trailing) { d in d[.trailing] }
        //               ↑ .trailing nhưng VStack dùng .leading
        //                 → KHÔNG có hiệu lực!
}

// ✅ alignmentGuide phải KHỚP với Stack alignment
VStack(alignment: .leading) {
    Text("Hello")
        .alignmentGuide(.leading) { d in d[.leading] - 20 }
        //               ↑ .leading khớp với VStack → có hiệu lực
}
```

### ❌ Quên defaultValue hợp lý

```swift
struct BadDefault: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        return 0    // top/leading → views KHÔNG có guide bị đẩy lên top
    }
}

// View không có .alignmentGuide sẽ căn theo 0 (top)
// → layout lạ nếu chỉ 1 trong nhiều views có guide

// ✅ Dùng center làm default cho behavior tự nhiên
struct GoodDefault: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[VerticalAlignment.center]
    }
}
```

### ❌ Dùng custom alignment khi built-in đủ

```swift
// ❌ Tạo custom alignment chỉ để căn center
// → .center đã có sẵn

// ✅ Chỉ tạo custom khi built-in KHÔNG đủ
// Ví dụ: căn theo icon center, form label column, timeline dot
```

### ❌ Alignment guide trả giá trị ngoài bounds

```swift
.alignmentGuide(.myAlignment) { d in
    d[.trailing] + 100
    // ↑ Ngoài bounds view → view bị dịch quá xa, có thể overlap
}

// ✅ Giữ giá trị trong bounds hợp lý
.alignmentGuide(.myAlignment) { d in
    d[VerticalAlignment.center]    // trong bounds
}
```

---

## 11. Tóm tắt

| Bước | Hành động |
|---|---|
| **1. AlignmentID** | Tạo struct conform `AlignmentID`, define `defaultValue` |
| **2. Extension** | Extend `HorizontalAlignment` hoặc `VerticalAlignment` với static property |
| **3. Sử dụng** | Stack dùng custom alignment + views dùng `.alignmentGuide()` |

| Khía cạnh | Chi tiết |
|---|---|
| **Là gì?** | Tạo đường căn tuỳ ý để align views theo điểm bất kỳ bên trong chúng |
| **Khi nào cần?** | Built-in alignment (leading/center/trailing/top/bottom) không đủ |
| **AlignmentID** | Struct cung cấp `defaultValue` cho views KHÔNG có `.alignmentGuide` |
| **alignmentGuide** | Modifier chỉ định "đường alignment nằm TẠI ĐÂY trong view tôi" |
| **Dùng trong** | HStack (VerticalAlignment), VStack (HorizontalAlignment), ZStack (cả hai) |
| **defaultValue** | Thường dùng `.center` — behavior hợp lý nhất cho views không chỉ định |
| **Ứng dụng** | Form label:value, timeline, icon menu, chart labels, two-column layout |
| **Quy tắc** | alignmentGuide phải KHỚP với alignment mà Stack đang dùng |

---

Custom Alignment giải quyết bài toán căn view theo **điểm tuỳ ý bên trong view**, Huy — thứ mà built-in alignment (leading/center/trailing) không làm được. Ba điểm cốt lõi:

**3 bước tạo custom alignment:** (1) Tạo struct conform `AlignmentID` với `defaultValue` (giá trị mặc định cho views không chỉ định). (2) Extend `HorizontalAlignment` hoặc `VerticalAlignment` với static property mới. (3) Dùng trong Stack (`HStack(alignment: .myCustom)`) + đánh dấu views bằng `.alignmentGuide(.myCustom) { d in ... }`. SwiftUI sẽ dịch các children sao cho tất cả điểm đánh dấu nằm trên **cùng một đường thẳng**.

**Cơ chế:** `.alignmentGuide(.myAlignment) { d in d[VerticalAlignment.center] }` nói "đường myAlignment nằm tại center của view tôi". Khi nhiều views trong cùng Stack đều chỉ định, Stack dịch children sao cho tất cả center đó thẳng hàng — dù views có kích thước khác nhau, nằm ở vị trí khác nhau trong hierarchy.

**Ứng dụng thực tế phổ biến:** Form layout (labels căn phải, values căn trái tại cùng đường dọc), timeline (dots và connecting lines căn thẳng), icon menu (icons đều căn center dù icon khác nhau có width khác), chart labels (text căn với data point). Quy tắc quan trọng: `.alignmentGuide` phải **khớp** với alignment mà Stack đang dùng — `.alignmentGuide(.trailing)` trong `VStack(alignment: .leading)` **không có hiệu lực**.
