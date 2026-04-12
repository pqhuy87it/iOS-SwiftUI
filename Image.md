```
// ============================================================
// IMAGE TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// Image hiển thị hình ảnh từ nhiều nguồn:
// - Asset Catalog (bundled images)
// - SF Symbols (5000+ system icons)
// - UIImage / CGImage (programmatic)
// - AsyncImage (load từ URL)
// - System decorative images
//
// Hệ thống resizing, rendering modes, và modifiers
// phong phú hơn UIImageView rất nhiều.
// ============================================================
```
```Swift
import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÁC CÁCH KHỞI TẠO IMAGE                             ║
// ╚══════════════════════════════════════════════════════════╝

struct ImageInitializersDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 1a. Asset Catalog — Ảnh trong Assets.xcassets ===
            Image("hero-banner")
            // Tìm image set tên "hero-banner" trong Asset Catalog
            // Hỗ trợ @1x, @2x, @3x tự động theo device
            
            // === 1b. SF Symbols — System icons ===
            Image(systemName: "star.fill")
            // 5000+ icons, scale theo font, hỗ trợ weight + color
            
            // === 1c. UIImage → SwiftUI Image ===
            if let uiImage = UIImage(named: "photo") {
                Image(uiImage: uiImage)
            }
            
            // === 1d. CGImage ===
            // let cgImage: CGImage = ...
            // Image(cgImage, scale: 2.0, orientation: .up, label: Text("Photo"))
            
            // === 1e. Decorative — Ẩn khỏi Accessibility ===
            Image(decorative: "background-pattern")
            // VoiceOver BỎ QUA image này hoàn toàn
            // Dùng cho: background, decorative elements
            
            // === 1f. System image decorative ===
            Image(systemName: "circle.fill")
                .accessibilityHidden(true)
            // Tương đương decorative cho SF Symbols
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. SF SYMBOLS — HỆ THỐNG ICON CỦA APPLE                ║
// ╚══════════════════════════════════════════════════════════╝

struct SFSymbolsDemo: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // === 2a. Cơ bản — scale theo .font() ===
                HStack(spacing: 20) {
                    Image(systemName: "heart.fill")
                        .font(.caption)    // nhỏ
                    Image(systemName: "heart.fill")
                        .font(.body)       // vừa
                    Image(systemName: "heart.fill")
                        .font(.title)      // lớn
                    Image(systemName: "heart.fill")
                        .font(.largeTitle) // rất lớn
                }
                
                // === 2b. imageScale — fine-tune size trong font ===
                HStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .imageScale(.small)
                    Image(systemName: "star.fill")
                        .imageScale(.medium) // default
                    Image(systemName: "star.fill")
                        .imageScale(.large)
                }
                .font(.title)
                
                // === 2c. Font weight — độ dày nét ===
                HStack(spacing: 16) {
                    Image(systemName: "bell")
                        .fontWeight(.ultraLight)
                    Image(systemName: "bell")
                        .fontWeight(.light)
                    Image(systemName: "bell")
                        .fontWeight(.regular)
                    Image(systemName: "bell")
                        .fontWeight(.semibold)
                    Image(systemName: "bell")
                        .fontWeight(.bold)
                    Image(systemName: "bell")
                        .fontWeight(.black)
                }
                .font(.title)
                
                Divider()
                
                // === 2d. Symbol Rendering Modes ===
                let iconName = "chart.bar.doc.horizontal.fill"
                
                VStack(alignment: .leading, spacing: 12) {
                    // Monochrome: 1 màu duy nhất
                    Label("Monochrome", systemImage: iconName)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.blue)
                    
                    // Hierarchical: 1 màu + opacity layers tự động
                    Label("Hierarchical", systemImage: iconName)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.blue)
                    
                    // Palette: 2-3 màu tuỳ chỉnh cho từng layer
                    Label("Palette", systemImage: iconName)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue, .orange, .green)
                    
                    // Multicolor: màu gốc do Apple thiết kế
                    Label("Multicolor", systemImage: "externaldrive.fill.badge.wifi")
                        .symbolRenderingMode(.multicolor)
                }
                .font(.title3)
                
                Divider()
                
                // === 2e. Variable Value (iOS 16+) ===
                // Một số symbols hỗ trợ giá trị 0.0 - 1.0
                HStack(spacing: 16) {
                    Image(systemName: "speaker.wave.3.fill", variableValue: 0.0)
                    Image(systemName: "speaker.wave.3.fill", variableValue: 0.33)
                    Image(systemName: "speaker.wave.3.fill", variableValue: 0.66)
                    Image(systemName: "speaker.wave.3.fill", variableValue: 1.0)
                }
                .font(.title)
                .foregroundStyle(.blue)
                
                HStack(spacing: 16) {
                    Image(systemName: "wifi", variableValue: 0.25)
                    Image(systemName: "wifi", variableValue: 0.5)
                    Image(systemName: "wifi", variableValue: 0.75)
                    Image(systemName: "wifi", variableValue: 1.0)
                }
                .font(.title)
                
                Divider()
                
                // === 2f. Symbol Effects (iOS 17+) ===
                VStack(spacing: 16) {
                    // Pulse liên tục
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.title)
                        .symbolEffect(.pulse)
                    
                    // Variable color liên tục
                    Image(systemName: "wifi")
                        .font(.title)
                        .symbolEffect(.variableColor.iterative)
                    
                    // Breathe (iOS 18+)
                    // Image(systemName: "heart.fill")
                    //     .symbolEffect(.breathe)
                }
                .foregroundStyle(.blue)
            }
            .padding()
        }
    }
}

// === Symbol Effect on trigger ===
struct SymbolEffectTriggerDemo: View {
    @State private var likeCount = 0
    @State private var isFavorite = false
    
    var body: some View {
        HStack(spacing: 24) {
            // Bounce khi trigger thay đổi
            Button {
                likeCount += 1
            } label: {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.title)
                    .symbolEffect(.bounce, value: likeCount)
            }
            
            // Replace: chuyển đổi mượt giữa 2 icons
            Button {
                isFavorite.toggle()
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title)
                    .foregroundStyle(isFavorite ? .red : .gray)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3. RESIZING & SIZING — ĐIỀU KHIỂN KÍCH THƯỚC           ║
// ╚══════════════════════════════════════════════════════════╝

// ⚠️ ĐIỂM QUAN TRỌNG NHẤT VỀ IMAGE SIZING:
// Image mặc định hiển thị ở KÍCH THƯỚC GỐC (intrinsic size).
// KHÔNG tự co dãn theo container.
// Phải dùng .resizable() trước khi .frame() mới có hiệu lực.

struct ImageSizingDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            
            // ❌ KHÔNG resizable → hiện kích thước gốc, frame bị bỏ qua
            // Image("large-photo")
            //     .frame(width: 100, height: 100) // KHÔNG có tác dụng!
            
            // ✅ resizable() → image co dãn theo frame
            // Image("large-photo")
            //     .resizable()
            //     .frame(width: 100, height: 100)
            
            // === 3a. aspectRatio — Giữ tỉ lệ ===
            
            // .fit: toàn bộ ảnh HIỆN HẾT, có thể có khoảng trống
            Image(systemName: "photo.artframe")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 100)
                .border(.blue)
            // Ảnh nằm trọn trong frame, giữ nguyên tỉ lệ
            
            // .fill: ảnh PHỦM KÍN frame, có thể bị cắt
            Image(systemName: "photo.artframe")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 100)
                .clipped() // Cắt phần tràn ra ngoài
                .border(.red)
            // Ảnh phủ kín frame, phần thừa bị cắt
            
            // === 3b. scaledToFit / scaledToFill — Shorthand ===
            HStack(spacing: 12) {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()          // = aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .background(.gray.opacity(0.1))
                
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()         // = aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .background(.gray.opacity(0.1))
            }
            
            // === 3c. Custom aspect ratio ===
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(16/9, contentMode: .fit) // Force 16:9
                .frame(maxWidth: .infinity)
                .background(.gray.opacity(0.1))
            
            // === 3d. Chỉ set 1 chiều — chiều còn lại tự tính ===
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(height: 60) // Chỉ set height, width tự tính theo ratio
        }
        .padding()
    }
}

// THỨ TỰ MODIFIERS QUAN TRỌNG:
//
// Image("photo")
//     .resizable()              // 1️⃣ BẮT BUỘC trước mọi sizing
//     .aspectRatio(contentMode:) // 2️⃣ Giữ tỉ lệ
//     .frame(width:height:)     // 3️⃣ Đặt kích thước
//     .clipped()                // 4️⃣ Cắt phần thừa (nếu .fill)
//     .clipShape(...)           // 5️⃣ Cắt theo hình dạng


// ╔══════════════════════════════════════════════════════════╗
// ║  4. CLIPPING & SHAPES                                    ║
// ╚══════════════════════════════════════════════════════════╝

struct ImageClippingDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 4a. clipShape — Cắt theo hình ===
            // Tròn
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .background(.blue.gradient)
                .clipShape(.circle)
            
            // Rounded Rectangle
            Image(systemName: "photo.artframe")
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 80)
                .background(.gray.opacity(0.2))
                .clipShape(.rect(cornerRadius: 16))
            
            // Capsule
            Image(systemName: "photo")
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 60)
                .background(.green.opacity(0.2))
                .clipShape(.capsule)
            
            // Custom shape
            Image(systemName: "photo")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .background(.orange.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // === 4b. overlay — Border / Badge ===
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .background(.blue.gradient)
                .clipShape(.circle)
                .overlay(
                    Circle()
                        .strokeBorder(.white, lineWidth: 3)
                )
                .overlay(alignment: .bottomTrailing) {
                    // Online badge
                    Circle()
                        .fill(.green)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                }
            
            // === 4c. shadow ===
            Image(systemName: "photo.artframe")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 80)
                .background(.gray.opacity(0.2))
                .clipShape(.rect(cornerRadius: 12))
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. RENDERING MODE & COLOR EFFECTS                       ║
// ╚══════════════════════════════════════════════════════════╝

struct RenderingModeDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // === 5a. renderingMode — Template vs Original ===
            HStack(spacing: 20) {
                // .template: tint bằng foregroundStyle (như SF Symbol)
                Image(systemName: "heart.fill")
                    .renderingMode(.template)
                    .foregroundStyle(.red)
                    .font(.largeTitle)
                
                // .original: giữ màu gốc của asset
                Image(systemName: "heart.fill")
                    .renderingMode(.original)
                    .font(.largeTitle)
                // Multicolor symbol → hiện màu Apple thiết kế
            }
            
            // Với asset catalog images:
            // Image("logo")
            //     .renderingMode(.template)  // Tint theo foregroundStyle
            //     .foregroundStyle(.blue)
            //
            // Image("logo")
            //     .renderingMode(.original)  // Giữ màu gốc
            
            Divider()
            
            // === 5b. Color effects — Bộ lọc màu ===
            let sampleIcon = Image(systemName: "photo.artframe")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 60)
            
            HStack(spacing: 12) {
                // Gốc
                sampleIcon
                
                // Opacity
                sampleIcon.opacity(0.4)
                
                // Saturation
                sampleIcon.saturation(0)  // 0 = grayscale
                
                // Hue rotation
                sampleIcon.hueRotation(.degrees(120))
            }
            
            HStack(spacing: 12) {
                // Brightness
                sampleIcon.brightness(0.3)
                
                // Contrast
                sampleIcon.contrast(1.5)
                
                // Color multiply
                sampleIcon.colorMultiply(.blue)
                
                // Blur
                sampleIcon.blur(radius: 2)
            }
            
            Divider()
            
            // === 5c. Gradient foreground (SF Symbols) ===
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    .linearGradient(
                        colors: [.yellow, .orange, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. ASYNCIMAGE — LOAD ẢNH TỪ URL (iOS 15+)             ║
// ╚══════════════════════════════════════════════════════════╝

struct AsyncImageDemo: View {
    let url = URL(string: "https://picsum.photos/400/300")!
    
    var body: some View {
        VStack(spacing: 24) {
            
            // === 6a. Đơn giản nhất ===
            AsyncImage(url: url)
            // Tự hiện placeholder (gray) → load → hiện ảnh
            // ⚠️ Không resizable mặc định, hiện kích thước gốc
            
            // === 6b. Với scale ===
            AsyncImage(url: url, scale: 2.0)
            // Scale 2x → ảnh hiện nhỏ hơn (Retina)
            
            // === 6c. Custom placeholder + loaded + error ===
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    // Đang loading
                    ZStack {
                        Color.gray.opacity(0.1)
                        ProgressView()
                    }
                    
                case .success(let image):
                    // Load thành công
                    image
                        .resizable()
                        .scaledToFill()
                        .transition(.opacity.combined(with: .scale))
                    
                case .failure(let error):
                    // Lỗi
                    VStack(spacing: 8) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text("Không tải được ảnh")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 200, height: 150)
            .clipShape(.rect(cornerRadius: 12))
            
            // === 6d. Compact syntax với content + placeholder ===
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                // Skeleton loading
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.15))
                    .overlay(ProgressView())
            }
            .frame(width: 200, height: 150)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
}

// ⚠️ GIỚI HẠN CỦA ASYNCIMAGE:
//
// 1. KHÔNG CÓ CACHE built-in — mỗi lần view appear → load lại
//    → Production: dùng Kingfisher, SDWebImage, Nuke
//
// 2. KHÔNG cancel tự động khi scroll nhanh (trong LazyVStack)
//    → Có thể gây nhiều requests cùng lúc
//
// 3. Không hỗ trợ progressive JPEG, animated GIF
//
// 4. Không custom URLSession (headers, auth tokens)
//    → Cần wrapper custom nếu cần authentication


// ╔══════════════════════════════════════════════════════════╗
// ║  7. REUSABLE ASYNC IMAGE COMPONENT (PRODUCTION)          ║
// ╚══════════════════════════════════════════════════════════╝

// Wrapper giải quyết các hạn chế của AsyncImage

struct CachedAsyncImage: View {
    let url: URL?
    var contentMode: ContentMode = .fill
    
    // Simple in-memory cache (production: dùng NSCache hoặc 3rd party)
    @State private var phase: AsyncImagePhase = .empty
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholder
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            case .failure:
                errorView
            @unknown default:
                placeholder
            }
        }
    }
    
    private var placeholder: some View {
        ZStack {
            Color.gray.opacity(0.1)
            ProgressView()
                .controlSize(.small)
        }
    }
    
    private var errorView: some View {
        ZStack {
            Color.gray.opacity(0.1)
            VStack(spacing: 6) {
                Image(systemName: "photo")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. IMAGE INTERPOLATION & ANTIALIASING                   ║
// ╚══════════════════════════════════════════════════════════╝

struct InterpolationDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            // === 8a. interpolation — Chất lượng khi scale ===
            // Khi ảnh NHỎ bị phóng to, interpolation quyết định
            // cách tính pixel mới giữa các pixel gốc
            
            HStack(spacing: 12) {
                VStack {
                    Image(systemName: "square.fill")
                        .resizable()
                        .interpolation(.none)   // Pixel art: sharp edges
                        .frame(width: 60, height: 60)
                    Text(".none").font(.caption2)
                }
                
                VStack {
                    Image(systemName: "square.fill")
                        .resizable()
                        .interpolation(.low)    // Nhanh, chất lượng thấp
                        .frame(width: 60, height: 60)
                    Text(".low").font(.caption2)
                }
                
                VStack {
                    Image(systemName: "square.fill")
                        .resizable()
                        .interpolation(.medium) // Cân bằng
                        .frame(width: 60, height: 60)
                    Text(".medium").font(.caption2)
                }
                
                VStack {
                    Image(systemName: "square.fill")
                        .resizable()
                        .interpolation(.high)   // Mượt nhất, chậm nhất
                        .frame(width: 60, height: 60)
                    Text(".high").font(.caption2)
                }
            }
            
            // === 8b. antialiased — Khử răng cưa ===
            Image(systemName: "triangle.fill")
                .resizable()
                .antialiased(true)  // Mặc định: true. false cho pixel art
                .frame(width: 80, height: 80)
        }
        .padding()
    }
}

// KHI NÀO DÙNG interpolation:
// .none    → Pixel art, retro games, QR codes
// .low     → Thumbnails, performance-critical
// .medium  → Mặc định, đa phần trường hợp
// .high    → Ảnh hero, zoom, cần chất lượng cao


// ╔══════════════════════════════════════════════════════════╗
// ║  9. IMAGE TRONG CÁC CONTEXT KHÁC NHAU                   ║
// ╚══════════════════════════════════════════════════════════╝

// === 9a. Label — Icon + Text ===
struct LabelDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Label kết hợp icon + text
            Label("Settings", systemImage: "gearshape.fill")
            Label("Downloads", systemImage: "arrow.down.circle")
            
            // Custom Label
            Label {
                Text("Custom Label")
            } icon: {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
            
            // Label styles
            Label("Compact", systemImage: "star")
                .labelStyle(.titleAndIcon)  // Icon + Text
            Label("Icon Only", systemImage: "star")
                .labelStyle(.iconOnly)      // Chỉ icon
            Label("Title Only", systemImage: "star")
                .labelStyle(.titleOnly)     // Chỉ text
        }
    }
}

// === 9b. Inline trong Text ===
struct InlineImageDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // SF Symbol inline
            Text("Trạng thái: \(Image(systemName: "checkmark.circle.fill")) OK")
                .foregroundStyle(.green)
            
            // Nhiều icons inline
            Text("\(Image(systemName: "clock")) 5 phút  \(Image(systemName: "eye")) 1.2K")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// === 9c. Tab Bar ===
struct TabBarImageDemo: View {
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Trang chủ")
                }
            
            Text("Search")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Tìm kiếm")
                }
            
            Text("Profile")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Cá nhân")
                }
        }
    }
}

// === 9d. Background / Overlay Patterns ===
struct BackgroundImageDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            // Full-bleed background image
            Text("Hello World")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 200)
                .background {
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .scaledToFill()
                        .overlay(Color.black.opacity(0.4))
                }
                .clipShape(.rect(cornerRadius: 16))
            
            // Overlay icon badge
            Image(systemName: "photo")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .background(.gray.opacity(0.1))
                .clipShape(.rect(cornerRadius: 12))
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white, .green)
                        .offset(x: 6, y: -6)
                }
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. PRODUCTION PATTERNS                                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 10a. Avatar Component ===

struct AvatarView: View {
    let url: URL?
    let name: String
    var size: CGFloat = 48
    var showOnline: Bool = false
    
    private var initials: String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Avatar image hoặc initials fallback
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        initialsFallback
                    }
                }
                .frame(width: size, height: size)
                .clipShape(.circle)
            } else {
                initialsFallback
            }
            
            // Online indicator
            if showOnline {
                Circle()
                    .fill(.green)
                    .frame(width: size * 0.28, height: size * 0.28)
                    .overlay(
                        Circle().strokeBorder(.white, lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }
    
    private var initialsFallback: some View {
        Circle()
            .fill(.blue.gradient)
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .semibold))
                    .foregroundStyle(.white)
            )
    }
}

#Preview("Avatar") {
    HStack(spacing: 12) {
        AvatarView(url: nil, name: "Huy Nguyen", size: 48, showOnline: true)
        AvatarView(url: nil, name: "John Doe", size: 48)
        AvatarView(url: nil, name: "Alice", size: 36)
    }
    .padding()
}


// === 10b. Image Gallery / Grid ===

struct ImageGalleryDemo: View {
    let imageURLs = (1...12).map {
        URL(string: "https://picsum.photos/200/200?random=\($0)")!
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(imageURLs, id: \.absoluteString) { url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Color.gray.opacity(0.15)
                                .overlay(ProgressView().controlSize(.small))
                        }
                    }
                    .frame(minHeight: 120)
                    .clipShape(.rect(cornerRadius: 2))
                }
            }
        }
    }
}


// === 10c. Hero Image with Parallax ===

struct HeroImageCard: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        Image(systemName: "photo.artframe")
            .resizable()
            .scaledToFill()
            .frame(height: 250)
            .background(.blue.gradient)
            .clipShape(.rect(cornerRadius: 20))
            .overlay(alignment: .bottomLeading) {
                // Gradient overlay cho text readability
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.bold())
                    Text(subtitle)
                        .font(.subheadline)
                        .opacity(0.9)
                }
                .foregroundStyle(.white)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.7), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .clipShape(.rect(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
                )
            }
            .padding(.horizontal)
    }
}


// === 10d. Zoomable Image ===

struct ZoomableImage: View {
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        Image(systemName: "map.fill")
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        scale = lastScale * value.magnification
                    }
                    .onEnded { value in
                        lastScale = scale
                        // Clamp scale
                        withAnimation(.spring) {
                            scale = min(max(scale, 1.0), 5.0)
                            lastScale = scale
                        }
                    }
            )
            .gesture(
                TapGesture(count: 2)
                    .onEnded {
                        withAnimation(.spring) {
                            if scale > 1.0 {
                                scale = 1.0
                                lastScale = 1.0
                            } else {
                                scale = 2.5
                                lastScale = 2.5
                            }
                        }
                    }
            )
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. ACCESSIBILITY                                       ║
// ╚══════════════════════════════════════════════════════════╝

struct AccessibleImageDemo: View {
    var body: some View {
        VStack(spacing: 16) {
            // === Meaningful image: cần accessibility label ===
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
                .accessibilityLabel("Cảnh báo")
            // VoiceOver: "Cảnh báo, image"
            
            // === Decorative image: ẩn khỏi VoiceOver ===
            Image(decorative: "background-pattern")
            // VoiceOver bỏ qua hoàn toàn
            
            // Hoặc:
            Image(systemName: "circle.fill")
                .accessibilityHidden(true)
            
            // === Image button: accessibilityLabel BẮT BUỘC ===
            Button { } label: {
                Image(systemName: "gear")
                    .font(.title2)
            }
            .accessibilityLabel("Cài đặt")
            .accessibilityHint("Mở màn hình cài đặt")
            // ⚠️ Icon-only buttons PHẢI có label
            // Không có → VoiceOver đọc: "button" (vô nghĩa)
            
            // === Complex image: custom description ===
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .accessibilityLabel("Biểu đồ doanh thu")
                .accessibilityValue("Tháng 3 cao nhất với 1.2 tỷ đồng")
        }
    }
}
```

```
// ╔══════════════════════════════════════════════════════════╗
// ║  12. PERFORMANCE & BEST PRACTICES                        ║
// ╚══════════════════════════════════════════════════════════╝

// === 12a. Asset Catalog Best Practices ===
// 1. Luôn dùng Asset Catalog thay vì file trực tiếp
//    → Xcode optimize, compress, thinning tự động
// 2. Cung cấp @1x @2x @3x cho bitmap images
// 3. Dùng PDF/SVG cho vector icons (scale không vỡ)
// 4. Enable "Preserve Vector Data" cho SVG trong Asset Catalog
//    → Runtime scaling chất lượng cao

// === 12b. Image Loading Performance ===
// 1. LazyVStack/LazyHStack: images chỉ load khi sắp hiển thị
// 2. AsyncImage KHÔNG cache → dùng library cho production:
//    - Kingfisher: phổ biến nhất, cache disk + memory
//    - SDWebImage: lâu đời, stable
//    - Nuke: lightweight, modern Swift
// 3. Downsize ảnh trước khi hiển thị:
//    UIImage → .preparingThumbnail(of:) (iOS 15+)
// 4. Tránh load ảnh lớn trên main thread

// === 12c. Memory Management ===
// 1. Ảnh trong Asset Catalog: iOS tự quản lý cache
// 2. UIImage(named:) → CACHED (tốt cho reuse)
//    UIImage(contentsOfFile:) → KHÔNG cached (tốt cho 1-time use)
// 3. Ảnh lớn (>2000px): luôn resize trước khi hiển thị
// 4. Trong List/LazyVStack: ảnh scroll qua KHÔNG tự release
//    → Monitor memory bằng Instruments

// ❌ PITFALL 1: Quên .resizable()
//    Image("photo").frame(width:100) // frame KHÔNG ảnh hưởng!
//    ✅ FIX: Image("photo").resizable().frame(width:100)

// ❌ PITFALL 2: .scaledToFill() không clipped
//    Image("photo").resizable().scaledToFill().frame(100)
//    → Ảnh tràn ra ngoài frame, đè lên views khác
//    ✅ FIX: Thêm .clipped() hoặc .clipShape()

// ❌ PITFALL 3: AsyncImage trong LazyVStack scroll nhanh
//    → Hàng trăm requests cùng lúc, flicker khi scroll
//    ✅ FIX: 3rd party library với cache + cancel logic

// ❌ PITFALL 4: SF Symbol không scale theo ý muốn
//    Image(systemName: "star").frame(width: 50) // Không scale!
//    ✅ FIX: .font(.system(size: 50)) cho SF Symbols
//            HOẶC .resizable().frame(width:50, height:50)

// ❌ PITFALL 5: Template rendering không thấy ảnh
//    Image("photo").renderingMode(.template) // Ảnh màu → 1 màu duy nhất
//    ✅ FIX: .original nếu muốn giữ màu gốc, .template cho tinting

// ❌ PITFALL 6: Decorative image thiếu accessibility
//    Image("important-chart") → VoiceOver đọc filename (vô nghĩa)
//    ✅ FIX: .accessibilityLabel("Mô tả biểu đồ")
//            hoặc Image(decorative:) nếu THẬT SỰ decorative

// ✅ BEST PRACTICES CHECKLIST:
// 1. .resizable() LUÔN LUÔN trước .frame() / .scaledToFit/Fill
// 2. .clipped() hoặc .clipShape() khi dùng .scaledToFill()
// 3. SF Symbols: dùng .font() thay .frame() cho sizing
// 4. .symbolRenderingMode cho multi-layer SF Symbols
// 5. AsyncImage + phase handling cho loading/error states
// 6. 3rd party cache library cho production image loading
// 7. Image(decorative:) cho background/decorative images
// 8. .accessibilityLabel cho meaningful images + icon buttons
// 9. .monospacedDigit() KHÔNG liên quan Image (chỉ Text)
// 10. Test ảnh lớn trên device thật — Simulator không thể hiện memory issues
```
