import Combine
import SwiftUI

struct ControllingTimingView: View {
    var body: some View {
        VStack {
            List {
                // 1. NavigationLink cho delay
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Delay",
                        description: ".delay(for: 2)",
                        comparingPublisher: self.delayPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Delay").font(.headline)
                        Text("Dời thời gian phát của toàn bộ luồng chậm lại X giây").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. NavigationLink cho debounce
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Debounce",
                        description: ".debounce(for: 1.5)",
                        comparingPublisher: self.debouncePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Debounce").font(.headline)
                        Text("Chờ người dùng 'ngừng tay' X giây rồi mới lấy giá trị").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 3. NavigationLink cho throttle
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Throttle",
                        description: ".throttle(for: 2.5)",
                        comparingPublisher: self.throttlePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Throttle").font(.headline)
                        Text("Ép nhịp độ: Chỉ nhận 1 giá trị mỗi X giây").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 4. NavigationLink cho measureInterval
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "MeasureInterval",
                        description: ".measureInterval(using: RunLoop.main)",
                        comparingPublisher: self.measureIntervalPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("MeasureInterval").font(.headline)
                        Text("Đo lường thời gian trôi qua giữa 2 lần phát dữ liệu").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 5. NavigationLink cho timeout
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Timeout",
                        description: ".timeout(.seconds(2))",
                        comparingPublisher: self.timeoutPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Timeout").font(.headline)
                        Text("Chờ dữ liệu tối đa X giây, quá hạn là cắt luồng báo lỗi").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Controlling timing")
    }
    // MARK: - 1. Hàm Delay
    func delayPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Giữ nguyên mọi thứ (giá trị, khoảng cách giữa các phần tử)
        // Chỉ đơn giản là dời vạch xuất phát chậm lại 2 giây.
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm Debounce
    func debouncePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Debounce sẽ khởi động một cái đồng hồ đếm ngược 1.5 giây.
        // Mỗi khi có bóng mới rơi xuống, nó sẽ RESET đồng hồ về 1.5s.
        // Nếu đồng hồ đếm được về 0 (tức là đã yên tĩnh được 1.5s), nó mới nhả quả bóng gần nhất ra.
            .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 3. Hàm Throttle
    func throttlePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Throttle ép luồng phải chạy theo một nhịp điệu cố định (ở đây là 2.5 giây).
        // Trong khoảng thời gian 2.5s đó, ai chen vào sẽ bị nuốt chửng.
        // Hết 2.5s, nó sẽ lấy phần tử MỚI NHẤT (latest: true) để nhả ra.
            .throttle(for: .seconds(2.5), scheduler: DispatchQueue.main, latest: true)
            .eraseToAnyPublisher()
    }
    
    // MARK: - 4. Hàm MeasureInterval
    func measureIntervalPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Bấm giờ xem khoảng cách giữa các quả bóng rớt xuống là bao lâu.
        // 💡 Thủ thuật: Dùng RunLoop.main thay vì DispatchQueue.main để
        // kết quả trả về là TimeInterval (Double) đếm theo giây, rất dễ format.
            .measureInterval(using: RunLoop.main)
            .map { interval in
                // Chuyển đổi con số thời gian thành String (ví dụ: "1.0s")
                // Toán tử này NUỐT giá trị gốc (1, 2, 3...) và thay bằng Khoảng Thời Gian.
                String(format: "%.1fs", interval.magnitude)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 5 Hàm Timeout
    enum TimeError: Error {
        case tookTooLong
    }
    
    func timeoutPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // 1. Gài bẫy: Cố tình làm nghẽn luồng mất 5 giây khi gặp số 3
            .flatMap { value -> AnyPublisher<String, Never> in
                if value == "3" {
                    return Just(value)
                        .delay(for: .seconds(5), scheduler: DispatchQueue.main)
                        .eraseToAnyPublisher()
                }
                return Just(value).eraseToAnyPublisher()
            }
        
        // 👉 CÁCH SỬA LỖI: Chủ động đổi kiểu luồng từ <String, Never> sang <String, TimeError>
        // Nhờ dòng này, hàm timeout phía dưới mới chấp nhận customError của chúng ta.
            .setFailureType(to: TimeError.self)
        
        // 2. Thiết lập tối hậu thư: Nếu im lặng quá 2 giây -> NÉM LỖI
            .timeout(.seconds(2), scheduler: DispatchQueue.main, customError: { TimeError.tookTooLong })
        
        // 3. Hứng lỗi để báo lên UI.
        // Toán tử catch sẽ "nuốt" cái TimeError và trả về luồng Never, khớp hoàn toàn với UI.
            .catch { _ in Just("Time\nOut") }
            .eraseToAnyPublisher()
    }
}

#Preview {
    ControllingTimingView()
}
