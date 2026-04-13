//
//  ZStackExampleView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ZStackExampleView: View {
    var body: some View {
        List {
            // ╔══════════════════════════════════════════════════════════╗
            // ║  1. CÚ PHÁP & CƠ CHẾ LAYER                               ║
            // ╚══════════════════════════════════════════════════════════╝
            // THỨ TỰ LAYER (Z-ORDER):
            //
            // ┌─────────────────────────────┐  ← Màn hình (user nhìn)
            // │  Child cuối (layer trên)    │  ← Khai báo SAU → hiện TRÊN
            // │  ┌───────────────────────┐  │
            // │  │  Child giữa           │  │
            // │  │  ┌─────────────────┐  │  │
            // │  │  │  Child đầu      │  │  │  ← Khai báo TRƯỚC → hiện DƯỚI
            // │  │  │  (layer dưới)   │  │  │
            // │  │  └─────────────────┘  │  │
            // │  └───────────────────────┘  │
            // └─────────────────────────────┘
            //
            // Giống Photoshop layers: layer dưới cùng trong panel = nền
            NavigationLink(destination: BasicZStackDemo()) {
                MenuRow(detailViewName: "1. CÚ PHÁP & CƠ CHẾ LAYER")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  2. ALIGNMENT — CĂNG CHỈNH 2 CHIỀU                       ║
            // ╚══════════════════════════════════════════════════════════╝
            // ZStack alignment là Alignment (2D), KHÁC với:
            // - HStack: VerticalAlignment (1 chiều dọc)
            // - VStack: HorizontalAlignment (1 chiều ngang)
            // - ZStack: Alignment (2 chiều: ngang + dọc)
            // 9 ALIGNMENT OPTIONS:
            // ┌──────────────┬─────────────┬───────────────┐
            // │ .topLeading  │    .top     │ .topTrailing  │
            // ├──────────────┼─────────────┼───────────────┤
            // │  .leading    │   .center   │  .trailing    │
            // ├──────────────┼─────────────┼───────────────┤
            // │.bottomLeading│  .bottom    │.bottomTrailing│
            // └──────────────┴─────────────┴───────────────┘
            NavigationLink(destination: AlignmentDemo()) {
                MenuRow(detailViewName: "2. ALIGNMENT — CĂNG CHỈNH 2 CHIỀU")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  3. SIZING — CÁCH ZStack XÁC ĐỊNH KÍCH THƯỚC             ║
            // ╚══════════════════════════════════════════════════════════╝
            // ZStack sizing rule: kích thước = CHILD LỚN NHẤT
            // (union bounding box của tất cả children)
            NavigationLink(destination: SizingDemo()) {
                MenuRow(detailViewName: "3. SIZING — CÁCH ZStack XÁC ĐỊNH KÍCH THƯỚC")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  4. ZStack vs .overlay vs .background                    ║
            // ╚══════════════════════════════════════════════════════════╝
            // 3 cách chồng views, KHÁC NHAU về sizing behavior:
            // ┌──────────────────┬──────────────────────────────────────┐
            // │ Cách dùng        │ Sizing behavior                      │
            // ├──────────────────┼──────────────────────────────────────┤
            // │ ZStack           │ Size = CHILD LỚN NHẤT                │
            // │                  │ Tất cả children ĐỀU ảnh hưởng size   │
            // ├──────────────────┼──────────────────────────────────────┤
            // │ .overlay         │ Size = BASE VIEW (view được overlay) │
            // │                  │ Overlay content KHÔNG ảnh hưởng size │
            // │                  │ → Dùng cho: badges, indicators       │
            // ├──────────────────┼──────────────────────────────────────┤
            // │ .background      │ Size = BASE VIEW (view phía trước)   │
            // │                  │ Background KHÔNG ảnh hưởng size      │
            // │                  │ → Dùng cho: fill, gradient, image    │
            // └──────────────────┴──────────────────────────────────────┘
            //
            // 📌 NGUYÊN TẮC CHỌN:
            // Cần layers ĐỒNG ĐẲNG (không ai là chính)    → ZStack
            // Có BASE VIEW + thêm lớp TRÊN                → .overlay
            // Có CONTENT + thêm lớp DƯỚI (nền)            → .background
            NavigationLink(destination: OverlayVsZStack()) {
                MenuRow(detailViewName: "4. ZStack vs .overlay vs .background")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  5. zIndex — THAY ĐỔI THỨ TỰ LAYER RUNTIME               ║
            // ╚══════════════════════════════════════════════════════════╝
            // Mặc định: thứ tự layer = thứ tự khai báo.
            // .zIndex() override thứ tự này tại runtime.
            // Giá trị CAO hơn → hiển thị TRÊN.
            // zIndex RULES:
            // - Mặc định tất cả children có zIndex = 0
            // - Trong cùng zIndex → thứ tự khai báo quyết định (sau = trên)
            // - zIndex CAO hơn LUÔN trên zIndex thấp hơn
            // - Hữu ích khi cần dynamic reorder (card decks, drag&drop)
            // - zIndex KHÔNG ảnh hưởng hit testing — view trên vẫn nhận tap trước
            NavigationLink(destination: ZIndexDemo()) {
                MenuRow(detailViewName: "5. zIndex — THAY ĐỔI THỨ TỰ LAYER RUNTIME")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  6. CONDITIONAL LAYERS & TRANSITIONS                     ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: ConditionalLayerDemo()) {
                MenuRow(detailViewName: "6. CONDITIONAL LAYERS & TRANSITIONS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  7. PRODUCTION PATTERNS                                  ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: ZStackExample7View()) {
                MenuRow(detailViewName: "7. PRODUCTION PATTERNS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  8. GEOMETRY & COORDINATE SPACES                         ║
            // ╚══════════════════════════════════════════════════════════╝
            // ZStack kết hợp GeometryReader cho responsive layouts
            // và custom positioning.
            NavigationLink(destination: GeometryZStackDemo()) {
                MenuRow(detailViewName: "8. GEOMETRY & COORDINATE SPACES")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  9. ANIMATION PATTERNS VỚI ZStack                        ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: ZStackExample9View()) {
                MenuRow(detailViewName: "9. ANIMATION PATTERNS VỚI ZStack")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  10. ignoresSafeArea & FULL-SCREEN PATTERNS              ║
            // ╚══════════════════════════════════════════════════════════╝
            // NGUYÊN TẮC ignoresSafeArea TRONG ZStack:
            //
            // Background layer: .ignoresSafeArea()     ← Phủ kín
            // Content layers: KHÔNG ignoresSafeArea    ← Trong safe area
            //
            // Đây là pattern chuẩn cho:
            // - Splash screen
            // - Onboarding
            // - Login / Welcome screen
            // - Image viewers
            NavigationLink(destination: FullScreenZStack()) {
                MenuRow(detailViewName: "10. ignoresSafeArea & FULL-SCREEN PATTERNS")
            }
        }
    }
}

#Preview {
    ZStackExampleView()
}
