import SwiftUI
import Combine

struct MappingElementsView: View {
    var body: some View {
        VStack {
            List {
                // 1. Ví dụ Map hiện tại của bạn
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Map",
                        description: ".map { $0 * 2 }",
                        comparingPublisher: self.mapPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Map").font(.headline)
                        Text("Biến đổi 1-1").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. Thêm ví dụ FlatMap mới
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "FlatMap",
                        description: ".flatMap { ... phát ra 2 giá trị ... }",
                        comparingPublisher: self.flatMapPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("FlatMap").font(.headline)
                        Text("Biến đổi 1 thành 1 luồng nhiều giá trị").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 3. TryMap (VÍ DỤ MỚI)
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryMap",
                        description: ".tryMap { ném lỗi nếu là số 3 }",
                        comparingPublisher: self.tryMapPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryMap").font(.headline)
                        Text("Có thể ném lỗi -> Luồng sẽ bị ĐÓNG").font(.caption).foregroundColor(.gray)
                    }
                }
                
                
                // 4. Scan
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Scan",
                        description: ".scan(0) { $0 + $1 }",
                        comparingPublisher: self.scanPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Scan").font(.headline)
                        Text("Cộng dồn liên tục các giá trị").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 5. Thêm NavigationLink cho tryScan
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryScan",
                        description: ".tryScan { ném lỗi nếu tổng > 10 }",
                        comparingPublisher: self.tryScanPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryScan").font(.headline)
                        Text("Cộng dồn nhưng ném lỗi nếu vượt giới hạn").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 6. Thêm NavigationLink cho setFailureType
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "SetFailureType",
                        description: ".setFailureType(to: MyError.self)",
                        comparingPublisher: self.setFailureTypePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("SetFailureType").font(.headline)
                        Text("Thay đổi kiểu Lỗi của luồng (chỉ đổi Type)").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Mapping elements")
    }
    
    // MARK: - Map Publisher (Code cũ của bạn)
    func mapPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { (Int($0) ?? 0) * 2 }
            .map { String($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - FlatMap Publisher (Ví dụ mới)
    func flatMapPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher.flatMap { value -> AnyPublisher<String, Never> in
            // Từ 1 giá trị đầu vào (VD: "1"), chúng ta tạo ra một Publisher mới
            // Publisher mới này sẽ phát ra 2 giá trị: "1a" và "1b"
            
            // Giá trị thứ nhất: Phát ra ngay lập tức
            let firstValue = Just("\(value)a")
                .eraseToAnyPublisher()
            
            // Giá trị thứ hai: Bị delay 0.4 giây trước khi phát ra
            let secondValue = Just("\(value)b")
                .delay(for: .seconds(0.4), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
            
            // Dùng .append để nối 2 publisher này lại thành 1 luồng con
            return firstValue
                .append(secondValue)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - 3. TryMap Publisher (Ví dụ Mới)
    
    // Định nghĩa một Error tùy chỉnh
    enum MyCombineError: Error {
        case badNumber
    }
    
    func tryMapPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .tryMap { value -> String in
                // Giả lập logic kiểm tra: Nếu luồng chính phát ra số "3", ta CHỦ ĐỘNG ném lỗi
                if value == "3" {
                    throw MyCombineError.badNumber
                }
                
                // Nếu không lỗi, biến đổi bình thường (nhân 10)
                let intValue = Int(value) ?? 0
                return String(intValue * 10)
            }
        // Vì tryMap đổi kiểu lỗi từ 'Never' sang 'Error'
        // Ta cần dùng .catch để "hứng" lỗi này lại cho khớp với UI (đòi hỏi Never)
            .catch { error -> Just<String> in
                // Khi bắt được lỗi, phát ra một chữ "Lỗi" duy nhất.
                // LƯU Ý: Sau hàm catch này, luồng Combine chính thức CHẾT (Hoàn thành).
                return Just("Lỗi")
            }
            .eraseToAnyPublisher()
    }
    
    func scanPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher.map { Int($0) ?? 0 }.scan(0) { $0 + $1 }.map { String($0) }.eraseToAnyPublisher()
    }
    
    // MARK: - 1. Hàm TryScan
    // Định nghĩa một Error tuỳ chỉnh
    enum ScanError: Error {
        case limitExceeded
    }
    
    func tryScanPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            .tryScan(0) { accumulated, current -> Int in
                let newValue = accumulated + current
                // Đặt luật: Nếu tổng cộng dồn vượt quá 10, ta chủ động ném lỗi
                if newValue > 10 {
                    throw ScanError.limitExceeded
                }
                return newValue
            }
            .map { String($0) }
        // Vì tryScan đổi Failure từ Never sang Error, ta cần catch để bắt lỗi và trả về UI
            .catch { _ in Just("Lỗi") }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm SetFailureType
    enum CustomError: Error {
        case someError
    }
    
    func setFailureTypePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        // Toán tử này KHÔNG làm thay đổi giá trị chạy qua nó.
        // Nó chỉ "đánh lừa" compiler (thay đổi Type Signature).
        publisher
        // Luồng đầu vào đang là <String, Never>
        // Sau dòng này, nó biến thành <String, CustomError>
            .setFailureType(to: CustomError.self)
        
        // Ép ngược lại về Never để GenericCombineStreamView có thể hiển thị
        // Do luồng Never không bao giờ có lỗi thực sự, khối catch này sẽ không bao giờ bị gọi tới.
            .catch { _ in Just("Lỗi") }
            .eraseToAnyPublisher()
    }
}

#Preview {
    MappingElementsView()
}

