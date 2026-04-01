# SwiftUI: Drag and Drop — Giải thích chi tiết

## 1. Tổng quan — Hai thế hệ API

```
iOS 13–15:  onDrag { } + onDrop(of:delegate:)
            Dùng NSItemProvider (Objective-C bridge, async phức tạp)

iOS 16+:    .draggable() + .dropDestination(for:)
            Dùng Transferable protocol (Swift-native, đơn giản hơn nhiều)
```

Bài viết tập trung **iOS 16+ API** (Transferable-based) — đơn giản, type-safe, và là hướng Apple khuyến khích.

---

## 2. `Transferable` Protocol — Nền tảng của Drag & Drop

`Transferable` định nghĩa **cách data được serialize/deserialize** khi kéo thả giữa các views, apps, hoặc ra ngoài hệ thống.

### Built-in Transferable types

```swift
// Các type đã conform sẵn:
String          // text
URL             // link
Data            // raw bytes
AttributedString
Image           // SwiftUI Image (iOS 17+)
Color           // SwiftUI Color
```

### Custom Transferable

```swift
struct TodoItem: Identifiable, Codable, Transferable {
    let id: UUID
    var title: String
    var isDone: Bool
    
    // Khai báo cách transfer
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
        // ↑ Serialize thành JSON khi drag
        //   Deserialize từ JSON khi drop
    }
}
```

### Nhiều representations — Ưu tiên từ trên xuống

```swift
struct Photo: Transferable {
    var image: UIImage
    var caption: String
    
    static var transferRepresentation: some TransferRepresentation {
        // Ưu tiên 1: transfer full Photo object (Codable)
        CodableRepresentation(contentType: .photo)
        
        // Ưu tiên 2: fallback thành plain image data
        DataRepresentation(exportedContentType: .png) { photo in
            photo.image.pngData() ?? Data()
        }
        
        // Ưu tiên 3: fallback thành text (caption)
        ProxyRepresentation(exporting: \.caption)
    }
}
```

### Transfer Representation types

```swift
// CodableRepresentation — cho Codable types
CodableRepresentation(contentType: .json)

// DataRepresentation — export/import raw Data
DataRepresentation(exportedContentType: .png) { item in
    // convert item → Data
}
DataRepresentation(importedContentType: .png) { data in
    // convert Data → item
}

// FileRepresentation — transfer files
FileRepresentation(exportedContentType: .pdf) { item in
    SentTransferredFile(item.fileURL)
}

// ProxyRepresentation — delegate sang type khác đã Transferable
ProxyRepresentation(exporting: \.title)  // String property
```

---

## 3. `.draggable()` — Làm view có thể kéo

### Cú pháp cơ bản

```swift
Text("Drag me")
    .draggable("Hello World")
    //          ↑ Transferable value — data được kéo đi
```

### Với custom type

```swift
struct TaskRow: View {
    let task: TodoItem   // TodoItem: Transferable
    
    var body: some View {
        HStack {
            Text(task.title)
            Spacer()
        }
        .padding()
        .draggable(task)
        //         ↑ kéo cả TodoItem object
    }
}
```

### Custom drag preview

```swift
Text(item.title)
    .draggable(item) {
        // Custom preview khi đang kéo
        HStack {
            Image(systemName: "doc")
            Text(item.title)
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
```

```
Không custom preview:           Custom preview:
┌─────────────┐                 ┌────────────────┐
│ Drag me     │ ← snapshot      │ 📄 Drag me     │ ← custom view
│             │   của view gốc  └────────────────┘   nhỏ gọn hơn
└─────────────┘
```

---

## 4. `.dropDestination(for:)` — Nhận data được thả vào

### Cú pháp cơ bản

```swift
Rectangle()
    .fill(.gray.opacity(0.2))
    .frame(height: 200)
    .dropDestination(for: String.self) { items, location in
        //                  ↑ Type data chấp nhận
        //                               ↑ [String]: mảng items drop
        //                                        ↑ CGPoint: vị trí drop
        for item in items {
            print("Dropped: \(item) at \(location)")
        }
        return true    // true = drop thành công, false = reject
    }
```

### isTargeted — Highlight khi đang hover

```swift
@State private var isTargeted = false

Rectangle()
    .fill(isTargeted ? .blue.opacity(0.3) : .gray.opacity(0.1))
    //     ↑ đổi màu khi drag item hover lên
    .dropDestination(for: TodoItem.self) { items, location in
        handleDrop(items)
        return true
    } isTargeted: { targeted in
        withAnimation { isTargeted = targeted }
        //              ↑ true khi drag hover, false khi rời
    }
```

```
Không hover:              Đang hover:                  Dropped:
┌──────────────────┐     ┌──────────────────┐        ┌──────────────────┐
│                  │     │ ████████████████ │        │ Item added!      │
│   Drop here      │     │ ██ Drop here ██ │        │                  │
│                  │     │ ████████████████ │        │                  │
└──────────────────┘     └──────────────────┘        └──────────────────┘
  gray                     blue highlight              normal + data
```

---

## 5. Ứng dụng thực tế

### 5.1 Reorder List items bằng drag & drop

```swift
struct ReorderableList: View {
    @State private var items = ["Apple", "Banana", "Cherry", "Date", "Elderberry"]
    
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .draggable(item)
                    // ↑ Mỗi row có thể kéo
            }
            .onMove { from, to in
                items.move(fromOffsets: from, toOffset: to)
            }
        }
    }
}
```

**Lưu ý:** `List` + `ForEach` + `.onMove` là cách **đơn giản nhất** cho reorder. `.draggable()` + `.dropDestination()` cần thiết khi muốn drag **giữa các container khác nhau**.

### 5.2 Kanban Board — Drag giữa columns

```swift
struct Task: Identifiable, Codable, Transferable, Equatable {
    let id: UUID
    var title: String
    var status: Status
    
    enum Status: String, Codable, CaseIterable {
        case todo, inProgress, done
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

struct KanbanBoard: View {
    @State private var tasks: [Task] = sampleTasks
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ForEach(Task.Status.allCases, id: \.self) { status in
                KanbanColumn(
                    status: status,
                    tasks: tasks.filter { $0.status == status },
                    onDrop: { droppedTasks in
                        moveTask(droppedTasks, to: status)
                    }
                )
            }
        }
        .padding()
    }
    
    private func moveTask(_ droppedTasks: [Task], to status: Task.Status) {
        for task in droppedTasks {
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                withAnimation {
                    tasks[index].status = status
                }
            }
        }
    }
}

struct KanbanColumn: View {
    let status: Task.Status
    let tasks: [Task]
    let onDrop: ([Task]) -> Void
    
    @State private var isTargeted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(status.rawValue.capitalized)
                    .font(.headline)
                Spacer()
                Text("\(tasks.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Cards
            VStack(spacing: 8) {
                ForEach(tasks) { task in
                    TaskCard(task: task)
                        .draggable(task)
                    //  ↑ Card có thể kéo
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 200, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isTargeted ? .blue.opacity(0.1) : .gray.opacity(0.05))
        )
        .dropDestination(for: Task.self) { droppedTasks, _ in
            onDrop(droppedTasks)
            return true
        } isTargeted: { targeted in
            withAnimation(.easeInOut(duration: 0.2)) {
                isTargeted = targeted
            }
        }
    }
}

struct TaskCard: View {
    let task: Task
    
    var body: some View {
        Text(task.title)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}
```

```
┌─── Todo ────────┬─── In Progress ──┬─── Done ─────────┐
│                 │                  │                   │
│ ┌─────────────┐ │ ┌──────────────┐ │ ┌───────────────┐ │
│ │ Design UI   │←drag──→ Design UI│ │ │ Setup project │ │
│ └─────────────┘ │ └──────────────┘ │ └───────────────┘ │
│ ┌─────────────┐ │                  │                   │
│ │ Write tests │ │                  │                   │
│ └─────────────┘ │                  │                   │
└─────────────────┴──────────────────┴───────────────────┘
```

### 5.3 Drop zone — Nhận ảnh từ Photos app

```swift
struct ImageDropZone: View {
    @State private var droppedImages: [Image] = []
    @State private var isTargeted = false
    
    var body: some View {
        VStack {
            if droppedImages.isEmpty {
                // Drop zone placeholder
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                    )
                    .foregroundStyle(isTargeted ? .blue : .gray)
                    .frame(height: 200)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                            Text("Drop images here")
                        }
                        .foregroundStyle(isTargeted ? .blue : .secondary)
                    }
                    .dropDestination(for: Data.self) { items, _ in
                        for data in items {
                            if let uiImage = UIImage(data: data) {
                                droppedImages.append(Image(uiImage: uiImage))
                            }
                        }
                        return !items.isEmpty
                    } isTargeted: { targeted in
                        withAnimation { isTargeted = targeted }
                    }
            } else {
                // Show dropped images
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(droppedImages.indices, id: \.self) { index in
                            droppedImages[index]
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
    }
}
```

### 5.4 Drag text giữa TextFields

```swift
struct DragTextView: View {
    @State private var sourceText = "Drag this text"
    @State private var destinationText = ""
    
    var body: some View {
        VStack(spacing: 40) {
            // Source
            Text(sourceText)
                .padding()
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .draggable(sourceText)
            
            // Destination
            VStack(alignment: .leading) {
                Text("Drop zone:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(destinationText.isEmpty ? "Drop text here..." : destinationText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .dropDestination(for: String.self) { items, _ in
                        destinationText = items.joined(separator: "\n")
                        return true
                    }
            }
        }
        .padding()
    }
}
```

### 5.5 Bucket sort — Drag items vào categories

```swift
struct Fruit: Identifiable, Codable, Transferable {
    let id: UUID
    let name: String
    let emoji: String
    var category: String?
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

struct BucketSortGame: View {
    @State private var fruits: [Fruit] = [
        Fruit(id: UUID(), name: "Apple", emoji: "🍎", category: nil),
        Fruit(id: UUID(), name: "Banana", emoji: "🍌", category: nil),
        Fruit(id: UUID(), name: "Carrot", emoji: "🥕", category: nil),
        Fruit(id: UUID(), name: "Broccoli", emoji: "🥦", category: nil),
    ]
    
    let buckets = ["Fruits", "Vegetables"]
    
    var body: some View {
        VStack(spacing: 24) {
            // Unsorted items
            Text("Drag items to correct bucket").font(.headline)
            
            HStack(spacing: 12) {
                ForEach(fruits.filter { $0.category == nil }) { fruit in
                    Text("\(fruit.emoji) \(fruit.name)")
                        .padding(10)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(radius: 2)
                        .draggable(fruit)
                }
            }
            
            // Buckets
            HStack(spacing: 16) {
                ForEach(buckets, id: \.self) { bucket in
                    BucketView(
                        name: bucket,
                        items: fruits.filter { $0.category == bucket },
                        onDrop: { droppedFruits in
                            for fruit in droppedFruits {
                                if let index = fruits.firstIndex(where: { $0.id == fruit.id }) {
                                    withAnimation { fruits[index].category = bucket }
                                }
                            }
                        }
                    )
                }
            }
        }
        .padding()
    }
}

struct BucketView: View {
    let name: String
    let items: [Fruit]
    let onDrop: ([Fruit]) -> Void
    @State private var isTargeted = false
    
    var body: some View {
        VStack {
            Text(name).font(.title3.bold())
            
            VStack(spacing: 4) {
                ForEach(items) { item in
                    Text("\(item.emoji) \(item.name)")
                        .font(.callout)
                }
                
                if items.isEmpty {
                    Text("Drop here")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isTargeted ? .green.opacity(0.15) : .gray.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isTargeted ? .green : .clear, lineWidth: 2)
            )
        }
        .dropDestination(for: Fruit.self) { droppedFruits, _ in
            onDrop(droppedFruits)
            return true
        } isTargeted: { targeted in
            withAnimation { isTargeted = targeted }
        }
    }
}
```

---

## 6. Legacy API — `onDrag` / `onDrop` (iOS 13+)

Dùng khi cần hỗ trợ iOS 13–15 hoặc cần **NSItemProvider** cho inter-app drag:

### onDrag

```swift
Text("Drag me")
    .onDrag {
        // Trả về NSItemProvider
        NSItemProvider(object: "Hello World" as NSString)
    }
```

### onDrop

```swift
Rectangle()
    .onDrop(of: [.text], isTargeted: $isTargeted) { providers in
        // providers: [NSItemProvider]
        for provider in providers {
            provider.loadObject(ofClass: NSString.self) { string, error in
                if let string = string as? String {
                    DispatchQueue.main.async {
                        self.droppedText = string
                    }
                }
            }
        }
        return true
    }
```

### onDrop with delegate — Kiểm soát chi tiết

```swift
struct MyDropDelegate: DropDelegate {
    @Binding var items: [Item]
    let targetItem: Item
    
    // Khi drag vào vùng drop
    func dropEntered(info: DropInfo) {
        // Reorder logic
        guard let fromIndex = items.firstIndex(of: draggedItem),
              let toIndex = items.firstIndex(of: targetItem),
              fromIndex != toIndex else { return }
        
        withAnimation {
            items.move(fromOffsets: IndexSet(integer: fromIndex),
                      toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }
    
    // Validate drop
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.text])
    }
    
    // Thực hiện drop
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    // Khi drag rời vùng drop
    func dropExited(info: DropInfo) { }
    
    // Update khi drag di chuyển trong vùng
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

// Sử dụng
ForEach(items) { item in
    ItemRow(item: item)
        .onDrag { NSItemProvider(object: item.id.uuidString as NSString) }
        .onDrop(of: [.text], delegate: MyDropDelegate(items: $items, targetItem: item))
}
```

---

## 7. Reorder trong List/ForEach — Cách đơn giản nhất

### EditMode + onMove (không cần drag API)

```swift
struct SimpleReorder: View {
    @State private var items = ["First", "Second", "Third", "Fourth", "Fifth"]
    @State private var editMode: EditMode = .active
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                .onMove { from, to in
                    items.move(fromOffsets: from, toOffset: to)
                }
                .onDelete { offsets in
                    items.remove(atOffsets: offsets)
                }
            }
            .environment(\.editMode, $editMode)
            .toolbar {
                EditButton()
            }
        }
    }
}
```

### iOS 16+: Reorder bằng .draggable + .dropDestination

```swift
struct DraggableList: View {
    @State private var items = (1...10).map { "Item \($0)" }
    @State private var draggingItem: String?
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(draggingItem == item ? .blue.opacity(0.2) : .gray.opacity(0.1))
                    )
                    .draggable(item) {
                        // Preview
                        Text(item)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onAppear { draggingItem = item }
                    }
                    .dropDestination(for: String.self) { droppedItems, _ in
                        guard let droppedItem = droppedItems.first,
                              let fromIndex = items.firstIndex(of: droppedItem),
                              let toIndex = items.firstIndex(of: item),
                              fromIndex != toIndex else { return false }
                        
                        withAnimation(.spring(duration: 0.3)) {
                            items.move(fromOffsets: IndexSet(integer: fromIndex),
                                      toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                        }
                        return true
                    } isTargeted: { targeted in
                        if !targeted { draggingItem = nil }
                    }
            }
        }
        .padding()
    }
}
```

---

## 8. Spring-loaded destinations (iOS 17+)

```swift
// Folder tự mở khi hover đủ lâu
FolderView(folder: folder)
    .dropDestination(for: FileItem.self) { items, _ in
        moveFiles(items, to: folder)
        return true
    }
    .springLoadedDestination(isEnabled: true) {
        // Action khi hover đủ lâu (spring-loaded)
        // Ví dụ: mở folder, expand section
        navigateToFolder(folder)
    }
```

---

## 9. Cross-app Drag & Drop (iPad multitasking)

```swift
// App A: Drag text ra ngoài
Text("Share this text")
    .draggable("Text to share with other apps")

// App B: Nhận text từ app khác
TextEditor(text: $content)
    .dropDestination(for: String.self) { items, _ in
        content += items.joined(separator: "\n")
        return true
    }
```

`Transferable` tự động handle inter-app transfer qua system pasteboard — không cần code thêm. Data được serialize/deserialize theo `TransferRepresentation` đã khai báo.

### UTType cho inter-app compatibility

```swift
import UniformTypeIdentifiers

// Custom UTType
extension UTType {
    static let todoItem = UTType(exportedAs: "com.myapp.todoitem")
}

struct TodoItem: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .todoItem)
        // ↑ Custom UTType → chỉ app biết type này mới drop được
        
        ProxyRepresentation(exporting: \.title)
        // ↑ Fallback: export thành String → app khác nhận được text
    }
}
```

---

## 10. Sai lầm thường gặp

### ❌ Quên conform Transferable

```swift
struct Item: Identifiable {
    let id: UUID
    var name: String
}

Text(item.name)
    .draggable(item)    // ❌ Error: Item does not conform to Transferable

// ✅ Conform Transferable
struct Item: Identifiable, Codable, Transferable {
    let id: UUID
    var name: String
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}
```

### ❌ Drop type không khớp drag type

```swift
// Drag String
Text("Hello").draggable("Hello")

// ❌ Drop nhận Int → không nhận được
Rectangle().dropDestination(for: Int.self) { items, _ in
    // items luôn rỗng vì type không khớp
    return false
}

// ✅ Drop nhận String → khớp
Rectangle().dropDestination(for: String.self) { items, _ in
    print(items)    // ["Hello"]
    return true
}
```

### ❌ Quên return true trong drop handler

```swift
.dropDestination(for: String.self) { items, _ in
    processItems(items)
    // ❌ Quên return → mặc định false → system hiện "cancel" animation
    
    return true    // ✅ Báo system: drop thành công
}
```

### ❌ Drag trong ScrollView — conflict gesture

```swift
// ⚠️ Drag gesture có thể conflict với scroll gesture
ScrollView {
    ForEach(items) { item in
        ItemRow(item: item)
            .draggable(item)
            // Trên iPhone: long press để bắt đầu drag (tránh conflict scroll)
            // Trên iPad: drag ngay (vì có thể dùng pencil/trackpad)
    }
}
// SwiftUI tự xử lý gesture priority, nhưng UX có thể cần tuning
```

### ❌ Modify source data trong drag handler

```swift
// ❌ Xoá item ngay khi bắt đầu drag → item biến mất trước khi drop
.draggable(item) {
    items.removeAll { $0.id == item.id }    // ❌ quá sớm
    return preview
}

// ✅ Xoá item SAU KHI drop thành công
.dropDestination(for: Item.self) { droppedItems, _ in
    // Thêm vào destination
    targetItems.append(contentsOf: droppedItems)
    // Xoá khỏi source
    sourceItems.removeAll { item in droppedItems.contains { $0.id == item.id } }
    return true
}
```

---

## 11. Platform Behavior

```
             iPhone          iPad              macOS
             ──────          ────              ─────
Trigger      Long press      Long press /      Click + drag
                             Pencil drag
Inter-app    ❌ Single app    ✅ Split View      ✅ Window drag
Spring-load  ❌              ✅ (iOS 17+)       ✅
Multi-item   Hạn chế         ✅                 ✅
Preview      System default  Customizable       Customizable
```

---

## 12. Tóm tắt

| Concept | Vai trò |
|---|---|
| **Transferable** | Protocol định nghĩa cách data serialize/deserialize cho drag & drop |
| **TransferRepresentation** | Khai báo format: Codable, Data, File, Proxy |
| **.draggable()** | Modifier làm view có thể kéo — truyền Transferable value |
| **.dropDestination(for:)** | Modifier nhận data thả vào — specify type chấp nhận |
| **isTargeted** | Bool callback khi drag hover — dùng highlight drop zone |
| **Custom preview** | Trailing closure trong .draggable — custom drag preview |
| **onDrag/onDrop** | Legacy API (iOS 13+) — dùng NSItemProvider |
| **DropDelegate** | Legacy protocol — kiểm soát chi tiết (enter, update, exit, perform) |

| Dùng khi | API |
|---|---|
| Reorder trong List | `.onMove` + `EditButton` (đơn giản nhất) |
| Drag giữa containers | `.draggable()` + `.dropDestination()` |
| Drag giữa apps (iPad) | Transferable + UTType |
| Hỗ trợ iOS 13–15 | `onDrag` + `onDrop` + NSItemProvider |
| Reorder phức tạp | `DropDelegate` (legacy) hoặc custom logic |

---

Drag & Drop trong SwiftUI có hai thế hệ API, Huy. Ba điểm cốt lõi:

**`Transferable` protocol là nền tảng (iOS 16+).** Mọi data muốn drag/drop phải conform `Transferable` — khai báo `TransferRepresentation` để SwiftUI biết cách serialize/deserialize. Built-in types (String, URL, Data) đã conform sẵn. Custom types thường dùng `CodableRepresentation(contentType: .json)`. Có thể khai báo nhiều representations theo thứ tự ưu tiên (Codable → Data → Proxy) để tương thích với nhiều drop targets.

**`.draggable(value)` + `.dropDestination(for:)` — cặp API cốt lõi.** `.draggable()` gắn lên view nguồn, truyền Transferable value. `.dropDestination(for: Type.self)` gắn lên vùng đích, chỉ định type chấp nhận + closure xử lý. `isTargeted` callback cho biết drag đang hover → dùng highlight drop zone. **Type phải khớp**: drag String nhưng drop nhận Int → không nhận được gì.

**Reorder list thì KHÔNG cần drag API phức tạp.** `List` + `ForEach` + `.onMove` + `EditButton` là cách đơn giản nhất. `.draggable()` + `.dropDestination()` chỉ cần thiết khi drag **giữa các container khác nhau** (Kanban columns, bucket sort, cross-section). Cho inter-app drag trên iPad, `Transferable` tự động handle qua system pasteboard — khai báo `UTType` custom nếu muốn chỉ app mình nhận được.
