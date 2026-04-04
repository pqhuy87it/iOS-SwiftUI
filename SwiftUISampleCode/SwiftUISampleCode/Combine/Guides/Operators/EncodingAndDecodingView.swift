import Combine
import SwiftUI

struct EncodingAndDecodingView: View {
    var body: some View {
        VStack {
            List {
                // 1. NavigationLink cho encode
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Encode",
                        description: ".encode(encoder: JSONEncoder())",
                        comparingPublisher: self.encodePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Encode").font(.headline)
                        Text("Biến đổi Model (Struct/Class) thành cục Data (JSON)").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. NavigationLink cho decode
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Decode",
                        description: ".decode(type: User.self, decoder: JSONDecoder())",
                        comparingPublisher: self.decodePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Decode").font(.headline)
                        Text("Phân tích cục Data (JSON) thành Model. Ném lỗi nếu sai định dạng.").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Encoding and decoding")
    }
    
    // MARK: - Model hỗ trợ cho Encode/Decode
    // Chú ý: Bắt buộc phải tuân thủ protocol Codable
    struct User: Codable {
        let id: Int
        let name: String
    }
    
    // MARK: - 1. Hàm Encode
    func encodePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // 1. Biến các số "1", "2" thành các đối tượng Model thực thụ
            .map { value -> User in
                let id = Int(value) ?? 0
                return User(id: id, name: "Người dùng \(id)")
            }
        // 2. Ép kiểu Model thành Data thông qua JSONEncoder
        // Toán tử này có thể ném lỗi (EncodingError) nên kiểu trả về sẽ bị biến thành Error
            .encode(encoder: JSONEncoder())
        
        // 3. (Chỉ dành cho UI) Biến cục Data thành String dạng JSON để bạn nhìn thấy được trên màn hình
            .compactMap { data in
                String(data: data, encoding: .utf8)
            }
        // Bắt lỗi nếu quá trình mã hóa thất bại
            .catch { _ in Just("Lỗi Encode") }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm Decode
    func decodePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // 1. Giả lập việc nhận Data từ mạng (API)
            .map { value -> Data in
                // Cố tình gài bẫy: Khi đến số 3, ta trả về một chuỗi JSON BỊ LỖI (thiếu ngoặc kép ở chữ name)
                if value == "3" {
                    let badJSON = "{ \"id\": 3, \"name\": Lỗi định dạng }"
                    return badJSON.data(using: .utf8)!
                }
                
                // Các số khác: Trả về JSON chuẩn
                let goodJSON = "{ \"id\": \(value), \"name\": \"Người dùng \(value)\" }"
                return goodJSON.data(using: .utf8)!
            }
        
        // 2. Giải mã (Decode) cục Data thành Model User
        // Nếu JSON bị lỗi hoặc thiếu trường dữ liệu, nó sẽ NÉM LỖI (DecodingError) và ngắt luồng ngay lập tức.
            .decode(type: User.self, decoder: JSONDecoder())
        
        // 3. Lấy tên User ra để hiển thị lên UI
            .map { user in
                user.name
            }
        // Hứng lỗi (do số 3 gây ra)
            .catch { _ in Just("Lỗi Decode JSON!") }
            .eraseToAnyPublisher()
    }
}

#Preview {
    EncodingAndDecodingView()
}
