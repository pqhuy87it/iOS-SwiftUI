import Combine
import SwiftUI

struct CombiningElementsMultiplePublishersView: View {
    var body: some View {
        VStack {
            List {
                // 1. NavigationLink cho Merge
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Merge",
                        description: ".merge(with: streamB)",
                        comparingPublisher: self.mergePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Merge").font(.headline)
                        Text("Trộn 2 luồng lại với nhau (Ai đến trước ra trước)").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. NavigationLink cho CombineLatest
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "CombineLatest",
                        description: ".combineLatest(streamB)",
                        comparingPublisher: self.combineLatestPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("CombineLatest").font(.headline)
                        Text("Gộp các giá trị MỚI NHẤT của cả 2 luồng").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 3. NavigationLink cho Zip
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Zip",
                        description: ".zip(streamB)",
                        comparingPublisher: self.zipPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Zip").font(.headline)
                        Text("Bắt cặp 1-1 (Chờ đủ đôi mới phát)").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Filtering elements")
    }
    
    // MARK: - Hàm hỗ trợ tạo Luồng thứ 2 (Phát ra A, B, C, D, E)
    // Luồng gốc của bạn phát số cách nhau 1s. Luồng này sẽ phát chữ cách nhau 1.5s để thấy sự khác biệt.
    func createSecondStream(interval: TimeInterval) -> AnyPublisher<String, Never> {
        let letters = ["A", "B", "C", "D", "E"]
        let publishers = letters.map {
            Just($0).delay(for: .seconds(interval), scheduler: DispatchQueue.main).eraseToAnyPublisher()
        }
        return publishers[1...].reduce(publishers[0]) {
            Publishers.Concatenate(prefix: $0, suffix: $1).eraseToAnyPublisher()
        }
    }
    
    // MARK: - 1. Hàm Merge
    func mergePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        let streamB = createSecondStream(interval: 1.5)
        
        // Merge yêu cầu 2 luồng CÙNG KIỂU dữ liệu (cùng là String).
        // Nó sẽ trộn lẫn các quả bóng của 2 luồng thành 1 hàng dọc.
        return publisher
            .merge(with: streamB)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm CombineLatest
    func combineLatestPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        let streamB = createSecondStream(interval: 1.5)
        
        return publisher
        // CombineLatest ghép số và chữ thành một Tuple (String, String)
            .combineLatest(streamB)
        // Ta nối Tuple lại thành chuỗi (vd: "1A") để hiện lên UI
            .map { number, letter in
                "\(number)\(letter)"
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 3. Hàm Zip
    func zipPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        let streamB = createSecondStream(interval: 1.5)
        
        return publisher
        // Zip cũng ghép thành Tuple (String, String) nhưng theo logic Bắt cặp
            .zip(streamB)
            .map { number, letter in
                "\(number)\(letter)"
            }
            .eraseToAnyPublisher()
    }
}

#Preview {
    CombiningElementsMultiplePublishersView()
}
