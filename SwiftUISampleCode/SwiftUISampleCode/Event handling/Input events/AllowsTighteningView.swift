import SwiftUI

struct AllowsTighteningView: View {
    // Một đoạn text khá dài để ép SwiftUI phải xử lý khi bị giới hạn chiều rộng
    let longText = "Đây là một đoạn văn bản khá dài cần hiển thị trọn vẹn."
    
    var body: some View {
        VStack(spacing: 50) {
            
            // --- TRƯỜNG HỢP 1: MẶC ĐỊNH ---
            VStack(alignment: .leading, spacing: 8) {
                Text("1. Mặc định (Bị cắt xén)")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Text(longText)
                    .lineLimit(1) // Ép hiển thị trên 1 dòng
                    .frame(width: 250, alignment: .leading) // Khung cố định 250pt
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .border(Color.red, width: 1)
                
                Text("Chữ bị cắt và hiện dấu '...' ở cuối.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // --- TRƯỜNG HỢP 2: DÙNG ALLOWS TIGHTENING ---
            VStack(alignment: .leading, spacing: 8) {
                Text("2. Có allowsTightening(true)")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text(longText)
                    .lineLimit(1)
                    // BẬT TÍNH NĂNG ÉP KHOẢNG CÁCH CHỮ
                    .allowsTightening(true)
                    .frame(width: 250, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .border(Color.blue, width: 1)
                
                Text("Khoảng cách giữa các ký tự bị ép sát lại để cố gắng hiển thị đủ câu.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // --- TRƯỜNG HỢP 3: COMBO HOÀN HẢO ---
            VStack(alignment: .leading, spacing: 8) {
                Text("3. Tightening + Scale Factor")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Text(longText)
                    .lineLimit(1)
                    .allowsTightening(true)
                    // Cho phép font chữ nhỏ đi một chút (tối đa bằng 90% font gốc) nếu ép chữ vẫn không vừa
                    .minimumScaleFactor(0.9)
                    .frame(width: 250, alignment: .leading)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .border(Color.green, width: 1)
                
                Text("Giải pháp tốt nhất: Vừa ép chữ, vừa cho phép giảm nhẹ size chữ.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    AllowsTighteningView()
}
