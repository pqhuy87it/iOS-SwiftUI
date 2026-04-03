import SwiftUI
import Combine

struct MathematicElementsView: View {
    var body: some View {
        VStack {
            List {
                // 1. NavigationLink cho max
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Max",
                        description: ".max()",
                        comparingPublisher: self.maxPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Max").font(.headline)
                        Text("Tìm giá trị lớn nhất (Chỉ phát khi kết thúc)").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. NavigationLink cho tryMax
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryMax",
                        description: ".tryMax { ném lỗi nếu thấy số 4 }",
                        comparingPublisher: self.tryMaxPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryMax").font(.headline)
                        Text("Tìm max nhưng ném lỗi nếu vi phạm điều kiện").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 3. NavigationLink cho count
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Count",
                        description: ".count()",
                        comparingPublisher: self.countPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Count").font(.headline)
                        Text("Đếm số lượng phần tử (Chỉ phát khi kết thúc)").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 4. NavigationLink cho min
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Min",
                        description: ".min()",
                        comparingPublisher: self.minPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Min").font(.headline)
                        Text("Tìm giá trị nhỏ nhất (Chỉ phát khi kết thúc)").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 5. NavigationLink cho tryMin
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryMin",
                        description: ".tryMin { ném lỗi nếu thấy số 4 }",
                        comparingPublisher: self.tryMinPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryMin").font(.headline)
                        Text("Tìm min nhưng ném lỗi nếu vi phạm điều kiện").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Mathematic operations on elements")
    }
    
    // MARK: - 1. Hàm Max
    func maxPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Chuyển String thành Int để so sánh độ lớn (Nếu để String nó sẽ so sánh theo bảng chữ cái)
            .map { Int($0) ?? 0 }
        // Tìm giá trị lớn nhất trong suốt vòng đời của luồng
            .max()
            .map { String($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm TryMax
    enum MaxError: Error {
        case illegalValue
    }
    
    func tryMaxPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
        // tryMax cho phép chúng ta tự định nghĩa logic so sánh (đâu là số lớn hơn)
        // Đồng thời cho phép ném lỗi nếu phát hiện dữ liệu bất thường
            .tryMax { currentMax, newValue -> Bool in
                // Giả lập: Nếu phát hiện số 4 truyền vào, hệ thống báo lỗi ngay lập tức
                if newValue == 4 || currentMax == 4 {
                    throw MaxError.illegalValue
                }
                
                // Trả về true nếu newValue lớn hơn currentMax (Logic so sánh bình thường)
                return currentMax < newValue
            }
            .map { String($0) }
            .catch { _ in Just("Lỗi") } // Hứng lỗi và in ra UI
            .eraseToAnyPublisher()
    }
    
    // MARK: - 3. Hàm Count
    func countPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Chỉ đơn giản là đếm xem có bao nhiêu phần tử đã lọt qua luồng này
            .count()
            .map { String($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 4. Hàm Min
    func minPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Chuyển String thành Int để so sánh chính xác theo giá trị số
            .map { Int($0) ?? 0 }
        // Tìm giá trị nhỏ nhất. Nó sẽ chờ luồng gốc kết thúc mới phát ra kết quả.
            .min()
            .map { String($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 5. Hàm TryMin
    enum MinError: Error {
        case illegalValue
    }
    
    func tryMinPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
        // tryMin cho phép tự định nghĩa thế nào là "nhỏ hơn" và ném lỗi nếu cần
            .tryMin { currentMin, newValue -> Bool in
                // Giả lập luật cấm: Nếu gặp số 4, hệ thống từ chối tính toán tiếp và báo lỗi
                if newValue == 4 || currentMin == 4 {
                    throw MinError.illegalValue
                }
                
                // Trả về true nếu newValue NHỎ HƠN currentMin
                // (Đừng nhầm với tryMax là currentMax < newValue nhé)
                return newValue < currentMin
            }
            .map { String($0) }
        // Bắt lỗi và hiện thông báo lên UI
            .catch { _ in Just("Lỗi") }
            .eraseToAnyPublisher()
    }
}

#Preview {
    MathematicElementsView()
}
