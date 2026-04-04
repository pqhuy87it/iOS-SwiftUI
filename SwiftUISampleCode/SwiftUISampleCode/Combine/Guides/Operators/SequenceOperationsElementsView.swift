import Combine
import SwiftUI

struct SequenceOperationsElementsView: View {
    var body: some View {
        VStack {
            List {
                // 1. NavigationLink cho first
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "First",
                        description: ".first()",
                        comparingPublisher: self.firstPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("First").font(.headline)
                        Text("Lấy phần tử đầu tiên và ngắt luồng ngay lập tức").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. NavigationLink cho firstWhere
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "FirstWhere",
                        description: ".first(where: { $0 > 3 })",
                        comparingPublisher: self.firstWherePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("FirstWhere").font(.headline)
                        Text("Lấy phần tử ĐẦU TIÊN thỏa mãn điều kiện").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 3. NavigationLink cho tryFirstWhere
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryFirstWhere",
                        description: ".tryFirst(where: { ném lỗi nếu là 2 })",
                        comparingPublisher: self.tryFirstWherePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryFirstWhere").font(.headline)
                        Text("Tìm theo điều kiện, ném lỗi nếu vi phạm luật").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 4. NavigationLink cho last
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Last",
                        description: ".last()",
                        comparingPublisher: self.lastPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Last").font(.headline)
                        Text("Lấy phần tử cuối cùng (Chỉ phát khi kết thúc)").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 5. NavigationLink cho lastWhere
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "LastWhere",
                        description: ".last(where: { số chẵn })",
                        comparingPublisher: self.lastWherePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("LastWhere").font(.headline)
                        Text("Lấy phần tử thỏa mãn điều kiện xuất hiện CUỐI CÙNG").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 6. NavigationLink cho tryLastWhere
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryLastWhere",
                        description: ".tryLast(where: { ném lỗi nếu là 5 })",
                        comparingPublisher: self.tryLastWherePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryLastWhere").font(.headline)
                        Text("Chờ lấy phần tử cuối, nhưng ném lỗi nếu giẫm mìn").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 7. NavigationLink cho dropFirst
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "DropFirst",
                        description: ".dropFirst(2)",
                        comparingPublisher: self.dropFirstPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("DropFirst").font(.headline)
                        Text("Bỏ qua N phần tử đầu tiên, sau đó mở cổng").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 8. NavigationLink cho dropWhile
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "DropWhile",
                        description: ".drop(while: { $0 < 3 })",
                        comparingPublisher: self.dropWhilePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("DropWhile").font(.headline)
                        Text("Bỏ qua CHO ĐẾN KHI điều kiện bị sai (false)").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 9. NavigationLink cho tryDropWhile
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryDropWhile",
                        description: ".tryDrop(while: { ném lỗi nếu là 2 })",
                        comparingPublisher: self.tryDropWhilePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryDropWhile").font(.headline)
                        Text("Bỏ qua theo điều kiện, ném lỗi nếu gặp mìn").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 10. NavigationLink cho dropUntilOutput
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "DropUntil",
                        description: ".drop(untilOutputFrom: trigger)",
                        comparingPublisher: self.dropUntilPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("DropUntilOutput").font(.headline)
                        Text("Bỏ qua mọi thứ cho đến khi luồng khác lên tiếng").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 11. NavigationLink cho prepend
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Prepend",
                        description: ".prepend(\"0\")",
                        comparingPublisher: self.prependPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Prepend").font(.headline)
                        Text("Chèn thêm phần tử vào ngay đầu luồng").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 12. NavigationLink cho prefixUntilOutput
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "PrefixUntil",
                        description: ".prefix(untilOutputFrom: trigger)",
                        comparingPublisher: self.prefixUntilPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("PrefixUntilOutput").font(.headline)
                        Text("Lấy dữ liệu cho đến khi luồng khác lên tiếng thì ngắt").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 13. NavigationLink cho prefixWhile
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "PrefixWhile",
                        description: ".prefix(while: { $0 < 4 })",
                        comparingPublisher: self.prefixWhilePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("PrefixWhile").font(.headline)
                        Text("Lấy dữ liệu chừng nào điều kiện còn ĐÚNG").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 14. NavigationLink cho tryPrefixWhile
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryPrefixWhile",
                        description: ".tryPrefix(while: { ném lỗi nếu là 3 })",
                        comparingPublisher: self.tryPrefixWhilePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryPrefixWhile").font(.headline)
                        Text("Lấy dữ liệu, nhưng có quyền ném lỗi đóng luồng").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 15. NavigationLink cho output
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Output",
                        description: ".output(at: 2)",
                        comparingPublisher: self.outputPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Output(at:)").font(.headline)
                        Text("Chỉ lấy đúng phần tử ở vị trí Index chỉ định").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Filtering elements")
    }
    
    // MARK: - 1. Hàm First
    func firstPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Chộp lấy phần tử đầu tiên xuất hiện.
        // Sau khi lấy được, Combine tự động gọi .cancel() lên luồng gốc.
            .first()
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm FirstWhere
    func firstWherePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
        // Bỏ qua các phần tử không thỏa mãn.
        // Ngay khi tìm thấy số ĐẦU TIÊN LỚN HƠN 3, lấy nó và hủy luồng.
            .first(where: { value in
                value > 3
            })
            .map { String($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 3. Hàm TryFirstWhere
    enum FirstError: Error {
        case fatalEncounter
    }
    
    func tryFirstWherePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            .tryFirst(where: { value -> Bool in
                // 1. Cái bẫy: Nếu quét trúng số 2 -> NÉM LỖI VÀ ĐÓNG LUỒNG
                if value == 2 {
                    throw FirstError.fatalEncounter
                }
                
                // 2. Mục tiêu tìm kiếm: Tìm số đầu tiên lớn hơn 4
                return value > 4
            })
            .map { String($0) }
            .catch { _ in Just("Lỗi") } // Hứng lỗi lên UI
            .eraseToAnyPublisher()
    }
    
    // MARK: - 4. Hàm Last
    func lastPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Âm thầm ghi nhớ phần tử đi qua.
        // Chỉ khi luồng báo Finished, nó mới nhả phần tử cuối cùng nó nhớ được.
            .last()
            .eraseToAnyPublisher()
    }
    
    // MARK: - 5. Hàm LastWhere
    func lastWherePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
        // Tìm số CHẴN cuối cùng của luồng
            .last(where: { value in
                value % 2 == 0
            })
            .map { String($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 6. Hàm TryLastWhere
    enum LastError: Error {
        case fatalEnd
    }
    
    func tryLastWherePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            .tryLast(where: { value -> Bool in
                // 1. Cái bẫy ở phút chót: Nếu số cuối cùng là 5 -> NÉM LỖI
                if value == 5 {
                    throw LastError.fatalEnd
                }
                
                // 2. Điều kiện tìm kiếm: Lấy số nhỏ hơn 4
                return value < 4
            })
            .map { String($0) }
            .catch { _ in Just("Lỗi") } // Hứng lỗi lên UI
            .eraseToAnyPublisher()
    }
    
    // MARK: - 7. Hàm DropFirst
    func dropFirstPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Chặn và vứt bỏ 2 phần tử đầu tiên.
        // Từ phần tử thứ 3 trở đi, cho qua tất cả.
            .dropFirst(2)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 8. Hàm DropWhile
    func dropWhilePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
        // Cổng đóng KHI: số < 3.
        // Cổng mở toang KHI: điều kiện này bị sai (số >= 3).
            .drop(while: { value in
                value < 3
            })
            .map { String($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 9. Hàm TryDropWhile
    enum DropError: Error {
        case fatalEncounter
    }
    
    func tryDropWhilePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            .tryDrop(while: { value -> Bool in
                // 1. Nếu đang trong lúc chặn mà dẫm phải số 2 -> NÉM LỖI
                if value == 2 {
                    throw DropError.fatalEncounter
                }
                
                // 2. Điều kiện chặn: chặn các số < 4
                return value < 4
            })
            .map { String($0) }
            .catch { _ in Just("Lỗi") } // Hứng lỗi lên UI
            .eraseToAnyPublisher()
    }
    
    // MARK: - 10. Hàm DropUntilOutputFrom
    func dropUntilPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        // Tạo một luồng "cò súng" (trigger). Nó sẽ im lặng và sau 2.5 giây mới phát ra 1 tín hiệu.
        let trigger = Just("Go!")
            .delay(for: .seconds(2.5), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return publisher
        // Chặn tất cả dữ liệu từ luồng gốc, cho ĐẾN KHI luồng 'trigger' phát ra tín hiệu đầu tiên.
            .drop(untilOutputFrom: trigger)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 11. Hàm Prepend
    func prependPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Chèn giá trị "0" vào trước khi luồng gốc kịp phát ra bất cứ thứ gì.
        // Bạn có thể chèn 1 mảng bằng .prepend(["-2", "-1", "0"])
            .prepend("0")
            .eraseToAnyPublisher()
    }
    
    // MARK: - 12. Hàm PrefixUntilOutput
    func prefixUntilPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        // Tạo một trigger bắn tín hiệu sau 2.5 giây
        let trigger = Just("Stop")
            .delay(for: .seconds(2.5), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return publisher
        // Cho phép dữ liệu đi qua thoải mái, nhưng hễ trigger kêu "Stop" là đóng sập cửa (Finished)
            .prefix(untilOutputFrom: trigger)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 13. Hàm PrefixWhile
    func prefixWhilePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
        // Cho phép lọt qua nếu điều kiện là TRUE.
        // Hễ gặp FALSE lần đầu tiên -> Đóng sập cửa, Finished luồng, hủy các phần tử sau.
            .prefix(while: { value in
                value < 4
            })
            .map { String($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 14. Hàm TryPrefixWhile
    enum PrefixError: Error {
        case fatalBreak
    }
    
    func tryPrefixWhilePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            .tryPrefix(while: { value -> Bool in
                // Gài bẫy: Đang yên đang lành nếu dẫm phải số 3 -> Ném lỗi sập luồng
                if value == 3 {
                    throw PrefixError.fatalBreak
                }
                return value < 5
            })
            .map { String($0) }
            .catch { _ in Just("Lỗi") } // Bắt lỗi lên UI
            .eraseToAnyPublisher()
    }
    
    // MARK: - 15. Hàm Output
    func outputPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Chỉ lấy duy nhất phần tử ở vị trí Index thứ 2 (Tức là phần tử thứ 3 xuất hiện, vì đếm từ 0).
        // Lấy xong lập tức Finished luồng.
            .output(at: 2)
            .eraseToAnyPublisher()
    }
}

#Preview {
    SequenceOperationsElementsView()
}
