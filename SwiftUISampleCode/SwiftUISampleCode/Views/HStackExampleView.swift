//
//  HStackExampleView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/11.
//

import SwiftUI

struct DemoRow: View {
    let title: String
    let alignment: VerticalAlignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
            
            HStack(alignment: alignment, spacing: 12) {
                Text("A").font(.caption)
                    .padding(8).background(.blue.opacity(0.2), in: .rect(cornerRadius: 4))
                
                Text("B").font(.title)
                    .padding(8).background(.green.opacity(0.2), in: .rect(cornerRadius: 4))
                
                Text("C\nLine2").font(.body)
                    .padding(8).background(.orange.opacity(0.2), in: .rect(cornerRadius: 4))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(.gray.opacity(0.08), in: .rect(cornerRadius: 8))
        }
    }
}

struct HStackExampleView: View {
    
    var body: some View {
        List {
            // ╔══════════════════════════════════════════════════════════╗
            // ║  1. CÚ PHÁP & INITIALIZER                                ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: HStackExample1View()) {
                MenuRow(detailViewName: "1. CÚ PHÁP & INITIALIZER")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  2. VERTICAL ALIGNMENT — CĂN CHỈNH THEO CHIỀU DỌC        ║
            // ╚══════════════════════════════════════════════════════════╝
            // Khi children có CHIỀU CAO KHÁC NHAU,
            // alignment quyết định chúng căn theo đâu.
            
            NavigationLink(destination: HStackExample2View()) {
                MenuRow(detailViewName: "2. VERTICAL ALIGNMENT — CĂN CHỈNH THEO CHIỀU DỌC")
            }            
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  2b. firstTextBaseline vs lastTextBaseline CHI TIẾT      ║
            // ╚══════════════════════════════════════════════════════════╝
            // Khi views có text với FONT SIZE KHÁC NHAU,
            // .firstTextBaseline đảm bảo text đọc trên cùng 1 "dòng kẻ".
            // Đây là chuẩn typography mà Apple khuyến khích.
            NavigationLink(destination: HStackExample2_2View()) {
                MenuRow(detailViewName: "2b. firstTextBaseline vs lastTextBaseline CHI TIẾT")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  3. CUSTOM ALIGNMENT GUIDE                               ║
            // ╚══════════════════════════════════════════════════════════╝
            // Khi built-in alignments không đủ, tạo custom alignment
            // để căn chỉnh tại bất kỳ vị trí nào trong child views.
            
            NavigationLink(destination: HStackExample3View()) {
                MenuRow(detailViewName: "3. CUSTOM ALIGNMENT GUIDE")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  4. LAYOUT SYSTEM — CÁCH HStack PHÂN BỔ KHÔNG GIAN       ║
            // ╚══════════════════════════════════════════════════════════╝
            // HStack phân bổ không gian theo 3 bước:
            //
            // Bước 1: Hỏi mỗi child "bạn cần bao nhiêu không gian?"
            //         (intrinsic content size / ideal size)
            //
            // Bước 2: Trừ đi spacing giữa các children
            //
            // Bước 3: Chia không gian CÒN LẠI cho flexible children
            //         theo layoutPriority (cao → được chia trước)
            //
            // ┌──────────────────────── HStack width ─────────────────────┐
            // │ [Fixed A] [spacing] [Flexible B ←→] [spacing] [Fixed C]   │
            // └───────────────────────────────────────────────────────────┘
            //         ↑                    ↑                       ↑
            //    Lấy đúng size       Chiếm phần còn lại      Lấy đúng size
            //    mình cần             sau khi A, C xong       mình cần
            
            NavigationLink(destination: HStackExample4View()) {
                MenuRow(detailViewName: "4. LAYOUT SYSTEM — CÁCH HStack PHÂN BỔ KHÔNG GIAN")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  5. SPACER — ĐIỀU KHIỂN KHOẢNG TRỐNG                     ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: HStackExample5View()) {
                MenuRow(detailViewName: "5. SPACER — ĐIỀU KHIỂN KHOẢNG TRỐNG")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  6. layoutPriority — ƯU TIÊN PHÂN BỔ KHÔNG GIAN          ║
            // ╚══════════════════════════════════════════════════════════╝
            // Khi không đủ chỗ, HStack cần quyết định child nào bị CẮT.
            // .layoutPriority() quyết định thứ tự ưu tiên:
            // - Priority CAO → được không gian TRƯỚC, ít bị cắt
            // - Priority THẤP → bị cắt trước
            // - Mặc định: tất cả children có priority = 0
            
            NavigationLink(destination: HStackExample6View()) {
                MenuRow(detailViewName: "6. layoutPriority — ƯU TIÊN PHÂN BỔ KHÔNG GIAN")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  7. fixedSize — CHỐNG CO LẠI                             ║
            // ╚══════════════════════════════════════════════════════════╝
            // .fixedSize() ngăn view bị co nhỏ hơn ideal size.
            // Hữu ích khi muốn text KHÔNG bao giờ bị truncate.
            
            NavigationLink(destination: HStackExample7View()) {
                MenuRow(detailViewName: "7. fixedSize — CHỐNG CO LẠI")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  8. HSTACK VỚI FOREACH — DYNAMIC CHILDREN                ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: HStackExample8View()) {
                MenuRow(detailViewName: "8. HSTACK VỚI FOREACH — DYNAMIC CHILDREN")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  9. LAZYHSTACK — PHIÊN BẢN LAZY CHO DANH SÁCH NGANG      ║
            // ╚══════════════════════════════════════════════════════════╝
            // HStack: tạo TẤT CẢ children ngay lập tức (eager)
            // LazyHStack: chỉ tạo children khi SẮP HIỂN THỊ (lazy)
            // → Dùng LazyHStack trong ScrollView ngang với nhiều items
            
            NavigationLink(destination: HStackExample9View()) {
                MenuRow(detailViewName: "9. LAZYHSTACK — PHIÊN BẢN LAZY CHO DANH SÁCH NGANG")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  10. PRODUCTION PATTERNS                                 ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: HStackExample10View()) {
                MenuRow(detailViewName: "10. PRODUCTION PATTERNS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  11. ADAPTIVE LAYOUT — RESPONSIVE DESIGN                 ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: HStackExample11View()) {
                MenuRow(detailViewName: "11. ADAPTIVE LAYOUT — RESPONSIVE DESIGN")
            }
            
        }
        .navigationTitle("HStack exmaples")
    }
}

struct StatBar: View {
    let stats: [(label: String, value: String)]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                if index > 0 {
                    Divider().frame(height: 30)
                }
                
                VStack(spacing: 4) {
                    Text(stat.value)
                        .font(.headline)
                    Text(stat.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity) // Chia BẰNG NHAU
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
    }
}

struct UserRow: View {
    let name: String
    let subtitle: String
    let isOnline: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar + online indicator
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                    )
                
                if isOnline {
                    Circle()
                        .fill(.green)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .offset(x: 2, y: 2)
                }
            }
            
            // User info (flexible)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .layoutPriority(1)
            
            Spacer(minLength: 0)
            
            // Timestamp
            Text("2 phút")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

struct PriceDisplay: View {
    let currency: String
    let amount: String
    let decimal: String
    let period: String
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(currency)
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Text(amount)
                .font(.system(size: 56, weight: .bold, design: .rounded))
            
            Text(decimal)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Text(period)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .padding(.leading, 2)
        }
    }
}

// Bước 1: Định nghĩa custom VerticalAlignment
extension VerticalAlignment {
    // Custom alignment ID
    private enum IconCenterAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center] // Fallback về center
        }
    }
    
    // Public alignment value
    static let iconCenter = VerticalAlignment(IconCenterAlignment.self)
}

#Preview {
    HStackExampleView()
}
