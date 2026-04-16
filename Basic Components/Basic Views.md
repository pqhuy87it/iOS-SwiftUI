# SwiftUI: Basic Views — Giải thích chi tiết

## Phân loại tổng thể

```
Basic Views
│
├── 1. Text & Label        — Hiển thị văn bản
├── 2. Image               — Hiển thị hình ảnh
├── 3. Button & Link       — Tương tác tap
├── 4. TextField & Editor  — Nhập văn bản
├── 5. Toggle              — Bật/Tắt
├── 6. Picker              — Chọn từ danh sách
├── 7. Slider & Stepper    — Chọn giá trị số
├── 8. ProgressView        — Tiến trình
├── 9. Shape               — Hình dạng cơ bản
├── 10. Color & Gradient   — Màu sắc
├── 11. Divider & Spacer   — Phân cách & Đẩy
└── 12. Container helpers  — Group, ForEach, EmptyView
```

---

## 1. `Text` — Hiển thị văn bản

### Cơ bản

```swift
Text("Hello, World!")

Text(verbatim: "Hello \(name)")   // không interpret markdown/localization
```

`Text` là **hugging** — chỉ lấy đúng kích thước nội dung cần, không mở rộng.

### Styling

```swift
Text("Styled Text")
    .font(.title)                    // system font
    .font(.system(size: 24, weight: .bold, design: .rounded))
    .fontWeight(.semibold)
    .italic()
    .bold()
    .underline(color: .blue)
    .strikethrough()
    .foregroundStyle(.blue)
    .foregroundStyle(.linearGradient(
        colors: [.blue, .purple],
        startPoint: .leading,
        endPoint: .trailing
    ))
```

### Font system

```swift
// Dynamic Type — tự scale theo user settings
.font(.largeTitle)     // 34pt
.font(.title)          // 28pt
.font(.title2)         // 22pt
.font(.title3)         // 20pt
.font(.headline)       // 17pt semibold
.font(.body)           // 17pt (default)
.font(.callout)        // 16pt
.font(.subheadline)    // 15pt
.font(.footnote)       // 13pt
.font(.caption)        // 12pt
.font(.caption2)       // 11pt

// Custom font
.font(.custom("Avenir-Heavy", size: 20))
.font(.custom("Avenir", size: 16, relativeTo: .body))
//                                         ↑ scale theo Dynamic Type
```

### Multi-line & Truncation

```swift
Text("Very long text that might need multiple lines or truncation")
    .lineLimit(2)                     // tối đa 2 dòng
    .lineLimit(1...5)                 // iOS 16+: linh hoạt 1-5 dòng
    .multilineTextAlignment(.center)  // căn giữa multi-line
    .truncationMode(.tail)            // "..." ở cuối
    .truncationMode(.middle)          // "Very...truncation"
    .minimumScaleFactor(0.5)          // thu nhỏ font đến 50% trước khi truncate
```

### String Interpolation nâng cao

```swift
// Kết hợp styles khác nhau trong 1 Text
Text("Hello ") + Text("World").bold() + Text("!").foregroundStyle(.red)
// "Hello " (normal) + "World" (bold) + "!" (red)

// Date formatting
Text(Date(), style: .date)           // "March 29, 2026"
Text(Date(), style: .time)           // "2:30 PM"
Text(Date(), style: .relative)       // "2 hours ago"
Text(Date(), style: .timer)          // "1:23:45" (live counting)
Text(Date()...Date().addingTimeInterval(3600), style: .timer) // countdown

// Number formatting
Text(42.5, format: .number.precision(.fractionLength(1)))  // "42.5"
Text(0.85, format: .percent)                                // "85%"
Text(1299, format: .currency(code: "USD"))                  // "$1,299.00"
```

### Markdown support (iOS 15+)

```swift
Text("**Bold**, *italic*, ~~strikethrough~~, `code`")
// Renders markdown tự động

Text("[Link](https://apple.com)")
// Clickable link

// Attributed string
Text(AttributedString("Custom styling with AttributedString"))
```

### Selectable text (iOS 15+)

```swift
Text("You can select this text")
    .textSelection(.enabled)
// User có thể long-press để copy
```

---

## 2. `Label` — Icon + Text

```swift
Label("Favorites", systemImage: "heart.fill")
// ★ Favorites

Label("Document", image: "custom-icon")
// Custom image + text

Label {
    Text("Custom Label")
        .font(.headline)
} icon: {
    Circle()
        .fill(.blue)
        .frame(width: 20, height: 20)
}
```

### Label styles

```swift
Label("Title", systemImage: "star")
    .labelStyle(.automatic)        // icon + title (default)
    .labelStyle(.titleOnly)        // chỉ title
    .labelStyle(.iconOnly)         // chỉ icon
    .labelStyle(.titleAndIcon)     // cả hai (tường minh)
```

`Label` là view chuẩn cho menu items, list rows, tab items — tự adapt theo context (sidebar hiện icon+text, toolbar có thể chỉ icon).

---

## 3. `Image` — Hiển thị hình ảnh

### SF Symbols (system images)

```swift
Image(systemName: "heart.fill")
    .font(.title)                    // size theo font
    .foregroundStyle(.red)
    .symbolEffect(.bounce)          // iOS 17+ animation

// Multi-color SF Symbols
Image(systemName: "cloud.sun.rain.fill")
    .symbolRenderingMode(.multicolor)  // màu gốc của symbol
    .symbolRenderingMode(.hierarchical) // hierarchical opacity
    .symbolRenderingMode(.palette)      // custom palette
    .foregroundStyle(.blue, .yellow)    // palette colors

// Variable value (iOS 16+)
Image(systemName: "speaker.wave.3.fill", variableValue: 0.7)
// Volume icon hiển thị 70%
```

### Asset images

```swift
Image("photo")                       // từ Asset Catalog
Image("photo", bundle: .module)      // từ SPM module

// Resizable — BẮT BUỘC trước khi resize
Image("photo")
    .resizable()                     // cho phép resize
    .scaledToFit()                   // giữ tỷ lệ, vừa frame
    .scaledToFill()                  // giữ tỷ lệ, phủ đầy frame
    .frame(width: 200, height: 150)
    .clipped()                       // cắt phần tràn (với scaledToFill)
    .clipShape(RoundedRectangle(cornerRadius: 12))
```

**Lưu ý: `.resizable()` BẮT BUỘC trước frame.** Không có nó → Image hiển thị kích thước gốc, bỏ qua frame.

### AsyncImage (iOS 15+) — Load ảnh từ URL

```swift
AsyncImage(url: URL(string: "https://example.com/photo.jpg")) { phase in
    switch phase {
    case .empty:
        ProgressView()
    case .success(let image):
        image
            .resizable()
            .scaledToFill()
    case .failure:
        Image(systemName: "photo")
            .foregroundStyle(.gray)
    @unknown default:
        EmptyView()
    }
}
.frame(width: 200, height: 200)
.clipShape(RoundedRectangle(cornerRadius: 12))

// Phiên bản ngắn gọn
AsyncImage(url: url) { image in
    image.resizable().scaledToFit()
} placeholder: {
    ProgressView()
}
```

---

## 4. `Button` — Tương tác tap

### Cơ bản

```swift
Button("Tap Me") {
    print("Tapped!")
}

Button {
    performAction()
} label: {
    // Custom label — bất kỳ View nào
    HStack {
        Image(systemName: "plus")
        Text("Add Item")
    }
    .padding()
    .background(.blue)
    .foregroundStyle(.white)
    .clipShape(Capsule())
}
```

### Button roles (iOS 15+)

```swift
Button("Delete", role: .destructive) {
    deleteItem()
}
// Tự động đỏ trong alert, swipe actions

Button("Cancel", role: .cancel) {
    dismiss()
}
```

### Button styles

```swift
Button("Style") { }
    .buttonStyle(.automatic)       // platform default
    .buttonStyle(.plain)           // không highlight
    .buttonStyle(.bordered)        // viền nhẹ
    .buttonStyle(.borderedProminent) // nền accent color
    .buttonStyle(.borderless)      // không viền
```

### Custom ButtonStyle

```swift
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

Button("Animated") { }
    .buttonStyle(ScaleButtonStyle())
```

### Link — Mở URL

```swift
Link("Visit Apple", destination: URL(string: "https://apple.com")!)

Link(destination: URL(string: "https://apple.com")!) {
    Label("Website", systemImage: "globe")
}
```

### ShareLink (iOS 16+)

```swift
ShareLink(item: URL(string: "https://example.com")!) {
    Label("Share", systemImage: "square.and.arrow.up")
}

ShareLink(item: image, preview: SharePreview("Photo", image: image))
```

---

## 5. `TextField` & `TextEditor` — Nhập văn bản

### TextField — Một dòng

```swift
@State private var name = ""

TextField("Enter name", text: $name)
    .textFieldStyle(.roundedBorder)    // viền bo góc
    .textFieldStyle(.plain)            // không viền
    .textContentType(.name)            // autofill suggestion
    .keyboardType(.emailAddress)       // loại keyboard
    .textInputAutocapitalization(.never)
    .autocorrectionDisabled()
    .submitLabel(.next)                // nút Return hiện "Next"
    .onSubmit { focusNext() }          // action khi nhấn Return
```

### Keyboard types

```swift
.keyboardType(.default)            // chữ + số
.keyboardType(.emailAddress)       // có @ và .
.keyboardType(.numberPad)          // chỉ số (không Return)
.keyboardType(.decimalPad)         // số + dấu chấm
.keyboardType(.phonePad)           // số điện thoại
.keyboardType(.URL)                // URL
.keyboardType(.asciiCapable)       // ASCII only
```

### Text content types — Autofill

```swift
.textContentType(.name)
.textContentType(.emailAddress)
.textContentType(.password)
.textContentType(.newPassword)     // tạo password mới → suggest strong password
.textContentType(.oneTimeCode)     // OTP từ SMS
.textContentType(.telephoneNumber)
.textContentType(.addressCity)
.textContentType(.creditCardNumber)
```

### SecureField — Nhập password

```swift
SecureField("Password", text: $password)
    .textContentType(.password)
// Hiển thị ••••••, có toggle show/hide trên iOS 15+
```

### TextField với format (iOS 15+)

```swift
// Tự động format number
TextField("Amount", value: $amount, format: .currency(code: "USD"))
// User gõ "1234" → hiển thị "$1,234.00"

TextField("Quantity", value: $quantity, format: .number)
// Chỉ nhận số

TextField("Date", value: $date, format: .dateTime.day().month().year())
```

### TextEditor — Nhiều dòng

```swift
@State private var bio = ""

TextEditor(text: $bio)
    .frame(minHeight: 100, maxHeight: 300)
    .scrollContentBackground(.hidden)  // iOS 16+: bỏ background mặc định
    .background(Color.gray.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 8))

// TextField multiline (iOS 16+) — thay thế TextEditor đơn giản
TextField("Bio", text: $bio, axis: .vertical)
    .lineLimit(3...6)
//              ↑ expand từ 3 đến 6 dòng
```

---

## 6. `Toggle` — Bật/Tắt

```swift
@State private var isEnabled = false

Toggle("Dark Mode", isOn: $isEnabled)

Toggle(isOn: $isEnabled) {
    Label("Notifications", systemImage: "bell.fill")
}

// Toggle styles
Toggle("WiFi", isOn: $wifi)
    .toggleStyle(.automatic)    // switch (iOS), checkbox (macOS)
    .toggleStyle(.switch)       // switch
    .toggleStyle(.button)       // button that toggles
    .tint(.green)               // custom on-color
```

---

## 7. `Picker` — Chọn từ danh sách

### Cơ bản

```swift
enum Flavor: String, CaseIterable, Identifiable {
    case chocolate, vanilla, strawberry
    var id: Self { self }
}

@State private var selectedFlavor: Flavor = .chocolate

Picker("Flavor", selection: $selectedFlavor) {
    ForEach(Flavor.allCases) { flavor in
        Text(flavor.rawValue.capitalized).tag(flavor)
    }
}
```

### Picker styles

```swift
// Segmented control
Picker("Filter", selection: $filter) { ... }
    .pickerStyle(.segmented)

// Inline (trong List)
    .pickerStyle(.inline)

// Menu dropdown
    .pickerStyle(.menu)

// Navigation link (push to selection list)
    .pickerStyle(.navigationLink)

// Wheel
    .pickerStyle(.wheel)

// iOS 17+ Palette
    .pickerStyle(.palette)
```

### DatePicker

```swift
@State private var date = Date()

DatePicker("Birthday", selection: $date, displayedComponents: .date)
DatePicker("Alarm", selection: $date, displayedComponents: .hourAndMinute)
DatePicker("Event", selection: $date,
           in: Date()...,              // chỉ tương lai
           displayedComponents: [.date, .hourAndMinute])

// Styles
    .datePickerStyle(.automatic)
    .datePickerStyle(.compact)       // inline nhỏ gọn
    .datePickerStyle(.graphical)     // calendar view
    .datePickerStyle(.wheel)         // wheel picker
```

### ColorPicker

```swift
@State private var color = Color.blue

ColorPicker("Theme Color", selection: $color)
ColorPicker("Background", selection: $color, supportsOpacity: false)
// supportsOpacity: false → không cho chọn transparency
```

---

## 8. `Slider` & `Stepper` — Chọn giá trị số

### Slider

```swift
@State private var volume: Double = 50

Slider(value: $volume, in: 0...100)

Slider(value: $volume, in: 0...100, step: 5) {
    Text("Volume")         // label (ẩn trên iOS)
} minimumValueLabel: {
    Image(systemName: "speaker")
} maximumValueLabel: {
    Image(systemName: "speaker.wave.3.fill")
} onEditingChanged: { isEditing in
    if !isEditing { saveVolume() }
}
```

### Stepper

```swift
@State private var quantity = 1

Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)

Stepper("Custom") {
    quantity += 1       // increment
} onDecrement: {
    quantity -= 1       // decrement
}

Stepper(value: $quantity, in: 1...99, step: 5) {
    Text("Quantity: \(quantity)")
}
```

---

## 9. `ProgressView` — Tiến trình

### Indeterminate (không biết % hoàn thành)

```swift
ProgressView()                       // spinner mặc định
ProgressView("Loading...")           // spinner + label
```

### Determinate (biết % hoàn thành)

```swift
ProgressView(value: 0.7)            // 70% thanh ngang
ProgressView(value: 35, total: 100) // 35/100

ProgressView(value: progress) {
    Text("Downloading")
} currentValueLabel: {
    Text("\(Int(progress * 100))%")
}
```

### Styles

```swift
ProgressView()
    .progressViewStyle(.automatic)
    .progressViewStyle(.circular)     // spinner tròn
    .progressViewStyle(.linear)       // thanh ngang
    .tint(.blue)
    .scaleEffect(2.0)                 // phóng to spinner
```

---

## 10. `Shape` — Hình dạng cơ bản

### Built-in Shapes

```swift
Rectangle()
RoundedRectangle(cornerRadius: 12)
RoundedRectangle(cornerRadius: 12, style: .continuous) // smooth corners
Circle()
Ellipse()
Capsule()
UnevenRoundedRectangle(         // iOS 17+: bo góc khác nhau
    topLeadingRadius: 20,
    bottomLeadingRadius: 0,
    bottomTrailingRadius: 0,
    topTrailingRadius: 20
)
```

### Shape modifiers

```swift
Circle()
    .fill(.blue)                      // tô đầy
    .stroke(.red, lineWidth: 3)       // chỉ viền
    .strokeBorder(.red, lineWidth: 3) // viền nằm TRONG bounds
    .frame(width: 100, height: 100)

// fill + stroke cùng lúc (iOS 17+)
Circle()
    .fill(.blue)
    .stroke(.white, lineWidth: 3)

// Trước iOS 17: dùng overlay
Circle()
    .fill(.blue)
    .overlay(Circle().stroke(.white, lineWidth: 3))
```

### Dùng Shape làm clip/mask

```swift
Image("photo")
    .clipShape(Circle())              // cắt thành tròn

Image("photo")
    .clipShape(RoundedRectangle(cornerRadius: 20))

Text("Hello")
    .padding()
    .background(Capsule().fill(.blue))
```

### Custom Shape

```swift
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

Triangle()
    .fill(.orange)
    .frame(width: 100, height: 100)
```

---

## 11. `Color` & `Gradient`

### Color

```swift
Color.blue                           // system blue
Color.primary                        // adaptive (black/white)
Color.secondary                      // adaptive gray
Color(.systemBackground)             // UIColor bridge
Color(red: 0.2, green: 0.5, blue: 0.9)
Color(hex: 0xFF5733)                  // cần extension
Color("BrandColor")                   // từ Asset Catalog
```

`Color` là **expanding** view — mở rộng hết không gian có sẵn:

```swift
Color.blue                           // phủ toàn bộ parent
Color.blue.frame(width: 100, height: 50)  // giới hạn
```

### Gradient

```swift
// Linear
LinearGradient(
    colors: [.blue, .purple],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

// Radial
RadialGradient(
    colors: [.yellow, .red],
    center: .center,
    startRadius: 0,
    endRadius: 200
)

// Angular
AngularGradient(
    colors: [.red, .yellow, .green, .blue, .purple, .red],
    center: .center
)

// Mesh Gradient (iOS 18+)
MeshGradient(
    width: 3, height: 3,
    points: [...],
    colors: [...]
)

// Dùng làm foreground
Text("Gradient Text")
    .font(.largeTitle.bold())
    .foregroundStyle(
        .linearGradient(colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing)
    )
```

### Material (blur backgrounds)

```swift
Text("Over Image")
    .padding()
    .background(.ultraThinMaterial)   // blur rất nhẹ
    .background(.thinMaterial)        // blur nhẹ
    .background(.regularMaterial)     // blur trung bình
    .background(.thickMaterial)       // blur đậm
    .background(.ultraThickMaterial)  // blur rất đậm
```

---

## 12. `Divider` & `Spacer`

### Divider

```swift
// Trong VStack → đường ngang
VStack {
    Text("Above")
    Divider()        // ────────────────
    Text("Below")
}

// Trong HStack → đường dọc
HStack {
    Text("Left")
    Divider()        // │
    Text("Right")
}
```

### Spacer

```swift
// Expanding invisible view
HStack {
    Text("Left")
    Spacer()              // đẩy Right sang phải
    Text("Right")
}

HStack {
    Spacer()
    Text("Right-aligned") // đẩy sang phải
}

Spacer(minLength: 20)    // tối thiểu 20pt
Spacer().frame(width: 50) // spacer cố định 50pt (hack, ít dùng)
```

---

## 13. Container Helpers

### Group — Nhóm views không thêm layout

```swift
Group {
    Text("A")
    Text("B")
    Text("C")
}
.font(.title)           // apply cho tất cả children
.foregroundStyle(.blue)

// Dùng khi cần apply modifier cho nhiều view
// hoặc vượt quá 10 children trong ViewBuilder
```

### ForEach — Lặp tạo views

```swift
// Với Identifiable
ForEach(items) { item in
    Text(item.name)
}

// Với id keypath
ForEach(names, id: \.self) { name in
    Text(name)
}

// Với range
ForEach(0..<5) { index in
    Text("Row \(index)")
}
```

### EmptyView — View rỗng, không hiển thị gì

```swift
// Dùng trong conditional
@ViewBuilder
func optionalContent() -> some View {
    if showContent {
        Text("Content")
    } else {
        EmptyView()
    }
}

// Dùng trong generic container
struct Wrapper<Content: View>: View {
    var content: Content = EmptyView() as! Content
    // ...
}
```

### ContentUnavailableView (iOS 17+) — Trạng thái trống

```swift
ContentUnavailableView(
    "No Results",
    systemImage: "magnifyingglass",
    description: Text("Try a different search term")
)

ContentUnavailableView.search            // built-in search empty state
ContentUnavailableView.search(text: query)
```

---

## 14. Ví dụ tổng hợp — Profile Card

```swift
struct ProfileCard: View {
    let user: User
    @State private var isFollowing = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            AsyncImage(url: user.avatarURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.3))
                    .overlay(ProgressView())
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(.white, lineWidth: 3))
            .shadow(radius: 4)
            
            // Info
            VStack(spacing: 4) {
                Text(user.name)
                    .font(.title3.bold())
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Bio
            Text(user.bio)
                .font(.body)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .foregroundStyle(.secondary)
            
            // Stats
            HStack(spacing: 24) {
                VStack {
                    Text("\(user.postCount)")
                        .font(.headline)
                    Text("Posts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider().frame(height: 30)
                
                VStack {
                    Text("\(user.followerCount)")
                        .font(.headline)
                    Text("Followers")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Follow button
            Button {
                isFollowing.toggle()
            } label: {
                Text(isFollowing ? "Following" : "Follow")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isFollowing ? Color.gray.opacity(0.2) : Color.blue)
                    .foregroundStyle(isFollowing ? .primary : .white)
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}
```

---

## 15. Cheat Sheet — Chọn view nào?

```
Hiển thị text?                → Text
Icon + text?                  → Label
Hình ảnh local?               → Image
Hình ảnh URL?                 → AsyncImage
Tap action?                   → Button
Mở URL?                       → Link
Nhập 1 dòng?                  → TextField
Nhập password?                → SecureField
Nhập nhiều dòng?              → TextEditor hoặc TextField(axis: .vertical)
Bật/tắt?                      → Toggle
Chọn 1 từ nhiều?              → Picker
Chọn ngày?                    → DatePicker
Chọn màu?                     → ColorPicker
Giá trị liên tục (âm lượng)?  → Slider
Giá trị rời rạc (số lượng)?   → Stepper
Loading không xác định?       → ProgressView()
Loading xác định %?           → ProgressView(value:)
Hình dạng?                    → Circle, Rectangle, Capsule, custom Shape
Màu nền?                      → Color
Blur background?              → .background(.regularMaterial)
Gradient?                     → LinearGradient, RadialGradient
Đường kẻ?                     → Divider
Đẩy view?                     → Spacer
Trạng thái trống?             → ContentUnavailableView (iOS 17+)
```

----

Đây là toàn bộ basic views trong SwiftUI, Huy. Tóm gọn theo nhóm quan trọng nhất:

**Text & Image** là hai view dùng nhiều nhất. Text hỗ trợ markdown, date/number formatting, string interpolation kết hợp styles (`Text("A") + Text("B").bold()`). Image **bắt buộc `.resizable()`** trước khi set frame — quên là hình hiển thị kích thước gốc bỏ qua frame. `AsyncImage` cho load ảnh từ URL với built-in loading/error states.

**Input views** — `TextField` (1 dòng), `SecureField` (password), `TextEditor` (nhiều dòng). iOS 16+ có `TextField(axis: .vertical)` thay thế TextEditor cho multiline đơn giản. Quan trọng: luôn set `.textContentType()` cho autofill và `.keyboardType()` phù hợp — UX tốt hơn đáng kể. `TextField` với `format:` tự động validate và format number/date/currency.

**Selection views** — `Toggle` (on/off), `Picker` (chọn từ list — nhiều styles: segmented, menu, wheel, navigationLink), `Slider` (giá trị liên tục), `Stepper` (giá trị rời rạc), `DatePicker`, `ColorPicker`. Tất cả đều dùng `Binding` (`$variable`) để two-way data flow.

**Shape & Color** — Shape (Circle, Rectangle, Capsule...) vừa là view vừa dùng cho `.clipShape()`, `.background()`. Color là **expanding view** (chiếm hết space) — khác Text (hugging). Material (`.ultraThinMaterial`, `.regularMaterial`) tạo blur background rất đẹp cho overlay/card.
