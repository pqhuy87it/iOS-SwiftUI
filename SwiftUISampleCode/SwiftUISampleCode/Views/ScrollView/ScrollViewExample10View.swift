//
//  ScrollViewExample10View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ScrollViewExample10View: View {
    var body: some View {
//        Group {
//            ScrollGeometryDemo()
            
            TrackableScrollViewDemo()
//        }
    }
}

struct ScrollGeometryDemo: View {
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolling = false
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<50) { i in
                        Text("Row \(i)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.gray.opacity(0.05), in: .rect(cornerRadius: 8))
                    }
                }
                .padding()
            }
            // iOS 18+: Track scroll geometry changes
            // .onScrollGeometryChange(for: CGFloat.self) { geo in
            //     geo.contentOffset.y
            // } action: { oldValue, newValue in
            //     scrollOffset = newValue
            //     isScrolling = true
            // }
            
            // iOS 17 alternative: dùng GeometryReader trong background
            // hoặc PreferenceKey approach (xem bên dưới)
            
            // Floating header fade
            if scrollOffset > 50 {
                Text("Scrolled: \(Int(scrollOffset))pt")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: .capsule)
                    .transition(.opacity)
            }
        }
    }
}

// === iOS 14-16: Track scroll offset via PreferenceKey ===

// MARK: - 2. Ứng dụng thực tế (Dynamic Header)
struct TrackableScrollViewDemo: View {
    // Biến lưu trữ tọa độ cuộn lấy từ TrackableScrollView
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // --- LỚP DƯỚI: NỘI DUNG CUỘN ---
            TrackableScrollView(offset: $scrollOffset) {
                VStack(spacing: 16) {
                    // Spacer ảo để đẩy nội dung xuống dưới Header ban đầu
                    Color.clear.frame(height: 100)
                    
                    // Hình ảnh minh họa
                    Image(systemName: "apple.logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.bottom, 20)
                    
                    Text("Kéo xuống để xem hiệu ứng Header!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Nội dung danh sách
                    ForEach(1...30, id: \.self) { index in
                        HStack {
                            Text("Dữ liệu hàng số \(index)")
                                .font(.body)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            
            // --- LỚP TRÊN CÙNG: DYNAMIC HEADER ---
            VStack {
                HStack {
                    Text("Offset: \(Int(scrollOffset))")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "gearshape.fill")
                }
                // Thay đổi màu chữ dựa trên offset (nếu cuộn qua 50 point thì đổi thành màu trắng)
                .foregroundColor(scrollOffset > 50 ? .white : .primary)
                .padding(.horizontal)
                .padding(.top, 50) // Tránh tai thỏ / Dynamic Island
                .padding(.bottom, 15)
            }
            .frame(maxWidth: .infinity)
            // Tính toán độ mờ (opacity) của nền dựa trên tọa độ cuộn
            // min(max(..., 0), 1) đảm bảo giá trị opacity luôn nằm trong khoảng 0.0 đến 1.0
            .background(
                Color.blue
                    .opacity(min(max(Double(scrollOffset) / 80.0, 0), 1))
                    .ignoresSafeArea() // Phủ màu lên tận sát viền trên của máy
            )
            // Thêm hiệu ứng bóng mờ khi header hiện ra hoàn toàn
            .shadow(color: .black.opacity(scrollOffset > 80 ? 0.2 : 0), radius: 5, y: 5)
            .animation(.easeInOut(duration: 0.2), value: scrollOffset > 50)
        }
        .ignoresSafeArea(.all, edges: .top) // Bỏ safe area mặc định để tự quản lý Header
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TrackableScrollView<Content: View>: View {
    @Binding var offset: CGFloat
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                // Invisible tracker
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ScrollOffsetKey.self,
                            value: -geo.frame(in: .named("scroll")).origin.y
                        )
                }
                .frame(height: 0)
                
                // Actual content
                content()
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            offset = value
        }
    }
}
