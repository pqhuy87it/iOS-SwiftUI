import SwiftUI

struct TunnelView: View {
    
    @Binding var streamValues: [String]
    
    let verticalPadding: CGFloat = 5
     
    let tunnelColor: Color = Color(red: 242/255.0, green: 242/255.0, blue: 242/255.0)
    
    var body: some View {
        // 1. Thêm ScrollView với tuỳ chọn cuộn ngang và ẩn thanh cuộn
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: verticalPadding) {
                ForEach(streamValues.reversed(), id: \.self) { value in
                    CircularTextView(text: value)
                }
            }
            .padding(.horizontal, 5)
            // Đảm bảo chiều cao tối thiểu cho nội dung bên trong ScrollView
            .frame(minHeight: 50, alignment: .trailing)
            
        }
        // 2. Thiết lập độ rộng tối đa và căn lề cho ScrollView
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding([.top, .bottom], verticalPadding)
        .background(tunnelColor)
    }
}

struct TunnelView_Previews: PreviewProvider {
    static var previews: some View {
        Section {
            TunnelView(streamValues: .constant(["1"]))
            TunnelView(streamValues: .constant(["1", "2"]))
            // Thêm một test case với nhiều giá trị để xem trước hiệu ứng cuộn
            TunnelView(streamValues: .constant(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]))
        }.previewLayout(.sizeThatFits)
    }
}
