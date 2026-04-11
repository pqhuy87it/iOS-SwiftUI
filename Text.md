```
// ============================================================
// TEXT TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// Text là view hiển thị nội dung văn bản READ-ONLY.
// (Nhập liệu → dùng TextField / TextEditor)
//
// Khả năng của Text rất phong phú:
// - Font system hoàn chỉnh (Dynamic Type, custom fonts)
// - Markdown rendering built-in (iOS 15+)
// - Text concatenation (nối Text + Text giữ styling riêng)
// - AttributedString (rich text nâng cao)
// - Format: date, number, currency, measurement...
// - Localization tự động
// - Text animations (iOS 17+)
// ============================================================
```
```Swift
import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. KHỞI TẠO TEXT — CÁC INITIALIZER                     ║
// ╚══════════════════════════════════════════════════════════╝

struct TextInitializersDemo: View {
    let price = 1_250_000.5
    let ratio = 0.856
    let now = Date.now
    let range = Date.now...Date.now.addingTimeInterval(3600)
    let interval: TimeInterval = 3725 // 1h 2m 5s
    let distance = Measurement(value: 5.2, unit: UnitLength.kilometers)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // === 1a. String literal ===
            Text("Xin chào SwiftUI")
            
            // === 1b. String variable ===
            let name = "Huy"
            Text(name)
            
            // === 1c. Verbatim — KHÔNG localize ===
            Text(verbatim: "key_not_localized")
            // Bỏ qua Localizable.strings, hiện đúng chuỗi gốc
            
            // === 1d. Markdown (iOS 15+) ===
            Text("**Bold**, *italic*, ~~strike~~, `code`, [link](https://apple.com)")
            
            // === 1e. Date formatting ===
            Text(now, style: .date)        // "Apr 11, 2026"
            Text(now, style: .time)        // "2:30 PM"
            Text(now, style: .relative)    // "2 hours ago"
            Text(now, style: .offset)      // "+2 hours"
            Text(now, style: .timer)       // "2:15:30" (live đếm)
            Text(range, style: .timer)     // Countdown range
            
            // === 1f. Format — Số, tiền, phần trăm ===
            Text(price, format: .currency(code: "VND"))
            // → "₫1,250,000.50"
            
            Text(ratio, format: .percent)
            // → "85.6%"
            
            Text(42, format: .number.precision(.fractionLength(2)))
            // → "42.00"
            
            // === 1g. Measurement formatting ===
            Text(distance, format: .measurement(width: .abbreviated))
            // → "5.2 km"
            
            // === 1h. Image trong Text (inline icon) ===
            Text("Trạng thái: \(Image(systemName: "checkmark.circle.fill")) Hoàn thành")
            // Icon nằm INLINE với text, scale theo font size
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. FONT SYSTEM — HỆ THỐNG FONT                         ║
// ╚══════════════════════════════════════════════════════════╝

struct FontSystemDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                
                // === 2a. Semantic fonts (Dynamic Type tự động) ===
                // Apple khuyến khích dùng semantic → scale theo user settings
                Group {
                    Text("Large Title").font(.largeTitle)     // 34pt
                    Text("Title").font(.title)                // 28pt
                    Text("Title 2").font(.title2)             // 22pt
                    Text("Title 3").font(.title3)             // 20pt
                    Text("Headline").font(.headline)          // 17pt semi-bold
                    Text("Subheadline").font(.subheadline)    // 15pt
                    Text("Body").font(.body)                  // 17pt (default)
                    Text("Callout").font(.callout)            // 16pt
                    Text("Footnote").font(.footnote)          // 13pt
                    Text("Caption").font(.caption)            // 12pt
                }
                Text("Caption 2").font(.caption2)             // 11pt
                
                Divider()
                
                // === 2b. System font với tuỳ chỉnh ===
                Text("Size + Weight")
                    .font(.system(size: 24, weight: .bold))
                
                Text("Rounded Design")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                
                Text("Monospaced")
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                
                Text("Serif Design")
                    .font(.system(size: 18, weight: .light, design: .serif))
                
                Divider()
                
                // === 2c. Font weight modifiers ===
                Text("Ultra Light").fontWeight(.ultraLight)
                Text("Thin").fontWeight(.thin)
                Text("Light").fontWeight(.light)
                Text("Regular").fontWeight(.regular)
                Text("Medium").fontWeight(.medium)
                Text("Semibold").fontWeight(.semibold)
                Text("Bold").fontWeight(.bold)
                Text("Heavy").fontWeight(.heavy)
                Text("Black").fontWeight(.black)
                
                Divider()
                
                // === 2d. Font width (iOS 16+) ===
                Text("Condensed").fontWidth(.condensed)
                Text("Standard").fontWidth(.standard)
                Text("Expanded").fontWidth(.expanded)
                
                Divider()
                
                // === 2e. Custom fonts ===
                // Cần thêm font file vào project + Info.plist
                // Text("Custom Font")
                //     .font(.custom("Montserrat-Bold", size: 20))
                
                // Custom font với relative sizing (scale theo Dynamic Type)
                // Text("Relative Custom")
                //     .font(.custom("Montserrat", size: 17, relativeTo: .body))
                //     // size: base size, relativeTo: scale reference
            }
            .padding()
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3. TEXT STYLING MODIFIERS                                ║
// ╚══════════════════════════════════════════════════════════╝

struct TextStylingDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // === 3a. Màu sắc ===
                Text("Primary color (mặc định)")
                    .foregroundStyle(.primary)
                Text("Secondary color")
                    .foregroundStyle(.secondary)
                Text("Tertiary color")
                    .foregroundStyle(.tertiary)
                Text("Màu tuỳ chỉnh")
                    .foregroundStyle(.blue)
                Text("Gradient text")
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .font(.title.bold())
                
                Divider()
                
                // === 3b. Bold, Italic, Underline, Strikethrough ===
                Text("Bold text").bold()
                Text("Italic text").italic()
                Text("Underline").underline()
                Text("Underline styled").underline(true, color: .red)
                Text("Strikethrough").strikethrough()
                Text("Strikethrough styled").strikethrough(true, color: .orange)
                
                // Chain nhiều modifiers
                Text("Bold + Italic + Underline")
                    .bold()
                    .italic()
                    .underline()
                
                Divider()
                
                // === 3c. Letter spacing & Kerning ===
                Text("TRACKING +3").tracking(3)
                // tracking: khoảng cách đều giữa TẤT CẢ ký tự
                
                Text("KERNING +3").kerning(3)
                // kerning: khoảng cách giữa CẶP ký tự (font-aware)
                // Khác biệt: tracking thêm space AFTER mỗi glyph
                //            kerning chỉnh khoảng cách GIỮA cặp glyphs
                
                Divider()
                
                // === 3d. Baseline offset ===
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("H")
                        .font(.title)
                    Text("2")
                        .font(.caption)
                        .baselineOffset(-6) // Kéo XUỐNG → subscript
                    Text("O")
                        .font(.title)
                }
                
                HStack(spacing: 0) {
                    Text("E = mc")
                        .font(.title2)
                    Text("2")
                        .font(.caption)
                        .baselineOffset(10) // Kéo LÊN → superscript
                }
                
                Divider()
                
                // === 3e. Text case ===
                Text("hello world").textCase(.uppercase)     // "HELLO WORLD"
                Text("Hello World").textCase(.lowercase)     // "hello world"
                Text("hello world").textCase(nil)            // Giữ nguyên
                
                Divider()
                
                // === 3f. Monospaced digits ===
                Text("1234567890")
                    .monospacedDigit()
                // Mỗi SỐ có cùng width → cột số thẳng hàng
                // Rất quan trọng cho: giá, timer, bảng số liệu
            }
            .padding()
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. MULTILINE — LINE LIMIT, TRUNCATION, WRAPPING        ║
// ╚══════════════════════════════════════════════════════════╝

struct MultilineDemo: View {
    let longText = "SwiftUI cung cấp hệ thống Text rất mạnh mẽ cho phép hiển thị văn bản với nhiều tùy chỉnh phong phú từ font, color, spacing đến rich text và animations."
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // === 4a. lineLimit — Giới hạn số dòng ===
            Text(longText)
                .lineLimit(1) // Chỉ 1 dòng, còn lại bị cắt
            
            Text(longText)
                .lineLimit(2) // Tối đa 2 dòng
            
            Text(longText)
                .lineLimit(nil) // Không giới hạn (hiện TẤT CẢ)
            
            // iOS 16+: Range line limit
            Text(longText)
                .lineLimit(2...4)
            // Tối thiểu 2, tối đa 4 dòng
            // SwiftUI tự chọn trong khoảng phù hợp
            
            Divider()
            
            // === 4b. truncationMode — Vị trí dấu "..." ===
            Text(longText)
                .lineLimit(1)
                .truncationMode(.tail)    // "SwiftUI cung cấp hệ thống..."
            
            Text(longText)
                .lineLimit(1)
                .truncationMode(.middle)  // "SwiftUI cung...và animations."
            
            Text(longText)
                .lineLimit(1)
                .truncationMode(.head)    // "...rich text và animations."
            
            Divider()
            
            // === 4c. multilineTextAlignment ===
            Group {
                Text(longText)
                    .multilineTextAlignment(.leading)   // Căn trái (default)
                
                Text(longText)
                    .multilineTextAlignment(.center)    // Căn giữa
                
                Text(longText)
                    .multilineTextAlignment(.trailing)   // Căn phải
            }
            .lineLimit(3)
            .frame(width: 300)
            
            Divider()
            
            // === 4d. lineSpacing — Khoảng cách giữa các dòng ===
            Text(longText)
                .lineSpacing(8) // Thêm 8pt giữa mỗi dòng
                .lineLimit(3)
            
            // === 4e. minimumScaleFactor — Co text để vừa ===
            Text("Đoạn text dài sẽ tự thu nhỏ để vừa trong 1 dòng")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            // Scale xuống tối đa 50% kích thước gốc
            // Nếu vẫn không vừa → truncate
            // ⚠️ Dùng cẩn thận: text quá nhỏ → khó đọc
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. TEXT CONCATENATION — NỐI TEXT GIỮ STYLING            ║
// ╚══════════════════════════════════════════════════════════╝

// Operator + nối nhiều Text views, mỗi phần GIỮ style riêng.
// Kết quả vẫn là 1 Text view duy nhất (không phải HStack).

struct TextConcatenationDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // === 5a. Cơ bản: nối Text + Text ===
            Text("Xin chào, ")
                .foregroundStyle(.secondary)
            + Text("Huy")
                .bold()
                .foregroundStyle(.blue)
            + Text("!")
                .foregroundStyle(.secondary)
            
            // === 5b. Mix font sizes ===
            Text("$")
                .font(.body)
                .foregroundStyle(.secondary)
            + Text("99")
                .font(.system(size: 42, weight: .bold, design: .rounded))
            + Text(".99")
                .font(.title3)
                .foregroundStyle(.secondary)
            + Text(" /tháng")
                .font(.caption)
                .foregroundStyle(.tertiary)
            
            // === 5c. Inline icons ===
            Text("Trạng thái: ")
                .foregroundStyle(.secondary)
            + Text(Image(systemName: "checkmark.circle.fill"))
                .foregroundStyle(.green)
            + Text(" Đã xác minh")
                .bold()
                .foregroundStyle(.green)
            
            // === 5d. Required field indicator ===
            Text("Email ")
                .font(.headline)
            + Text("*")
                .foregroundStyle(.red)
                .font(.headline)
            
            // === 5e. Hashtags / Mentions ===
            Text("Bài viết về ")
            + Text("#SwiftUI")
                .bold()
                .foregroundStyle(.blue)
            + Text(" và ")
            + Text("#iOS")
                .bold()
                .foregroundStyle(.blue)
            + Text(" development")
            
            // === 5f. Terms & Conditions ===
            Text("Bằng việc tiếp tục, bạn đồng ý với ")
                .font(.footnote)
                .foregroundStyle(.secondary)
            + Text("[Điều khoản sử dụng](https://example.com/terms)")
                .font(.footnote)
            + Text(" và ")
                .font(.footnote)
                .foregroundStyle(.secondary)
            + Text("[Chính sách bảo mật](https://example.com/privacy)")
                .font(.footnote)
        }
        .padding()
    }
}

// ⚠️ GIỚI HẠN CỦA TEXT CONCATENATION:
// - Chỉ nối Text + Text (không nối Text + other View)
// - Modifier sau + áp dụng cho phần TRƯỚC đó, không phải toàn bộ
// - Không dùng được với @ViewBuilder conditions (if/else)
// - Kết quả là Text → vẫn dùng được .lineLimit(), .multilineTextAlignment()


// ╔══════════════════════════════════════════════════════════╗
// ║  6. MARKDOWN RENDERING (iOS 15+)                         ║
// ╚══════════════════════════════════════════════════════════╝

struct MarkdownDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // === 6a. Inline Markdown ===
            Text("**Bold** and *italic* text")
            Text("~~Strikethrough~~ text")
            Text("`inline code` block")
            Text("Visit [Apple](https://apple.com)")  // Tappable link!
            Text("**Bold *and italic* combined**")
            
            Divider()
            
            // === 6b. Markdown từ variable ===
            // ⚠️ String variable KHÔNG auto-parse Markdown!
            let raw = "**This won't be bold**"
            Text(raw) // → Hiện đúng "**This won't be bold**"
            
            // ✅ Phải dùng LocalizedStringKey hoặc AttributedString
            Text(LocalizedStringKey(raw)) // → This won't be bold (bold)
            
            // Hoặc init từ AttributedString
            if let md = try? AttributedString(markdown: raw) {
                Text(md) // → Bold!
            }
            
            Divider()
            
            // === 6c. Markdown link styling ===
            Text("Xem [tài liệu](https://docs.swift.org) để biết thêm.")
                .tint(.purple) // Đổi màu link
            
            // === 6d. Complex markdown ===
            let complex = """
            **SwiftUI** hỗ trợ *Markdown* trong `Text` view:
            - ~~Gạch ngang~~
            - **Bold *nested italic***
            - [Links](https://apple.com) tự động tappable
            """
            if let attr = try? AttributedString(markdown: complex) {
                Text(attr)
            }
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. ATTRIBUTEDSTRING — RICH TEXT NÂNG CAO                ║
// ╚══════════════════════════════════════════════════════════╝

struct AttributedStringDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // === 7a. Build AttributedString thủ công ===
            Text(buildHighlightedText())
            
            // === 7b. Từng phần styling khác nhau ===
            Text(buildPriceText())
            
            // === 7c. Link trong AttributedString ===
            Text(buildLinkText())
            
            // === 7d. Combine attributes ===
            Text(buildComplexText())
            
            // === 7e. Search highlight ===
            Text(highlightSearch(
                in: "SwiftUI là framework UI hiện đại của Apple cho iOS",
                query: "SwiftUI"
            ))
        }
        .padding()
    }
    
    func buildHighlightedText() -> AttributedString {
        var text = AttributedString("Chào mừng đến với SwiftUI!")
        
        // Style toàn bộ
        text.font = .body
        text.foregroundColor = .primary
        
        // Tìm range và style riêng
        if let range = text.range(of: "SwiftUI") {
            text[range].font = .body.bold()
            text[range].foregroundColor = .blue
        }
        
        return text
    }
    
    func buildPriceText() -> AttributedString {
        var dollar = AttributedString("$")
        dollar.font = .body
        dollar.foregroundColor = .secondary
        
        var amount = AttributedString("49")
        amount.font = .system(size: 36, weight: .bold, design: .rounded)
        
        var cents = AttributedString(".99")
        cents.font = .title3
        cents.foregroundColor = .secondary
        
        var period = AttributedString(" /năm")
        period.font = .caption
        period.foregroundColor = .tertiary
        
        return dollar + amount + cents + period
    }
    
    func buildLinkText() -> AttributedString {
        var text = AttributedString("Xem chi tiết tại ")
        text.font = .footnote
        text.foregroundColor = .secondary
        
        var link = AttributedString("trang web")
        link.font = .footnote
        link.foregroundColor = .blue
        link.underlineStyle = .single
        link.link = URL(string: "https://apple.com")
        // link.link → Text tự động tappable!
        
        return text + link
    }
    
    func buildComplexText() -> AttributedString {
        var result = AttributedString()
        
        var warning = AttributedString("⚠️ Cảnh báo: ")
        warning.font = .headline
        warning.foregroundColor = .orange
        
        var message = AttributedString("Hành động này ")
        message.font = .body
        
        var emphasis = AttributedString("không thể hoàn tác")
        emphasis.font = .body.bold()
        emphasis.foregroundColor = .red
        emphasis.underlineStyle = .single
        emphasis.underlineColor = .red
        
        var ending = AttributedString(".")
        ending.font = .body
        
        result.append(warning)
        result.append(message)
        result.append(emphasis)
        result.append(ending)
        return result
    }
    
    func highlightSearch(in source: String, query: String) -> AttributedString {
        var attributed = AttributedString(source)
        attributed.font = .body
        attributed.foregroundColor = .primary
        
        // Highlight tất cả occurrences
        var searchRange = attributed.startIndex
        while let range = attributed[searchRange...].range(of: query,
                    options: .caseInsensitive) {
            attributed[range].backgroundColor = .yellow.opacity(0.3)
            attributed[range].font = .body.bold()
            searchRange = range.upperBound
        }
        
        return attributed
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. DATE & NUMBER FORMATTING                             ║
// ╚══════════════════════════════════════════════════════════╝

struct FormattingDemo: View {
    let now = Date.now
    let price = 1_599_000.0
    let ratio = 0.156
    let bigNumber = 1_234_567
    let weight = Measurement(value: 68.5, unit: UnitMass.kilograms)
    let temp = Measurement(value: 32, unit: UnitTemperature.celsius)
    let bytes = Measurement(value: 2.5, unit: UnitInformationStorage.gigabytes)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // === 8a. Date styles ===
            Section("Date") {
                Text(now, format: .dateTime)
                // "Apr 11, 2026 at 2:30 PM"
                
                Text(now, format: .dateTime.day().month(.wide).year())
                // "April 11, 2026"
                
                Text(now, format: .dateTime.weekday(.wide))
                // "Saturday"
                
                Text(now, format: .dateTime.hour().minute())
                // "2:30 PM"
            }
            
            Divider()
            
            // === 8b. Number formats ===
            Section("Numbers") {
                Text(price, format: .currency(code: "VND"))
                // "₫1,599,000"
                
                Text(price, format: .currency(code: "USD"))
                // "$1,599,000.00"
                
                Text(ratio, format: .percent.precision(.fractionLength(1)))
                // "15.6%"
                
                Text(bigNumber, format: .number.grouping(.automatic))
                // "1,234,567"
                
                Text(bigNumber, format: .number.notation(.compactName))
                // "1.2M"
            }
            
            Divider()
            
            // === 8c. Measurement formats ===
            Section("Measurements") {
                Text(weight, format: .measurement(width: .abbreviated))
                // "68.5 kg"
                
                Text(temp, format: .measurement(width: .narrow))
                // "32°C"
                
                Text(bytes, format: .byteCount(style: .file))
                // "2.5 GB"
            }
            
            Divider()
            
            // === 8d. Relative date (live updating) ===
            Section("Live") {
                Text(now.addingTimeInterval(-120), style: .relative)
                // "2 minutes ago" (tự cập nhật!)
                
                Text(now.addingTimeInterval(3600), style: .timer)
                // Countdown live
            }
        }
        .padding()
    }
    
    func Section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.bold()).foregroundStyle(.blue)
            content()
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. TEXT TRANSITIONS & ANIMATIONS (iOS 17+)              ║
// ╚══════════════════════════════════════════════════════════╝

struct TextAnimationDemo: View {
    @State private var count = 0
    @State private var status = "Đang chờ"
    @State private var emoji = "😀"
    
    var body: some View {
        VStack(spacing: 24) {
            
            // === 9a. .contentTransition(.numericText()) ===
            // Số chuyển đổi mượt (rolling digits effect)
            Text("\(count)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .contentTransition(.numericText(value: Double(count)))
            
            HStack(spacing: 16) {
                Button("-") { withAnimation(.spring) { count -= 1 } }
                Button("+") { withAnimation(.spring) { count += 1 } }
            }
            .font(.title)
            
            Divider()
            
            // === 9b. .contentTransition(.interpolate) ===
            // Morph mượt giữa 2 text bất kỳ
            Text(status)
                .font(.title2.bold())
                .foregroundStyle(status == "Thành công" ? .green : .orange)
                .contentTransition(.interpolate)
            
            Button("Toggle") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    status = status == "Đang chờ" ? "Thành công" : "Đang chờ"
                }
            }
            
            Divider()
            
            // === 9c. .contentTransition(.identity) ===
            // Không animation (snap ngay lập tức)
            Text(emoji)
                .font(.system(size: 60))
                .contentTransition(.identity)
            
            Button("Random Emoji") {
                emoji = ["😀", "🚀", "🎉", "💡", "🔥"].randomElement()!
            }
            
            Divider()
            
            // === 9d. Symbol effects (SF Symbols) ===
            HStack(spacing: 24) {
                // Bounce
                Image(systemName: "bell.fill")
                    .font(.title)
                    .symbolEffect(.bounce, value: count)
                
                // Pulse
                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundStyle(.red)
                    .symbolEffect(.pulse)
                
                // Variable color
                Image(systemName: "wifi")
                    .font(.title)
                    .symbolEffect(.variableColor.iterative)
            }
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. TEXT SELECTION & INTERACTION                         ║
// ╚══════════════════════════════════════════════════════════╝

struct TextInteractionDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // === 10a. textSelection — Copy text (iOS 15+) ===
            Text("Long press để copy đoạn text này")
                .textSelection(.enabled)
            // User long press → highlight → Copy menu xuất hiện
            
            // Disable selection
            Text("Không thể copy")
                .textSelection(.disabled) // Mặc định
            
            // Apply cho tất cả child texts
            VStack(alignment: .leading) {
                Text("Dòng 1: có thể copy")
                Text("Dòng 2: cũng copy được")
                Text("Dòng 3: tất cả đều selectable")
            }
            .textSelection(.enabled)
            // Tất cả 3 dòng đều selectable
            
            Divider()
            
            // === 10b. Link tappable (Markdown) ===
            Text("Truy cập [Apple Developer](https://developer.apple.com)")
                .tint(.purple) // Màu link
            // Tap → mở URL tự động
            
            // === 10c. Combine Text + tappable ===
            // Muốn tap vào phần text cụ thể → dùng AttributedString + link
            Text(tappableText())
        }
        .padding()
    }
    
    func tappableText() -> AttributedString {
        var text = AttributedString("Bấm vào ")
        text.font = .body
        
        var link = AttributedString("đây")
        link.font = .body.bold()
        link.foregroundColor = .blue
        link.link = URL(string: "https://example.com")
        
        var ending = AttributedString(" để xem thêm.")
        ending.font = .body
        
        return text + link + ending
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. LOCALIZATION                                        ║
// ╚══════════════════════════════════════════════════════════╝

struct LocalizationDemo: View {
    let itemCount = 5
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // === 11a. Auto localization ===
            // Text("Hello") tự động tìm key "Hello" trong Localizable.strings
            Text("Hello") // → "Xin chào" (nếu có localization)
            
            // === 11b. String interpolation → localized ===
            Text("Welcome, \("Huy")")
            // Tìm key "Welcome, %@" trong strings file
            
            // === 11c. Verbatim → KHÔNG localize ===
            Text(verbatim: "API_KEY_12345")
            // Hiện đúng chuỗi gốc, bỏ qua localization
            
            // === 11d. Pluralization (String Catalog) ===
            // Trong String Catalog (.xcstrings):
            // key: "%lld items"
            // one: "%lld item"
            // other: "%lld items"
            Text("\(itemCount) items")
            // → "5 items" (English) / "5 mục" (Vietnamese)
            
            // === 11e. LocalizedStringKey explicit ===
            let key: LocalizedStringKey = "greeting_\("Huy")"
            Text(key)
        }
        .padding()
    }
}

// ⚠️ QUY TẮC LOCALIZATION:
//
// Text("string literal")     → TỰ ĐỘNG localize
// Text(stringVariable)       → KHÔNG localize (type String, not LocalizedStringKey)
// Text(verbatim: "...")       → KHÔNG localize (explicit)
// Text(LocalizedStringKey(v)) → Localize string variable
//
// Khi nào dùng verbatim:
// - Hiển thị data từ server (tên user, ID, API responses)
// - Debug text không cần dịch
// - Khi string variable đã đúng ngôn ngữ


// ╔══════════════════════════════════════════════════════════╗
// ║  12. PRODUCTION PATTERNS                                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 12a. Timer / Countdown ===

struct CountdownView: View {
    let targetDate: Date
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Sự kiện bắt đầu trong")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Live countdown — tự cập nhật mỗi giây
            Text(targetDate, style: .timer)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .monospacedDigit()
                // monospacedDigit: các số có cùng width → không nhảy layout
        }
    }
}

// === 12b. Stat Display — Animated Number ===

struct AnimatedStatView: View {
    let label: String
    let value: Int
    let prefix: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Text(prefix)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(value)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .contentTransition(.numericText(value: Double(value)))
                    .monospacedDigit()
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("Animated Stats") {
    @Previewable @State var followers = 1234
    
    VStack(spacing: 24) {
        HStack(spacing: 32) {
            AnimatedStatView(label: "Posts", value: 128, prefix: "")
            AnimatedStatView(label: "Followers", value: followers, prefix: "")
            AnimatedStatView(label: "Following", value: 345, prefix: "")
        }
        
        Button("Add Follower") {
            withAnimation(.spring) { followers += 1 }
        }
    }
    .padding()
}


// === 12c. Expandable / Read More Text ===

struct ExpandableText: View {
    let text: String
    let lineLimit: Int
    
    @State private var isExpanded = false
    @State private var isTruncated = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(text)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(
                    // Invisible text đo xem có bị truncate không
                    Text(text)
                        .lineLimit(lineLimit)
                        .background(GeometryReader { visible in
                            Text(text)
                                .lineLimit(nil)
                                .background(GeometryReader { full in
                                    Color.clear.onAppear {
                                        isTruncated = full.size.height > visible.size.height
                                    }
                                })
                        })
                        .hidden()
                )
                .animation(.easeInOut(duration: 0.25), value: isExpanded)
            
            if isTruncated {
                Button(isExpanded ? "Thu gọn" : "Xem thêm") {
                    isExpanded.toggle()
                }
                .font(.subheadline.bold())
                .foregroundStyle(.blue)
            }
        }
    }
}

#Preview("Expandable Text") {
    ExpandableText(
        text: "SwiftUI là framework UI khai báo (declarative) của Apple, ra mắt năm 2019. Nó cho phép developers xây dựng giao diện người dùng bằng cách mô tả WHAT (muốn gì) thay vì HOW (làm thế nào). SwiftUI tích hợp sâu với Swift language, tận dụng features như property wrappers, result builders, và macros để tạo ra API cực kỳ gọn gàng. Với mỗi phiên bản iOS mới, SwiftUI ngày càng mạnh mẽ hơn.",
        lineLimit: 3
    )
    .padding()
}


// === 12d. Gradient Masked Text (Visual Effect) ===

struct GradientText: View {
    let text: String
    let gradient: LinearGradient
    
    var body: some View {
        Text(text)
            .font(.system(size: 36, weight: .bold))
            .foregroundStyle(gradient)
    }
}

#Preview("Gradient Text") {
    VStack(spacing: 16) {
        GradientText(
            text: "Hello SwiftUI",
            gradient: LinearGradient(
                colors: [.blue, .purple, .pink],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        
        GradientText(
            text: "Premium ✨",
            gradient: LinearGradient(
                colors: [.yellow, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  13. REDACTION — PLACEHOLDER / SKELETON                   ║
// ╚══════════════════════════════════════════════════════════╝

struct RedactionDemo: View {
    @State private var isLoading = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nguyễn Văn Huy")
                        .font(.headline)
                    Text("Senior iOS Developer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text("Đây là mô tả dài về profile, có thể nhiều dòng text hiển thị ở đây khi dữ liệu đã tải xong.")
                .font(.body)
            
            HStack {
                Text("128 bài viết").font(.caption)
                Text("1.2K followers").font(.caption)
            }
        }
        .redacted(reason: isLoading ? .placeholder : [])
        // .placeholder → tất cả Text hiện dạng skeleton blocks
        // Hình ảnh, shapes cũng bị redacted
        
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { isLoading = false }
            }
        }
    }
}

// === Unredacted cho elements cụ thể ===
struct PartialRedactionDemo: View {
    var body: some View {
        VStack {
            Text("Loading...").unredacted() // LUÔN HIỆN, không bị skeleton
            Text("Sẽ bị redacted")
            Text("Cũng bị redacted")
        }
        .redacted(reason: .placeholder)
    }
}

// === Privacy redaction ===
struct PrivacyRedactionDemo: View {
    var body: some View {
        VStack {
            Text("Số dư: ₫15,000,000")
                .privacySensitive()
            // Trên Lock Screen widget → hiện placeholder
            // Mở khoá → hiện giá trị thật
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  14. ACCESSIBILITY                                       ║
// ╚══════════════════════════════════════════════════════════╝

struct AccessibleTextDemo: View {
    var body: some View {
        VStack(spacing: 12) {
            // Dynamic Type tự động scale với semantic fonts
            Text("Body text scales automatically")
                .font(.body)
                // User tăng text size trong Settings → text tự to lên
            
            // Cố định size: KHÔNG scale theo Dynamic Type
            Text("Fixed 14pt — không thay đổi")
                .font(.system(size: 14))
                // ⚠️ Tránh dùng fixed size cho content text
                // Chỉ dùng cho decorative hoặc constrained layouts
            
            // Custom accessibility label
            Text("$99.99")
                .accessibilityLabel("Chín mươi chín đô la chín mươi chín xu")
            
            // Combine nhiều Text thành 1 accessible element
            VStack {
                Text("Huy Nguyen").font(.headline)
                Text("iOS Developer").font(.subheadline)
            }
            .accessibilityElement(children: .combine)
            // VoiceOver đọc: "Huy Nguyen, iOS Developer"
            
            // Header trait (VoiceOver rotor navigation)
            Text("Phần Settings")
                .font(.title2)
                .accessibilityAddTraits(.isHeader)
        }
        .padding()
    }
}
```

// ╔══════════════════════════════════════════════════════════╗
// ║  15. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Markdown không hoạt động với String variable
//    let text = "**bold**"
//    Text(text)  // → Hiện "**bold**" (RAW, không parse)
//    ✅ FIX: Text(LocalizedStringKey(text))
//            hoặc Text(try! AttributedString(markdown: text))

// ❌ PITFALL 2: .foregroundColor deprecated
//    .foregroundColor(.red) // ⚠️ Deprecated iOS 17+
//    ✅ FIX: .foregroundStyle(.red) // Hỗ trợ gradient, hierarchical

// ❌ PITFALL 3: minimumScaleFactor khiến text quá nhỏ
//    .minimumScaleFactor(0.1) // Text có thể co còn 10%!
//    ✅ FIX: Dùng 0.5-0.7 là hợp lý, hoặc dùng lineLimit thay thế

// ❌ PITFALL 4: Timer text không monospacedDigit
//    Text("12:05:33") // Số có width khác nhau → layout nhảy
//    ✅ FIX: .monospacedDigit() cho timers, counters, prices

// ❌ PITFALL 5: Text concatenation + modifier order
//    (Text("A") + Text("B")).bold() // ❌ bold toàn bộ
//    Text("A").bold() + Text("B")   // ✅ chỉ A bold
//    Modifier đặt SAU + áp dụng cho TOÀN BỘ kết quả

// ❌ PITFALL 6: .textSelection(.enabled) trên Text concat
//    (Text("A").bold() + Text("B")).textSelection(.enabled)
//    // ⚠️ Có thể không hoạt động đúng trên một số iOS versions
//    ✅ FIX: Dùng 1 AttributedString thay vì Text concatenation

// ✅ BEST PRACTICES:
// 1. Semantic fonts (.body, .headline) thay vì fixed sizes
// 2. .foregroundStyle thay .foregroundColor (hỗ trợ gradient)
// 3. .monospacedDigit() cho số, timer, giá tiền
// 4. Text concatenation cho inline rich text (giữ 1 Text view)
// 5. AttributedString cho complex rich text + tappable links
// 6. .contentTransition(.numericText()) cho animated numbers
// 7. .redacted(reason: .placeholder) cho skeleton loading
// 8. .textSelection(.enabled) cho text user cần copy
// 9. Dynamic Type: test với .dynamicTypeSize(.accessibility5)
// 10. Localization: String literal → auto localize, variable → không
// 11. .privacySensitive() cho data nhạy cảm trên widgets
// 12. .accessibilityAddTraits(.isHeader) cho section titles

---

Text là view cơ bản nhất nhưng hệ thống typography và formatting của SwiftUI cực kỳ sâu. Mình sẽ giải thích toàn bộ từ cơ bản đến AttributedString và text animations.Mình đã tổng hợp toàn bộ kiến thức Text trong 15 phần. Đây là những điểm cốt lõi:

**Text tưởng đơn giản nhưng có chiều sâu** ở ba trục chính: **typography** (font system, weights, designs), **rich text** (concatenation, Markdown, AttributedString), và **formatting** (date, number, measurement tự động locale-aware).

**Năm phần giá trị nhất:**

**Phần 5 — Text Concatenation**: Operator `+` nối nhiều Text mà **mỗi phần giữ styling riêng**, kết quả vẫn là 1 Text view duy nhất (không phải HStack). Pattern kinh điển: pricing display `$` + `99` + `.99` + `/tháng` với 4 font sizes khác nhau, hoặc inline icon `Text(Image(systemName:))` nằm trong dòng text.

**Phần 6 & 7 — Markdown + AttributedString**: Gotcha lớn nhất là Markdown **chỉ hoạt động với string literal**, string variable phải qua `LocalizedStringKey()` hoặc `AttributedString(markdown:)`. AttributedString mạnh hơn: hỗ trợ `.link` property khiến text tự động tappable, `.backgroundColor` cho search highlight.

**Phần 9 — Text Animations (iOS 17+)**: `.contentTransition(.numericText())` tạo rolling digits effect cho counters/prices — chỉ 1 modifier mà hiệu ứng rất premium. `.interpolate` cho text morph mượt giữa 2 giá trị bất kỳ.

**Phần 12 — Expandable Text**: Pattern "Xem thêm / Thu gọn" hoàn chỉnh, dùng hidden Text + GeometryReader để detect truncation — kỹ thuật hay mà nhiều app cần.

**Phần 3 — `.monospacedDigit()`**: Modifier nhỏ nhưng critical cho mọi UI có số (timer, giá tiền, bảng thống kê). Không có nó thì layout nhảy liên tục khi số thay đổi vì mỗi digit có width khác nhau.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
