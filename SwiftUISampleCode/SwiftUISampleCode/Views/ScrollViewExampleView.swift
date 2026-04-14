//
//  ScrollViewExampleView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ScrollViewExampleView: View {
    var body: some View {
        List {
            // ╔══════════════════════════════════════════════════════════╗
            // ║  1. CÚ PHÁP & INITIALIZER                                ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: BasicScrollViewDemo()) {
                MenuRow(detailViewName: "1. CÚ PHÁP & INITIALIZER")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  2. SCROLL INDICATORS                                    ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: ScrollIndicatorsDemo()) {
                MenuRow(detailViewName: "2. SCROLL INDICATORS")
            }
                        
            // ╔══════════════════════════════════════════════════════════╗
            // ║  3. ScrollView + VStack vs LazyVStack vs List            ║
            // ╚══════════════════════════════════════════════════════════╝
            // ┌─────────────────────┬────────────┬────────────┬───────────┐
            // │                     │  VStack    │ LazyVStack │  List     │
            // ├─────────────────────┼────────────┼────────────┼───────────┤
            // │ Init children       │ Tất cả     │ Khi cần    │ Khi cần   │
            // │ Cell reuse          │ ❌         │ ❌         │ ✅        │
            // │ Memory (scroll all) │ Cao nhất   │ Tăng dần   │ Ổn định   │
            // │ Custom layout       │ ✅ 100%    │ ✅ 100%    │ Hạn chế   │
            // │ Built-in features   │ ❌         │ pinnedViews│ Swipe/Edit│
            // │ Scroll indicator    │ Chính xác  │ Có thể nhảy│ Chính xác │
            // │ Tốt cho             │ < 50 items │ 50-10K     │ 10K+      │
            // └─────────────────────┴────────────┴────────────┴───────────┘
            NavigationLink(destination: ContentComparisonDemo()) {
                MenuRow(detailViewName: "3. ScrollView + VStack vs LazyVStack vs List")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  4. SCROLLVIEWREADER — PROGRAMMATIC SCROLLING (iOS 14+)  ║
            // ╚══════════════════════════════════════════════════════════╝
            // scrollTo() ANCHOR OPTIONS:
            // .top       → item nằm ở TOP viewport
            // .center    → item nằm GIỮA viewport
            // .bottom    → item nằm ở BOTTOM viewport
            // .leading   → cho horizontal scroll
            // .trailing  → cho horizontal scroll
            // nil        → SwiftUI tự chọn (scroll ít nhất có thể)
            
            NavigationLink(destination: ScrollViewReaderDemo()) {
                MenuRow(detailViewName: "4. SCROLLVIEWREADER — PROGRAMMATIC SCROLLING (iOS 14+)")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  5. .scrollPosition — TRACKING & CONTROL (iOS 17+)       ║
            // ╚══════════════════════════════════════════════════════════╝
            // Thay thế ScrollViewReader với API sạch hơn, 2-way binding.
            
            NavigationLink(destination: ScrollPositionDemo()) {
                MenuRow(detailViewName: "5. .scrollPosition — TRACKING & CONTROL (iOS 17+)")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  6. SCROLL TARGET BEHAVIOR — PAGING & SNAPPING (iOS 17+) ║
            // ╚══════════════════════════════════════════════════════════╝
            // .containerRelativeFrame() (iOS 17+):
            // Size view TƯƠNG ĐỐI với scroll container
            // .containerRelativeFrame(.horizontal)          → full width
            // .containerRelativeFrame(.horizontal, count: 3) → 1/3 width
            // Cực hữu ích cho carousel, paging layouts
            
            NavigationLink(destination: ScrollTargetDemo()) {
                MenuRow(detailViewName: "6. SCROLL TARGET BEHAVIOR — PAGING & SNAPPING (iOS 17+)")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  7. SCROLL TRANSITIONS — HIỆU ỨNG KHI SCROLL (iOS 17+)   ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: ScrollTransitionDemo()) {
                MenuRow(detailViewName: "7. SCROLL TRANSITIONS — HIỆU ỨNG KHI SCROLL (iOS 17+)")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  8. PULL-TO-REFRESH & SEARCHABLE                         ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: RefreshableScrollView()) {
                MenuRow(detailViewName: "8. PULL-TO-REFRESH & SEARCHABLE")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  9. SCROLL CLIP & OVERFLOW                               ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: ScrollClipDemo()) {
                MenuRow(detailViewName: "9. SCROLL CLIP & OVERFLOW")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  10. onScrollGeometryChange & SCROLL EVENTS (iOS 18+)    ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: ScrollViewExample10View()) {
                MenuRow(detailViewName: "10. onScrollGeometryChange & SCROLL EVENTS (iOS 18+)")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  11. PRODUCTION PATTERNS                                 ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: ScrollViewExample11View()) {
                MenuRow(detailViewName: "11. PRODUCTION PATTERNS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  12. KEYBOARD AVOIDANCE & SAFE AREA                      ║
            // ╚══════════════════════════════════════════════════════════╝
            // .safeAreaInset(edge:) (iOS 15+):
            // Thêm view CỐ ĐỊNH ở edge, ScrollView content tự
            // adjust insets để không bị che.
            // Dùng cho: bottom bars, floating inputs, mini players
            
            NavigationLink(destination: KeyboardAvoidanceDemo()) {
                MenuRow(detailViewName: "12. KEYBOARD AVOIDANCE & SAFE AREA")
            }
        }
    }
}

#Preview {
    ScrollViewExampleView()
}
