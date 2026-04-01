
import SwiftUI

struct DragDropInteractionsView: View {
    // Dữ liệu nguồn (Các loại trái cây trên kệ)
    @State private var availableFruits = ["🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓"]
    
    // Dữ liệu đích (Các trái cây đã nằm trong giỏ)
    @State private var basket: [String] = []
    
    // Biến để tạo hiệu ứng "bừng sáng" khi người dùng đang cầm trái cây lơ lửng trên giỏ
    @State private var isTargetedBasket = false
    @State private var isTargetedShelf = false

    var body: some View {
        VStack(spacing: 40) {
            
            // MARK: - 1. KỆ TRÁI CÂY (Nguồn)
            VStack(alignment: .leading) {
                Text("Kệ Trái Cây (Kéo xuống giỏ)")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(availableFruits, id: \.self) { fruit in
                            Text(fruit)
                                .font(.system(size: 50))
                                // BƯỚC 1: Cho phép kéo phần tử này đi
                                // (String mặc định đã tuân thủ Transferable nên có thể kéo được luôn)
                                .draggable(fruit)
                        }
                    }
                    .padding()
                }
                .background(isTargetedShelf ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(15)
                // BƯỚC 2 (Tùy chọn): Cho phép thả ngược từ giỏ lên kệ
                .dropDestination(for: String.self) { items, location in
                    moveItems(items, from: &basket, to: &availableFruits)
                    return true
                } isTargeted: { targeted in
                    withAnimation { isTargetedShelf = targeted }
                }
            }
            
            // MARK: - 2. GIỎ TRÁI CÂY (Đích)
            VStack(alignment: .leading) {
                Text("Giỏ Của Bạn")
                    .font(.headline)
                
                ZStack {
                    // Vẽ cái giỏ
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isTargetedBasket ? Color.green.opacity(0.2) : Color.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(isTargetedBasket ? Color.green : Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
                        )
                    
                    if basket.isEmpty {
                        Text("Hãy kéo trái cây thả vào đây")
                            .foregroundColor(.gray)
                    } else {
                        // Hiển thị các trái cây đã thả vào giỏ
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                                ForEach(basket, id: \.self) { fruit in
                                    Text(fruit)
                                        .font(.system(size: 40))
                                        // Cho phép kéo ra khỏi giỏ
                                        .draggable(fruit)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .frame(height: 250)
                // BƯỚC 3: Đăng ký vùng này làm nơi NHẬN dữ liệu kéo vào
                .dropDestination(for: String.self) { items, location in
                    // items: Mảng các dữ liệu được thả vào (ở đây là String)
                    moveItems(items, from: &availableFruits, to: &basket)
                    return true // Trả về true để báo hệ thống là xử lý thả thành công
                } isTargeted: { targeted in
                    // Cập nhật state để đổi màu giỏ khi đang có vật thể bay lơ lửng bên trên
                    withAnimation { isTargetedBasket = targeted }
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Kéo và Thả")
    }
    
    // MARK: - Hàm hỗ trợ di chuyển item giữa 2 mảng
    private func moveItems(_ items: [String], from source: inout [String], to destination: inout [String]) {
        for item in items {
            // Nếu đích đến chưa có trái cây này thì thêm vào
            if !destination.contains(item) {
                destination.append(item)
                // Đồng thời xóa khỏi mảng nguồn để tạo cảm giác "di chuyển" vật lý
                source.removeAll { $0 == item }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DragDropInteractionsView()
}
