
import SwiftUI
import Combine

struct ReducingElementsView: View {
    var body: some View {
        VStack {
            List {
                // 1. NavigationLink cho collect (Gom tất cả)
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Collect",
                        description: ".collect()",
                        comparingPublisher: self.collectPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Collect").font(.headline)
                        Text("Gom toàn bộ dữ liệu thành 1 mảng khi luồng kết thúc").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. NavigationLink cho collect(count) (Gom theo nhóm)
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Collect(3)",
                        description: ".collect(3)",
                        comparingPublisher: self.collectByCountPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Collect(3)").font(.headline)
                        Text("Gom dữ liệu theo từng nhóm 3 phần tử").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 3. NavigationLink cho ignoreOutput
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "IgnoreOutput",
                        description: ".ignoreOutput()",
                        comparingPublisher: self.ignoreOutputPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("IgnoreOutput").font(.headline)
                        Text("Bỏ qua mọi giá trị, chỉ quan tâm khi nào kết thúc").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 4. reduce
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Reduce",
                        description: ".reduce(0) { $0 + $1 }",
                        comparingPublisher: self.reducePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Reduce").font(.headline)
                        Text("Cộng dồn và CHỈ phát kết quả khi luồng kết thúc").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 5. tryReduce
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryReduce",
                        description: ".tryReduce { ném lỗi nếu tổng > 10 }",
                        comparingPublisher: self.tryReducePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryReduce").font(.headline)
                        Text("Cộng dồn nhưng ném lỗi nếu vi phạm điều kiện").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Filtering elements")
    }
    
    // MARK: - 1. Hàm Collect (Gom tất cả)
    func collectPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Gom tất cả các phần tử lại. Operator này CHỈ phát ra dữ liệu
        // khi luồng gốc báo hiệu "Finished" (Đã hoàn thành).
            .collect()
        // Dữ liệu lúc này chuyển thành mảng [String].
        // Ta dùng map để nối mảng lại thành 1 chuỗi hiển thị lên UI.
            .map { array in
                "[\(array.joined(separator: ","))]"
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm Collect theo số lượng
    func collectByCountPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Cứ gom đủ 3 phần tử thì phát ra 1 mảng.
        // Nếu luồng kết thúc mà chưa đủ 3 (ví dụ còn lẻ 2), nó sẽ phát ra mảng 2 phần tử đó.
            .collect(3)
            .map { array in
                "[\(array.joined(separator: ","))]"
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 3. Hàm IgnoreOutput
    func ignoreOutputPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Chặn TẤT CẢ các giá trị đi qua, chỉ cho phép tín hiệu "Finished" đi qua.
        // Lúc này kiểu dữ liệu bị đổi thành <Never, Never> (Không bao giờ phát dữ liệu).
            .ignoreOutput()
        
        // 👉 Thủ thuật: Vì UI của chúng ta yêu cầu kiểu <String, Never>,
        // ta ép kiểu Never về String (đoạn code bên trong sẽ không bao giờ bị chạy tới).
            .map { _ -> String in }
        
        // Để bạn thấy được luồng dưới có hoạt động, ta gài thêm một chữ "Xong!".
        // Chữ này chỉ xuất hiện khi tín hiệu "Finished" lọt qua được ignoreOutput.
            .append("Xong!")
            .eraseToAnyPublisher()
    }
    
    // MARK: - 1. Hàm Reduce
    func reducePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
        // Khởi tạo tổng = 0, cộng dồn từng giá trị vào
        // Sẽ không phát ra bất cứ thứ gì cho đến khi nhận được tín hiệu Finished
            .reduce(0) { accumulated, current in
                accumulated + current
            }
            .map { String($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm TryReduce
    enum ReduceError: Error {
        case limitExceeded
    }
    
    func tryReducePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            .tryReduce(0) { accumulated, current -> Int in
                let newValue = accumulated + current
                
                // Đặt luật: Nếu tổng cộng dồn vượt quá 10, ta chủ động ném lỗi
                if newValue > 10 {
                    throw ReduceError.limitExceeded
                }
                
                return newValue
            }
            .map { String($0) }
        // Bắt lỗi và hiển thị lên UI, sau đó luồng kết thúc
            .catch { _ in Just("Lỗi") }
            .eraseToAnyPublisher()
    }
}

#Preview {
    ReducingElementsView()
}
