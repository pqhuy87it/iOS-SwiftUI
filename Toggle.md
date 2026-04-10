// ============================================================
// TOGGLE TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// Toggle là UI control cho phép user BẬT/TẮT một trạng thái Bool.
// Tương đương UISwitch trong UIKit, nhưng SwiftUI mở rộng thêm
// nhiều ToggleStyle: switch, checkbox, button... và cho phép
// tạo custom style hoàn toàn.
//
// Toggle cũng là building block cho các patterns phức tạp:
// multi-select, mixed state, feature flags UI, settings forms...
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÚ PHÁP CƠ BẢN & ANATOMY                           ║
// ╚══════════════════════════════════════════════════════════╝

// Toggle(
//     "Label",                  ← Nhãn mô tả
//     isOn: $boolBinding        ← Binding<Bool> điều khiển on/off
// )

struct BasicToggleDemo: View {
    @State private var wifiEnabled = true
    @State private var bluetoothEnabled = false
    @State private var airplaneMode = false
    
    var body: some View {
        Form {
            // --- Cách 1: String label ---
            Toggle("Wi-Fi", isOn: $wifiEnabled)
            
            // --- Cách 2: Label view builder ---
            Toggle(isOn: $bluetoothEnabled) {
                Label("Bluetooth", systemImage: "antenna.radiowaves.left.and.right")
            }
            
            // --- Cách 3: Custom label phức tạp ---
            Toggle(isOn: $airplaneMode) {
                HStack {
                    Image(systemName: "airplane")
                        .foregroundStyle(.orange)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Chế độ máy bay")
                            .font(.body)
                        Text("Tắt tất cả kết nối không dây")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Hiển thị trạng thái
            Section("Trạng thái") {
                Text("Wi-Fi: \(wifiEnabled ? "Bật" : "Tắt")")
                Text("Bluetooth: \(bluetoothEnabled ? "Bật" : "Tắt")")
                Text("Airplane: \(airplaneMode ? "Bật" : "Tắt")")
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. TOGGLE STYLES — TẤT CẢ CÁC KIỂU GIAO DIỆN         ║
// ╚══════════════════════════════════════════════════════════╝

struct ToggleStylesShowcase: View {
    @State private var option1 = true
    @State private var option2 = false
    @State private var option3 = true
    @State private var option4 = false
    
    var body: some View {
        Form {
            // === 2a. .switch (Default trên iOS) ===
            // Thanh trượt on/off kinh điển của iOS
            Section(".switch (Default)") {
                Toggle("Wi-Fi", isOn: $option1)
                    .toggleStyle(.switch)
                // .toggleStyle(.switch) là default, không cần ghi explicit
            }
            
            // === 2b. .button (iOS 15+) ===
            // Hiển thị dạng button: tap để toggle
            // Highlighted khi ON, normal khi OFF
            Section(".button") {
                Toggle("Yêu thích", isOn: $option2)
                    .toggleStyle(.button)
                // Khi ON: button có background tint
                // Khi OFF: button style bình thường
            }
            
            // === 2c. .checkbox (macOS only) ===
            // ⚠️ Chỉ có trên macOS, KHÔNG có trên iOS
            // Toggle("Đồng ý", isOn: $option3)
            //     .toggleStyle(.checkbox)
            
            // === 2d. .automatic ===
            // Platform tự chọn: iOS → switch, macOS → checkbox
            Section(".automatic") {
                Toggle("Tự động", isOn: $option4)
                    .toggleStyle(.automatic)
            }
        }
    }
}

// ┌──────────────────┬──────────┬────────────────────────────┐
// │ Style            │ Platform │ Giao diện                  │
// ├──────────────────┼──────────┼────────────────────────────┤
// │ .automatic       │ All      │ Platform tự chọn           │
// │ .switch          │ iOS/mac  │ Thanh trượt on/off (UISwitch) │
// │ .button          │ iOS 15+  │ Button highlight khi ON    │
// │ .checkbox        │ macOS    │ Checkbox ☑️ (không có iOS) │
// └──────────────────┴──────────┴────────────────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  3. TINT & APPEARANCE CUSTOMIZATION                      ║
// ╚══════════════════════════════════════════════════════════╝

struct ToggleAppearanceDemo: View {
    @State private var premium = false
    @State private var darkMode = true
    @State private var notifications = true
    @State private var autoSave = false
    
    var body: some View {
        Form {
            // === 3a. .tint() — Đổi màu ON state ===
            Section("Tint Color") {
                Toggle("Premium", isOn: $premium)
                    .tint(.purple)      // Màu tím khi ON
                
                Toggle("Dark Mode", isOn: $darkMode)
                    .tint(.indigo)      // Màu indigo khi ON
                
                Toggle("Thông báo", isOn: $notifications)
                    .tint(.orange)
                
                // .tint chỉ ảnh hưởng màu ON
                // Màu OFF (xám) KHÔNG thay đổi được qua .tint
            }
            
            // === 3b. .labelsHidden() — Ẩn label ===
            Section("Hidden Label") {
                HStack {
                    Text("Tự động lưu")
                    Spacer()
                    Image(systemName: autoSave ? "checkmark.icloud" : "icloud")
                        .foregroundStyle(autoSave ? .green : .gray)
                    Toggle("Auto Save", isOn: $autoSave)
                        .labelsHidden()
                        // Label ẩn nhưng VẪN CÒN cho VoiceOver
                        // → Accessibility vẫn đọc "Auto Save"
                }
            }
            
            // === 3c. .disabled() — Vô hiệu hoá ===
            Section("Disabled State") {
                Toggle("Premium Feature", isOn: .constant(false))
                    .disabled(true)
                    // Hiển thị mờ, không tap được
                
                Toggle("Enabled Feature", isOn: $notifications)
                    .disabled(false) // Mặc định
            }
            
            // === 3d. .button style + tint ===
            Section("Button Style Tints") {
                HStack {
                    Toggle(isOn: $premium) {
                        Label("Star", systemImage: "star.fill")
                    }
                    .toggleStyle(.button)
                    .tint(.yellow)
                    
                    Toggle(isOn: $darkMode) {
                        Label("Moon", systemImage: "moon.fill")
                    }
                    .toggleStyle(.button)
                    .tint(.indigo)
                    
                    Toggle(isOn: $notifications) {
                        Label("Bell", systemImage: "bell.fill")
                    }
                    .toggleStyle(.button)
                    .tint(.orange)
                }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. onChange — PHẢN ỨNG KHI TOGGLE THAY ĐỔI              ║
// ╚══════════════════════════════════════════════════════════╝

struct ToggleOnChangeDemo: View {
    @State private var notificationsEnabled = true
    @State private var biometricEnabled = false
    @State private var statusMessage = ""
    
    var body: some View {
        Form {
            Section {
                Toggle("Thông báo", isOn: $notificationsEnabled)
                
                Toggle("Face ID / Touch ID", isOn: $biometricEnabled)
            }
            
            Section("Log") {
                Text(statusMessage)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        // === iOS 17+ syntax (old + new value) ===
        .onChange(of: notificationsEnabled) { oldValue, newValue in
            statusMessage = "Thông báo: \(oldValue ? "ON" : "OFF") → \(newValue ? "ON" : "OFF")"
            
            if newValue {
                requestNotificationPermission()
            }
        }
        .onChange(of: biometricEnabled) { _, newValue in
            if newValue {
                authenticateWithBiometric()
            }
        }
        
        // === iOS 14-16 syntax ===
        // .onChange(of: notificationsEnabled) { newValue in ... }
    }
    
    func requestNotificationPermission() {
        // Request push notification permission
    }
    
    func authenticateWithBiometric() {
        // Trigger Face ID / Touch ID authentication
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. TOGGLE VỚI @Observable / ObservableObject            ║
// ╚══════════════════════════════════════════════════════════╝

// === 5a. @Observable (iOS 17+) — Khuyến khích ===

@Observable
final class SettingsModel {
    var pushNotifications = true
    var emailNotifications = false
    var soundEnabled = true
    var hapticEnabled = true
    var autoUpdate = false
    var darkMode = false
    
    // Computed property dựa trên nhiều toggles
    var allNotificationsOff: Bool {
        !pushNotifications && !emailNotifications
    }
    
    func resetToDefaults() {
        pushNotifications = true
        emailNotifications = false
        soundEnabled = true
        hapticEnabled = true
        autoUpdate = false
        darkMode = false
    }
}

struct SettingsView: View {
    @Bindable var settings: SettingsModel
    
    var body: some View {
        Form {
            Section("Thông báo") {
                Toggle("Push Notifications", isOn: $settings.pushNotifications)
                Toggle("Email Notifications", isOn: $settings.emailNotifications)
                
                if settings.allNotificationsOff {
                    Text("⚠️ Tất cả thông báo đã tắt")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            
            Section("Âm thanh & Rung") {
                Toggle("Âm thanh", isOn: $settings.soundEnabled)
                Toggle("Haptic Feedback", isOn: $settings.hapticEnabled)
                    .disabled(!settings.soundEnabled)
                    // Haptic disabled nếu sound tắt
            }
            
            Section("Hệ thống") {
                Toggle("Tự động cập nhật", isOn: $settings.autoUpdate)
                Toggle("Dark Mode", isOn: $settings.darkMode)
            }
            
            Section {
                Button("Khôi phục mặc định", role: .destructive) {
                    withAnimation {
                        settings.resetToDefaults()
                    }
                }
            }
        }
    }
}

#Preview("Settings") {
    @Previewable @State var settings = SettingsModel()
    NavigationStack {
        SettingsView(settings: settings)
            .navigationTitle("Cài đặt")
    }
}

// === 5b. ObservableObject (iOS 13+) — Legacy ===

final class LegacySettings: ObservableObject {
    @Published var isDarkMode = false
    @Published var isNotificationsOn = true
}

struct LegacySettingsView: View {
    @StateObject private var settings = LegacySettings()
    // Hoặc @EnvironmentObject var settings: LegacySettings
    
    var body: some View {
        Form {
            Toggle("Dark Mode", isOn: $settings.isDarkMode)
            Toggle("Notifications", isOn: $settings.isNotificationsOn)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. CUSTOM TOGGLE STYLE — TẠO GIAO DIỆN RIÊNG           ║
// ╚══════════════════════════════════════════════════════════╝

// ToggleStyle protocol cho phép custom hoàn toàn giao diện Toggle.
// Chỉ cần implement 1 method: makeBody(configuration:)
//
// Configuration cung cấp:
// - configuration.isOn: Bool (trạng thái hiện tại)
// - configuration.$isOn: Binding<Bool> (two-way binding)
// - configuration.label: Label view (nhãn từ Toggle)

// === 6a. Checkbox Style (iOS) ===

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(configuration.isOn ? .blue : .gray)
                    .contentTransition(.symbolEffect(.replace))
                
                configuration.label
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

// Extension cho syntax đẹp
extension ToggleStyle where Self == CheckboxToggleStyle {
    static var checkbox: CheckboxToggleStyle { CheckboxToggleStyle() }
}

#Preview("Checkbox Style") {
    @Previewable @State var agree = false
    @Previewable @State var newsletter = true
    
    VStack(alignment: .leading, spacing: 16) {
        Toggle("Tôi đồng ý điều khoản sử dụng", isOn: $agree)
            .toggleStyle(.checkbox)
        
        Toggle("Nhận bản tin hàng tuần", isOn: $newsletter)
            .toggleStyle(.checkbox)
    }
    .padding()
}


// === 6b. Power Button Style ===

struct PowerToggleStyle: ToggleStyle {
    var onColor: Color = .green
    var offColor: Color = .gray.opacity(0.3)
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    configuration.isOn.toggle()
                }
            } label: {
                Image(systemName: "power")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(configuration.isOn ? onColor : .gray)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(configuration.isOn ? onColor.opacity(0.15) : offColor)
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                configuration.isOn ? onColor : .gray.opacity(0.3),
                                lineWidth: 3
                            )
                    )
                    .scaleEffect(configuration.isOn ? 1.0 : 0.92)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact, trigger: configuration.isOn)
            
            configuration.label
                .font(.caption)
                .foregroundStyle(configuration.isOn ? onColor : .secondary)
        }
    }
}

extension ToggleStyle where Self == PowerToggleStyle {
    static var power: PowerToggleStyle { PowerToggleStyle() }
    static func power(onColor: Color) -> PowerToggleStyle {
        PowerToggleStyle(onColor: onColor)
    }
}

#Preview("Power Button") {
    @Previewable @State var isOn = false
    
    HStack(spacing: 40) {
        Toggle("Wi-Fi", isOn: $isOn)
            .toggleStyle(.power)
        
        Toggle("Bluetooth", isOn: .constant(true))
            .toggleStyle(.power(onColor: .blue))
    }
    .padding()
}


// === 6c. Animated Switch Style ===

struct AnimatedSwitchStyle: ToggleStyle {
    var onColor: Color = .green
    var offColor: Color = .gray.opacity(0.3)
    var thumbColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            ZStack {
                // Track
                Capsule()
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: 52, height: 32)
                
                // Thumb
                Circle()
                    .fill(thumbColor)
                    .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                    .frame(width: 28, height: 28)
                    .offset(x: configuration.isOn ? 10 : -10)
                
                // Icon trên thumb
                Image(systemName: configuration.isOn ? "checkmark" : "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(configuration.isOn ? onColor : .gray)
                    .offset(x: configuration.isOn ? 10 : -10)
            }
            .onTapGesture {
                withAnimation(.spring(duration: 0.25, bounce: 0.2)) {
                    configuration.isOn.toggle()
                }
            }
        }
    }
}

extension ToggleStyle where Self == AnimatedSwitchStyle {
    static var animatedSwitch: AnimatedSwitchStyle { AnimatedSwitchStyle() }
}

#Preview("Animated Switch") {
    @Previewable @State var isOn = true
    
    Toggle("Airplane Mode", isOn: $isOn)
        .toggleStyle(.animatedSwitch)
        .padding()
}


// === 6d. Card Toggle Style ===

struct CardToggleStyle: ToggleStyle {
    var icon: String
    var activeColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                configuration.isOn.toggle()
            }
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(configuration.isOn ? activeColor : .gray)
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(configuration.isOn
                                  ? activeColor.opacity(0.15)
                                  : Color.gray.opacity(0.08))
                    )
                
                configuration.label
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(configuration.isOn ? .primary : .secondary)
                
                Circle()
                    .fill(configuration.isOn ? activeColor : .gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn
                          ? activeColor.opacity(0.06)
                          : Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        configuration.isOn ? activeColor.opacity(0.3) : .clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Card Toggles") {
    @Previewable @State var wifi = true
    @Previewable @State var bluetooth = false
    @Previewable @State var airdrop = true
    @Previewable @State var hotspot = false
    
    HStack(spacing: 12) {
        Toggle("Wi-Fi", isOn: $wifi)
            .toggleStyle(CardToggleStyle(icon: "wifi", activeColor: .blue))
        Toggle("Bluetooth", isOn: $bluetooth)
            .toggleStyle(CardToggleStyle(icon: "antenna.radiowaves.left.and.right", activeColor: .blue))
        Toggle("AirDrop", isOn: $airdrop)
            .toggleStyle(CardToggleStyle(icon: "airdrop", activeColor: .blue))
        Toggle("Hotspot", isOn: $hotspot)
            .toggleStyle(CardToggleStyle(icon: "personalhotspot", activeColor: .green))
    }
    .padding()
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. SOURCES OF TRUTH — TOGGLE VỚI CÁC BINDING SOURCES   ║
// ╚══════════════════════════════════════════════════════════╝

// Toggle luôn cần Binding<Bool>. Có nhiều nguồn tạo Binding:

struct BindingSourcesDemo: View {
    // === 7a. @State — Phổ biến nhất ===
    @State private var isOn = false
    
    // === 7b. @AppStorage — Persist qua UserDefaults ===
    @AppStorage("notifications_enabled") private var notificationsEnabled = true
    @AppStorage("dark_mode") private var darkMode = false
    
    // === 7c. @Observable model ===
    @State private var settings = SettingsModel()
    
    var body: some View {
        Form {
            // @State binding
            Toggle("Local State", isOn: $isOn)
            
            // @AppStorage: giá trị LƯU LẠI khi kill app
            Section("Persisted (UserDefaults)") {
                Toggle("Thông báo", isOn: $notificationsEnabled)
                Toggle("Dark Mode", isOn: $darkMode)
                // Kill app → mở lại → giá trị vẫn giữ nguyên!
            }
            
            // @Bindable model
            Section("Model Binding") {
                Toggle("Push", isOn: $settings.pushNotifications)
            }
            
            // === 7d. Constant binding (không thay đổi được) ===
            Section("Constant") {
                Toggle("Luôn bật", isOn: .constant(true))
                Toggle("Luôn tắt", isOn: .constant(false))
                // User tap nhưng KHÔNG thay đổi được → dùng cho demo/preview
            }
            
            // === 7e. Custom Binding (transform logic) ===
            Section("Custom Binding") {
                Toggle("Inverse Dark Mode", isOn: Binding(
                    get: { !darkMode },        // Đọc: đảo ngược
                    set: { darkMode = !$0 }    // Ghi: đảo ngược lại
                ))
                // Toggle ON → darkMode = false, và ngược lại
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. MIXED STATE — TOGGLE CHA + CON (tri-state)           ║
// ╚══════════════════════════════════════════════════════════╝

// Pattern: Toggle cha điều khiển tất cả toggles con.
// Nếu một số con ON, một số OFF → cha hiển thị "mixed" state.
// Giống "Select All" checkbox trong desktop apps.

struct MixedStateDemo: View {
    @State private var pushEnabled = true
    @State private var emailEnabled = false
    @State private var smsEnabled = true
    
    // Computed binding cho "parent" toggle
    private var allNotifications: Binding<Bool> {
        Binding(
            get: {
                // ON nếu TẤT CẢ đều ON
                pushEnabled && emailEnabled && smsEnabled
            },
            set: { newValue in
                // Set TẤT CẢ cùng giá trị
                pushEnabled = newValue
                emailEnabled = newValue
                smsEnabled = newValue
            }
        )
    }
    
    // Kiểm tra có đang mixed state không
    private var isMixed: Bool {
        let values = [pushEnabled, emailEnabled, smsEnabled]
        let onCount = values.filter { $0 }.count
        return onCount > 0 && onCount < values.count
    }
    
    var body: some View {
        Form {
            Section {
                // Parent toggle
                HStack {
                    Toggle("Tất cả thông báo", isOn: allNotifications)
                        .font(.headline)
                    
                    if isMixed {
                        Image(systemName: "minus.square.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }
            }
            
            Section {
                // Child toggles
                Toggle("Push Notifications", isOn: $pushEnabled)
                Toggle("Email", isOn: $emailEnabled)
                Toggle("SMS", isOn: $smsEnabled)
            } header: {
                Text("Chi tiết")
            } footer: {
                if isMixed {
                    Text("Một số loại thông báo đang tắt")
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. TOGGLE TRONG CÁC CONTEXT KHÁC NHAU                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 9a. Toggle trong List với ForEach ===

struct TodoItem: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

struct ToggleInListDemo: View {
    @State private var todos = [
        TodoItem(title: "Mua sữa", isCompleted: false),
        TodoItem(title: "Code review", isCompleted: true),
        TodoItem(title: "Tập gym", isCompleted: false),
        TodoItem(title: "Đọc sách", isCompleted: false),
        TodoItem(title: "Nấu cơm", isCompleted: true),
    ]
    
    var completedCount: Int {
        todos.filter(\.isCompleted).count
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Tiến độ: \(completedCount)/\(todos.count)") {
                    ForEach($todos) { $todo in
                        // $todos → ForEach cung cấp $todo (Binding<TodoItem>)
                        Toggle(isOn: $todo.isCompleted) {
                            Text(todo.title)
                                .strikethrough(todo.isCompleted)
                                .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                        }
                        .tint(.green)
                    }
                }
            }
            .navigationTitle("Todo List")
            .animation(.default, value: completedCount)
        }
    }
}


// === 9b. Toggle trong Toolbar ===

struct ToggleInToolbarDemo: View {
    @State private var showCompleted = true
    @State private var isGridView = false
    
    var body: some View {
        NavigationStack {
            Text(showCompleted ? "Hiện tất cả" : "Ẩn đã xong")
            
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        // Toggle button style phù hợp cho toolbar
                        Toggle(isOn: $isGridView) {
                            Image(systemName: isGridView ? "square.grid.2x2" : "list.bullet")
                        }
                        .toggleStyle(.button)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Toggle(isOn: $showCompleted) {
                            Image(systemName: showCompleted ? "eye" : "eye.slash")
                        }
                        .toggleStyle(.button)
                    }
                }
                .navigationTitle("Tasks")
        }
    }
}


// === 9c. Toggle ngoài Form (Standalone) ===

struct StandaloneToggleDemo: View {
    @State private var isEnabled = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Standalone: Toggle chiếm full width
            Toggle("Bật tính năng", isOn: $isEnabled)
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                .padding(.horizontal)
            
            // Compact: labelsHidden + HStack
            HStack {
                Text("Chế độ nâng cao")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(.purple)
            }
            .padding()
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. ANIMATION & TRANSITIONS                             ║
// ╚══════════════════════════════════════════════════════════╝

struct ToggleAnimationDemo: View {
    @State private var showAdvanced = false
    @State private var enableFeature = false
    
    var body: some View {
        Form {
            // === 10a. Ẩn/Hiện content dựa trên toggle ===
            Section {
                Toggle("Hiện tuỳ chọn nâng cao", isOn: $showAdvanced.animation(.spring))
                //                                         ^^^^^^^^^^^^^^^^^^^^^^
                // .animation trên Binding → animate MỌI thay đổi liên quan
                
                if showAdvanced {
                    // Content tự animate in/out
                    Toggle("Feature A", isOn: $enableFeature)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Toggle("Feature B", isOn: .constant(false))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Picker("Quality", selection: .constant(0)) {
                        Text("Low").tag(0)
                        Text("High").tag(1)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            
            // === 10b. Animate content thay đổi ===
            Section {
                Toggle("Enable Feature", isOn: $enableFeature)
                
                // UI thay đổi theo toggle state
                HStack {
                    Image(systemName: enableFeature ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundStyle(enableFeature ? .green : .red)
                        .contentTransition(.symbolEffect(.replace))
                    
                    Text(enableFeature ? "Đã bật" : "Đã tắt")
                        .contentTransition(.numericText())
                }
                .animation(.easeInOut, value: enableFeature)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  11. ASYNC TOGGLE — XỬ LÝ BẤT ĐỒNG BỘ                  ║
// ╚══════════════════════════════════════════════════════════╝

// Pattern: Toggle gọi API để thay đổi setting trên server.
// Cần hiện loading state + rollback nếu API fail.

@Observable
final class FeatureToggleViewModel {
    var isFeatureEnabled = false
    var isLoading = false
    var error: String?
    
    @MainActor
    func toggleFeature(newValue: Bool) async {
        let previousValue = isFeatureEnabled
        
        // Optimistic update: thay đổi UI ngay
        isFeatureEnabled = newValue
        isLoading = true
        error = nil
        
        do {
            // Gọi API
            try await updateFeatureOnServer(enabled: newValue)
            isLoading = false
        } catch {
            // Rollback nếu thất bại
            isFeatureEnabled = previousValue
            isLoading = false
            self.error = "Không thể cập nhật. Vui lòng thử lại."
        }
    }
    
    private func updateFeatureOnServer(enabled: Bool) async throws {
        // Simulate API call
        try await Task.sleep(for: .seconds(1.5))
        // Simulate random failure
        if Bool.random() { throw URLError(.badServerResponse) }
    }
}

struct AsyncToggleDemo: View {
    @State private var viewModel = FeatureToggleViewModel()
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Toggle("Premium Feature", isOn: Binding(
                        get: { viewModel.isFeatureEnabled },
                        set: { newValue in
                            Task {
                                await viewModel.toggleFeature(newValue: newValue)
                            }
                        }
                    ))
                    .disabled(viewModel.isLoading)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            } footer: {
                if let error = viewModel.error {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  12. ACCESSIBILITY                                       ║
// ╚══════════════════════════════════════════════════════════╝

struct AccessibleToggleDemo: View {
    @State private var isVoiceOverOptimized = false
    @State private var largeText = false
    
    var body: some View {
        Form {
            // Built-in: Toggle đã có accessibility tốt
            // VoiceOver tự đọc: "Wi-Fi, switch button, on/off"
            Toggle("Wi-Fi", isOn: .constant(true))
            
            // Custom accessibility
            Toggle(isOn: $isVoiceOverOptimized) {
                Text("VoiceOver Mode")
            }
            .accessibilityLabel("Chế độ VoiceOver")
            .accessibilityHint("Bật để tối ưu giao diện cho VoiceOver")
            .accessibilityValue(isVoiceOverOptimized ? "Đang bật" : "Đang tắt")
            
            // Accessibility action thêm
            Toggle("Chữ lớn", isOn: $largeText)
                .accessibilityAddTraits(.isButton)
            
            // ⚠️ Khi dùng Custom ToggleStyle:
            // PHẢI đảm bảo style vẫn accessible.
            // .accessibilityAddTraits(.isToggle) nếu cần.
            Toggle("Checkbox accessible", isOn: $largeText)
                .toggleStyle(.checkbox)
                .accessibilityAddTraits(.isToggle)
                // Nhắc VoiceOver đây là toggle, không chỉ là button
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  13. PRODUCTION PATTERNS                                 ║
// ╚══════════════════════════════════════════════════════════╝

// === 13a. Feature Flag UI ===

struct FeatureFlag: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    var isEnabled: Bool
    let requiresPremium: Bool
}

struct FeatureFlagsView: View {
    @State private var features = [
        FeatureFlag(id: "dark", name: "Dark Mode", description: "Giao diện tối",
                   icon: "moon.fill", isEnabled: true, requiresPremium: false),
        FeatureFlag(id: "ai", name: "AI Assistant", description: "Trợ lý AI thông minh",
                   icon: "brain", isEnabled: false, requiresPremium: true),
        FeatureFlag(id: "cloud", name: "Cloud Sync", description: "Đồng bộ iCloud",
                   icon: "icloud.fill", isEnabled: true, requiresPremium: false),
        FeatureFlag(id: "analytics", name: "Analytics", description: "Theo dõi hiệu suất",
                   icon: "chart.bar.fill", isEnabled: false, requiresPremium: true),
    ]
    
    let isPremium = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach($features) { $feature in
                    HStack(spacing: 14) {
                        Image(systemName: feature.icon)
                            .font(.title3)
                            .foregroundStyle(feature.isEnabled ? .blue : .gray)
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(feature.name)
                                    .font(.body.weight(.medium))
                                if feature.requiresPremium {
                                    Text("PRO")
                                        .font(.system(size: 9, weight: .bold))
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(.orange, in: .capsule)
                                        .foregroundStyle(.white)
                                }
                            }
                            Text(feature.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $feature.isEnabled)
                            .labelsHidden()
                            .disabled(feature.requiresPremium && !isPremium)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Tính năng")
        }
    }
}


// === 13b. iOS Settings-like Section ===

struct SettingsSection: View {
    @AppStorage("notifications") private var notifications = true
    @AppStorage("sounds") private var sounds = true
    @AppStorage("badges") private var badges = true
    @AppStorage("lock_screen") private var lockScreen = false
    @AppStorage("biometric") private var biometric = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $notifications) {
                        SettingsRow(
                            icon: "bell.badge.fill",
                            iconColor: .red,
                            title: "Thông báo"
                        )
                    }
                    
                    Toggle(isOn: $sounds) {
                        SettingsRow(
                            icon: "speaker.wave.2.fill",
                            iconColor: .pink,
                            title: "Âm thanh"
                        )
                    }
                    .disabled(!notifications)
                    
                    Toggle(isOn: $badges) {
                        SettingsRow(
                            icon: "app.badge.fill",
                            iconColor: .red,
                            title: "Badges"
                        )
                    }
                    .disabled(!notifications)
                    
                    Toggle(isOn: $lockScreen) {
                        SettingsRow(
                            icon: "lock.shield.fill",
                            iconColor: .blue,
                            title: "Hiện trên Lock Screen"
                        )
                    }
                    .disabled(!notifications)
                }
                
                Section {
                    Toggle(isOn: $biometric) {
                        SettingsRow(
                            icon: "faceid",
                            iconColor: .green,
                            title: "Face ID"
                        )
                    }
                }
            }
            .navigationTitle("Cài đặt")
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(iconColor, in: .rect(cornerRadius: 6))
            
            Text(title)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  14. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Toggle không phản ứng
//    Toggle("Test", isOn: .constant(true)) // .constant = không thay đổi được!
//    ✅ FIX: Dùng @State hoặc Binding thực sự

// ❌ PITFALL 2: Quên disabled cho dependent toggles
//    Sound toggle vẫn bật được khi Notifications đã tắt
//    ✅ FIX: .disabled(!parentToggle) cho child toggles

// ❌ PITFALL 3: Side effects trong Binding set
//    Toggle("X", isOn: Binding(get: { val }, set: { val = $0; heavyWork() }))
//    → heavyWork() chạy trên main thread → freeze UI
//    ✅ FIX: Dùng .onChange + Task { } cho async side effects

// ❌ PITFALL 4: Custom ToggleStyle thiếu accessibility
//    Custom checkbox/power button không được VoiceOver nhận diện
//    ✅ FIX: .accessibilityAddTraits(.isToggle)

// ❌ PITFALL 5: Animation conflict
//    withAnimation { isOn.toggle() } bên trong custom ToggleStyle
//    + .animation() modifier bên ngoài → animation chồng chéo
//    ✅ FIX: Chọn 1 cách animate, ưu tiên .animation trên Binding

// ✅ BEST PRACTICES:
// 1. .tint() thay vì hack màu bằng overlay/background
// 2. .onChange(of:) cho side effects, KHÔNG đặt logic trong Binding.set
// 3. .disabled() cho dependent toggles (sound phụ thuộc notification)
// 4. @AppStorage cho settings cần persist qua UserDefaults
// 5. Custom ToggleStyle phải có .accessibilityAddTraits(.isToggle)
// 6. sensoryFeedback cho custom styles (haptic khi tap)
// 7. .labelsHidden() khi label custom nằm riêng → ẩn label mặc định
//    nhưng VẪN GIỮ label text cho VoiceOver
// 8. Optimistic update + rollback cho async toggles (server sync)

---

Mình sẽ giải thích toàn bộ Toggle từ cơ bản đến các patterns nâng cao, bao gồm cả custom toggle styles mà ít tài liệu đề cập chi tiết.Mình đã tổng hợp toàn bộ kiến thức Toggle trong 14 phần. Đây là những điểm cốt lõi:

**Toggle tuy đơn giản nhưng có chiều sâu** ở hai khía cạnh: **ToggleStyle protocol** cho phép custom giao diện hoàn toàn, và **Binding patterns** cho phép xử lý các tình huống phức tạp.

**Ba phần quan trọng nhất cho production:**

**Phần 6 — Custom ToggleStyle** là phần giá trị nhất. SwiftUI chỉ cung cấp `.switch` và `.button` trên iOS, nhưng `ToggleStyle` protocol cho phép tạo bất kỳ giao diện nào: checkbox, power button, animated switch, card toggle... Chỉ cần implement `makeBody(configuration:)` — `configuration` cung cấp `isOn`, `$isOn` (Binding), và `label`. Lưu ý quan trọng là custom style **phải thêm** `.accessibilityAddTraits(.isToggle)` để VoiceOver nhận diện đúng.

**Phần 8 — Mixed State**: Pattern "Select All" toggle cha điều khiển toggles con thông qua **computed Binding** — `Binding(get:set:)`. Khi một số con ON, một số OFF → cha hiển thị trạng thái mixed. Đây là pattern phổ biến trong settings và permission screens.

**Phần 11 — Async Toggle**: Pattern **optimistic update + rollback** khi toggle gọi API. UI thay đổi ngay lập tức (responsive), nếu API fail thì rollback về giá trị cũ. Dùng custom `Binding(get:set:)` để wrap logic async vào set closure, kết hợp `Task { await ... }`.

**Một tip hay ở Phần 10**: thay vì dùng `withAnimation` rồi toggle, có thể dùng `$showAdvanced.animation(.spring)` — gắn animation trực tiếp vào Binding, mọi thay đổi liên quan đều tự animate.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
