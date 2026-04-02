import SwiftUI

struct UnifiedAnimationView: View {
    @State private var position = CGPoint(x: 150, y: 150)
    @State private var boxColor = Color.blue
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 30) {
            
            Text("Unified Animations (iOS 18+)")
                .font(.headline)
            
            // Khu vực chứa vật thể di chuyển
            GeometryReader { proxy in
                ZStack {
                    Color.gray.opacity(0.1).cornerRadius(15)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(boxColor)
                        .frame(width: 80, height: 80)
                        .position(position)
                        .shadow(radius: 10)
                }
            }
            .frame(height: 350)
            .padding()
            
            // MARK: - 1. Nút Test Completion Handler
            Button(action: {
                // Đưa về màu mặc định trước khi chạy
                boxColor = .blue
                
                // Cú pháp withAnimation mới có hỗ trợ completion
                withAnimation(.smooth(duration: 1.0)) {
                    position = CGPoint(x: 300, y: 150) // Bay sang phải
                } completion: {
                    // Code ở đây chỉ chạy khi hộp đã bay TỚI NƠI
                    boxColor = .green
                }
            }) {
                Text("1. Bay xong thì đổi màu (Completion)")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // MARK: - 2. Nút Test Retargeting (Bẻ lái giữa chừng)
            Button(action: {
                Task {
                    boxColor = .orange
                    // Lệnh 1: Bắt đầu bay từ từ xuống góc dưới
                    withAnimation(.spring(duration: 2.0)) {
                        position = CGPoint(x: 150, y: 300)
                    }
                    
                    // Đợi nửa giây (lúc này hộp đang bay lơ lửng giữa đường)
                    try await Task.sleep(for: .seconds(0.5))
                    
                    // Lệnh 2: Bất ngờ bẻ lái sang vị trí khác!
                    // LƯU Ý: Hộp sẽ không bị khựng lại mà dùng luôn quán tính đang có để vòng sang điểm mới rất mượt.
                    withAnimation(.spring(duration: 1.5)) {
                        position = CGPoint(x: 50, y: 50)
                        boxColor = .purple
                    }
                }
            }) {
                Text("2. Bẻ lái giữa không trung (Retargeting)")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Nút Reset
            Button("Đặt lại vị trí ban đầu") {
                withAnimation(.snappy) {
                    position = CGPoint(x: 150, y: 150)
                    boxColor = .blue
                }
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding(.top)
    }
}

#Preview {
    UnifiedAnimationView()
}
