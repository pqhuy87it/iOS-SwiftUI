// ============================================================
// PICKER TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// Picker là UI control cho phép user CHỌN 1 GIÁ TRỊ từ danh sách.
// SwiftUI cung cấp nhiều PickerStyle để thay đổi giao diện
// mà KHÔNG cần đổi logic code — cùng 1 Picker, chỉ đổi style
// là có thể chuyển từ dropdown → wheel → segmented → menu...
//
// Tương đương: UIPickerView, UISegmentedControl,
//              UIMenu (context menu), ActionSheet trong UIKit.
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÚ PHÁP CƠ BẢN & ANATOMY                           ║
// ╚══════════════════════════════════════════════════════════╝

// Picker(
//     "Label",                    ← Nhãn mô tả (có thể ẩn)
//     selection: $boundValue,     ← Binding tới state chứa giá trị đã chọn
//     content: { ... }            ← Danh sách options (mỗi option cần .tag)
// )

struct BasicPickerDemo: View {
    @State private var selectedFruit = "Táo"
    let fruits = ["Táo", "Cam", "Xoài", "Nho", "Dưa hấu"]
    
    var body: some View {
        Form {
            // Cách 1: ForEach với String array
            Picker("Trái cây", selection: $selectedFruit) {
                ForEach(fruits, id: \.self) { fruit in
                    Text(fruit)
                        .tag(fruit)  // tag() PHẢI khớp TYPE với selection
                }
            }
            
            Text("Đã chọn: \(selectedFruit)")
        }
    }
}

// ⚠️ QUY TẮC VÀNG CỦA .tag():
//
// 1. TYPE của .tag() PHẢI GIỐNG CHÍNH XÁC type của selection
//    selection: $myInt (Int) → .tag(1), .tag(2)       ✅
//    selection: $myInt (Int) → .tag("one")             ❌ Type mismatch!
//
// 2. Nếu selection là Optional<T>, tag cũng phải Optional<T>
//    selection: $myOptional (String?) → .tag(String?("Táo")) ✅
//    selection: $myOptional (String?) → .tag("Táo")          ❌ String ≠ String?
//
// 3. ForEach + Identifiable: id property được tự động dùng làm tag
//    NẾU id property CÙNG TYPE với selection → KHÔNG CẦN .tag()
//    Nhưng explicitly dùng .tag() luôn AN TOÀN hơn.


// ╔══════════════════════════════════════════════════════════╗
// ║  2. DATA SOURCES — CÁC CÁCH CUNG CẤP DỮ LIỆU           ║
// ╚══════════════════════════════════════════════════════════╝

// === 2a. Enum — Cách phổ biến & type-safe nhất ===

enum Priority: String, CaseIterable, Identifiable {
    case low = "Thấp"
    case medium = "Trung bình"
    case high = "Cao"
    case urgent = "Khẩn cấp"
    
    var id: Self { self }
    
    var icon: String {
        switch self {
        case .low: return "arrow.down"
        case .medium: return "minus"
        case .high: return "arrow.up"
        case .urgent: return "exclamationmark.2"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}

struct EnumPickerDemo: View {
    @State private var priority: Priority = .medium
    
    var body: some View {
        Form {
            // CaseIterable cho phép iterate tất cả cases
            Picker("Ưu tiên", selection: $priority) {
                ForEach(Priority.allCases) { p in
                    Label(p.rawValue, systemImage: p.icon)
                        .foregroundStyle(p.color)
                        .tag(p)
                }
            }
            
            // Hiển thị kết quả
            Label(priority.rawValue, systemImage: priority.icon)
                .foregroundStyle(priority.color)
                .font(.headline)
        }
    }
}

// === 2b. Identifiable Struct Array ===

struct Country: Identifiable, Hashable {
    let id: String  // country code
    let name: String
    let flag: String
}

struct StructPickerDemo: View {
    let countries = [
        Country(id: "VN", name: "Việt Nam", flag: "🇻🇳"),
        Country(id: "US", name: "Hoa Kỳ", flag: "🇺🇸"),
        Country(id: "JP", name: "Nhật Bản", flag: "🇯🇵"),
        Country(id: "KR", name: "Hàn Quốc", flag: "🇰🇷"),
        Country(id: "SG", name: "Singapore", flag: "🇸🇬"),
    ]
    
    // Selection theo ID (String), không phải toàn bộ struct
    @State private var selectedCountryID = "VN"
    
    var body: some View {
        Form {
            Picker("Quốc gia", selection: $selectedCountryID) {
                ForEach(countries) { country in
                    Text("\(country.flag) \(country.name)")
                        .tag(country.id) // tag = id type (String)
                }
            }
        }
    }
}

// === 2c. Selection là toàn bộ Struct (cần Hashable) ===

struct StructSelectionPicker: View {
    let countries = [
        Country(id: "VN", name: "Việt Nam", flag: "🇻🇳"),
        Country(id: "US", name: "Hoa Kỳ", flag: "🇺🇸"),
        Country(id: "JP", name: "Nhật Bản", flag: "🇯🇵"),
    ]
    
    // Selection là TOÀN BỘ struct → struct phải Hashable
    @State private var selected: Country
    
    init() {
        let countries = [
            Country(id: "VN", name: "Việt Nam", flag: "🇻🇳"),
            Country(id: "US", name: "Hoa Kỳ", flag: "🇺🇸"),
            Country(id: "JP", name: "Nhật Bản", flag: "🇯🇵"),
        ]
        _selected = State(initialValue: countries[0])
    }
    
    var body: some View {
        Form {
            Picker("Quốc gia", selection: $selected) {
                ForEach(countries) { country in
                    Text("\(country.flag) \(country.name)")
                        .tag(country) // tag = Country struct
                }
            }
            
            // Truy cập trực tiếp properties
            Text("Code: \(selected.id)")
            Text("Tên: \(selected.name)")
        }
    }
}

// === 2d. Optional Selection ===

struct OptionalPickerDemo: View {
    let categories = ["Công việc", "Cá nhân", "Học tập", "Sức khoẻ"]
    
    // Optional: ban đầu chưa chọn gì
    @State private var selectedCategory: String? = nil
    
    var body: some View {
        Form {
            Picker("Danh mục", selection: $selectedCategory) {
                // Option "Chưa chọn" → tag nil
                Text("Không có")
                    .tag(String?.none) // ← Optional<String>.none = nil
                
                Divider()
                
                ForEach(categories, id: \.self) { cat in
                    Text(cat)
                        .tag(String?.some(cat)) // ← Optional<String>.some("...")
                        // HOẶC viết: .tag(cat as String?)
                }
            }
            
            if let category = selectedCategory {
                Text("Đã chọn: \(category)")
            } else {
                Text("Chưa chọn danh mục")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// === 2e. Int / Index Selection ===

struct IndexPickerDemo: View {
    let sizes = ["S", "M", "L", "XL", "XXL"]
    @State private var selectedIndex = 1 // Mặc định chọn "M"
    
    var body: some View {
        Form {
            Picker("Size", selection: $selectedIndex) {
                ForEach(0..<sizes.count, id: \.self) { i in
                    Text(sizes[i]).tag(i)
                }
            }
            
            Text("Size: \(sizes[selectedIndex])")
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3. PICKER STYLES — TẤT CẢ CÁC KIỂU GIAO DIỆN         ║
// ╚══════════════════════════════════════════════════════════╝

// SwiftUI cung cấp nhiều PickerStyle.
// CÙNG 1 Picker logic, chỉ đổi .pickerStyle() là thay đổi giao diện.

enum Flavor: String, CaseIterable, Identifiable {
    case chocolate = "Sô-cô-la"
    case vanilla = "Vani"
    case strawberry = "Dâu"
    case matcha = "Trà xanh"
    case mango = "Xoài"
    
    var id: Self { self }
}

// === 3a. .automatic (Default) ===
// Platform tự chọn style phù hợp nhất theo context.
// Trong Form/List → .menu (iOS 16+) hoặc navigation link (iOS 15)
// Ngoài Form → inline

struct AutomaticPickerStyle: View {
    @State private var flavor: Flavor = .chocolate
    
    var body: some View {
        Form {
            // Trong Form: hiển thị như menu dropdown (iOS 16+)
            // Tap vào → popup menu xuất hiện
            Picker("Vị kem", selection: $flavor) {
                ForEach(Flavor.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            // Không cần .pickerStyle() → dùng .automatic
        }
    }
}


// === 3b. .menu — Dropdown Menu (iOS 14+) ===
// Tap → popup menu xuất hiện phía trên/dưới.
// Compact, tiết kiệm không gian.
// ĐÂY LÀ DEFAULT trong Form từ iOS 16+.

struct MenuPickerDemo: View {
    @State private var flavor: Flavor = .vanilla
    
    var body: some View {
        Form {
            Picker("Vị kem", selection: $flavor) {
                ForEach(Flavor.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.menu)
        }
    }
}

// === 3c. .inline — Hiển thị TẤT CẢ options trực tiếp ===
// Tất cả options hiện luôn, không cần tap để mở.
// Phù hợp khi ít options (3-5) và muốn user thấy ngay.

struct InlinePickerDemo: View {
    @State private var flavor: Flavor = .strawberry
    
    var body: some View {
        Form {
            Picker("Vị kem", selection: $flavor) {
                ForEach(Flavor.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.inline)
            // Hiển thị dạng list với checkmark ở item đang chọn
        }
    }
}


// === 3d. .segmented — Segmented Control (iOS 13+) ===
// Hiển thị dạng thanh ngang, mỗi option là 1 segment.
// Phù hợp cho 2-5 options ngắn (tab switching, filter).
// ⚠️ Không phù hợp cho text dài hoặc nhiều options.

struct SegmentedPickerDemo: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Picker("Tab", selection: $selectedTab) {
                Text("Tất cả").tag(0)
                Text("Đang làm").tag(1)
                Text("Xong").tag(2)
            }
            .pickerStyle(.segmented)
            
            // Content thay đổi theo selection
            switch selectedTab {
            case 0: Text("📋 Hiển thị tất cả tasks")
            case 1: Text("⏳ Hiển thị tasks đang làm")
            case 2: Text("✅ Hiển thị tasks đã xong")
            default: EmptyView()
            }
        }
        .padding()
    }
}

// Segmented với Label (icon + text):
struct SegmentedWithIcons: View {
    @State private var viewMode = 0
    
    var body: some View {
        Picker("View", selection: $viewMode) {
            Label("List", systemImage: "list.bullet").tag(0)
            Label("Grid", systemImage: "square.grid.2x2").tag(1)
            Label("Map", systemImage: "map").tag(2)
        }
        .pickerStyle(.segmented)
        .padding()
        // ⚠️ Segmented chỉ hiện icon HOẶC text tuỳ theo không gian
        // Trên iPhone: thường chỉ hiện icon nếu có Label
    }
}


// === 3e. .wheel — Spinning Wheel (iOS 13+) ===
// Kiểu cuộn tròn kinh điển của iOS (giống UIPickerView).
// Chiếm nhiều không gian, phù hợp cho date/time hoặc danh sách dài.

struct WheelPickerDemo: View {
    @State private var selectedHour = 8
    @State private var selectedMinute = 30
    
    var body: some View {
        VStack {
            Text("Giờ hẹn: \(selectedHour):\(String(format: "%02d", selectedMinute))")
                .font(.title)
            
            HStack {
                // Wheel cho giờ
                Picker("Giờ", selection: $selectedHour) {
                    ForEach(0..<24) { hour in
                        Text("\(hour) giờ").tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 120)
                
                // Wheel cho phút
                Picker("Phút", selection: $selectedMinute) {
                    ForEach(0..<60) { min in
                        Text("\(min) phút").tag(min)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 120)
            }
            .frame(height: 150) // Giới hạn chiều cao
        }
    }
}


// === 3f. .navigationLink — Push sang màn mới (iOS 16+) ===
// Tap → NavigationLink push sang screen mới chứa danh sách.
// Phù hợp cho danh sách DÀI (countries, languages...).
// ⚠️ BẮT BUỘC nằm trong NavigationStack/NavigationView.

struct NavigationLinkPickerDemo: View {
    @State private var selectedCountry = "VN"
    let countries = [
        ("VN", "🇻🇳 Việt Nam"), ("US", "🇺🇸 Hoa Kỳ"),
        ("JP", "🇯🇵 Nhật Bản"), ("KR", "🇰🇷 Hàn Quốc"),
        ("SG", "🇸🇬 Singapore"), ("TH", "🇹🇭 Thái Lan"),
        ("MY", "🇲🇾 Malaysia"), ("ID", "🇮🇩 Indonesia"),
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Quốc gia", selection: $selectedCountry) {
                    ForEach(countries, id: \.0) { code, name in
                        Text(name).tag(code)
                    }
                }
                .pickerStyle(.navigationLink)
                // Tap → push sang screen mới với full list
                // Chọn xong → tự pop back
            }
            .navigationTitle("Cài đặt")
        }
    }
}


// === 3g. .palette — Color/Icon Palette (iOS 17+) ===
// Hiển thị dạng lưới icon/color ngang.
// Phù hợp cho chọn màu, icon, biểu tượng.
// Thường dùng trong Menu hoặc ControlGroup.

struct PalettePickerDemo: View {
    @State private var selectedColor = "red"
    let colors: [(String, Color)] = [
        ("red", .red), ("orange", .orange), ("yellow", .yellow),
        ("green", .green), ("blue", .blue), ("purple", .purple),
    ]
    
    var body: some View {
        Form {
            Picker("Màu sắc", selection: $selectedColor) {
                ForEach(colors, id: \.0) { name, color in
                    Label(name, systemImage: "circle.fill")
                        .foregroundStyle(color)
                        .tag(name)
                }
            }
            .pickerStyle(.palette)
            
            // Palette bên trong Menu
            Menu("Chọn màu") {
                Picker("Màu", selection: $selectedColor) {
                    ForEach(colors, id: \.0) { name, color in
                        Label(name, systemImage: "circle.fill")
                            .foregroundStyle(color)
                            .tag(name)
                    }
                }
                .pickerStyle(.palette)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3h. BẢNG TỔNG HỢP PICKER STYLES                        ║
// ╚══════════════════════════════════════════════════════════╝

// ┌─────────────────┬──────────┬───────────┬──────────────────────┐
// │ Style           │ Min iOS  │ Số options│ Dùng khi             │
// ├─────────────────┼──────────┼───────────┼──────────────────────┤
// │ .automatic      │ 13       │ Bất kỳ    │ Để SwiftUI tự chọn  │
// │ .menu           │ 14       │ 3-15      │ Dropdown compact     │
// │ .inline         │ 14       │ 3-10      │ Hiện tất cả options  │
// │ .segmented      │ 13       │ 2-5       │ Tab, filter toggle   │
// │ .wheel          │ 13       │ Nhiều     │ Date/time, số lượng  │
// │ .navigationLink │ 16       │ 5+        │ List dài, detail page│
// │ .palette        │ 17       │ 3-10      │ Màu sắc, icon set   │
// └─────────────────┴──────────┴───────────┴──────────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  4. CUSTOM LABEL & APPEARANCE                            ║
// ╚══════════════════════════════════════════════════════════╝

// === 4a. Custom Label với Label view ===

struct CustomLabelPicker: View {
    @State private var priority: Priority = .medium
    
    var body: some View {
        Form {
            // Label dạng icon + text
            Picker(selection: $priority) {
                ForEach(Priority.allCases) { p in
                    Label(p.rawValue, systemImage: p.icon)
                        .tag(p)
                }
            } label: {
                // Custom label phức tạp
                Label {
                    VStack(alignment: .leading) {
                        Text("Mức ưu tiên")
                        Text("Ảnh hưởng thứ tự hiển thị")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "flag.fill")
                        .foregroundStyle(priority.color)
                }
            }
        }
    }
}

// === 4b. Ẩn Label ===

struct HiddenLabelPicker: View {
    @State private var flavor: Flavor = .chocolate
    
    var body: some View {
        VStack {
            Text("Chọn vị yêu thích:")
                .font(.headline)
            
            Picker("Vị", selection: $flavor) {
                ForEach(Flavor.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .labelsHidden() // Ẩn label mặc định
            .pickerStyle(.wheel)
        }
    }
}

// === 4c. Tint / AccentColor ===

struct TintedPicker: View {
    @State private var tab = 0
    
    var body: some View {
        Picker("Tab", selection: $tab) {
            Text("Hot").tag(0)
            Text("New").tag(1)
            Text("Top").tag(2)
        }
        .pickerStyle(.segmented)
        .tint(.orange) // iOS 17+: đổi màu highlight
        // .accentColor(.orange) // Fallback cho iOS cũ hơn
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. RICH CONTENT TRONG OPTIONS                           ║
// ╚══════════════════════════════════════════════════════════╝

// Mỗi option có thể chứa views phức tạp, không chỉ Text.
// ⚠️ Một số styles (menu, segmented) chỉ render text/icon đơn giản.
// Styles hỗ trợ rich content tốt: .inline, .navigationLink, .wheel.

struct RichContentPicker: View {
    struct Theme: Identifiable, Hashable {
        let id: String
        let name: String
        let primaryColor: Color
        let icon: String
        let description: String
    }
    
    let themes = [
        Theme(id: "ocean", name: "Đại dương", primaryColor: .blue,
              icon: "water.waves", description: "Xanh mát, chuyên nghiệp"),
        Theme(id: "forest", name: "Rừng xanh", primaryColor: .green,
              icon: "leaf.fill", description: "Tự nhiên, thư giãn"),
        Theme(id: "sunset", name: "Hoàng hôn", primaryColor: .orange,
              icon: "sun.horizon.fill", description: "Ấm áp, năng động"),
        Theme(id: "midnight", name: "Nửa đêm", primaryColor: .indigo,
              icon: "moon.stars.fill", description: "Tối, tập trung"),
    ]
    
    @State private var selectedTheme: Theme
    
    init() {
        let themes = [
            Theme(id: "ocean", name: "Đại dương", primaryColor: .blue,
                  icon: "water.waves", description: "Xanh mát, chuyên nghiệp"),
        ]
        _selectedTheme = State(initialValue: themes[0])
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Giao diện", selection: $selectedTheme) {
                    ForEach(themes) { theme in
                        HStack(spacing: 12) {
                            Image(systemName: theme.icon)
                                .font(.title2)
                                .foregroundStyle(theme.primaryColor)
                                .frame(width: 40)
                            
                            VStack(alignment: .leading) {
                                Text(theme.name)
                                    .font(.headline)
                                Text(theme.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tag(theme)
                    }
                }
                .pickerStyle(.inline)
                
                // Preview theme đã chọn
                Section("Preview") {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedTheme.primaryColor.gradient)
                        .frame(height: 80)
                        .overlay(
                            Label(selectedTheme.name, systemImage: selectedTheme.icon)
                                .foregroundStyle(.white)
                                .font(.headline)
                        )
                }
            }
            .navigationTitle("Theme")
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. MULTI-COMPONENT PICKER (DEPENDENT PICKERS)           ║
// ╚══════════════════════════════════════════════════════════╝

// Nhiều Picker phụ thuộc lẫn nhau:
// Chọn Picker A → thay đổi options của Picker B.

struct DependentPickersDemo: View {
    let data: [String: [String]] = [
        "Hà Nội": ["Ba Đình", "Hoàn Kiếm", "Đống Đa", "Hai Bà Trưng", "Cầu Giấy"],
        "TP.HCM": ["Quận 1", "Quận 3", "Quận 7", "Bình Thạnh", "Thủ Đức"],
        "Đà Nẵng": ["Hải Châu", "Thanh Khê", "Sơn Trà", "Ngũ Hành Sơn"],
    ]
    
    @State private var selectedCity = "Hà Nội"
    @State private var selectedDistrict = "Ba Đình"
    
    var districts: [String] {
        data[selectedCity] ?? []
    }
    
    var body: some View {
        Form {
            // Picker 1: Thành phố
            Picker("Thành phố", selection: $selectedCity) {
                ForEach(Array(data.keys.sorted()), id: \.self) { city in
                    Text(city).tag(city)
                }
            }
            
            // Picker 2: Quận/Huyện — options thay đổi theo thành phố
            Picker("Quận/Huyện", selection: $selectedDistrict) {
                ForEach(districts, id: \.self) { district in
                    Text(district).tag(district)
                }
            }
            
            Section("Địa chỉ đã chọn") {
                Text("\(selectedDistrict), \(selectedCity)")
            }
        }
        // Reset district khi đổi thành phố
        .onChange(of: selectedCity) { _, newCity in
            if let firstDistrict = data[newCity]?.first {
                selectedDistrict = firstDistrict
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. DYNAMIC & SEARCHABLE PICKER                          ║
// ╚══════════════════════════════════════════════════════════╝

// === 7a. Dynamic Picker — Options thay đổi theo điều kiện ===

struct DynamicPickerDemo: View {
    @State private var showAllSizes = false
    @State private var selectedSize = "M"
    
    let basicSizes = ["S", "M", "L"]
    let allSizes = ["XS", "S", "M", "L", "XL", "XXL", "XXXL"]
    
    var availableSizes: [String] {
        showAllSizes ? allSizes : basicSizes
    }
    
    var body: some View {
        Form {
            Toggle("Hiện tất cả size", isOn: $showAllSizes)
            
            Picker("Size", selection: $selectedSize) {
                ForEach(availableSizes, id: \.self) { size in
                    Text(size).tag(size)
                }
            }
            .pickerStyle(.segmented)
            .animation(.easeInOut, value: showAllSizes)
        }
        // Reset nếu size đang chọn không còn trong list
        .onChange(of: showAllSizes) { _, _ in
            if !availableSizes.contains(selectedSize) {
                selectedSize = "M"
            }
        }
    }
}

// === 7b. Searchable Picker — Tìm kiếm trong danh sách dài ===
// SwiftUI chưa có built-in searchable picker,
// nhưng kết hợp .navigationLink + .searchable để tạo.

struct SearchablePickerDemo: View {
    @State private var selectedLanguage = "Swift"
    
    var body: some View {
        NavigationStack {
            Form {
                // Hiển thị selection hiện tại
                NavigationLink {
                    LanguagePickerList(selection: $selectedLanguage)
                } label: {
                    HStack {
                        Text("Ngôn ngữ")
                        Spacer()
                        Text(selectedLanguage)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct LanguagePickerList: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    let languages = [
        "Swift", "Kotlin", "Dart", "TypeScript", "JavaScript",
        "Python", "Rust", "Go", "Java", "C++", "C#", "Ruby",
        "PHP", "Scala", "Elixir", "Haskell", "Lua", "R",
    ]
    
    var filtered: [String] {
        if searchText.isEmpty { return languages }
        return languages.filter {
            $0.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List(filtered, id: \.self) { lang in
            Button {
                selection = lang
                dismiss() // Tự pop back sau khi chọn
            } label: {
                HStack {
                    Text(lang)
                        .foregroundStyle(.primary)
                    Spacer()
                    if lang == selection {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Tìm ngôn ngữ...")
        .navigationTitle("Ngôn ngữ")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. PICKER TRONG CÁC CONTEXT KHÁC NHAU                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 8a. Picker trong Toolbar ===

struct ToolbarPickerDemo: View {
    @State private var sortOrder = "date"
    @State private var items = (1...20).map { "Item \($0)" }
    
    var body: some View {
        NavigationStack {
            List(items, id: \.self) { item in
                Text(item)
            }
            .navigationTitle("Danh sách")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Picker trong Menu trên toolbar
                    Menu {
                        Picker("Sắp xếp", selection: $sortOrder) {
                            Label("Ngày tạo", systemImage: "calendar").tag("date")
                            Label("Tên A-Z", systemImage: "textformat.abc").tag("name")
                            Label("Ưu tiên", systemImage: "flag").tag("priority")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
}

// === 8b. Picker trong Alert / ConfirmationDialog ===
// ⚠️ Picker KHÔNG hoạt động trực tiếp trong .alert()
// Giải pháp: dùng Sheet hoặc ConfirmationDialog

struct PickerInSheetDemo: View {
    @State private var showPicker = false
    @State private var selectedPriority: Priority = .medium
    
    var body: some View {
        VStack {
            Button("Chọn ưu tiên") { showPicker = true }
            
            Text("Đã chọn: \(selectedPriority.rawValue)")
        }
        .sheet(isPresented: $showPicker) {
            NavigationStack {
                Form {
                    Picker("Ưu tiên", selection: $selectedPriority) {
                        ForEach(Priority.allCases) { p in
                            Label(p.rawValue, systemImage: p.icon).tag(p)
                        }
                    }
                    .pickerStyle(.inline)
                }
                .navigationTitle("Chọn ưu tiên")
                .toolbar {
                    Button("Xong") { showPicker = false }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

// === 8c. Picker ngoài Form (Standalone) ===
// Ngoài Form, .automatic style khác với trong Form.

struct StandalonePicker: View {
    @State private var flavor: Flavor = .matcha
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Chọn vị kem")
                .font(.title2.bold())
            
            // Ngoài Form: .menu style hiển thị dạng button
            Picker("Vị", selection: $flavor) {
                ForEach(Flavor.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.menu)
            // Hiển thị: button với tên vị hiện tại
            // Tap → dropdown menu xuất hiện
            
            // Segmented standalone (phổ biến nhất ngoài Form)
            Picker("Vị", selection: $flavor) {
                ForEach(Flavor.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            .pickerStyle(.segmented)
            
            Text("✅ \(flavor.rawValue)")
                .font(.headline)
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. onChange — PHẢN ỨNG KHI SELECTION THAY ĐỔI           ║
// ╚══════════════════════════════════════════════════════════╝

struct OnChangePickerDemo: View {
    @State private var selectedTab = 0
    @State private var message = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Picker("Tab", selection: $selectedTab) {
                Text("Home").tag(0)
                Text("Search").tag(1)
                Text("Profile").tag(2)
            }
            .pickerStyle(.segmented)
            
            Text(message)
                .foregroundStyle(.secondary)
        }
        .padding()
        // iOS 17+ syntax:
        .onChange(of: selectedTab) { oldValue, newValue in
            message = "Chuyển từ tab \(oldValue) → tab \(newValue)"
            
            // Thực hiện side effects:
            // → Analytics tracking
            // → Load data cho tab mới
            // → Cancel requests tab cũ
        }
        // iOS 14-16 syntax:
        // .onChange(of: selectedTab) { newValue in
        //     message = "Đã chọn tab \(newValue)"
        // }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. DISABLED & CONDITIONAL PICKER                       ║
// ╚══════════════════════════════════════════════════════════╝

struct ConditionalPickerDemo: View {
    @State private var isPremium = false
    @State private var selectedTheme = "default"
    @State private var selectedQuality = "720p"
    
    var body: some View {
        Form {
            Toggle("Tài khoản Premium", isOn: $isPremium)
            
            // Disabled khi không phải Premium
            Picker("Theme", selection: $selectedTheme) {
                Text("Mặc định").tag("default")
                Text("Dark Pro").tag("dark_pro")
                Text("Ocean").tag("ocean")
            }
            .disabled(!isPremium)
            // Khi disabled: hiển thị mờ, không tap được
            
            // Conditional options
            Picker("Chất lượng video", selection: $selectedQuality) {
                Text("480p").tag("480p")
                Text("720p").tag("720p")
                Text("1080p").tag("1080p")
                
                if isPremium {
                    // Options này CHỈ HIỆN khi Premium
                    Text("4K").tag("4k")
                    Text("8K HDR").tag("8k")
                }
            }
            
            if !isPremium {
                Text("Nâng cấp Premium để mở khoá theme & chất lượng cao")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. CUSTOM PICKER (BUILD TỪ SCRATCH)                    ║
// ╚══════════════════════════════════════════════════════════╝

// Khi built-in Picker không đáp ứng UI requirements,
// tự build picker component riêng.

// === 11a. Chip/Tag Picker ===

struct ChipPicker<T: Hashable & Identifiable>: View {
    let title: String
    let options: [T]
    @Binding var selection: T
    let label: (T) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // FlowLayout-like: wrap chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(options) { option in
                        let isSelected = option == selection
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selection = option
                            }
                        } label: {
                            Text(label(option))
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    isSelected
                                        ? Color.blue
                                        : Color.gray.opacity(0.15)
                                )
                                .foregroundStyle(isSelected ? .white : .primary)
                                .clipShape(.capsule)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview("Chip Picker") {
    @Previewable @State var selected: Priority = .medium
    
    ChipPicker(
        title: "Mức ưu tiên",
        options: Priority.allCases,
        selection: $selected,
        label: { $0.rawValue }
    )
    .padding()
}

// === 11b. Card Selection Picker ===

struct CardPicker<T: Hashable & Identifiable>: View {
    let options: [T]
    @Binding var selection: T
    let content: (T, Bool) -> AnyView // (item, isSelected) → view
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(options) { option in
                let isSelected = option == selection
                
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        selection = option
                    }
                } label: {
                    content(option, isSelected)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    isSelected ? Color.blue : Color.gray.opacity(0.2),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  12. ACCESSIBILITY                                       ║
// ╚══════════════════════════════════════════════════════════╝

struct AccessiblePickerDemo: View {
    @State private var fontSize: Int = 16
    
    var body: some View {
        Form {
            Picker("Cỡ chữ", selection: $fontSize) {
                Text("Nhỏ (14pt)").tag(14)
                Text("Vừa (16pt)").tag(16)
                Text("Lớn (20pt)").tag(20)
                Text("Rất lớn (24pt)").tag(24)
            }
            // Accessibility hints
            .accessibilityLabel("Chọn cỡ chữ")
            .accessibilityHint("Tap để thay đổi kích thước font chữ")
            
            Text("Văn bản mẫu để xem thay đổi")
                .font(.system(size: CGFloat(fontSize)))
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  13. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Tag type mismatch
//    @State var selection: String = "A"
//    Text("Option").tag(1)       // tag Int ≠ selection String → KHÔNG CHỌN ĐƯỢC!
//    ✅ FIX: .tag("A")          // Cùng type String

// ❌ PITFALL 2: Optional mismatch
//    @State var selection: String? = nil
//    Text("Option").tag("value") // tag String ≠ selection String?
//    ✅ FIX: .tag(String?("value")) hoặc .tag("value" as String?)

// ❌ PITFALL 3: Selection value không có trong options
//    @State var selection = "Z"  // "Z" không có trong list
//    → Picker không hiển thị gì hoặc hiển thị sai
//    ✅ FIX: Đảm bảo initial value nằm trong options
//            Hoặc dùng Optional selection

// ❌ PITFALL 4: Segmented với quá nhiều options
//    5+ options trên iPhone → text bị cắt, không đọc được
//    ✅ FIX: Segmented chỉ dùng cho 2-4 options ngắn
//            Options dài → dùng .menu hoặc .navigationLink

// ❌ PITFALL 5: .navigationLink ngoài NavigationStack
//    → Không hoạt động, không navigate được
//    ✅ FIX: Đảm bảo có NavigationStack/NavigationView bao ngoài

// ❌ PITFALL 6: Quên .onChange khi có dependent pickers
//    Đổi city nhưng district vẫn giữ giá trị cũ → không hợp lệ
//    ✅ FIX: Luôn reset dependent selection trong .onChange

// ✅ BEST PRACTICES:
// 1. Enum + CaseIterable là data source TỐT NHẤT cho Picker
// 2. .tag() phải CÙNG TYPE chính xác với selection
// 3. Chọn PickerStyle theo SỐ LƯỢNG options + context
// 4. .onChange cho side effects (analytics, load data, validation)
// 5. Test Accessibility: VoiceOver phải đọc được label + giá trị
// 6. Dependent pickers: luôn reset child khi parent thay đổi
// 7. Custom picker khi UI phức tạp (chips, cards, color swatches)

---

Picker là component tưởng đơn giản nhưng có rất nhiều biến thể và edge cases. Mình sẽ giải thích toàn bộ từ cơ bản đến các patterns nâng cao trong production.Mình đã tổng hợp toàn bộ kiến thức về Picker trong 13 phần. Đây là những điểm cốt lõi:

**Quy tắc vàng** mà cực kỳ nhiều developer mắc phải (Phần 1): `.tag()` **phải cùng type chính xác** với `selection`. Đặc biệt với Optional — nếu `selection` là `String?` thì tag phải là `.tag(String?("value"))` chứ không phải `.tag("value")`. Type mismatch sẽ không báo lỗi compile mà âm thầm khiến Picker không chọn được.

**Ba phần quan trọng nhất cho production:**

**Phần 3 — Bảng tổng hợp 7 PickerStyles**: Cùng một Picker logic, chỉ đổi `.pickerStyle()` là thay đổi hoàn toàn giao diện. Điểm hay là `.automatic` sẽ tự chọn style phù hợp theo context — trong Form thì hiện dạng menu, ngoài Form thì khác. `.palette` (iOS 17+) là style mới rất phù hợp cho chọn màu/icon.

**Phần 6 — Dependent Pickers**: Pattern chọn Thành phố → tự động thay đổi danh sách Quận/Huyện. Điểm then chốt là **phải dùng `.onChange(of:)` để reset child selection** khi parent thay đổi, nếu không child sẽ giữ giá trị cũ không hợp lệ.

**Phần 7 — Searchable Picker**: SwiftUI chưa có built-in searchable picker, nhưng kết hợp `NavigationLink` + `List` + `.searchable()` modifier tạo ra trải nghiệm tương đương — rất cần thiết cho danh sách dài như quốc gia, ngôn ngữ.

**Phần 11 — Custom Picker** cho thấy khi nào nên tự build: khi cần UI dạng chip/tag selection hoặc card selection mà built-in styles không đáp ứng được. Pattern chung là `ForEach` + `Button` + `@Binding` + animation.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
