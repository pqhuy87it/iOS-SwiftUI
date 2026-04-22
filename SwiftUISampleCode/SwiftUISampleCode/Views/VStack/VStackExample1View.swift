import SwiftUI

struct VStackExample1View: View {
    var body: some View {
        HStack(spacing: 30) {
            
            // === 1a. Mặc định: alignment .center, spacing hệ thống ===
            VStack {
                Text("Dòng 1")
                Text("Dòng 2 dài hơn")
                Text("Dòng 3")
            }
            .border(.gray)
            // spacing mặc định ≈ 8pt
            // alignment mặc định: .center (căn giữa ngang)
            
            // === 1b. Custom spacing ===
            VStack(spacing: 20) {
                Text("Cách")
                Text("nhau")
                Text("20pt")
            }
            .border(.gray)
            
            // === 1c. Spacing = 0 ===
            VStack(spacing: 0) {
                Text("Sát").padding(8).background(.blue.opacity(0.2))
                Text("nhau").padding(8).background(.green.opacity(0.2))
                Text("hoàn toàn").padding(8).background(.orange.opacity(0.2))
            }
            
            // === 1d. Custom alignment ===
            VStack(alignment: .leading) {
                Text("Leading")
                Text("Căn trái")
                Text("Tất cả")
            }
            .border(.gray)
        }
        .padding()
    }
}

#Preview {
    VStackExample1View()
}
