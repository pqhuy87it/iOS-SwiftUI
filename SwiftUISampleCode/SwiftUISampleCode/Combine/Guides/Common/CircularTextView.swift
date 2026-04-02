import SwiftUI

struct CircularTextView: View {
    
    @State var text: String
    
    // 1. Tạo một thuộc tính tính toán để xác định màu nền dựa trên text
    var backgroundColor: Color {
        // Cố gắng chuyển đổi chuỗi văn bản thành số nguyên
        guard let intValue = Int(text) else {
            // Nếu text không phải là số (ví dụ: chữ cái), trả về màu xám mặc định
            return .gray
        }
        
        // Danh sách các màu sẽ được lặp lại
        let colors: [Color] = [.red, .orange, .green, .blue, .purple, .pink]
        
        // Sử dụng phép chia lấy dư (%) để đảm bảo luôn chọn được màu hợp lệ
        // ngay cả khi số lớn hơn độ dài của mảng màu
        let colorIndex = abs(intValue) % colors.count
        
        return colors[colorIndex]
    }
    
    var body: some View {
        Text(text)
        .font(.system(size: 14))
        .bold()
        .foregroundColor(Color.white)
        .padding()
        // 2. Thay thế Color.green cứng bằng thuộc tính backgroundColor chúng ta vừa tạo
        .background(backgroundColor)
        .clipShape(Circle())
        .shadow(radius: 1)
    }
}

struct CircularTextView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            CircularTextView(text: "1")
            CircularTextView(text: "2")
            CircularTextView(text: "3")
            CircularTextView(text: "A") // Test case cho chữ cái
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
