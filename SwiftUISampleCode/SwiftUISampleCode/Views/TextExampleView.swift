//
//  TextExampleView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

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

struct TextExampleView: View {
    @State var followers = 1234
    
    var body: some View {
        List {
            // ╔══════════════════════════════════════════════════════════╗
            // ║  1. KHỞI TẠO TEXT — CÁC INITIALIZER                      ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: TextInitializersDemo()) {
                MenuRow(detailViewName: "KHỞI TẠO TEXT — CÁC INITIALIZER")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  2. FONT SYSTEM — HỆ THỐNG FONT                          ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: FontSystemDemo()) {
                MenuRow(detailViewName: "FONT SYSTEM — HỆ THỐNG FONT")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  3. TEXT STYLING MODIFIERS                               ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: TextStylingDemo()) {
                MenuRow(detailViewName: "TEXT STYLING MODIFIERS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  4. MULTILINE — LINE LIMIT, TRUNCATION, WRAPPING         ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: MultilineDemo()) {
                MenuRow(detailViewName: "MULTILINE — LINE LIMIT, TRUNCATION, WRAPPING")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  5. TEXT CONCATENATION — NỐI TEXT GIỮ STYLING            ║
            // ╚══════════════════════════════════════════════════════════╝
            // Operator + nối nhiều Text views, mỗi phần GIỮ style riêng.
            // Kết quả vẫn là 1 Text view duy nhất (không phải HStack).
            // ⚠️ GIỚI HẠN CỦA TEXT CONCATENATION:
            // - Chỉ nối Text + Text (không nối Text + other View)
            // - Modifier sau + áp dụng cho phần TRƯỚC đó, không phải toàn bộ
            // - Không dùng được với @ViewBuilder conditions (if/else)
            // - Kết quả là Text → vẫn dùng được .lineLimit(), .multilineTextAlignment()
            
            NavigationLink(destination: TextConcatenationDemo()) {
                MenuRow(detailViewName: "TEXT CONCATENATION — NỐI TEXT GIỮ STYLING")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  6. MARKDOWN RENDERING (iOS 15+)                         ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: MarkdownDemo()) {
                MenuRow(detailViewName: "MARKDOWN RENDERING (iOS 15+)")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  7. ATTRIBUTEDSTRING — RICH TEXT NÂNG CAO                ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: AttributedStringDemo()) {
                MenuRow(detailViewName: "ATTRIBUTEDSTRING — RICH TEXT NÂNG CAO")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  8. DATE & NUMBER FORMATTING                             ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: FormattingDemo()) {
                MenuRow(detailViewName: "DATE & NUMBER FORMATTING")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  9. TEXT TRANSITIONS & ANIMATIONS (iOS 17+)              ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: TextAnimationDemo()) {
                MenuRow(detailViewName: "TEXT TRANSITIONS & ANIMATIONS (iOS 17+)")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  10. TEXT SELECTION & INTERACTION                         ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: TextInteractionDemo()) {
                MenuRow(detailViewName: "TEXT SELECTION & INTERACTION")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  11. LOCALIZATION                                        ║
            // ╚══════════════════════════════════════════════════════════╝
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
            
            NavigationLink(destination: LocalizationDemo()) {
                MenuRow(detailViewName: "LOCALIZATION")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  12. PRODUCTION PATTERNS                                  ║
            // ╚══════════════════════════════════════════════════════════╝
            
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
            
            ExpandableText(
                text: "SwiftUI là framework UI khai báo (declarative) của Apple, ra mắt năm 2019. Nó cho phép developers xây dựng giao diện người dùng bằng cách mô tả WHAT (muốn gì) thay vì HOW (làm thế nào). SwiftUI tích hợp sâu với Swift language, tận dụng features như property wrappers, result builders, và macros để tạo ra API cực kỳ gọn gàng. Với mỗi phiên bản iOS mới, SwiftUI ngày càng mạnh mẽ hơn.",
                lineLimit: 3
            )
            .padding()
            
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
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  13. REDACTION — PLACEHOLDER / SKELETON                  ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: RedactionDemo()) {
                MenuRow(detailViewName: "REDACTION — PLACEHOLDER / SKELETON")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  14. ACCESSIBILITY                                       ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: AccessibleTextDemo()) {
                MenuRow(detailViewName: "ACCESSIBILITY")
            }
        }
    }
}

#Preview {
    TextExampleView()
}
