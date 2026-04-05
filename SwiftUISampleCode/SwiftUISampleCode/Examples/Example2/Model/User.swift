import Foundation

struct User: Hashable, Identifiable, Decodable {
    var id: Int64
    var login: String
    var avatarUrl: URL // Đổi tên biến chuẩn Swift (camelCase)
    
    // Mapping JSON key
    enum CodingKeys: String, CodingKey {
        case id, login
        case avatarUrl = "avatar_url"
    }
}
