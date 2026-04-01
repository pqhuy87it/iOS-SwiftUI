
import SwiftUI

// MARK: - Màn hình chính
struct ComposingGesturesView: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("Nhấn giữ hình tròn 0.5 giây\nCho đến khi hiện viền trắng rồi mới kéo")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            DraggableCircle()
        }
    }
}

// MARK: - Component Hình tròn có thể kéo thả
struct DraggableCircle: View {
    
    // 1. Dùng Enum để định nghĩa các trạng thái phức tạp của thao tác chuỗi
    enum DragState {
        case inactive // Đang đứng im
        case pressing // Đang được nhấn giữ (Long Press)
        case dragging(translation: CGSize) // Đã giữ đủ lâu và đang bị kéo đi (Drag)
        
        // Tính toán khoảng cách di chuyển
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        // Kiểm tra xem có đang tương tác không (Bao gồm cả nhấn giữ hoặc kéo)
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }
        
        // Kiểm tra xem có đang thực sự kéo không
        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
    }

    // 2. Biến theo dõi trạng thái
    @GestureState private var dragState = DragState.inactive
    @State private var viewState = CGSize.zero

    var body: some View {
        let minimumLongPressDuration = 0.5
        
        // 3. TẠO CHUỖI GESTURE: LongPress nối tiếp bởi Drag
        let longPressDrag = LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture())
            .updating($dragState) { value, state, transaction in
                switch value {
                // Giai đoạn 1: Bắt đầu nhấn giữ (Long press begins)
                case .first(true):
                    state = .pressing
                // Giai đoạn 2: Giữ đủ lâu, bắt đầu kéo đi (Long press confirmed, dragging begins)
                case .second(true, let drag):
                    state = .dragging(translation: drag?.translation ?? .zero)
                // Giai đoạn 3: Người dùng thả tay hoặc thao tác bị hủy
                default:
                    state = .inactive
                }
            }
            .onEnded { value in
                // Khi toàn bộ chuỗi thao tác kết thúc, lưu lại tọa độ mới
                guard case .second(true, let drag?) = value else { return }
                self.viewState.width += drag.translation.width
                self.viewState.height += drag.translation.height
            }

        // 4. Vẽ giao diện
        return Circle()
            .fill(Color.blue)
            // Hiện viền trắng để báo hiệu người dùng có thể bắt đầu kéo
            .overlay(dragState.isDragging ? Circle().stroke(Color.white, lineWidth: 3) : nil)
            .frame(width: 100, height: 100, alignment: .center)
            // Di chuyển hình tròn dựa trên tọa độ tĩnh (viewState) + tọa độ đang kéo (translation)
            .offset(
                x: viewState.width + dragState.translation.width,
                y: viewState.height + dragState.translation.height
            )
            // Đổ bóng khi ngón tay vừa chạm vào (isActive = true)
            .shadow(color: .black.opacity(0.3), radius: dragState.isActive ? 10 : 0)
            // Thêm animation mượt mà cho hiệu ứng nổi lên khi nhấn giữ
            .animation(.linear(duration: minimumLongPressDuration), value: dragState.isActive)
            // Gắn chuỗi Gesture vào View
            .gesture(longPressDrag)
    }
}

// MARK: - Preview
#Preview {
    ComposingGesturesView()
}
