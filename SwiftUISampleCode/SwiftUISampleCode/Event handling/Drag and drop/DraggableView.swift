
import SwiftUI

struct DraggableView: View {
    let fruits = ["🍎 Táo", "🍌 Chuối", "🍉 Dưa hấu"]
    
    // Biến để lưu trữ kết quả khi thả thành công
    @State private var droppedItem: String = "Kéo trái cây và thả vào đây"
    @State private var isTargeted = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                
                // MARK: - 1. Kéo thả cơ bản (Mặc định)
                VStack(alignment: .leading, spacing: 15) {
                    Text("1. Kéo thả cơ bản")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("Bản xem trước (preview) sẽ giống hệt như View gốc.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 20) {
                        ForEach(fruits, id: \.self) { fruit in
                            Text(fruit)
                                .font(.title2)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                                // 👉 MODIFIER QUAN TRỌNG: Biến View này thành nguồn kéo
                                // 'fruit' (String) là dữ liệu sẽ được gửi đi
                                .draggable(fruit)
                        }
                    }
                }
                
                Divider()
                
                // MARK: - 2. Kéo thả với Custom Preview (Tuỳ chỉnh)
                VStack(alignment: .leading, spacing: 15) {
                    Text("2. Kéo thả với Custom Preview")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("Khi kéo, bạn sẽ thấy một giao diện khác hiện lên.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 20) {
                        ForEach(fruits, id: \.self) { fruit in
                            Text(fruit)
                                .font(.title2)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(10)
                                // 👉 MODIFIER QUAN TRỌNG: Custom Preview
                                .draggable(fruit) {
                                    // Giao diện này CHỈ hiện ra khi bạn đang nhấc View này lên và kéo đi
                                    HStack {
                                        Image(systemName: "hand.draw.fill")
                                        Text("Đang di chuyển \(fruit)")
                                    }
                                    .font(.headline)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 10, y: 5)
                                }
                        }
                    }
                }
                
                Spacer()
                
                // MARK: - KHU VỰC ĐÍCH (Để bạn test thử việc thả)
                RoundedRectangle(cornerRadius: 15)
                    .fill(isTargeted ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isTargeted ? Color.green : Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                    )
                    .overlay(
                        Text(droppedItem)
                            .font(.headline)
                            .foregroundColor(isTargeted ? .green : .primary)
                    )
                    .frame(height: 150)
                    // Nhận dữ liệu là String
                    .dropDestination(for: String.self) { items, location in
                        if let firstItem = items.first {
                            droppedItem = "Đã nhận: \(firstItem) 🎉"
                            return true
                        }
                        return false
                    } isTargeted: { targeted in
                        withAnimation {
                            isTargeted = targeted
                        }
                    }
            }
            .padding()
            .navigationTitle("Drag Source")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
#Preview {
    DraggableView()
}
