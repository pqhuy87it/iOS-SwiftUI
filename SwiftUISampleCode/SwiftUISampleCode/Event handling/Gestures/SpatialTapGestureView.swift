
import SwiftUI

struct SpatialTapGestureView: View {
    // Biến lưu trữ tọa độ (x, y) của điểm chạm
    @State private var tapLocation: CGPoint? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Chạm vào khung xám bên dưới")
                .font(.headline)
            
            // Hiển thị tọa độ chạm trên UI
            if let location = tapLocation {
                Text("Tọa độ chạm: x: \(Int(location.x)), y: \(Int(location.y))")
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
            } else {
                Text("Chưa có thao tác chạm nào")
                    .foregroundColor(.gray)
            }
            
            // Vùng canvas để nhận diện thao tác chạm
            ZStack {
                Color.gray.opacity(0.2)
                    .cornerRadius(15)
                
                // Nếu đã chạm, vẽ một vòng tròn tại đúng tọa độ đó
                if let location = tapLocation {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 40, height: 40)
                        // Lệnh .position() sẽ neo trung tâm của vòng tròn vào đúng tọa độ chạm
                        .position(location)
                        .animation(.spring(), value: location)
                }
            }
            .frame(height: 400)
            
            // ----------------------------------------------------
            // ÁP DỤNG SPATIAL TAP GESTURE
            // ----------------------------------------------------
            .gesture(
                // Tham số count: 1 (chạm 1 lần), count: 2 (chạm đúp)
                // Tham số coordinateSpace: .local (tính tọa độ gốc 0,0 từ góc trái trên của ZStack này)
                SpatialTapGesture(count: 1, coordinateSpace: .local)
                    .onEnded { value in
                        // value.location chính là điểm mà người dùng vừa chạm xuống
                        self.tapLocation = value.location
                    }
            )
            .padding(.horizontal)
            
            // Nút để xóa điểm chạm
            Button("Xóa dấu chấm") {
                withAnimation {
                    tapLocation = nil
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(tapLocation == nil)
        }
        .padding(.vertical)
    }
}

// MARK: - Preview
#Preview {
    SpatialTapGestureView()
}
