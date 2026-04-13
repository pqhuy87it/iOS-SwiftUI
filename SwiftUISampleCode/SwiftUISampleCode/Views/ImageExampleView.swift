//
//  ImageExampleView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ImageExampleView: View {
    var body: some View {
        List {
            // ╔══════════════════════════════════════════════════════════╗
            // ║  1. CÁC CÁCH KHỞI TẠO IMAGE                              ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: ImageInitializersDemo()) {
                MenuRow(detailViewName: "1. CÁC CÁCH KHỞI TẠO IMAGE")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  2. SF SYMBOLS — HỆ THỐNG ICON CỦA APPLE                 ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: SFSymbolsDemo()) {
                MenuRow(detailViewName: "2. SF SYMBOLS — HỆ THỐNG ICON CỦA APPLE")
            }
            
            // === Symbol Effect on trigger ===
            SymbolEffectTriggerDemo()
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  3. RESIZING & SIZING — ĐIỀU KHIỂN KÍCH THƯỚC            ║
            // ╚══════════════════════════════════════════════════════════╝
            // ⚠️ ĐIỂM QUAN TRỌNG NHẤT VỀ IMAGE SIZING:
            // Image mặc định hiển thị ở KÍCH THƯỚC GỐC (intrinsic size).
            // KHÔNG tự co dãn theo container.
            // Phải dùng .resizable() trước khi .frame() mới có hiệu lực.
            // THỨ TỰ MODIFIERS QUAN TRỌNG:
            //
            // Image("photo")
            //     .resizable()               // 1️⃣ BẮT BUỘC trước mọi sizing
            //     .aspectRatio(contentMode:) // 2️⃣ Giữ tỉ lệ
            //     .frame(width:height:)      // 3️⃣ Đặt kích thước
            //     .clipped()                 // 4️⃣ Cắt phần thừa (nếu .fill)
            //     .clipShape(...)            // 5️⃣ Cắt theo hình dạng
            NavigationLink(destination: ImageSizingDemo()) {
                MenuRow(detailViewName: "3. RESIZING & SIZING — ĐIỀU KHIỂN KÍCH THƯỚC")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  4. CLIPPING & SHAPES                                    ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: ImageClippingDemo()) {
                MenuRow(detailViewName: "4. CLIPPING & SHAPES")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  5. RENDERING MODE & COLOR EFFECTS                       ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: RenderingModeDemo()) {
                MenuRow(detailViewName: "5. RENDERING MODE & COLOR EFFECTS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  6. ASYNCIMAGE — LOAD ẢNH TỪ URL (iOS 15+)               ║
            // ╚══════════════════════════════════════════════════════════╝
            // ⚠️ GIỚI HẠN CỦA ASYNCIMAGE:
            //
            // 1. KHÔNG CÓ CACHE built-in — mỗi lần view appear → load lại
            //    → Production: dùng Kingfisher, SDWebImage, Nuke
            //
            // 2. KHÔNG cancel tự động khi scroll nhanh (trong LazyVStack)
            //    → Có thể gây nhiều requests cùng lúc
            //
            // 3. Không hỗ trợ progressive JPEG, animated GIF
            //
            // 4. Không custom URLSession (headers, auth tokens)
            //    → Cần wrapper custom nếu cần authentication
            NavigationLink(destination: AsyncImageDemo()) {
                MenuRow(detailViewName: "6. ASYNCIMAGE — LOAD ẢNH TỪ URL (iOS 15+)")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  7. REUSABLE ASYNC IMAGE COMPONENT (PRODUCTION)          ║
            // ╚══════════════════════════════════════════════════════════╝
            // Wrapper giải quyết các hạn chế của AsyncImage
            
            NavigationLink(destination: ImageExample7View()) {
                MenuRow(detailViewName: "7. REUSABLE ASYNC IMAGE COMPONENT (PRODUCTION)")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  8. IMAGE INTERPOLATION & ANTIALIASING                   ║
            // ╚══════════════════════════════════════════════════════════╝
            // KHI NÀO DÙNG interpolation:
            // .none    → Pixel art, retro games, QR codes
            // .low     → Thumbnails, performance-critical
            // .medium  → Mặc định, đa phần trường hợp
            // .high    → Ảnh hero, zoom, cần chất lượng cao
            NavigationLink(destination: InterpolationDemo()) {
                MenuRow(detailViewName: "8. IMAGE INTERPOLATION & ANTIALIASING")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  9. IMAGE TRONG CÁC CONTEXT KHÁC NHAU                    ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: ImageExample9View()) {
                MenuRow(detailViewName: "9. IMAGE TRONG CÁC CONTEXT KHÁC NHAU")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  10. PRODUCTION PATTERNS                                 ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: ImageExample10View()) {
                MenuRow(detailViewName: "10. PRODUCTION PATTERNS")
            }
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  11. ACCESSIBILITY                                       ║
            // ╚══════════════════════════════════════════════════════════╝
            NavigationLink(destination: AccessibleImageDemo()) {
                MenuRow(detailViewName: "11. ACCESSIBILITY")
            }
        }
    }
}

#Preview {
    ImageExampleView()
}
