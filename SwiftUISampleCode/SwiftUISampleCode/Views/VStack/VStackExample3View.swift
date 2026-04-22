import SwiftUI

struct VStackExample3View: View {
    var body: some View {
        // === 3a. alignmentGuide modifier — Dịch chuyển alignment point ===
        
        VStack(alignment: .leading, spacing: 12) {
            // Dòng này căn bình thường
            Text("Tiêu đề chính")
                .font(.headline)
            
            // Dòng này THỤT VÀO 24pt so với leading edge
            Text("• Mục con thứ nhất")
                .alignmentGuide(.leading) { d in
                    d[.leading] - 24
                    // Trả về giá trị NHỎ HƠN .leading thực tế
                    // → SwiftUI đặt view SANG PHẢI 24pt để "căn leading"
                }
            
            Text("• Mục con thứ hai")
                .alignmentGuide(.leading) { d in
                    d[.leading] - 24
                }
            
            Text("Đoạn kết")
                .font(.headline)
        }
        .padding()
        
        // === 3b. Custom HorizontalAlignment — Form label alignment ===
        
        // Bài toán: căn dấu ":" của label form thẳng hàng
        // Label dài ngắn khác nhau nhưng ":" luôn thẳng cột
        VStack(alignment: .formLabel, spacing: 12) {
            HStack(spacing: 0) {
                Text("Tên")
                    .frame(minWidth: 0, alignment: .trailing)
                Text(" : ")
                    .alignmentGuide(.formLabel) { d in d[HorizontalAlignment.center] }
                Text("Nguyễn Văn Huy")
                    .frame(minWidth: 0, alignment: .leading)
            }
            
            HStack(spacing: 0) {
                Text("Email")
                    .frame(minWidth: 0, alignment: .trailing)
                Text(" : ")
                    .alignmentGuide(.formLabel) { d in d[HorizontalAlignment.center] }
                Text("huy@example.com")
                    .frame(minWidth: 0, alignment: .leading)
            }
            
            HStack(spacing: 0) {
                Text("Số điện thoại")
                    .frame(minWidth: 0, alignment: .trailing)
                Text(" : ")
                    .alignmentGuide(.formLabel) { d in d[HorizontalAlignment.center] }
                Text("0912 345 678")
                    .frame(minWidth: 0, alignment: .leading)
            }
        }
        .padding()
    }
}

#Preview {
    VStackExample3View()
}
