//
//  VStackExampleView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/11.
//

import SwiftUI

extension HorizontalAlignment {
    private enum FormLabelAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }
    
    static let formLabel = HorizontalAlignment(FormLabelAlignment.self)
}



struct ShareOption: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button { } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                    .frame(width: 28)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 14)
        }
    }
}

struct TagChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.blue.opacity(0.1), in: .capsule)
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Content (nhận views giống VStack)
            VStack(alignment: .leading, spacing: 10) {
                content()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray.opacity(0.06), in: .rect(cornerRadius: 16))
    }
}

struct ErrorBoundary<Content: View>: View {
    let isError: Bool
    let errorMessage: String
    var retryAction: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        if isError {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title)
                    .foregroundStyle(.orange)
                Text(errorMessage)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                if let retryAction {
                    Button("Thử lại", action: retryAction)
                        .buttonStyle(.bordered)
                }
            }
            .padding()
        } else {
            content()
        }
    }
}

struct VStackExampleView: View {
    
    
    var body: some View {
        List {
            // ╔══════════════════════════════════════════════════════════╗
            // ║  1. CÚ PHÁP & INITIALIZER                                ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: VStackExample1View()) {
                MenuRow(detailViewName: "1. CÚ PHÁP & INITIALIZER")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  2. HORIZONTAL ALIGNMENT — CĂN CHỈNH THEO CHIỀU NGANG    ║
            // ╚══════════════════════════════════════════════════════════╝
            // Khi children có WIDTH KHÁC NHAU,
            // alignment quyết định chúng căn theo cạnh nào.
            
            NavigationLink(destination: VStackExample2View()) {
                MenuRow(detailViewName: "2. HORIZONTAL ALIGNMENT — CĂN CHỈNH THEO CHIỀU NGANG")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  3. CUSTOM ALIGNMENT GUIDE — CĂN CHỈNH TẠI VỊ TRÍ TUỲ Ý  ║
            // ╚══════════════════════════════════════════════════════════╝
            // Built-in chỉ có .leading, .center, .trailing.
            // Custom AlignmentGuide cho phép căn tại BẤT KỲ điểm nào.
            // Kết quả:
            //           Tên : Nguyễn Văn Huy
            //         Email : huy@example.com
            // Số điện thoại : 0912 345 678
            // ↑ dấu ":" thẳng cột!
            
            NavigationLink(destination: VStackExample3View()) {
                MenuRow(detailViewName: "3. CUSTOM ALIGNMENT GUIDE — CĂN CHỈNH TẠI VỊ TRÍ TUỲ Ý")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  4. LAYOUT SYSTEM — CÁCH VStack PHÂN BỔ KHÔNG GIAN       ║
            // ╚══════════════════════════════════════════════════════════╝
            // VStack phân bổ HEIGHT cho children theo quy tắc:
            //
            // 1. Hỏi mỗi child ideal height
            // 2. Trừ spacing giữa các children
            // 3. Children CỐ ĐỊNH (Text, Image...) lấy đúng size cần
            // 4. Children LINH HOẠT (Spacer, frame(maxHeight:)) chia phần còn lại
            // 5. layoutPriority cao → được chia trước
            //
            // ┌────────────────── VStack height ──────────────────┐
            // │ [ Fixed Header  ]                                 │
            // │ [ spacing       ]                                 │
            // │ [ Flexible Body ↕ chiếm phần còn lại            ] │
            // │ [ spacing       ]                                 │
            // │ [ Fixed Footer  ]                                 │
            // └───────────────────────────────────────────────────┘
            
            NavigationLink(destination: VStackExample4View()) {
                MenuRow(detailViewName: "4. LAYOUT SYSTEM — CÁCH VStack PHÂN BỔ KHÔNG GIAN")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  5. SPACER, layoutPriority & fixedSize                   ║
            // ╚══════════════════════════════════════════════════════════╝
            // Cơ chế giống HStack nhưng hoạt động theo chiều DỌC.
            
            NavigationLink(destination: VStackExample5View()) {
                MenuRow(detailViewName: "5. SPACER, layoutPriority & fixedSize")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  6. VStack TRONG SCROLLVIEW                              ║
            // ╚══════════════════════════════════════════════════════════╝
            // VStack + ScrollView = scrollable vertical content.
            // KHÁC với LazyVStack: VStack tạo TẤT CẢ children ngay lập tức.
            
            NavigationLink(destination: VStackExample6View()) {
                MenuRow(detailViewName: "6. VStack TRONG SCROLLVIEW")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  7. NESTED VStacks — COMPOSITION PATTERNS                ║
            // ╚══════════════════════════════════════════════════════════╝
            // Nesting VStacks với SPACING KHÁC NHAU tạo visual hierarchy.
            // Đây là pattern cốt lõi để build mọi screen trong SwiftUI.
            // Outer VStack: spacing LỚN giữa các SECTIONS
            // NGUYÊN TẮC SPACING HIERARCHY:
            //
            // Outer spacing (giữa sections): 24-32pt
            // Inner spacing (giữa elements trong section): 8-12pt
            // Tight spacing (label + value, icon + text): 4-6pt
            //
            // Tạo ra "nhịp thở" visual rõ ràng cho người dùng,
            // giúp phân biệt đâu là group, đâu là item riêng lẻ.
            
            NavigationLink(destination: VStackExample7View()) {
                MenuRow(detailViewName: "7. NESTED VStacks — COMPOSITION PATTERNS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  8. VSTACK vs GROUP vs SECTION                           ║
            // ╚══════════════════════════════════════════════════════════╝
            // TÓM TẮT:
            // ┌──────────────┬──────────────────────────────────────────┐
            // │ Container    │ Vai trò trong Form/List                  │
            // ├──────────────┼──────────────────────────────────────────┤
            // │ VStack       │ Gom nhiều views thành 1 ROW              │
            // │ Group        │ Nhóm logic, mỗi child vẫn là ROW RIÊNG   │
            // │ Section      │ Tạo grouped section có header/footer     │
            // │ ForEach      │ Mỗi iteration là 1 ROW RIÊNG             │
            // └──────────────┴──────────────────────────────────────────┘
            
            NavigationLink(destination: VStackExample8View()) {
                MenuRow(detailViewName: "8. VSTACK vs GROUP vs SECTION")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  9. PRODUCTION PATTERNS                                  ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: VStackExample9View()) {
                MenuRow(detailViewName: "9. PRODUCTION PATTERNS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  10. ADAPTIVE VStack ↔ HStack                            ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: VStackExample10View()) {
                MenuRow(detailViewName: "10. ADAPTIVE VStack ↔ HStack")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  11. @ViewBuilder — TẠO CUSTOM VSTACK-LIKE CONTAINERS    ║
            // ╚══════════════════════════════════════════════════════════╝
            // Tạo reusable container components dùng @ViewBuilder
            // để nhận nội dung giống như VStack nhận children.
            
            NavigationLink(destination: VStackExample11View()) {
                MenuRow(detailViewName: "11. @ViewBuilder — TẠO CUSTOM VSTACK-LIKE CONTAINERS")
            }
        }
        .navigationTitle("VStack Example")
    }
}

#Preview {
    VStackExampleView()
}
