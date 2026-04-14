//
//  ListExampleView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ListExampleView: View {
    var body: some View {
        List {
            // ╔══════════════════════════════════════════════════════════╗
            // ║  1. CÁC CÁCH KHỞI TẠO LIST                               ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: ListExmaple1View()) {
                MenuRow(detailViewName: "1. CÁC CÁCH KHỞI TẠO LIST")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  2. SECTIONS — NHÓM ROWS                                 ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: SectionDemo()) {
                MenuRow(detailViewName: "2. SECTIONS — NHÓM ROWS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  3. LIST STYLES — CÁC KIỂU GIAO DIỆN                     ║
            // ╚══════════════════════════════════════════════════════════╝
            // ┌──────────────────────┬──────────┬──────────────────────────────┐
            // │ Style                │ Min iOS  │ Mô tả                        │
            // ├──────────────────────┼──────────┼──────────────────────────────┤
            // │ .automatic           │ 13       │ Platform tự chọn (default)   │
            // │ .insetGrouped        │ 14       │ Rounded cards, spaced groups │
            // │                      │          │ → Giống Settings app         │
            // │ .grouped             │ 13       │ Full-width groups, gray bg   │
            // │ .inset               │ 14       │ Single group, inset margins  │
            // │ .plain               │ 13       │ Không background, sát lề     │
            // │                      │          │ → Giống Messages, Contacts   │
            // │ .sidebar             │ 14       │ iPadOS/macOS sidebar style   │
            // └──────────────────────┴──────────┴──────────────────────────────┘
            //
            // 📌 NGUYÊN TẮC CHỌN:
            // Settings / Form-like       → .insetGrouped
            // Feed / Chat / Messages     → .plain
            // Master list / File browser → .sidebar (iPad)
            // Simple data list           → .inset hoặc .plain
            
            NavigationLink(destination: ListStyleDemo()) {
                MenuRow(detailViewName: "3. LIST STYLES — CÁC KIỂU GIAO DIỆN")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  4. ROW STYLING — TUỲ CHỈNH TỪNG ROW                     ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: ListExmaple4View()) {
                MenuRow(detailViewName: "4. ROW STYLING — TUỲ CHỈNH TỪNG ROW")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  5. SWIPE ACTIONS                                        ║
            // ╚══════════════════════════════════════════════════════════╝
            // SWIPE ACTIONS RULES:
            // - allowsFullSwipe: true → swipe hết → trigger nút ĐẦU TIÊN
            // - Nút ĐẦU TIÊN trong .swipeActions = nút GẦN RÌA nhất
            // - role: .destructive → background đỏ, animation remove
            // - .tint() đổi background color cho từng button
            // - Trailing: phải→trái (phổ biến: delete, archive)
            // - Leading: trái→phải (phổ biến: pin, unread, flag)
            
            NavigationLink(destination: SwipeActionsDemo()) {
                MenuRow(detailViewName: "5. SWIPE ACTIONS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  6. SELECTION — CHỌN ROWS                                ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: SelectionDemo()) {
                MenuRow(detailViewName: "6. SELECTION — CHỌN ROWS")
            }            
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  7. EDIT MODE — DELETE, MOVE, REORDER                    ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: ListExmaple7View()) {
                MenuRow(detailViewName: "7. EDIT MODE — DELETE, MOVE, REORDER")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  8. PULL-TO-REFRESH & SEARCHABLE                         ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: RefreshSearchDemo()) {
                MenuRow(detailViewName: "8. PULL-TO-REFRESH & SEARCHABLE")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  9. LIST + NAVIGATION                                    ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: ListExample9View()) {
                MenuRow(detailViewName: "9. LIST + NAVIGATION")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  10. LIST BACKGROUND & APPEARANCE CUSTOMIZATION          ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: ListExample10View()) {
                MenuRow(detailViewName: "10. LIST BACKGROUND & APPEARANCE CUSTOMIZATION")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  11. EMPTY STATE & CONTENT UNAVAILABLE                   ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: EmptyStateListDemo()) {
                MenuRow(detailViewName: "11. EMPTY STATE & CONTENT UNAVAILABLE")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  12. SCROLL POSITION & PROGRAMMATIC SCROLLING            ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: ListExample12View()) {
                MenuRow(detailViewName: "12. SCROLL POSITION & PROGRAMMATIC SCROLLING")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  13. PAGINATION / INFINITE SCROLL VỚI LIST               ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: ListExample13View()) {
                MenuRow(detailViewName: "13. PAGINATION / INFINITE SCROLL VỚI LIST")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  14. PRODUCTION PATTERNS                                 ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: ListExample14View()) {
                MenuRow(detailViewName: "14. PRODUCTION PATTERNS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  15. LIST vs LazyVStack vs FORM — KHI NÀO DÙNG?          ║
            // ╚══════════════════════════════════════════════════════════╝
            // ┌─────────────────┬───────────────────────────────────────────┐
            // │ Component       │ Dùng khi                                  │
            // ├─────────────────┼───────────────────────────────────────────┤
            // │ List            │ Data lists cần: cell reuse, swipe,        │
            // │                 │ selection, edit mode, separators, search  │
            // │                 │ → Settings, Contacts, Messages, Feeds     │
            // ├─────────────────┼───────────────────────────────────────────┤
            // │ Form            │ Input forms: toggles, pickers, text fields│
            // │                 │ Giống List nhưng optimize cho form input  │
            // │                 │ → Settings form, Registration, Filters    │
            // ├─────────────────┼───────────────────────────────────────────┤
            // │ ScrollView +    │ Custom UI: cards, mixed content, no       │
            // │ LazyVStack      │ reuse cần, full layout control            │
            // │                 │ → Social feeds, Discovery, Dashboards     │
            // ├─────────────────┼───────────────────────────────────────────┤
            // │ ScrollView +    │ Rất ít items (< 30), cần exact sizing     │
            // │ VStack          │ → About screen, static content            │
            // └─────────────────┴───────────────────────────────────────────┘
        }
    }
}

#Preview {
    ListExampleView()
}
