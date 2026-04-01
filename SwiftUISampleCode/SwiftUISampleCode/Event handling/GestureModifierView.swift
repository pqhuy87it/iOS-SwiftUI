import SwiftUI

// MARK: - Màn hình chính gộp các ví dụ
struct GestureModifierView: View {
    var body: some View {
        VStack(spacing: 50) {
            VStack(spacing: 15) {
                Text("1. Tap Gesture Cơ Bản")
                    .font(.headline)
                ShapeTapView()
            }
            
            Divider()
            
            VStack(spacing: 15) {
                Text("2. Long Press Gesture Nâng Cao")
                    .font(.headline)
                CounterView()
            }
        }
        .padding()
    }
}

// MARK: - Ví dụ 1: Nhận diện thao tác chạm (Tap)
struct ShapeTapView: View {
    @State private var color: Color = .blue
    
    var body: some View {
        let tap = TapGesture()
            .onEnded { _ in
                print("View tapped!")
                // Thay vì chỉ in ra console như bài viết, mình đổi màu để bạn dễ quan sát trên UI
                color = color == .blue ? .purple : .blue
            }

        return Circle()
            .fill(color)
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(tap)
            .overlay(Text("Chạm!").foregroundColor(.white).bold())
    }
}

// MARK: - Ví dụ 2: Nhận diện thao tác nhấn giữ (Long Press)
struct CounterView: View {
    // @GestureState chỉ tồn tại TRONG LÚC gesture đang diễn ra.
    // Khi thả tay ra hoặc gesture bị hủy, nó tự động trả về giá trị ban đầu (false).
    @GestureState private var isDetectingLongPress = false
    
    // @State lưu trữ dữ liệu vĩnh viễn (cho đến khi View bị hủy)
    @State private var totalNumberOfTaps = 0
    @State private var doneCounting = false

    var body: some View {
        // Yêu cầu nhấn giữ liên tục ít nhất 1 giây
        let press = LongPressGesture(minimumDuration: 1)
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                // Cập nhật trạng thái tạm thời (Đang giữ tay)
                gestureState = currentState
            }
            .onChanged { _ in
                // Ghi nhận ngay khi người dùng BẮT ĐẦU chạm vào hình tròn
                self.totalNumberOfTaps += 1
            }
            .onEnded { _ in
                // Chỉ được gọi khi người dùng đã GIỮ ĐỦ 1 GIÂY thành công
                self.doneCounting = true
            }

        return VStack(spacing: 20) {
            Text("Số lần thử chạm: \(totalNumberOfTaps)")
                .font(.title2)

            Circle()
                // Màu sắc tương ứng: Đỏ (Hoàn thành) -> Vàng (Đang giữ tay) -> Xanh (Chờ)
                .fill(doneCounting ? Color.red : isDetectingLongPress ? Color.yellow : Color.green)
                .frame(width: 100, height: 100, alignment: .center)
                // Nếu đã đếm xong (doneCounting = true) thì vô hiệu hóa gesture (truyền nil)
                .gesture(doneCounting ? nil : press)
                .overlay(
                    Text(doneCounting ? "Xong!" : "Giữ 1s")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                )
            
            // Nút hỗ trợ reset lại state để bạn test nhiều lần
            if doneCounting {
                Button("Thử lại") {
                    doneCounting = false
                    totalNumberOfTaps = 0
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    GestureModifierView()
}
