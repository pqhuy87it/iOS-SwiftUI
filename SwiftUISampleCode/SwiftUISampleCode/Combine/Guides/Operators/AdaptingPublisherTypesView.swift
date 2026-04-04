import Combine
import SwiftUI

struct AdaptingPublisherTypesView: View {
    var body: some View {
        VStack {
            List {
                // 1. NavigationLink cho switchToLatest
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "SwitchToLatest",
                        description: ".switchToLatest()",
                        comparingPublisher: self.switchToLatestPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("SwitchToLatest").font(.headline)
                        Text("Chuyển sang luồng mới nhất, HỦY luồng cũ đang chạy").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. NavigationLink cho eraseToAnyPublisher
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "EraseToAnyPublisher",
                        description: ".eraseToAnyPublisher()",
                        comparingPublisher: self.eraseTypePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("EraseToAnyPublisher").font(.headline)
                        Text("Xóa bỏ kiểu dữ liệu phức tạp, bọc lại thành AnyPublisher").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Adapting publisher types")
    }
    
    // MARK: - 1. Hàm SwitchToLatest
    func switchToLatestPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Bước 1: Biến mỗi giá trị (1, 2, 3...) thành một LUỒNG MỚI (Publisher con)
            .map { outerValue -> AnyPublisher<String, Never> in
                // Giả lập luồng con này mất thời gian để chạy (như gọi API)
                // Nó sẽ phát ra giá trị "A" sau 0.8s, và giá trị "B" sau 1.6s
                let first = Just("\(outerValue)A")
                    .delay(for: .seconds(0.8), scheduler: DispatchQueue.main)
                let second = Just("\(outerValue)B")
                    .delay(for: .seconds(1.6), scheduler: DispatchQueue.main)
                
                return first.append(second).eraseToAnyPublisher()
            }
        // Bước 2: Lúc này ta có một "Luồng chứa các luồng" (Publisher<Publisher, Never>)
        // switchToLatest sẽ giải quyết mớ bòng bong này bằng cách:
        // "Chỉ giữ lại luồng con được sinh ra GẦN NHẤT, lập tức hủy luồng con cũ"
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm EraseToAnyPublisher
    func eraseTypePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        // Hàm này KHÔNG làm thay đổi giá trị của luồng. 1,2,3 vẫn ra 1,2,3.
        // Nó sinh ra chỉ để phục vụ cho trình biên dịch (Compiler) của Swift.
        let complexPublisher = publisher
            .map { Int($0) ?? 0 }
            .filter { $0 > 0 }
            .map { String($0) }
        
        // Nếu bạn Option-Click (nhấn Alt + click chuột) vào chữ `complexPublisher` ở trên trong Xcode,
        // bạn sẽ thấy kiểu dữ liệu của nó dài ngoằng và kinh dị như sau:
        // Publishers.Map<Publishers.Filter<Publishers.Map<AnyPublisher<String, Never>, Int>>, String>
        
        return complexPublisher
        // Cắt bỏ cái đuôi dài ngoằng ở trên, đóng gói nó lại gọn gàng thành chiếc hộp AnyPublisher
            .eraseToAnyPublisher()
    }
}

#Preview {
    AdaptingPublisherTypesView()
}
