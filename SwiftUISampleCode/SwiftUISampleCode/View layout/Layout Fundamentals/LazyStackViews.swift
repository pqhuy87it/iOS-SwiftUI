import SwiftUI

// MARK: - 1. Model dữ liệu (Mock Data)
struct Contact: Identifiable {
    let id = UUID()
    let name: String
}

struct GroupedContacts {
    let letter: String
    let contacts: [Contact]
}

// MARK: - 2. Màn hình chính
struct LazyStackViews: View {
    // Tạo dữ liệu mẫu dài để có thể cuộn và thấy rõ hiệu ứng ghim
    let addressBook: [GroupedContacts] = [
        GroupedContacts(letter: "A",
                        contacts: [Contact(name: "Anh"),
                                   Contact(name: "An"),
                                   Contact(name: "Ánh"),
                                   Contact(name: "Alice"),
                                   Contact(name: "Alex")]),
        GroupedContacts(letter: "B",
                        contacts: [Contact(name: "Bình"),
                                   Contact(name: "Bảo"),
                                   Contact(name: "Bob"),
                                   Contact(name: "Ben"),
                                   Contact(name: "Bích")]),
        GroupedContacts(letter: "C",
                        contacts: [Contact(name: "Cường"),
                                   Contact(name: "Châu"),
                                   Contact(name: "Charlie"),
                                   Contact(name: "Cindy"),
                                   Contact(name: "Celine")]),
        GroupedContacts(letter: "D",
                        contacts: [Contact(name: "Dũng"),
                                   Contact(name: "Duy"),
                                   Contact(name: "David"),
                                   Contact(name: "Daniel")]),
        GroupedContacts(letter: "E",
                        contacts: [Contact(name: "Elena"),
                                   Contact(name: "Emma"),
                                   Contact(name: "Ethan")])
    ]
    
    var body: some View {
        ScrollView {
            // ĐIỂM QUAN TRỌNG: Sử dụng pinnedViews để ghim Header lên đỉnh khi cuộn
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                
                // Lặp qua từng nhóm (Chữ cái)
                ForEach(addressBook, id: \.letter) { group in
                    
                    // Sử dụng Section để tạo nhóm, gắn HeaderView vào tham số header
                    Section(header: HeaderView(letter: group.letter)) {
                        
                        // Lặp qua từng liên hệ trong nhóm đó
                        ForEach(group.contacts) { contact in
                            ContactRow(name: contact.name)
                        }
                        
                    }
                }
            }
        }
        .navigationTitle("Danh bạ")
    }
}

// MARK: - 3. View hiển thị Tiêu đề Nhóm (Sẽ được ghim khi cuộn)
struct HeaderView: View {
    let letter: String
    
    var body: some View {
        Text(letter)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        // Cần có màu nền đục (không trong suốt) để khi ghim, nó che đi các item cuộn bên dưới
            .background(Color.blue)
    }
}

// MARK: - 4. View hiển thị từng hàng dữ liệu
struct ContactRow: View {
    let name: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Avatar giả lập
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                    )
                
                Text(name)
                    .font(.body)
                    .padding(.leading, 15)
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            
            Divider() // Đường kẻ ngang phân cách
                .padding(.leading, 75)
        }
        // Gắn màu nền mặc định của hệ thống để chữ cuộn qua không bị đè lên nhau
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Preview
#Preview {
    LazyStackViews()
}
