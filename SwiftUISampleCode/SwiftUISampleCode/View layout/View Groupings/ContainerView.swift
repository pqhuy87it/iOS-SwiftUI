import SwiftUI

// MARK: - 1. Định nghĩa ContainerValues cho Custom Container
extension ContainerValues {
    // Lưu trữ hướng cuộn của Section (Dọc hoặc Ngang)
    @Entry var sectionAxis: Axis = .vertical
    
    // Lưu trữ số lượng item tối đa hiển thị ban đầu (0 nghĩa là không giới hạn)
    @Entry var sectionItemsLimit: Int = 0
}

extension View {
    // Modifier để người dùng dễ dàng setup hướng cho Section
    func sectionAxis(_ axis: Axis) -> some View {
        containerValue(\.sectionAxis, axis)
    }
    
    // Modifier để set giới hạn số item
    func sectionItemsLimit(_ limit: Int) -> some View {
        containerValue(\.sectionItemsLimit, limit)
    }
}

// MARK: - 2. Xây dựng Custom Container: FeedContainer
struct FeedContainer<Content: View>: View {
    @ViewBuilder var content: Content
    
    // Lưu trữ ID của các Section đang được mở rộng (Expanded)
    @State private var expandedSections = Set<AnyHashable>()
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 20) {
                // API Mới iOS 18: Tách Section từ ViewBuilder
                Group(sections: content) { sections in
                    ForEach(sections) { section in
                        
                        let itemsLimit = section.containerValues.sectionItemsLimit
                        let isExpanded = expandedSections.contains(section.id)
                        
                        // --- VẼ HEADER ---
                        if !section.header.isEmpty {
                            HStack(alignment: .center) {
                                section.header
                                    .font(.title2)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Nếu có giới hạn item và số lượng vượt quá giới hạn -> Hiện nút Mở rộng/Thu gọn
                                if itemsLimit > 0 && section.content.count > itemsLimit {
                                    Button(action: {
                                        withAnimation {
                                            if isExpanded {
                                                expandedSections.remove(section.id)
                                            } else {
                                                expandedSections.insert(section.id)
                                            }
                                        }
                                    }) {
                                        Image(systemName: isExpanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                                            .foregroundColor(.blue)
                                            .imageScale(.large)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // --- VẼ CONTENT (Có giới hạn bằng prefix) ---
                        // Tính toán lấy bao nhiêu view dựa trên việc có bị giới hạn và đang collapse hay không
                        let limitCount = (!isExpanded && itemsLimit > 0) ? itemsLimit : section.content.count
                        let subviews = section.content.prefix(limitCount)
                        
                        // Kiểm tra ContainerValue để render Dọc hoặc Ngang
                        switch section.containerValues.sectionAxis {
                        case .vertical:
                            LazyVStack(spacing: 10) {
                                subviews
                            }
                            .padding(.horizontal)
                            
                        case .horizontal:
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 10) {
                                    subviews
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // --- VẼ FOOTER ---
                        if !section.footer.isEmpty {
                            section.footer
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - 3. Màn hình sử dụng thực tế (Xem kết quả tại Preview)
struct ContainerView: View {
    var body: some View {
        FeedContainer {
            
            // Section 1: Cuộn dọc, có giới hạn 2 phần tử
            Section {
                ForEach(1...5, id: \.self) { item in
                    Text("Bài viết số \(item)")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
            } header: {
                Text("Tin nổi bật (Vertical)")
            } footer: {
                Text("Đây là footer của tin nổi bật.")
                    .font(.caption)
            }
            .sectionItemsLimit(2) // Giới hạn hiển thị 2 bài, tự động hiện nút Expand
            
            // Section 2: Cuộn ngang, không giới hạn
            Section {
                ForEach(1...6, id: \.self) { item in
                    VStack {
                        Circle()
                            .fill(Color.orange.opacity(0.5))
                            .frame(width: 80, height: 80)
                        Text("User \(item)")
                            .font(.subheadline)
                    }
                }
            } header: {
                Text("Gợi ý kết bạn (Horizontal)")
            }
            .sectionAxis(.horizontal) // Chuyển layout sang ngang
            
            // Section 3: Cuộn dọc, không giới hạn
            Section {
                ForEach(1...3, id: \.self) { item in
                    Text("Sự kiện \(item)")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                }
            } header: {
                Text("Sự kiện sắp tới")
            }
        }
        .navigationTitle("Trang chủ")
    }
}

#Preview {
    ContentView()
}
