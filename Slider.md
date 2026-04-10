// ============================================================
// SLIDER TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// Slider là UI control cho phép user CHỌN 1 GIÁ TRỊ SỐ
// trong một khoảng (range) bằng cách KÉO thumb trên track.
//
// Tương đương UISlider trong UIKit, nhưng SwiftUI bổ sung thêm:
// - Step (bước nhảy)
// - Label, minimumValueLabel, maximumValueLabel
// - onEditingChanged callback
// - Custom Slider hoàn toàn qua gestures
//
// Dùng cho: âm lượng, độ sáng, font size, filter range,
//           progress control, color picker, rating...
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÚ PHÁP CƠ BẢN & CÁC INITIALIZER                   ║
// ╚══════════════════════════════════════════════════════════╝

struct BasicSliderDemo: View {
    @State private var brightness: Double = 0.5
    @State private var volume: Double = 70
    @State private var fontSize: Double = 16
    @State private var rating: Double = 3
    
    var body: some View {
        Form {
            // === 1a. Đơn giản nhất: range 0...1 (default) ===
            Section("Cơ bản (0...1)") {
                Slider(value: $brightness)
                Text("Độ sáng: \(brightness, specifier: "%.2f")")
                // Range mặc định: 0.0 ... 1.0
                // Không có step → giá trị liên tục (continuous)
            }
            
            // === 1b. Custom range ===
            Section("Custom Range (0...100)") {
                Slider(value: $volume, in: 0...100)
                Text("Âm lượng: \(Int(volume))%")
            }
            
            // === 1c. Range + Step (bước nhảy) ===
            Section("Step = 2") {
                Slider(value: $fontSize, in: 10...40, step: 2)
                // Giá trị chỉ nhảy: 10, 12, 14, 16, 18... 40
                Text("Font size: \(Int(fontSize))pt")
                    .font(.system(size: fontSize))
            }
            
            // === 1d. Range + Step + Labels đầu/cuối ===
            Section("Với Min/Max Labels") {
                Slider(value: $rating, in: 1...5, step: 1) {
                    // Label chính (thường bị ẩn trong Form)
                    Text("Rating")
                } minimumValueLabel: {
                    Text("1")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } maximumValueLabel: {
                    Text("5")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text("Đánh giá: \(Int(rating)) ⭐")
            }
        }
    }
}

// TỔNG HỢP CÁC INITIALIZER:
//
// Slider(value: Binding<V>)
//   → Range 0...1, continuous
//
// Slider(value: Binding<V>, in: ClosedRange<V>)
//   → Custom range, continuous
//
// Slider(value: Binding<V>, in: ClosedRange<V>, step: V.Stride)
//   → Custom range + bước nhảy
//
// Slider(value:in:step:label:minimumValueLabel:maximumValueLabel:)
//   → Full options với labels
//
// Tất cả có thêm variant với onEditingChanged: (Bool) -> Void


// ╔══════════════════════════════════════════════════════════╗
// ║  2. onEditingChanged — PHÁT HIỆN ĐANG KÉO / THẢ         ║
// ╚══════════════════════════════════════════════════════════╝

// onEditingChanged nhận Bool:
// - true: user BẮT ĐẦU kéo (finger down)
// - false: user THẢ ra (finger up)
// Hữu ích cho: debounce API calls, hiện/ẩn tooltip, haptic feedback

struct EditingChangedDemo: View {
    @State private var volume: Double = 50
    @State private var isDragging = false
    @State private var commitCount = 0
    
    var body: some View {
        VStack(spacing: 24) {
            // Hiển thị tooltip khi đang kéo
            ZStack {
                if isDragging {
                    Text("\(Int(volume))%")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text("Kéo để điều chỉnh")
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                }
            }
            .frame(height: 50)
            .animation(.spring(duration: 0.3), value: isDragging)
            
            // Slider với onEditingChanged
            Slider(
                value: $volume,
                in: 0...100,
                step: 1,
                onEditingChanged: { editing in
                    isDragging = editing
                    
                    if !editing {
                        // User THẢ tay → commit giá trị cuối cùng
                        commitCount += 1
                        saveVolumeToServer(volume)
                    }
                }
            )
            .tint(.blue)
            .padding(.horizontal)
            
            Text("Số lần commit: \(commitCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    func saveVolumeToServer(_ value: Double) {
        // Chỉ gọi API khi user THẢ TAY
        // Tránh gọi API mỗi frame khi đang kéo
        print("💾 Saved volume: \(Int(value))%")
    }
}

// ⚠️ SO SÁNH onEditingChanged vs .onChange:
//
// .onChange(of: volume) { ... }
//   → Fire LIÊN TỤC mỗi khi value thay đổi (mỗi frame khi kéo)
//   → Dùng cho: update UI realtime, preview live
//
// onEditingChanged: false
//   → Fire 1 LẦN khi user thả tay
//   → Dùng cho: API calls, save data, expensive operations
//
// Production pattern: dùng CẢ HAI
// - .onChange → update UI preview (lightweight)
// - onEditingChanged(false) → commit to server (heavyweight)


// ╔══════════════════════════════════════════════════════════╗
// ║  3. TINT & APPEARANCE CUSTOMIZATION                      ║
// ╚══════════════════════════════════════════════════════════╝

struct SliderAppearanceDemo: View {
    @State private var red: Double = 0.8
    @State private var green: Double = 0.4
    @State private var blue: Double = 0.2
    @State private var opacity: Double = 1.0
    
    var selectedColor: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Color preview
            RoundedRectangle(cornerRadius: 16)
                .fill(selectedColor)
                .frame(height: 100)
                .overlay(
                    Text("R:\(Int(red*255)) G:\(Int(green*255)) B:\(Int(blue*255))")
                        .foregroundStyle(.white)
                        .font(.caption.monospaced())
                        .shadow(radius: 2)
                )
                .padding(.horizontal)
            
            // === 3a. .tint() — Đổi màu track filled ===
            VStack(spacing: 14) {
                HStack {
                    Text("R").frame(width: 20)
                    Slider(value: $red)
                        .tint(.red)
                    Text("\(Int(red * 255))")
                        .frame(width: 35)
                        .font(.caption.monospaced())
                }
                
                HStack {
                    Text("G").frame(width: 20)
                    Slider(value: $green)
                        .tint(.green)
                    Text("\(Int(green * 255))")
                        .frame(width: 35)
                        .font(.caption.monospaced())
                }
                
                HStack {
                    Text("B").frame(width: 20)
                    Slider(value: $blue)
                        .tint(.blue)
                    Text("\(Int(blue * 255))")
                        .frame(width: 35)
                        .font(.caption.monospaced())
                }
                
                HStack {
                    Text("A").frame(width: 20)
                    Slider(value: $opacity)
                        .tint(.gray)
                    Text("\(Int(opacity * 100))%")
                        .frame(width: 35)
                        .font(.caption.monospaced())
                }
            }
            .padding(.horizontal)
            
            // === 3b. .disabled() ===
            Slider(value: .constant(0.5))
                .disabled(true) // Mờ, không kéo được
                .padding(.horizontal)
            
            // === 3c. Kết hợp với system images ===
            HStack {
                Image(systemName: "speaker.fill")
                    .foregroundStyle(.secondary)
                Slider(value: $opacity, in: 0...1)
                    .tint(.indigo)
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
    }
}

// ⚠️ GIỚI HẠN CUSTOMIZATION CỦA SLIDER BUILT-IN:
//
// .tint()         → Đổi màu filled track ✅
// .disabled()     → Vô hiệu hoá ✅
// .accentColor()  → Legacy, dùng .tint() thay thế
//
// KHÔNG THỂ custom bằng modifier:
// ❌ Thumb size/shape/color
// ❌ Track height/shape
// ❌ Unfilled track color
// ❌ Gradient track
// ❌ Tick marks
//
// → Cần custom slider từ scratch (Phần 8) cho UI phức tạp


// ╔══════════════════════════════════════════════════════════╗
// ║  4. SLIDER VỚI FORMATTED DISPLAY                         ║
// ╚══════════════════════════════════════════════════════════╝

struct FormattedSliderDemo: View {
    @State private var price: Double = 500_000
    @State private var distance: Double = 5.0
    @State private var temperature: Double = 25
    @State private var percentage: Double = 0.75
    
    var body: some View {
        Form {
            // === 4a. Currency ===
            Section("Giá tối đa") {
                Slider(value: $price, in: 100_000...10_000_000, step: 100_000)
                Text(price, format: .currency(code: "VND"))
                    .font(.headline)
                // Hiển thị: ₫500,000
            }
            
            // === 4b. Distance ===
            Section("Bán kính tìm kiếm") {
                Slider(value: $distance, in: 0.5...50, step: 0.5) {
                    Text("Khoảng cách")
                } minimumValueLabel: {
                    Text("0.5")
                } maximumValueLabel: {
                    Text("50")
                }
                Text("\(distance, specifier: "%.1f") km")
                    .font(.headline)
            }
            
            // === 4c. Temperature ===
            Section("Nhiệt độ") {
                Slider(value: $temperature, in: -10...45, step: 0.5)
                    .tint(temperatureColor)
                
                HStack {
                    Image(systemName: temperatureIcon)
                        .foregroundStyle(temperatureColor)
                    Text("\(temperature, specifier: "%.1f")°C")
                        .font(.headline)
                }
            }
            
            // === 4d. Percentage ===
            Section("Phần trăm") {
                Slider(value: $percentage, in: 0...1, step: 0.01)
                Text(percentage, format: .percent)
                    .font(.headline)
                // Hiển thị: 75%
            }
        }
    }
    
    private var temperatureColor: Color {
        switch temperature {
        case ..<10: return .blue
        case 10..<25: return .green
        case 25..<35: return .orange
        default: return .red
        }
    }
    
    private var temperatureIcon: String {
        switch temperature {
        case ..<10: return "thermometer.snowflake"
        case 10..<25: return "thermometer.medium"
        case 25..<35: return "thermometer.high"
        default: return "thermometer.sun.fill"
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. SLIDER TRONG CÁC CONTEXT KHÁC NHAU                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 5a. Trong Form/List ===
struct SliderInFormDemo: View {
    @State private var volume: Double = 50
    @State private var bass: Double = 0
    @State private var treble: Double = 0
    
    var body: some View {
        Form {
            Section("Equalizer") {
                VStack(alignment: .leading) {
                    Text("Volume: \(Int(volume))%")
                        .font(.subheadline)
                    Slider(value: $volume, in: 0...100, step: 1)
                        .tint(.blue)
                }
                
                VStack(alignment: .leading) {
                    Text("Bass: \(bass > 0 ? "+" : "")\(Int(bass)) dB")
                        .font(.subheadline)
                    Slider(value: $bass, in: -12...12, step: 1)
                        .tint(.orange)
                }
                
                VStack(alignment: .leading) {
                    Text("Treble: \(treble > 0 ? "+" : "")\(Int(treble)) dB")
                        .font(.subheadline)
                    Slider(value: $treble, in: -12...12, step: 1)
                        .tint(.purple)
                }
            }
        }
    }
}

// === 5b. Ngoài Form — Standalone ===
struct StandaloneSliderDemo: View {
    @State private var progress: Double = 0.3
    
    var body: some View {
        VStack(spacing: 16) {
            // Video progress bar style
            VStack(spacing: 8) {
                Slider(value: $progress, in: 0...1)
                    .tint(.red)
                
                HStack {
                    Text(formatTime(progress * 180))
                        .font(.caption.monospaced())
                    Spacer()
                    Text(formatTime(180))
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }
    
    func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// === 5c. Trong Sheet/Popover ===
struct SliderInSheetDemo: View {
    @State private var showAdjustments = false
    @State private var brightness: Double = 0.5
    @State private var contrast: Double = 0.5
    @State private var saturation: Double = 0.5
    
    var body: some View {
        VStack {
            Image(systemName: "photo.artframe")
                .font(.system(size: 100))
                .foregroundStyle(.blue)
                .brightness(brightness - 0.5)
                .contrast(0.5 + contrast)
                .saturation(saturation * 2)
            
            Button("Điều chỉnh") { showAdjustments = true }
        }
        .sheet(isPresented: $showAdjustments) {
            NavigationStack {
                Form {
                    SliderRow(label: "Brightness", value: $brightness,
                              icon: "sun.max.fill", color: .yellow)
                    SliderRow(label: "Contrast", value: $contrast,
                              icon: "circle.lefthalf.filled", color: .gray)
                    SliderRow(label: "Saturation", value: $saturation,
                              icon: "drop.fill", color: .blue)
                }
                .navigationTitle("Adjustments")
                .toolbar {
                    Button("Xong") { showAdjustments = false }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

struct SliderRow: View {
    let label: String
    @Binding var value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(label)
                Spacer()
                Text("\(Int(value * 100))")
                    .foregroundStyle(.secondary)
                    .font(.caption.monospaced())
            }
            Slider(value: $value)
                .tint(color)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. SLIDER VỚI @Observable / VIEW MODEL                  ║
// ╚══════════════════════════════════════════════════════════╝

@Observable
final class AudioSettings {
    var masterVolume: Double = 80
    var musicVolume: Double = 70
    var sfxVolume: Double = 90
    var voiceVolume: Double = 100
    var isMuted: Bool = false
    
    var effectiveMasterVolume: Double {
        isMuted ? 0 : masterVolume
    }
    
    func resetDefaults() {
        masterVolume = 80
        musicVolume = 70
        sfxVolume = 90
        voiceVolume = 100
        isMuted = false
    }
}

struct AudioSettingsView: View {
    @Bindable var audio: AudioSettings
    
    var body: some View {
        Form {
            Section {
                Toggle("Tắt tiếng", isOn: $audio.isMuted)
            }
            
            Section("Master") {
                VolumeSlider(
                    label: "Master",
                    icon: "speaker.wave.3.fill",
                    value: $audio.masterVolume,
                    disabled: audio.isMuted
                )
            }
            
            Section("Channels") {
                VolumeSlider(
                    label: "Nhạc",
                    icon: "music.note",
                    value: $audio.musicVolume,
                    disabled: audio.isMuted
                )
                VolumeSlider(
                    label: "Hiệu ứng",
                    icon: "waveform",
                    value: $audio.sfxVolume,
                    disabled: audio.isMuted
                )
                VolumeSlider(
                    label: "Giọng nói",
                    icon: "person.wave.2.fill",
                    value: $audio.voiceVolume,
                    disabled: audio.isMuted
                )
            }
            
            Section {
                Button("Khôi phục mặc định") {
                    withAnimation { audio.resetDefaults() }
                }
            }
        }
    }
}

struct VolumeSlider: View {
    let label: String
    let icon: String
    @Binding var value: Double
    var disabled: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20)
                    .foregroundStyle(disabled ? .gray : .blue)
                Text(label)
                Spacer()
                Text("\(Int(value))%")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $value, in: 0...100, step: 1)
                .tint(disabled ? .gray : .blue)
                .disabled(disabled)
        }
    }
}

#Preview("Audio Settings") {
    @Previewable @State var audio = AudioSettings()
    NavigationStack {
        AudioSettingsView(audio: audio)
            .navigationTitle("Âm thanh")
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. RANGE SLIDER (DUAL THUMB) — TỰ BUILD                ║
// ╚══════════════════════════════════════════════════════════╝

// SwiftUI KHÔNG có built-in Range Slider (2 thumb).
// Tự build dùng DragGesture.

struct RangeSlider: View {
    @Binding var lowValue: Double
    @Binding var highValue: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    var tint: Color = .blue
    
    @State private var sliderWidth: CGFloat = 0
    
    private let thumbSize: CGFloat = 24
    private let trackHeight: CGFloat = 4
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width - thumbSize
            
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: trackHeight)
                    .padding(.horizontal, thumbSize / 2)
                
                // Filled track (giữa 2 thumbs)
                Capsule()
                    .fill(tint)
                    .frame(
                        width: CGFloat((highValue - lowValue) / (range.upperBound - range.lowerBound)) * width,
                        height: trackHeight
                    )
                    .offset(x: thumbSize / 2 + CGFloat((lowValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * width)
                
                // Low thumb
                Circle()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: CGFloat((lowValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * width)
                    .gesture(
                        DragGesture()
                            .onChanged { drag in
                                let percent = max(0, min(1, drag.location.x / width))
                                var newValue = range.lowerBound + Double(percent) * (range.upperBound - range.lowerBound)
                                newValue = round(newValue / step) * step
                                lowValue = min(newValue, highValue - step)
                            }
                    )
                
                // High thumb
                Circle()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: CGFloat((highValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * width)
                    .gesture(
                        DragGesture()
                            .onChanged { drag in
                                let percent = max(0, min(1, drag.location.x / width))
                                var newValue = range.lowerBound + Double(percent) * (range.upperBound - range.lowerBound)
                                newValue = round(newValue / step) * step
                                highValue = max(newValue, lowValue + step)
                            }
                    )
            }
            .frame(height: thumbSize)
            .onAppear { sliderWidth = geo.size.width }
        }
        .frame(height: thumbSize)
    }
}

// Sử dụng:
struct RangeSliderDemo: View {
    @State private var minPrice: Double = 200_000
    @State private var maxPrice: Double = 800_000
    
    @State private var minAge: Double = 18
    @State private var maxAge: Double = 35
    
    var body: some View {
        Form {
            Section("Khoảng giá") {
                RangeSlider(
                    lowValue: $minPrice,
                    highValue: $maxPrice,
                    range: 0...2_000_000,
                    step: 50_000,
                    tint: .green
                )
                .padding(.vertical, 8)
                
                HStack {
                    Text("\(Int(minPrice))đ")
                    Spacer()
                    Text("\(Int(maxPrice))đ")
                }
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            }
            
            Section("Khoảng tuổi") {
                RangeSlider(
                    lowValue: $minAge,
                    highValue: $maxAge,
                    range: 13...65,
                    step: 1,
                    tint: .blue
                )
                .padding(.vertical, 8)
                
                Text("\(Int(minAge)) – \(Int(maxAge)) tuổi")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. CUSTOM SLIDER — TẠO TỪ SCRATCH                      ║
// ╚══════════════════════════════════════════════════════════╝

// Khi cần: gradient track, custom thumb, tick marks,
// vertical slider, circular slider...

// === 8a. Gradient Track Slider ===

struct GradientSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double? = nil
    var gradient: LinearGradient = LinearGradient(
        colors: [.blue, .purple, .red],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    private let trackHeight: CGFloat = 8
    private let thumbSize: CGFloat = 28
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width - thumbSize
            let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
            
            ZStack(alignment: .leading) {
                // Gradient track
                Capsule()
                    .fill(gradient)
                    .frame(height: trackHeight)
                    .padding(.horizontal, thumbSize / 2)
                
                // Unfilled overlay
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: trackHeight)
                    .padding(.leading, thumbSize / 2 + CGFloat(percent) * width)
                    .padding(.trailing, thumbSize / 2)
                
                // Custom thumb
                Circle()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay(
                        Circle()
                            .fill(gradient)
                            .frame(width: 14, height: 14)
                    )
                    .offset(x: CGFloat(percent) * width)
                    .gesture(
                        DragGesture()
                            .onChanged { drag in
                                let pct = max(0, min(1, drag.location.x / width))
                                var newValue = range.lowerBound + Double(pct) * (range.upperBound - range.lowerBound)
                                if let step {
                                    newValue = round(newValue / step) * step
                                }
                                value = min(max(newValue, range.lowerBound), range.upperBound)
                            }
                    )
            }
            .frame(height: thumbSize)
        }
        .frame(height: thumbSize)
    }
}

#Preview("Gradient Slider") {
    @Previewable @State var hue: Double = 0.5
    
    VStack(spacing: 20) {
        GradientSlider(
            value: $hue,
            range: 0...1,
            gradient: LinearGradient(
                colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .padding(.horizontal)
        
        Circle()
            .fill(Color(hue: hue, saturation: 0.8, brightness: 0.9))
            .frame(width: 60, height: 60)
    }
    .padding()
}


// === 8b. Slider với Tick Marks ===

struct TickMarkSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    var tint: Color = .blue
    var labels: [Double: String]? = nil // Tuỳ chọn label cho từng tick
    
    private var tickCount: Int {
        Int((range.upperBound - range.lowerBound) / step) + 1
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Slider(value: $value, in: range, step: step)
                .tint(tint)
            
            // Tick marks + labels
            HStack {
                ForEach(0..<tickCount, id: \.self) { i in
                    VStack(spacing: 2) {
                        // Tick mark
                        Rectangle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 1, height: 6)
                        
                        // Label
                        let tickValue = range.lowerBound + Double(i) * step
                        if let labels, let label = labels[tickValue] {
                            Text(label)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        } else {
                            Text("\(Int(tickValue))")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if i < tickCount - 1 { Spacer(minLength: 0) }
                }
            }
        }
    }
}

#Preview("Tick Mark Slider") {
    @Previewable @State var speed: Double = 1.0
    
    VStack(spacing: 30) {
        TickMarkSlider(
            value: $speed,
            range: 0.5...2.0,
            step: 0.25,
            tint: .orange,
            labels: [0.5: "0.5x", 1.0: "1x", 1.5: "1.5x", 2.0: "2x"]
        )
        
        Text("Tốc độ phát: \(speed, specifier: "%.2f")x")
            .font(.headline)
    }
    .padding()
}


// === 8c. Vertical Slider ===

struct VerticalSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var tint: Color = .blue
    var height: CGFloat = 200
    
    var body: some View {
        // Xoay Slider 90 độ
        Slider(value: $value, in: range)
            .tint(tint)
            .rotationEffect(.degrees(-90))
            .frame(width: height, height: 30)
            .frame(width: 30, height: height)
    }
}

#Preview("Vertical Sliders") {
    @Previewable @State var bass: Double = 50
    @Previewable @State var mid: Double = 70
    @Previewable @State var treble: Double = 40
    
    HStack(spacing: 30) {
        VStack {
            VerticalSlider(value: $bass, range: 0...100, tint: .red, height: 180)
            Text("Bass")
                .font(.caption)
        }
        VStack {
            VerticalSlider(value: $mid, range: 0...100, tint: .green, height: 180)
            Text("Mid")
                .font(.caption)
        }
        VStack {
            VerticalSlider(value: $treble, range: 0...100, tint: .blue, height: 180)
            Text("Treble")
                .font(.caption)
        }
    }
    .padding()
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. SENSORY FEEDBACK & HAPTICS                           ║
// ╚══════════════════════════════════════════════════════════╝

struct HapticSliderDemo: View {
    @State private var value: Double = 50
    @State private var lastStepValue: Int = 50
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(Int(value))")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            
            Slider(value: $value, in: 0...100, step: 1)
                .tint(.blue)
                .padding(.horizontal)
                // iOS 17+: sensoryFeedback khi giá trị thay đổi
                .sensoryFeedback(.selection, trigger: Int(value))
                // Mỗi lần step → nhẹ "tick" haptic
                // Rất giống cảm giác kéo UIPickerView
        }
    }
}

// Haptic patterns khác cho slider:
// .sensoryFeedback(.selection, trigger:)    → Nhẹ mỗi step (phổ biến nhất)
// .sensoryFeedback(.impact(.light), trigger:) → Nhẹ hơn
// .sensoryFeedback(.impact(.medium), trigger:) → Vừa
// .sensoryFeedback(.alignment, trigger:)    → Khi snap vào vị trí


// ╔══════════════════════════════════════════════════════════╗
// ║  10. PRODUCTION PATTERNS                                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 10a. Image Filter Editor ===

struct ImageFilterEditor: View {
    @State private var brightness: Double = 0
    @State private var contrast: Double = 1
    @State private var saturation: Double = 1
    @State private var blur: Double = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Image preview
                Image(systemName: "photo.artframe")
                    .font(.system(size: 80))
                    .frame(maxWidth: .infinity, minHeight: 250)
                    .background(.gray.opacity(0.1))
                    .brightness(brightness)
                    .contrast(contrast)
                    .saturation(saturation)
                    .blur(radius: blur)
                
                // Filter sliders
                ScrollView {
                    VStack(spacing: 16) {
                        FilterSlider(label: "Sáng", icon: "sun.max.fill",
                                    value: $brightness, range: -0.5...0.5,
                                    defaultValue: 0)
                        
                        FilterSlider(label: "Tương phản", icon: "circle.lefthalf.filled",
                                    value: $contrast, range: 0.5...2.0,
                                    defaultValue: 1)
                        
                        FilterSlider(label: "Bão hoà", icon: "drop.fill",
                                    value: $saturation, range: 0...2,
                                    defaultValue: 1)
                        
                        FilterSlider(label: "Mờ", icon: "aqi.medium",
                                    value: $blur, range: 0...10,
                                    defaultValue: 0)
                    }
                    .padding()
                }
            }
            .navigationTitle("Chỉnh sửa ảnh")
            .toolbar {
                Button("Reset") {
                    withAnimation {
                        brightness = 0; contrast = 1
                        saturation = 1; blur = 0
                    }
                }
            }
        }
    }
}

struct FilterSlider: View {
    let label: String
    let icon: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let defaultValue: Double
    
    // Kiểm tra giá trị có phải default không
    private var isModified: Bool {
        abs(value - defaultValue) > 0.01
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(isModified ? .blue : .secondary)
                    .frame(width: 24)
                
                Text(label)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(value, specifier: "%.2f")")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .trailing)
                
                // Reset button cho từng slider
                if isModified {
                    Button {
                        withAnimation { value = defaultValue }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            
            Slider(value: $value, in: range)
                .tint(isModified ? .blue : .gray)
        }
    }
}


// === 10b. Onboarding Preference Sliders ===

struct OnboardingPreferences: View {
    @State private var readingSpeed: Double = 2  // 1-4: Chậm→Nhanh
    @State private var contentDensity: Double = 2 // 1-3: Ít→Nhiều
    @State private var notificationFreq: Double = 2 // 1-3
    
    let speedLabels = ["Chậm", "Vừa", "Nhanh", "Rất nhanh"]
    let densityLabels = ["Tối giản", "Cân bằng", "Chi tiết"]
    let freqLabels = ["Ít", "Vừa", "Nhiều"]
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Tuỳ chỉnh trải nghiệm")
                .font(.title2.bold())
            
            VStack(spacing: 24) {
                // Tốc độ đọc
                PreferenceSlider(
                    title: "Tốc độ đọc",
                    icon: "book.fill",
                    value: $readingSpeed,
                    range: 1...4,
                    step: 1,
                    labels: speedLabels
                )
                
                // Mật độ nội dung
                PreferenceSlider(
                    title: "Mật độ nội dung",
                    icon: "text.alignleft",
                    value: $contentDensity,
                    range: 1...3,
                    step: 1,
                    labels: densityLabels
                )
                
                // Tần suất thông báo
                PreferenceSlider(
                    title: "Thông báo",
                    icon: "bell.fill",
                    value: $notificationFreq,
                    range: 1...3,
                    step: 1,
                    labels: freqLabels
                )
            }
            
            Spacer()
            
            Button {
                // Save preferences
            } label: {
                Text("Tiếp tục")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue, in: .rect(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
        }
        .padding(24)
    }
}

struct PreferenceSlider: View {
    let title: String
    let icon: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let labels: [String]
    
    private var currentLabel: String {
        let index = Int(value - range.lowerBound)
        guard index >= 0 && index < labels.count else { return "" }
        return labels[index]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(currentLabel)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: currentLabel)
            }
            
            Slider(value: $value, in: range, step: step)
                .tint(.blue)
                .sensoryFeedback(.selection, trigger: Int(value))
            
            // Labels dưới slider
            HStack {
                ForEach(Array(labels.enumerated()), id: \.offset) { idx, label in
                    Text(label)
                        .font(.system(size: 10))
                        .foregroundStyle(
                            Int(value - range.lowerBound) == idx ? .blue : .secondary
                        )
                    if idx < labels.count - 1 { Spacer() }
                }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. ACCESSIBILITY                                       ║
// ╚══════════════════════════════════════════════════════════╝

struct AccessibleSliderDemo: View {
    @State private var fontSize: Double = 16
    
    var body: some View {
        Form {
            // Built-in: Slider đã có accessibility tốt
            // VoiceOver: "Font size, 16, adjustable"
            // Swipe up/down để tăng/giảm
            Slider(value: $fontSize, in: 10...40, step: 2) {
                Text("Font size")
            }
            // Custom accessibility
            .accessibilityLabel("Cỡ chữ")
            .accessibilityValue("\(Int(fontSize)) points")
            .accessibilityHint("Vuốt lên để tăng, vuốt xuống để giảm")
            
            // ⚠️ Với custom slider (DragGesture):
            // PHẢI thêm accessibility thủ công
            // .accessibilityElement()
            // .accessibilityLabel("...")
            // .accessibilityValue("...")
            // .accessibilityAdjustableAction { direction in
            //     switch direction {
            //     case .increment: value = min(value + step, max)
            //     case .decrement: value = max(value - step, min)
            //     @unknown default: break
            //     }
            // }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  12. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Gọi API trong .onChange mỗi frame khi kéo
//    .onChange(of: volume) { save(volume) } // 60 API calls/giây!
//    ✅ FIX: Dùng onEditingChanged: false để chỉ gọi khi THẢ TAY
//            Hoặc debounce trong .onChange

// ❌ PITFALL 2: Step không chia đều range
//    Slider(value: $v, in: 0...10, step: 3) // 0,3,6,9 → không bao giờ đạt 10!
//    ✅ FIX: Đảm bảo (range.upperBound - range.lowerBound) % step == 0
//            Hoặc dùng step chia đều: 0...10, step: 2.5

// ❌ PITFALL 3: Hiển thị nhiều chữ số thập phân
//    Text("\(value)") → "0.5333333333333"
//    ✅ FIX: specifier "%.1f" hoặc format: .number.precision(...)

// ❌ PITFALL 4: Custom slider thiếu Accessibility
//    DragGesture slider → VoiceOver KHÔNG nhận diện
//    ✅ FIX: .accessibilityAdjustableAction + accessibilityValue

// ❌ PITFALL 5: Slider trong ScrollView bị conflict gesture
//    Kéo slider ngang → ScrollView scroll dọc cùng lúc
//    ✅ FIX: .simultaneousGesture hoặc wrap Slider riêng biệt
//            iOS 17+: ScrollView thường handle tốt hơn

// ❌ PITFALL 6: Dùng Float thay vì Double
//    @State var x: Float = 0
//    Slider(value: $x) // ❌ Slider yêu cầu BinaryFloatingPoint
//    ✅ FIX: Luôn dùng Double. Convert sang Float nếu cần ở chỗ khác

// ✅ BEST PRACTICES:
// 1. onEditingChanged cho expensive operations (API, save)
// 2. .onChange cho lightweight UI updates (preview, label)
// 3. Luôn hiển thị giá trị hiện tại (text label bên cạnh)
// 4. Step phù hợp: 1 cho Int, 0.1 cho decimal, tuỳ context
// 5. .sensoryFeedback(.selection) cho stepped sliders (iOS 17+)
// 6. min/max labels giúp user biết phạm vi
// 7. Tint color thể hiện ý nghĩa (đỏ→xanh cho nhiệt độ)
// 8. Reset button cho filter/editor sliders
// 9. Custom slider cần accessibility: adjustableAction + value
// 10. Test trên device thật: thumb size ≥ 44pt cho touch target

---

Slider là component tưởng đơn giản nhưng có khá nhiều kỹ thuật để tạo trải nghiệm tốt. Mình sẽ giải thích toàn bộ từ cơ bản đến custom slider nâng cao.Mình đã tổng hợp toàn bộ kiến thức Slider trong 12 phần. Đây là những điểm cốt lõi:

**Điểm quan trọng nhất** mà nhiều developer bỏ qua là **Phần 2 — onEditingChanged vs .onChange**. Đây là hai callback hoàn toàn khác nhau: `.onChange` fire liên tục mỗi frame khi kéo (60 lần/giây), còn `onEditingChanged: false` chỉ fire 1 lần khi user thả tay. Production pattern đúng là dùng **cả hai**: `.onChange` cho UI preview nhẹ (update label, color), `onEditingChanged(false)` cho expensive operations (API call, save to database).

**Ba phần giá trị nhất cho production:**

**Phần 7 — Range Slider**: SwiftUI không có built-in dual-thumb slider, nhưng đây là requirement cực kỳ phổ biến (lọc giá, khoảng tuổi, khoảng cách). Mình đã build từ scratch dùng `DragGesture` + `GeometryReader`, hỗ trợ step snapping và tint color.

**Phần 8 — Custom Slider**: Ba variants quan trọng — **Gradient Track** (cho color picker, hue selector), **Tick Marks** (cho playback speed 0.5x→2x), và **Vertical Slider** (cho equalizer, audio mixing). Trick hay là Vertical Slider chỉ cần `.rotationEffect(.degrees(-90))` trên Slider thường.

**Phần 10 — Image Filter Editor**: Pattern hoàn chỉnh với `FilterSlider` component có reset button cho từng slider, trạng thái `isModified` highlight khi giá trị khác default, và `.sensoryFeedback(.selection)` cho haptic mỗi step — mang lại trải nghiệm rất giống native iOS Photos app.

**Pitfall đáng chú ý nhất (Phần 12)**: Step không chia đều range — ví dụ `0...10, step: 3` sẽ cho giá trị 0, 3, 6, 9 mà **không bao giờ đạt được 10**. Luôn đảm bảo `(upperBound - lowerBound)` chia hết cho `step`.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
