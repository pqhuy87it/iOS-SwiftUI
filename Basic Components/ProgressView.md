```Swift
// ============================================================
// PROGRESSVIEW TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// ProgressView hiển thị tiến trình hoạt động:
// - Indeterminate: spinner xoay (không biết bao lâu)
// - Determinate: thanh tiến trình 0% → 100% (biết tiến trình)
//
// Tương đương UIActivityIndicatorView + UIProgressView trong UIKit.
//
// Hệ thống API:
// - 2 loại: indeterminate (spinner) & determinate (bar)
// - Built-in styles: .automatic, .linear, .circular
// - Custom ProgressViewStyle: tạo giao diện hoàn toàn mới
// - Tích hợp async/await, Observation, Timer
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. INDETERMINATE — SPINNER (KHÔNG BIẾT TIẾN TRÌNH)      ║
// ╚══════════════════════════════════════════════════════════╝

struct IndeterminateDemo: View {
    var body: some View {
        VStack(spacing: 28) {
            
            // === 1a. Đơn giản nhất ===
            ProgressView()
            // Spinner xoay liên tục, không label
            
            // === 1b. Với label text ===
            ProgressView("Đang tải...")
            // Spinner + text bên cạnh (layout tuỳ style)
            
            // === 1c. Custom label view ===
            ProgressView {
                Label("Đang xử lý", systemImage: "arrow.triangle.2.circlepath")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // === 1d. controlSize — Kích thước ===
            HStack(spacing: 30) {
                VStack {
                    ProgressView().controlSize(.mini)
                    Text(".mini").font(.caption2)
                }
                VStack {
                    ProgressView().controlSize(.small)
                    Text(".small").font(.caption2)
                }
                VStack {
                    ProgressView().controlSize(.regular)
                    Text(".regular").font(.caption2)
                }
                VStack {
                    ProgressView().controlSize(.large)
                    Text(".large").font(.caption2)
                }
                VStack {
                    ProgressView().controlSize(.extraLarge) // iOS 17+
                    Text(".extraLarge").font(.caption2)
                }
            }
            
            // === 1e. Tint color ===
            HStack(spacing: 24) {
                ProgressView().tint(.red)
                ProgressView().tint(.blue)
                ProgressView().tint(.green)
                ProgressView().tint(.orange)
            }
            .controlSize(.large)
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. DETERMINATE — THANH TIẾN TRÌNH (BIẾT % HOÀN THÀNH)  ║
// ╚══════════════════════════════════════════════════════════╝

struct DeterminateDemo: View {
    @State private var progress = 0.35
    
    var body: some View {
        VStack(spacing: 24) {
            
            // === 2a. value only (0.0 ... 1.0) ===
            ProgressView(value: progress)
            // 0.0 = 0%, 1.0 = 100%
            // Hiển thị: thanh ngang filled đến 35%
            
            // === 2b. value + total (custom range) ===
            ProgressView(value: 7, total: 10)
            // 7/10 = 70%
            
            // === 2c. value + label ===
            ProgressView(value: progress) {
                Text("Đang tải dữ liệu")
                    .font(.subheadline)
            }
            
            // === 2d. value + label + currentValueLabel ===
            ProgressView(value: progress, total: 1.0) {
                Text("Upload ảnh")
                    .font(.subheadline)
            } currentValueLabel: {
                Text("\(Int(progress * 100))%")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            
            // === 2e. Slider để test ===
            Slider(value: $progress, in: 0...1, step: 0.05)
                .padding(.top)
            
            Text("Progress: \(progress, specifier: "%.0f")%")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  3. PROGRESSVIEW STYLES                                  ║
// ╚══════════════════════════════════════════════════════════╝

struct ProgressStylesDemo: View {
    @State private var progress = 0.6
    
    var body: some View {
        VStack(spacing: 28) {
            
            // === 3a. .automatic (Default) ===
            // Indeterminate → spinner, Determinate → linear bar
            Section(".automatic") {
                ProgressView()                         // Spinner
                ProgressView(value: progress)          // Linear bar
            }
            
            // === 3b. .linear — Thanh ngang ===
            Section(".linear") {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                
                // Indeterminate linear: thanh chạy qua lại
                ProgressView()
                    .progressViewStyle(.linear)
            }
            
            // === 3c. .circular — Vòng tròn ===
            Section(".circular") {
                HStack(spacing: 30) {
                    // Indeterminate circular = spinner mặc định
                    ProgressView()
                        .progressViewStyle(.circular)
                    
                    // Determinate circular = vòng tròn fill dần
                    ProgressView(value: progress)
                        .progressViewStyle(.circular)
                }
            }
        }
        .padding()
    }
    
    func Section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption.bold()).foregroundStyle(.blue)
            content()
        }
    }
}

// ┌──────────────────────┬────────────────────────────────────┐
// │ Style                │ Mô tả                              │
// ├──────────────────────┼────────────────────────────────────┤
// │ .automatic           │ Platform chọn: spinner / linear bar│
// │ .linear              │ Thanh ngang (thin bar)             │
// │ .circular            │ Vòng tròn (spinner hoặc ring)     │
// └──────────────────────┴────────────────────────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  4. PROGRESSVIEW VỚI ASYNC/AWAIT                         ║
// ╚══════════════════════════════════════════════════════════╝

// === 4a. Simple loading state ===

@Observable
final class DataLoader {
    var items: [String] = []
    var isLoading = false
    var progress: Double = 0
    var error: String?
    
    func load() async {
        isLoading = true
        progress = 0
        error = nil
        
        // Simulate step-by-step loading
        for i in 1...10 {
            try? await Task.sleep(for: .milliseconds(300))
            progress = Double(i) / 10.0
        }
        
        items = (1...20).map { "Item \($0)" }
        isLoading = false
    }
}

struct AsyncLoadingDemo: View {
    @State private var loader = DataLoader()
    
    var body: some View {
        NavigationStack {
            Group {
                if loader.isLoading {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView(value: loader.progress) {
                            Text("Đang tải dữ liệu...")
                                .font(.subheadline)
                        } currentValueLabel: {
                            Text("\(Int(loader.progress * 100))%")
                                .font(.caption.monospaced())
                        }
                        .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if loader.items.isEmpty {
                    ContentUnavailableView("Chưa có dữ liệu",
                        systemImage: "tray",
                        description: Text("Tap để tải"))
                    
                } else {
                    // Content
                    List(loader.items, id: \.self) { item in
                        Text(item)
                    }
                }
            }
            .navigationTitle("Data Loader")
            .toolbar {
                Button("Tải") {
                    Task { await loader.load() }
                }
            }
        }
    }
}

// === 4b. Inline loading trong button ===

struct InlineLoadingButton: View {
    @State private var isLoading = false
    
    var body: some View {
        Button {
            isLoading = true
            Task {
                try? await Task.sleep(for: .seconds(2))
                isLoading = false
            }
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                }
                Text(isLoading ? "Đang gửi..." : "Gửi yêu cầu")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.blue, in: .rect(cornerRadius: 12))
            .foregroundStyle(.white)
            .font(.headline)
        }
        .disabled(isLoading)
        .padding()
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. TRONG CÁC CONTEXT KHÁC NHAU                         ║
// ╚══════════════════════════════════════════════════════════╝

// === 5a. Overlay loading (ZStack) ===

struct OverlayLoadingDemo: View {
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Main content
            List(0..<20) { i in Text("Row \(i)") }
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)
            
            // Loading overlay
            if isLoading {
                ZStack {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 14) {
                        ProgressView()
                            .controlSize(.large)
                            .tint(.blue)
                        Text("Đang xử lý...")
                            .font(.subheadline)
                    }
                    .padding(28)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .onAppear {
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isLoading = false
            }
        }
    }
}

// === 5b. Trong List row (inline) ===

struct ListInlineProgress: View {
    var body: some View {
        List {
            // Download item with progress
            HStack {
                Image(systemName: "doc.fill")
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 4) {
                    Text("document.pdf")
                        .font(.subheadline)
                    ProgressView(value: 0.65)
                        .tint(.blue)
                }
                Spacer()
                Text("65%")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            
            // Loading item
            HStack {
                Image(systemName: "photo.fill")
                    .foregroundStyle(.green)
                Text("image.png")
                    .font(.subheadline)
                Spacer()
                ProgressView()
                    .controlSize(.small)
            }
            
            // Completed item
            HStack {
                Image(systemName: "music.note")
                    .foregroundStyle(.purple)
                Text("song.mp3")
                    .font(.subheadline)
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }
}

// === 5c. Pull-to-refresh (tự động ProgressView) ===

struct PullToRefreshDemo: View {
    @State private var items = (1...10).map { "Item \($0)" }
    
    var body: some View {
        List(items, id: \.self) { item in
            Text(item)
        }
        .refreshable {
            // SwiftUI TỰ ĐỘNG hiện ProgressView spinner
            try? await Task.sleep(for: .seconds(1.5))
            items.insert("New \(Int.random(in: 100...999))", at: 0)
            // Spinner TỰ ĐỘNG ẩn khi async hoàn thành
        }
    }
}

// === 5d. Trong Navigation / Toolbar ===

struct ToolbarProgressDemo: View {
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            List(0..<20) { i in Text("Row \(i)") }
                .navigationTitle("Feed")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if isLoading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Button("Refresh") { isLoading = true }
                        }
                    }
                }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. CUSTOM PROGRESSVIEW STYLE                            ║
// ╚══════════════════════════════════════════════════════════╝

// ProgressViewStyle protocol:
// func makeBody(configuration: Configuration) -> some View
//
// Configuration cung cấp:
// - configuration.fractionCompleted: Double? (nil = indeterminate)
// - configuration.label: Label view
// - configuration.currentValueLabel: CurrentValueLabel view

// === 6a. Gauge / Dashboard Style ===

struct GaugeProgressStyle: ProgressViewStyle {
    var strokeWidth: CGFloat = 10
    var size: CGFloat = 100
    var color: Color = .blue
    
    func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0
        
        VStack(spacing: 8) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(.gray.opacity(0.15), lineWidth: strokeWidth)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        color.gradient,
                        style: StrokeStyle(
                            lineWidth: strokeWidth,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.5), value: progress)
                
                // Center text
                VStack(spacing: 2) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                        .contentTransition(.numericText(value: progress))
                    
                    configuration.currentValueLabel
                        .font(.system(size: size * 0.1))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: size, height: size)
            
            configuration.label
                .font(.subheadline)
        }
    }
}

extension ProgressViewStyle where Self == GaugeProgressStyle {
    static var gauge: GaugeProgressStyle { GaugeProgressStyle() }
    static func gauge(size: CGFloat, color: Color = .blue) -> GaugeProgressStyle {
        GaugeProgressStyle(size: size, color: color)
    }
}


// === 6b. Step Progress Style (Wizard) ===

struct StepProgressStyle: ProgressViewStyle {
    let totalSteps: Int
    var activeColor: Color = .blue
    
    func makeBody(configuration: Configuration) -> some View {
        let currentStep = Int((configuration.fractionCompleted ?? 0) * Double(totalSteps))
        
        VStack(spacing: 8) {
            configuration.label
                .font(.subheadline.weight(.medium))
            
            HStack(spacing: 4) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    // Connector line
                    if step > 0 {
                        Rectangle()
                            .fill(step <= currentStep ? activeColor : .gray.opacity(0.2))
                            .frame(height: 2)
                    }
                    
                    // Step circle
                    ZStack {
                        Circle()
                            .fill(step <= currentStep ? activeColor : .gray.opacity(0.15))
                            .frame(width: 28, height: 28)
                        
                        if step < currentStep {
                            Image(systemName: "checkmark")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                        } else {
                            Text("\(step + 1)")
                                .font(.caption2.bold())
                                .foregroundStyle(step == currentStep ? .white : .secondary)
                        }
                    }
                }
            }
            
            configuration.currentValueLabel
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}


// === 6c. Dots Loading Style (Indeterminate) ===

struct DotsProgressStyle: ProgressViewStyle {
    @State private var phase = 0
    
    func makeBody(configuration: Configuration) -> some View {
        // Chỉ dùng cho indeterminate
        HStack(spacing: 6) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(.blue)
                    .frame(width: 10, height: 10)
                    .scaleEffect(phase == i ? 1.3 : 0.7)
                    .opacity(phase == i ? 1 : 0.4)
            }
        }
        .animation(
            .easeInOut(duration: 0.4).repeatForever(autoreverses: false),
            value: phase
        )
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                phase = (phase + 1) % 3
            }
        }
    }
}

extension ProgressViewStyle where Self == DotsProgressStyle {
    static var dots: DotsProgressStyle { DotsProgressStyle() }
}


// === 6d. Gradient Bar Style ===

struct GradientBarProgressStyle: ProgressViewStyle {
    var gradient: LinearGradient
    var height: CGFloat = 8
    
    init(colors: [Color] = [.blue, .purple], height: CGFloat = 8) {
        self.gradient = LinearGradient(
            colors: colors,
            startPoint: .leading,
            endPoint: .trailing
        )
        self.height = height
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0
        
        VStack(alignment: .leading, spacing: 6) {
            // Label row
            HStack {
                configuration.label
                    .font(.subheadline)
                Spacer()
                configuration.currentValueLabel
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            
            // Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(.gray.opacity(0.15))
                    
                    // Filled track
                    Capsule()
                        .fill(gradient)
                        .frame(width: geo.size.width * progress)
                        .animation(.spring(duration: 0.4), value: progress)
                }
            }
            .frame(height: height)
        }
    }
}

// === Demo tất cả custom styles ===

#Preview("Custom Styles") {
    ScrollView {
        VStack(spacing: 32) {
            // Gauge
            ProgressView(value: 0.72) {
                Text("Storage")
            } currentValueLabel: {
                Text("72 / 100 GB")
            }
            .progressViewStyle(.gauge(size: 120, color: .orange))
            
            Divider()
            
            // Steps
            ProgressView(value: 2, total: 4) {
                Text("Đăng ký tài khoản")
            } currentValueLabel: {
                Text("Bước 3 / 4")
            }
            .progressViewStyle(StepProgressStyle(totalSteps: 4))
            .padding(.horizontal)
            
            Divider()
            
            // Dots (indeterminate)
            ProgressView()
                .progressViewStyle(.dots)
            
            Divider()
            
            // Gradient bar
            ProgressView(value: 0.45) {
                Text("Upload")
            } currentValueLabel: {
                Text("45%")
            }
            .progressViewStyle(GradientBarProgressStyle(
                colors: [.green, .blue, .purple]
            ))
            .padding(.horizontal)
        }
        .padding(24)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. ANIMATED PROGRESS — TIMER & LIVE UPDATE              ║
// ╚══════════════════════════════════════════════════════════╝

// === 7a. Auto-increment with Timer ===

struct TimerProgressDemo: View {
    @State private var progress = 0.0
    @State private var isRunning = false
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: progress) {
                Text("Auto Progress")
            } currentValueLabel: {
                Text("\(Int(progress * 100))%")
                    .contentTransition(.numericText(value: progress))
            }
            .tint(.blue)
            
            HStack {
                Button(isRunning ? "Pause" : "Start") {
                    isRunning.toggle()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Reset") {
                    progress = 0
                    isRunning = false
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .onReceive(timer) { _ in
            guard isRunning, progress < 1.0 else {
                if progress >= 1.0 { isRunning = false }
                return
            }
            progress = min(progress + 0.005, 1.0)
        }
    }
}

// === 7b. Multi-file download simulation ===

struct FileDownload: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    var progress: Double = 0
    var isComplete: Bool { progress >= 1.0 }
}

struct MultiDownloadDemo: View {
    @State private var files: [FileDownload] = [
        FileDownload(name: "photo.jpg", icon: "photo", color: .blue),
        FileDownload(name: "video.mp4", icon: "film", color: .purple),
        FileDownload(name: "doc.pdf", icon: "doc.fill", color: .red),
        FileDownload(name: "music.mp3", icon: "music.note", color: .orange),
    ]
    
    @State private var isDownloading = false
    
    var overallProgress: Double {
        guard !files.isEmpty else { return 0 }
        return files.reduce(0) { $0 + $1.progress } / Double(files.count)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Overall progress
            ProgressView(value: overallProgress) {
                Text("Tổng tiến trình")
                    .font(.headline)
            } currentValueLabel: {
                Text("\(Int(overallProgress * 100))%")
                    .font(.caption.monospaced())
            }
            .tint(.blue)
            
            Divider()
            
            // Per-file progress
            ForEach(files) { file in
                HStack(spacing: 12) {
                    Image(systemName: file.icon)
                        .foregroundStyle(file.color)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(file.name)
                                .font(.subheadline)
                            Spacer()
                            if file.isComplete {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.subheadline)
                            } else {
                                Text("\(Int(file.progress * 100))%")
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        ProgressView(value: file.progress)
                            .tint(file.isComplete ? .green : file.color)
                    }
                }
            }
            
            // Controls
            Button(isDownloading ? "Downloading..." : "Start Downloads") {
                startDownloads()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isDownloading)
        }
        .padding()
        .animation(.easeInOut(duration: 0.3), value: files.map(\.progress))
    }
    
    func startDownloads() {
        isDownloading = true
        // Simulate different speeds
        for i in files.indices {
            files[i].progress = 0
            let speed = Double.random(in: 0.01...0.04)
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                if files[i].progress >= 1.0 {
                    timer.invalidate()
                    if files.allSatisfy(\.isComplete) { isDownloading = false }
                    return
                }
                files[i].progress = min(files[i].progress + speed, 1.0)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. PRODUCTION PATTERNS                                   ║
// ╚══════════════════════════════════════════════════════════╝

// === 8a. Skeleton Loading (Redacted) ===

struct SkeletonLoadingDemo: View {
    @State private var isLoading = true
    
    var body: some View {
        List {
            ForEach(0..<8) { _ in
                HStack(spacing: 12) {
                    Circle().frame(width: 48, height: 48)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Placeholder Name Long")
                            .font(.headline)
                        Text("Description text here")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .redacted(reason: isLoading ? .placeholder : [])
        // .placeholder: tất cả text/image → skeleton blocks
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { isLoading = false }
            }
        }
    }
}


// === 8b. Upload Progress Sheet ===

struct UploadProgressSheet: View {
    @Binding var isPresented: Bool
    @State private var progress = 0.0
    @State private var status = "Đang chuẩn bị..."
    @State private var isComplete = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(isComplete ? .green.opacity(0.1) : .blue.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.title.bold())
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    ProgressView(value: progress)
                        .progressViewStyle(.gauge(size: 60, color: .blue))
                }
            }
            .animation(.spring, value: isComplete)
            
            // Status
            VStack(spacing: 6) {
                Text(isComplete ? "Hoàn tất!" : "Đang upload...")
                    .font(.headline)
                Text(status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Progress bar
            if !isComplete {
                ProgressView(value: progress)
                    .tint(.blue)
                    .padding(.horizontal)
            }
            
            // Action
            if isComplete {
                Button("Xong") { isPresented = false }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .task { await simulateUpload() }
    }
    
    func simulateUpload() async {
        let stages = [
            (0.0, "Đang chuẩn bị..."),
            (0.2, "Đang nén file..."),
            (0.5, "Đang upload (1/2)..."),
            (0.8, "Đang upload (2/2)..."),
            (1.0, "Đang xác nhận..."),
        ]
        
        for (target, text) in stages {
            status = text
            while progress < target {
                try? await Task.sleep(for: .milliseconds(50))
                progress = min(progress + 0.02, target)
            }
        }
        
        try? await Task.sleep(for: .milliseconds(500))
        withAnimation { isComplete = true }
        status = "Upload thành công!"
    }
}


// === 8c. Step-by-step Onboarding ===

struct OnboardingProgress: View {
    @State private var currentStep = 0
    let totalSteps = 4
    let stepTitles = ["Tài khoản", "Hồ sơ", "Sở thích", "Hoàn tất"]
    
    var body: some View {
        VStack(spacing: 24) {
            // Step progress
            ProgressView(
                value: Double(currentStep),
                total: Double(totalSteps - 1)
            ) {
                Text(stepTitles[currentStep])
                    .font(.headline)
            } currentValueLabel: {
                Text("Bước \(currentStep + 1) / \(totalSteps)")
            }
            .progressViewStyle(StepProgressStyle(totalSteps: totalSteps))
            .padding(.horizontal)
            
            Spacer()
            
            // Step content
            Text("Nội dung bước \(currentStep + 1)")
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.gray.opacity(0.05), in: .rect(cornerRadius: 16))
                .padding(.horizontal)
            
            Spacer()
            
            // Navigation
            HStack {
                if currentStep > 0 {
                    Button("Quay lại") {
                        withAnimation { currentStep -= 1 }
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                Button(currentStep < totalSteps - 1 ? "Tiếp theo" : "Hoàn tất") {
                    withAnimation {
                        if currentStep < totalSteps - 1 {
                            currentStep += 1
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}


// === 8d. Content Loading States Pattern ===

enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)
}

struct LoadingStateView<T, Content: View, Empty: View>: View {
    let state: LoadingState<T>
    @ViewBuilder let content: (T) -> Content
    @ViewBuilder let emptyView: () -> Empty
    var retryAction: (() -> Void)? = nil
    
    var body: some View {
        switch state {
        case .idle:
            emptyView()
            
        case .loading:
            VStack(spacing: 14) {
                ProgressView()
                    .controlSize(.large)
                Text("Đang tải...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        case .loaded(let data):
            content(data)
            
        case .error(let message):
            ContentUnavailableView {
                Label("Lỗi", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                if let retryAction {
                    Button("Thử lại", action: retryAction)
                        .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. ACCESSIBILITY                                        ║
// ╚══════════════════════════════════════════════════════════╝

struct AccessibleProgressDemo: View {
    @State private var progress = 0.6
    
    var body: some View {
        VStack(spacing: 20) {
            // ProgressView tự động accessible
            // VoiceOver: "60 percent, Uploading, progress"
            ProgressView(value: progress) {
                Text("Uploading")
            }
            
            // Custom accessibility
            ProgressView(value: progress)
                .accessibilityLabel("Upload tiến trình")
                .accessibilityValue("\(Int(progress * 100)) phần trăm")
            
            // Indeterminate
            ProgressView()
                .accessibilityLabel("Đang tải dữ liệu")
            // VoiceOver: "Đang tải dữ liệu, activity indicator, animating"
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: ProgressView không hiện trong dark background
//    ZStack { Color.black; ProgressView() }
//    → Spinner MÀU ĐEN trên nền đen → không thấy!
//    ✅ FIX: .tint(.white) hoặc .tint(.blue)

// ❌ PITFALL 2: value > total → thanh tràn hoặc không đúng
//    ProgressView(value: 1.5, total: 1.0)
//    → SwiftUI clamp về 1.0 nhưng behavior không đảm bảo
//    ✅ FIX: Luôn clamp: min(progress, total)

// ❌ PITFALL 3: Progress không animate mượt
//    progress = 0.8 // Set trực tiếp → nhảy cục
//    ✅ FIX: withAnimation(.spring) { progress = 0.8 }
//            Hoặc increment dần qua Timer

// ❌ PITFALL 4: Spinner quá nhỏ trong custom context
//    ProgressView() // Default size rất nhỏ
//    ✅ FIX: .controlSize(.large) hoặc .scaleEffect(1.5)
//            Hoặc custom ProgressViewStyle

// ❌ PITFALL 5: Loading state không dismiss
//    .refreshable { loadData() } // loadData() KHÔNG async
//    → Spinner hiện MÃI vì function return ngay
//    ✅ FIX: .refreshable { await loadData() }
//            Function phải async, spinner ẩn khi await hoàn thành

// ❌ PITFALL 6: Indeterminate khi cần determinate
//    ProgressView() khi BIẾT tiến trình → user không biết còn bao lâu
//    ✅ FIX: Nếu biết progress → ProgressView(value:total:)
//            Nếu không → indeterminate + text mô tả giai đoạn

// ✅ BEST PRACTICES:
// 1. Indeterminate cho unknown duration, determinate khi biết %
// 2. .controlSize phù hợp: .small cho inline, .large cho full-screen
// 3. .tint() đảm bảo hiện trên MỌI background
// 4. Label + currentValueLabel cho context rõ ràng
// 5. Custom ProgressViewStyle cho design system (gauge, steps, dots)
// 6. LoadingState<T> enum pattern cho state management
// 7. .redacted(reason: .placeholder) cho skeleton loading
// 8. withAnimation khi update progress cho smooth transitions
// 9. .refreshable async function → spinner tự quản lý
// 10. Accessibility: ProgressView tự đọc %, thêm label nếu cần
// 11. Multi-file: overall progress + per-item progress
// 12. Upload sheet: stages + status text + completion state
```

---

TextField là component nhập liệu phức tạp nhất trong SwiftUI — từ formatting, validation, focus management đến keyboard customization và secure input. Mình sẽ giải thích toàn bộ.Mình đã tổng hợp toàn bộ kiến thức TextField trong 13 phần. Đây là những điểm cốt lõi:

**TextField phức tạp hơn nhiều so với vẻ ngoài** — không chỉ là ô nhập text mà bao gồm cả format parsing (number, currency, date), focus management, keyboard configuration, autofill integration, validation patterns, và custom styles.

**Năm phần giá trị nhất cho production:**

**Phần 4 — @FocusState**: Đây là API then chốt cho mọi form. Pattern `enum Field` + `.focused($focus, equals:)` + `.onSubmit` navigation cho phép user nhấn Next/Done trên keyboard để nhảy qua từng field — y hệt native iOS apps. Kết hợp `.submitLabel(.next)` cho fields giữa, `.submitLabel(.done)` cho field cuối.

**Phần 3 — textContentType**: Modifier nhỏ nhưng impact cực lớn — `.oneTimeCode` khiến iOS **tự đọc SMS OTP và suggest autofill**, `.emailAddress` + `.password` trigger **Keychain autofill**, `.newPassword` trigger **strong password suggestion**. Chỉ 1 dòng code mà UX cải thiện đáng kể.

**Phần 7 — Validation**: Reusable `ValidatedField` component kết hợp realtime validation (check mỗi keystroke), visual feedback (checkmark/error icon), error message animated, và integration với `@FocusState`. Pattern này scalable cho mọi form trong app.

**Phần 8 — Real-time Formatting**: Pattern `.onChange(of:)` để auto-format phone number (`0912 345 678`), credit card (`4242 4242 4242 4242`), và character limit + filter. Trick: filter → limit → format trong onChange, set lại binding nếu khác — SwiftUI chỉ re-render khi giá trị thực sự thay đổi.

**Phần 11c — OTP Input**: Component OTP 6 ô hoàn chỉnh — dùng hidden TextField nhận keyboard input, visual boxes hiển thị từng digit, `.textContentType(.oneTimeCode)` cho auto-fill SMS. Pattern này rất phổ biến mà SwiftUI không có built-in.

**Pitfall #3 đáng chú ý nhất**: `.numberPad` không có nút Return → `.onSubmit` **không bao giờ fire**. Phải thêm `.toolbar` keyboard button "Done" — đây là lỗi rất nhiều developer gặp.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
