import SwiftUI

struct ScrollViewExample: View {
    var body: some View {
        // 1. ScrollView chính (Cuộn dọc mặc định)
        // Lọc toàn bộ màn hình để có thể cuộn lên xuống
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // --- PHẦN 1: SCROLLVIEW CUỘN NGANG ---
                Text("Nổi bật (Cuộn Ngang)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // Khai báo .horizontal để cuộn ngang
                // showsIndicators: false để ẩn thanh cuộn màu xám đi cho đẹp
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 15) {
                        // Tạo ra 10 thẻ (Card)
                        ForEach(1...10, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue.gradient)
                                .frame(width: 250, height: 150)
                                .overlay(
                                    Text("Thẻ \(index)")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                )
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                        }
                    }
                    // Padding 2 bên để item đầu/cuối không bị sát viền màn hình
                    .padding(.horizontal)
                }
                
                Divider().padding(.vertical, 10)
                
                // --- PHẦN 2: NỘI DUNG CUỘN DỌC TỰ NHIÊN ---
                Text("Danh Sách (Cuộn Dọc)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Sử dụng LazyVStack bên trong ScrollView để tối ưu hiệu năng
                // (Chỉ load các hàng khi chúng chuẩn bị xuất hiện trên màn hình)
                LazyVStack(spacing: 15) {
                    // Tạo ra 20 hàng dữ liệu
                    ForEach(1...20, id: \.self) { index in
                        HStack(spacing: 15) {
                            Circle()
                                .fill(Color.green.opacity(0.8))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text("\(index)")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Dòng dữ liệu số \(index)")
                                    .font(.headline)
                                Text("Nội dung mô tả chi tiết nằm ở đây...")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 30) // Chừa một ít khoảng trống ở đáy
        }
        .navigationTitle("Trang Chủ")
    }
}

// MARK: - Preview
#Preview {
    ScrollViewExample()
}
