# SwiftUI: `LayoutProperties` — Giải thích chi tiết

## 1. Bản chất — Metadata mà Layout đọc từ subviews

`LayoutProperties` là struct chứa **thông tin bổ sung** mà mỗi subview cung cấp cho layout container. Khi tạo custom layout (conform `Layout` protocol), ta dùng `LayoutProperties` để đọc metadata từ children — giúp layout đưa ra quyết định thông minh hơn.

```
Layout Container (custom)
    │
    ├── Subview A → LayoutProperties { stackOrientation: .vertical }
    ├── Subview B → LayoutProperties { stackOrientation: nil }
    └── Subview C → LayoutProperties { stackOrientation: .horizontal }
    
Layout đọc properties để quyết định cách sắp xếp children
```

### LayoutProperties struct

```swift
// Apple's definition (đơn giản hoá):
struct LayoutProperties {
    var stackOrientation: Axis?
    // ↑ Property DUY NHẤT có sẵn
    // nil = không phải stack
    // .horizontal = HStack-like
    // .vertical = VStack-like
}
```

Hiện tại, `LayoutProperties` chỉ có **1 property built-in**: `stackOrientation`. Tuy nhiên, cơ chế mở rộng thông qua `LayoutValueKey` mới là sức mạnh thực sự.

---

## 2. Đọc LayoutProperties trong Custom Layout

### Layout Protocol — Recap nhanh

```swift
struct MyLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // Tính toán kích thước layout
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        // Đặt subviews vào vị trí
    }
}
```

### Đọc `stackOrientation` từ subviews

```swift
struct AdaptiveLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // ...
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for subview in subviews {
            let properties = subview.layoutProperties
            //                       ↑ LayoutProperties của subview này
            
            switch properties.stackOrientation {
            case .horizontal:
                // Subview là HStack-like → xử lý đặc biệt
                print("This child prefers horizontal")
            case .vertical:
                // Subview là VStack-like
                print("This child prefers vertical")
            case nil:
                // Không phải stack
                print("This child has no stack preference")
            default:
                break
            }
        }
    }
}
```

### Ví dụ thực tế: Layout đọc orientation để quyết định spacing

```swift
struct SmartSpacingLayout: Layout {
    var defaultSpacing: CGFloat = 8
    var stackSpacing: CGFloat = 16
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var totalHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(proposal)
            maxWidth = max(maxWidth, size.width)
            totalHeight += size.height
            
            if index > 0 {
                // Subview là stack → spacing lớn hơn
                let spacing = subview.layoutProperties.stackOrientation != nil
                    ? stackSpacing
                    : defaultSpacing
                totalHeight += spacing
            }
        }
        
        return CGSize(width: maxWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(proposal)
            
            if index > 0 {
                let spacing = subview.layoutProperties.stackOrientation != nil
                    ? stackSpacing
                    : defaultSpacing
                y += spacing
            }
            
            subview.place(
                at: CGPoint(x: bounds.midX, y: y),
                anchor: .top,
                proposal: proposal
            )
            y += size.height
        }
    }
}
```

---

## 3. `LayoutValueKey` — Sức mạnh thực sự: Custom Layout Properties

`stackOrientation` chỉ có 1 property, khá hạn chế. `LayoutValueKey` cho phép **truyền BẤT KỲ data nào** từ subview lên layout container — đây là cơ chế mở rộng chính.

### Cơ chế

```
1. Định nghĩa Key (struct conform LayoutValueKey)
2. Subview GÁN giá trị qua .layoutValue(key:value:) modifier
3. Layout ĐỌC giá trị qua subview[MyKey.self]
```

```
Subview ──.layoutValue(key: Priority.self, value: 1)──▶ Layout reads subview[Priority.self]
```

### 3.1 Định nghĩa LayoutValueKey

```swift
struct LayoutPriorityKey: LayoutValueKey {
    static let defaultValue: Double = 0
    //                        ↑ Giá trị mặc định khi subview KHÔNG set
}
```

### 3.2 Subview gán giá trị

```swift
struct MyView: View {
    var body: some View {
        MyCustomLayout {
            Text("Low priority")
                .layoutValue(key: LayoutPriorityKey.self, value: 0)
            
            Text("High priority")
                .layoutValue(key: LayoutPriorityKey.self, value: 1)
            
            Text("Default")
            // ← Không set → dùng defaultValue = 0
        }
    }
}
```

### 3.3 Layout đọc giá trị

```swift
struct MyCustomLayout: Layout {
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for subview in subviews {
            let priority = subview[LayoutPriorityKey.self]
            //                     ↑ subscript đọc custom value
            print("Priority: \(priority)")
        }
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // ...
    }
}
```

### Extension cho cú pháp gọn

```swift
extension View {
    func customPriority(_ value: Double) -> some View {
        layoutValue(key: LayoutPriorityKey.self, value: value)
    }
}

// Giờ gọi gọn:
Text("Important")
    .customPriority(1)
```

---

## 4. Ứng dụng thực tế

### 4.1 Flow Layout với item priority — Quan trọng xếp trước

```swift
// MARK: - Keys
struct FlowItemPriorityKey: LayoutValueKey {
    static let defaultValue: Int = 0
}

struct FlowItemMinWidthKey: LayoutValueKey {
    static let defaultValue: CGFloat? = nil
}

extension View {
    func flowPriority(_ priority: Int) -> some View {
        layoutValue(key: FlowItemPriorityKey.self, value: priority)
    }
    
    func flowMinWidth(_ width: CGFloat) -> some View {
        layoutValue(key: FlowItemMinWidthKey.self, value: width)
    }
}

// MARK: - Layout
struct PriorityFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(in: proposal.width ?? .infinity, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(in: bounds.width, subviews: subviews)
        
        for (index, position) in result.positions.enumerated() {
            subviews[result.sortedIndices[index]].place(
                at: CGPoint(
                    x: bounds.minX + position.x,
                    y: bounds.minY + position.y
                ),
                proposal: .unspecified
            )
        }
    }
    
    private func arrange(in maxWidth: CGFloat, subviews: Subviews) -> ArrangeResult {
        // Sắp xếp theo priority (cao → thấp)
        let sortedIndices = subviews.indices.sorted { a, b in
            subviews[a][FlowItemPriorityKey.self] > subviews[b][FlowItemPriorityKey.self]
            //        ↑ ĐỌC priority từ LayoutValueKey
        }
        
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalSize: CGSize = .zero
        
        for index in sortedIndices {
            let subview = subviews[index]
            let minWidth = subview[FlowItemMinWidthKey.self]
            //                     ↑ ĐỌC minWidth từ LayoutValueKey
            
            var size = subview.sizeThatFits(.unspecified)
            if let minWidth, size.width < minWidth {
                size.width = minWidth
            }
            
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
        
        return ArrangeResult(size: totalSize, positions: positions, sortedIndices: sortedIndices)
    }
    
    struct ArrangeResult {
        var size: CGSize
        var positions: [CGPoint]
        var sortedIndices: [Int]
    }
}

// MARK: - Usage
struct TagCloud: View {
    var body: some View {
        PriorityFlowLayout(spacing: 8) {
            Tag("Swift").flowPriority(3)           // ← cao nhất → xếp đầu
            Tag("SwiftUI").flowPriority(3)
            Tag("Combine").flowPriority(2)
            Tag("UIKit").flowPriority(2)
            Tag("CoreData").flowPriority(1)
            Tag("CloudKit").flowPriority(0)
            Tag("WidgetKit").flowPriority(0)
        }
    }
}
```

```
Priority sorting:
┌───────────────────────────────────────┐
│ [Swift] [SwiftUI] [Combine] [UIKit]  │  ← priority 3, 2 xếp trước
│ [CoreData] [CloudKit] [WidgetKit]    │  ← priority 1, 0 xếp sau
└───────────────────────────────────────┘
```

### 4.2 Grid Layout với column span — Item chiếm nhiều cột

```swift
// MARK: - Key
struct ColumnSpanKey: LayoutValueKey {
    static let defaultValue: Int = 1
}

extension View {
    func columnSpan(_ span: Int) -> some View {
        layoutValue(key: ColumnSpanKey.self, value: span)
    }
}

// MARK: - Layout
struct SpannableGridLayout: Layout {
    var columns: Int = 3
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        let placements = calculatePlacements(width: width, subviews: subviews)
        return placements.totalSize
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let placements = calculatePlacements(width: bounds.width, subviews: subviews)
        
        for (index, placement) in placements.items.enumerated() {
            subviews[index].place(
                at: CGPoint(
                    x: bounds.minX + placement.origin.x,
                    y: bounds.minY + placement.origin.y
                ),
                proposal: ProposedViewSize(placement.size)
            )
        }
    }
    
    private func calculatePlacements(width: CGFloat, subviews: Subviews) -> PlacementResult {
        let colWidth = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        var grid: [[Bool]] = []    // track occupied cells
        var items: [(origin: CGPoint, size: CGSize)] = []
        var maxY: CGFloat = 0
        
        for subview in subviews {
            let span = min(subview[ColumnSpanKey.self], columns)
            //                     ↑ ĐỌC column span
            let itemWidth = colWidth * CGFloat(span) + spacing * CGFloat(span - 1)
            let itemHeight = subview.sizeThatFits(
                ProposedViewSize(width: itemWidth, height: nil)
            ).height
            
            // Find available position (simplified)
            let (row, col) = findAvailableSlot(grid: &grid, span: span, columns: columns)
            let x = CGFloat(col) * (colWidth + spacing)
            let y = CGFloat(row) * (itemHeight + spacing)
            
            items.append((origin: CGPoint(x: x, y: y), size: CGSize(width: itemWidth, height: itemHeight)))
            maxY = max(maxY, y + itemHeight)
        }
        
        return PlacementResult(items: items, totalSize: CGSize(width: width, height: maxY))
    }
    
    // ... findAvailableSlot helper
    
    struct PlacementResult {
        var items: [(origin: CGPoint, size: CGSize)]
        var totalSize: CGSize
    }
}

// MARK: - Usage
struct DashboardGrid: View {
    var body: some View {
        SpannableGridLayout(columns: 3, spacing: 12) {
            RevenueCard()
                .columnSpan(2)      // ← chiếm 2 cột
            
            UsersCard()
                .columnSpan(1)      // ← chiếm 1 cột
            
            ChartCard()
                .columnSpan(3)      // ← chiếm full 3 cột
            
            MetricCard()            // ← mặc định 1 cột
            MetricCard()
            MetricCard()
        }
    }
}
```

```
┌──────────────────────┬──────────┐
│ Revenue (span 2)     │ Users    │
│                      │ (span 1) │
├──────────────────────┴──────────┤
│ Chart (span 3 = full width)     │
├──────────┬──────────┬──────────┤
│ Metric   │ Metric   │ Metric   │
└──────────┴──────────┴──────────┘
```

### 4.3 Weighted Layout — Phân chia theo tỷ trọng

```swift
// MARK: - Key
struct LayoutWeightKey: LayoutValueKey {
    static let defaultValue: CGFloat = 1
}

extension View {
    func layoutWeight(_ weight: CGFloat) -> some View {
        layoutValue(key: LayoutWeightKey.self, value: weight)
    }
}

// MARK: - Layout
struct WeightedHStack: Layout {
    var spacing: CGFloat = 0
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let height = subviews.reduce(CGFloat(0)) { max($0, $1.sizeThatFits(proposal).height) }
        return CGSize(width: proposal.width ?? 0, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let totalWeight = subviews.reduce(CGFloat(0)) { sum, subview in
            sum + subview[LayoutWeightKey.self]
            //             ↑ ĐỌC weight
        }
        
        let totalSpacing = spacing * CGFloat(subviews.count - 1)
        let availableWidth = bounds.width - totalSpacing
        var x = bounds.minX
        
        for subview in subviews {
            let weight = subview[LayoutWeightKey.self]
            let width = availableWidth * (weight / totalWeight)
            
            subview.place(
                at: CGPoint(x: x, y: bounds.minY),
                proposal: ProposedViewSize(width: width, height: bounds.height)
            )
            x += width + spacing
        }
    }
}

// MARK: - Usage
struct SplitView: View {
    var body: some View {
        WeightedHStack(spacing: 1) {
            // Sidebar: 1/4
            SidebarView()
                .layoutWeight(1)
                .background(.gray.opacity(0.1))
            
            // Content: 3/4
            ContentView()
                .layoutWeight(3)
                .background(.white)
        }
        .frame(height: 500)
    }
}
```

```
weight 1         weight 3
┌──────────┬──────────────────────────────┐
│ Sidebar  │          Content             │
│   25%    │            75%               │
│          │                              │
└──────────┴──────────────────────────────┘
```

### 4.4 Pinned / Sticky Item trong Custom Layout

```swift
// MARK: - Key
struct IsPinnedKey: LayoutValueKey {
    static let defaultValue: Bool = false
}

extension View {
    func pinned(_ isPinned: Bool = true) -> some View {
        layoutValue(key: IsPinnedKey.self, value: isPinned)
    }
}

// MARK: - Layout
struct PinnableVStack: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let heights = subviews.map { $0.sizeThatFits(proposal).height }
        let totalHeight = heights.reduce(0, +) + spacing * CGFloat(subviews.count - 1)
        let maxWidth = subviews.reduce(CGFloat(0)) { max($0, $1.sizeThatFits(proposal).width) }
        return CGSize(width: maxWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        
        for subview in subviews {
            let isPinned = subview[IsPinnedKey.self]
            //                      ↑ ĐỌC pinned flag
            let size = subview.sizeThatFits(proposal)
            
            if isPinned {
                // Pinned items: đặt ở top bounds (sticky behavior concept)
                subview.place(
                    at: CGPoint(x: bounds.minX, y: bounds.minY),
                    proposal: ProposedViewSize(width: bounds.width, height: size.height)
                )
            } else {
                subview.place(
                    at: CGPoint(x: bounds.minX, y: y),
                    proposal: ProposedViewSize(width: bounds.width, height: size.height)
                )
            }
            y += size.height + spacing
        }
    }
}

// MARK: - Usage
PinnableVStack {
    HeaderView()
        .pinned()          // ← sticky header
    
    ForEach(items) { item in
        ItemRow(item: item)
        // ← mặc định: không pinned
    }
}
```

### 4.5 Labeled Layout — Tự động căn label:value

```swift
// MARK: - Keys
struct IsLabelKey: LayoutValueKey {
    static let defaultValue: Bool = false
}

extension View {
    func isLabel(_ value: Bool = true) -> some View {
        layoutValue(key: IsLabelKey.self, value: value)
    }
}

// MARK: - Layout
struct LabeledRowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let labelWidth = subviews
            .filter { $0[IsLabelKey.self] }
            .reduce(CGFloat(0)) { max($0, $1.sizeThatFits(.unspecified).width) }
        
        let height = subviews.reduce(CGFloat(0)) { max($0, $1.sizeThatFits(proposal).height) }
        return CGSize(width: proposal.width ?? 300, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        // Tính max label width
        let labelWidth = subviews
            .filter { $0[IsLabelKey.self] }
            //         ↑ ĐỌC isLabel flag
            .reduce(CGFloat(0)) { max($0, $1.sizeThatFits(.unspecified).width) }
        
        var x = bounds.minX
        
        for subview in subviews {
            let isLabel = subview[IsLabelKey.self]
            
            if isLabel {
                // Label: chiều rộng cố định, căn phải
                subview.place(
                    at: CGPoint(x: x, y: bounds.minY),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: labelWidth, height: bounds.height)
                )
                x += labelWidth + spacing
            } else {
                // Value: chiếm phần còn lại
                let valueWidth = bounds.width - labelWidth - spacing
                subview.place(
                    at: CGPoint(x: x, y: bounds.minY),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: valueWidth, height: bounds.height)
                )
                x += valueWidth
            }
        }
    }
}

// MARK: - Usage
VStack(spacing: 12) {
    LabeledRowLayout {
        Text("Name:").isLabel()
        Text("Huy Nguyen")
    }
    LabeledRowLayout {
        Text("Email:").isLabel()
        Text("huy@example.com")
    }
    LabeledRowLayout {
        Text("Location:").isLabel()
        Text("Hanoi, Vietnam")
    }
}
```

```
     Name: Huy Nguyen
    Email: huy@example.com
 Location: Hanoi, Vietnam
          ↑ labels tự động cùng width (max label width)
```

---

## 5. Nhiều LayoutValueKey cùng lúc

Một subview có thể gán **nhiều layout values**:

```swift
struct ItemWidthKey: LayoutValueKey { static let defaultValue: CGFloat? = nil }
struct ItemHeightKey: LayoutValueKey { static let defaultValue: CGFloat? = nil }
struct ItemAlignmentKey: LayoutValueKey { static let defaultValue: Alignment = .center }
struct ItemOrderKey: LayoutValueKey { static let defaultValue: Int = 0 }

// Subview gán nhiều values
Text("Card")
    .layoutValue(key: ItemWidthKey.self, value: 200)
    .layoutValue(key: ItemHeightKey.self, value: 150)
    .layoutValue(key: ItemAlignmentKey.self, value: .topLeading)
    .layoutValue(key: ItemOrderKey.self, value: 2)

// Layout đọc tất cả
func placeSubviews(...) {
    for subview in subviews {
        let width = subview[ItemWidthKey.self]
        let height = subview[ItemHeightKey.self]
        let alignment = subview[ItemAlignmentKey.self]
        let order = subview[ItemOrderKey.self]
        // ...
    }
}
```

---

## 6. `layoutProperties` (static) — Layout container tự khai báo properties

Layout container cũng có thể khai báo **properties cho bản thân nó**:

```swift
struct MyLayout: Layout {
    // Layout tự khai báo properties
    static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .vertical
        // ↑ Nói với PARENT layout: "Tôi hoạt động như VStack"
        return properties
    }
    
    func sizeThatFits(...) -> CGSize { ... }
    func placeSubviews(...) { ... }
}
```

Khi `MyLayout` được dùng **bên trong** layout container khác, parent có thể đọc `stackOrientation` để biết `MyLayout` behave theo hướng nào.

```swift
struct ParentLayout: Layout {
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for subview in subviews {
            if subview.layoutProperties.stackOrientation == .vertical {
                // Child là vertical layout → cho width rộng hơn
            } else {
                // Child là horizontal layout → cho height cao hơn
            }
        }
    }
}
```

---

## 7. LayoutProperties vs LayoutValueKey vs Preference vs Environment

```
                  LayoutValueKey           PreferenceKey          Environment
                  ──────────────           ─────────────          ───────────
Hướng data        Child → Parent Layout    Child → Ancestor View  Parent → Child
Dùng trong        Layout protocol          View hierarchy         View hierarchy
Đọc ở đâu        Layout.placeSubviews     .onPreferenceChange    @Environment
Set ở đâu         .layoutValue(key:value:) .preference(key:value:) .environment()
Mục đích          Layout metadata          Geometry/size data     Config/theme/settings
```

```
LayoutValueKey:
  Child View ──layoutValue──▶ Custom Layout reads subview[Key.self]
  "Layout ơi, tôi muốn chiếm 2 cột, priority 3"

PreferenceKey:
  Child View ──preference──▶ Ancestor View .onPreferenceChange
  "Parent ơi, kích thước tôi là 200x44"

Environment:
  Parent View ──environment──▶ Child View @Environment
  "Con ơi, theme hiện tại là dark mode"
```

---

## 8. Sai lầm thường gặp

### ❌ Dùng LayoutValueKey ngoài custom Layout

```swift
// ❌ LayoutValueKey CHỈ đọc được trong Layout protocol
// Không đọc được trong View body hay ViewModifier

struct MyView: View {
    var body: some View {
        // ❌ Không có cách đọc LayoutValueKey ở đây
        VStack {
            Text("Hello").layoutValue(key: MyKey.self, value: 42)
            // VStack KHÔNG đọc MyKey — chỉ custom Layout mới đọc
        }
    }
}

// ✅ Phải dùng trong custom Layout
struct MyLayout: Layout {
    func placeSubviews(..., subviews: Subviews, ...) {
        let value = subviews[0][MyKey.self]    // ✅ đọc được ở đây
    }
}
```

### ❌ Quên defaultValue

```swift
// ❌ Compile error — thiếu defaultValue
struct BadKey: LayoutValueKey {
    // static let defaultValue bắt buộc
}

// ✅
struct GoodKey: LayoutValueKey {
    static let defaultValue: Int = 0
}
```

### ❌ LayoutValueKey với reference type

```swift
// ⚠️ Cẩn thận với reference types — có thể gây side effect
struct RefKey: LayoutValueKey {
    static let defaultValue: MyClass? = nil    // ⚠️ shared reference
}

// ✅ Ưu tiên value types
struct ValueKey: LayoutValueKey {
    static let defaultValue: MyStruct = .init()    // ✅ value type
}
```

---

## 9. Tóm tắt

| Concept | Vai trò |
|---|---|
| **LayoutProperties** | Struct metadata có sẵn trên mỗi subview — hiện chỉ có `stackOrientation` |
| **stackOrientation** | Property duy nhất built-in: `.horizontal`, `.vertical`, hoặc `nil` |
| **LayoutValueKey** | Protocol tạo custom properties — child gán, layout đọc |
| **layoutValue(key:value:)** | Modifier gán custom value lên view |
| **subview[Key.self]** | Subscript đọc custom value trong Layout |
| **static layoutProperties** | Layout container tự khai báo orientation cho parent |

| Khía cạnh | Chi tiết |
|---|---|
| **Dùng khi?** | Custom Layout cần metadata từ children: priority, span, weight, pinned, role |
| **Chỉ hoạt động trong** | `Layout` protocol — KHÔNG dùng trong View body hay ViewModifier |
| **Kiểu dữ liệu** | Bất kỳ (cần `static let defaultValue`) — ưu tiên value types |
| **Nhiều keys** | ✅ Một subview có thể gán nhiều LayoutValueKey |
| **Pattern** | Define Key → Extension `.myValue()` → Layout reads `subview[Key.self]` |

---

`LayoutProperties` và `LayoutValueKey` là cơ chế truyền metadata từ **child view lên custom Layout container**, Huy. Ba điểm cốt lõi:

**`LayoutProperties` built-in rất hạn chế** — chỉ có 1 property: `stackOrientation` (`.horizontal`, `.vertical`, `nil`). Đọc qua `subview.layoutProperties.stackOrientation` trong custom Layout. Dùng để biết subview là HStack-like hay VStack-like → layout quyết định spacing, size proposal phù hợp.

**`LayoutValueKey` mới là sức mạnh thực sự** — cho phép truyền **bất kỳ data nào** từ subview lên Layout. Pattern 3 bước: (1) Define key struct conform `LayoutValueKey` với `defaultValue`. (2) Subview gán value qua `.layoutValue(key:value:)`. (3) Layout đọc qua `subview[MyKey.self]`. Ứng dụng: column span (item chiếm 2-3 cột trong grid), weight (phân chia tỷ trọng như Flutter `Expanded`), priority (item quan trọng xếp trước), pinned flag (sticky items), label role (tự phân biệt label vs value trong form row).

**Chỉ hoạt động trong `Layout` protocol** — đây là hạn chế quan trọng. `LayoutValueKey` KHÔNG đọc được trong View body hay ViewModifier. `VStack`, `HStack` (built-in) cũng KHÔNG đọc custom keys. Chỉ khi viết custom Layout mới truy cập `subview[Key.self]`. Nếu cần truyền data trong View hierarchy thông thường → dùng `PreferenceKey` (child → parent) hoặc `Environment` (parent → child) thay thế.
