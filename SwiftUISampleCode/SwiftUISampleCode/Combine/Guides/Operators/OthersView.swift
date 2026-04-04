import Combine
import SwiftUI

struct OthersView: View {
    var body: some View {
        VStack {
            List {
                // 1. print
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Print",
                        description: ".print(\"Debug Log\")",
                        comparingPublisher: self.printPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Print").font(.headline)
                        Text("Ghi lại mọi diễn biến vào Console").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. handleEvents
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "HandleEvents",
                        description: ".handleEvents(receiveOutput: ...)",
                        comparingPublisher: self.handleEventsPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("HandleEvents").font(.headline)
                        Text("Thực hiện hành động phụ tại mỗi bước").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 3. breakpoint
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Breakpoint",
                        description: ".breakpoint(receiveOutput: { $0 == \"3\" })",
                        comparingPublisher: self.breakpointPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Breakpoint").font(.headline)
                        Text("Dừng chương trình để kiểm tra khi gặp điều kiện").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 4. multicast
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Multicast",
                        description: ".multicast(subject: PassthroughSubject())",
                        comparingPublisher: self.multicastPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Multicast").font(.headline)
                        Text("Chia sẻ luồng cho nhiều người nhận").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Others")
    }
    
    // MARK: - 1. Hàm Print
    func printPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Bạn hãy mở Console của Xcode để thấy dòng chữ "Log của tôi" xuất hiện
            .print("Log của tôi")
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm HandleEvents
    func handleEventsPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .handleEvents(
                receiveSubscription: { _ in print("Bắt đầu đăng ký luồng") },
                receiveOutput: { value in print("Sắp nhận giá trị: \(value)") },
                receiveCompletion: { _ in print("Luồng đã kết thúc") },
                receiveCancel: { print("Người dùng đã hủy đăng ký") }
            )
            .map { "🔥 \($0)" } // Thêm icon để phân biệt trên UI
            .eraseToAnyPublisher()
    }
    
    // MARK: - 3. Hàm Breakpoint
    func breakpointPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // 💡 LƯU Ý: Nếu bạn chạy trên máy thật/mô phỏng kèm Xcode,
        // nó sẽ dừng code lại ở số "3". Trên UI này ta chỉ giả lập logic.
            .breakpoint(receiveOutput: { value in
                return value == "3" // Trả về true để kích hoạt điểm ngắt
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: - 4. Hàm Multicast
    func multicastPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        // Tạo một Subject để làm trung gian chia sẻ
        let subject = PassthroughSubject<String, Never>()
        
        let multicasted = publisher
            .handleEvents(receiveOutput: { print("Thực hiện tác vụ nặng cho số \($0)") })
            .multicast(subject: { subject })
        
        // 💡 Multicast là ConnectablePublisher, nó chỉ chạy khi ta gọi .connect()
        // Ở đây ta dùng autoconnect() để nó tự chạy khi có người đăng ký đầu tiên
        return multicasted
            .autoconnect()
            .eraseToAnyPublisher()
    }
}

#Preview {
    OthersView()
}
