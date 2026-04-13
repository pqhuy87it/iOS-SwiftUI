//
//  TextFieldExampleView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct TextFieldExampleView: View {
    var body: some View {
        List {
            // ╔══════════════════════════════════════════════════════════╗
            // ║  1. CÁC CÁCH KHỞI TẠO                                    ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: TextFieldInitDemo()) {
                MenuRow(detailViewName: "1. CÁC CÁCH KHỞI TẠO")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  2. TEXFIELDSTYLE — CÁC KIỂU GIAO DIỆN                   ║
            // ╚══════════════════════════════════════════════════════════╝
            // ┌──────────────────────┬────────────────────────────────────┐
            // │ Style                │ Mô tả                              │
            // ├──────────────────────┼────────────────────────────────────┤
            // │ .automatic           │ Platform/context tự chọn           │
            // │ .plain               │ Không decoration, text thuần       │
            // │ .roundedBorder       │ Gray border, rounded corners       │
            // └──────────────────────┴────────────────────────────────────┘
            NavigationLink(destination: TextFieldStyleDemo()) {
                MenuRow(detailViewName: "2. TEXFIELDSTYLE — CÁC KIỂU GIAO DIỆN")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  3. KEYBOARD CONFIGURATION                               ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: KeyboardConfigDemo()) {
                MenuRow(detailViewName: "3. KEYBOARD CONFIGURATION")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  4. @FocusState — QUẢN LÝ FOCUS                          ║
            // ╚══════════════════════════════════════════════════════════╝
            // @FocusState điều khiển field nào đang active (có cursor).
            // Dùng cho: auto-focus, dismiss keyboard, navigate fields.
            NavigationLink(destination: TextFieldExample4View()) {
                MenuRow(detailViewName: "4. @FocusState — QUẢN LÝ FOCUS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  5. .onSubmit & .submitLabel — XỬ LÝ NÚT RETURN          ║
            // ╚══════════════════════════════════════════════════════════╝
            
            NavigationLink(destination: TextFieldExample5View()) {
                MenuRow(detailViewName: "5. .onSubmit & .submitLabel — XỬ LÝ NÚT RETURN")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  6. SECUREFIELD — MẬT KHẨU                               ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: SecureFieldDemo()) {
                MenuRow(detailViewName: "6. SECUREFIELD — MẬT KHẨU")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  7. VALIDATION — KIỂM TRA ĐẦU VÀO                        ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: ValidationDemo()) {
                MenuRow(detailViewName: "7. VALIDATION — KIỂM TRA ĐẦU VÀO")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  8. .onChange — REALTIME TEXT PROCESSING                 ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: TextProcessingDemo()) {
                MenuRow(detailViewName: "8. .onChange — REALTIME TEXT PROCESSING")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  9. CUSTOM TEXTFIELD STYLE — TẠO STYLE RIÊNG             ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: TextFieldExample9View()) {
                MenuRow(detailViewName: "9. CUSTOM TEXTFIELD STYLE — TẠO STYLE RIÊNG")
            }

            // ╔══════════════════════════════════════════════════════════╗
            // ║  10. TEXTEDITOR — MULTI-LINE INPUT                       ║
            // ╚══════════════════════════════════════════════════════════╝
            // ┌────────────────────┬──────────────────┬──────────────────────┐
            // │                    │ TextField axis:  │ TextEditor           │
            // │                    │ .vertical        │                      │
            // ├────────────────────┼──────────────────┼──────────────────────┤
            // │ Multi-line         │ ✅               │ ✅                   │
            // │ Placeholder        │ ✅ Built-in      │ ❌ Phải tự build     │
            // │ Auto-expand        │ ✅ lineLimit     │ ❌ Fixed frame       │
            // │ onSubmit           │ ✅               │ ❌                   │
            // │ Min iOS            │ 16               │ 14                   │
            // │ Format support     │ ✅               │ ❌                   │
            // │ Full text editing  │ Limited          │ ✅ Rich editing      │
            // └────────────────────┴──────────────────┴──────────────────────┘
            NavigationLink(destination: TextEditorDemo()) {
                MenuRow(detailViewName: "10. TEXTEDITOR — MULTI-LINE INPUT")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  11. PRODUCTION PATTERNS                                 ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: TextFieldExample11View()) {
                MenuRow(detailViewName: "11. PRODUCTION PATTERNS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  12. ACCESSIBILITY                                       ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: AccessibleTextFieldDemo()) {
                MenuRow(detailViewName: "12. ACCESSIBILITY")
            }
        }
    }
}

#Preview {
    TextFieldExampleView()
}
