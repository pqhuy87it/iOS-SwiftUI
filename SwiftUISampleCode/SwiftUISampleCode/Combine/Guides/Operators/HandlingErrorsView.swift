import Combine
import SwiftUI

// Helper class để đếm số lần thử lại cho ví dụ retry
class RetryTracker {
    var attempts = 0
}

struct HandlingErrorsView: View {
    var body: some View {
        VStack {
            List {
                // 1. NavigationLink cho catch
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Catch",
                        description: ".catch { nối vào luồng dự phòng }",
                        comparingPublisher: self.catchPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Catch").font(.headline)
                        Text("Khi lỗi, thay thế bằng một luồng dự phòng mới").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. NavigationLink cho tryCatch
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryCatch",
                        description: ".tryCatch { cố gắng cứu, nhưng có thể ném lỗi }",
                        comparingPublisher: self.tryCatchPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryCatch").font(.headline)
                        Text("Cứu viện luồng lỗi, nhưng có quyền ném ra lỗi khác").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 3. NavigationLink cho retry
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Retry",
                        description: ".retry(2)",
                        comparingPublisher: self.retryPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Retry").font(.headline)
                        Text("Khi gặp lỗi, tự động đăng ký lại luồng từ đầu").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 4. NavigationLink cho mapError
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "MapError",
                        description: ".mapError { đổi lỗi A thành lỗi B }",
                        comparingPublisher: self.mapErrorPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("MapError").font(.headline)
                        Text("Chuyển đổi kiểu lỗi (vd: từ lỗi mạng sang lỗi UI)").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 5. NavigationLink cho assertNoFailure
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "AssertNoFailure",
                        description: ".assertNoFailure()",
                        comparingPublisher: self.assertNoFailurePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("AssertNoFailure").font(.headline)
                        Text("Cam kết không có lỗi. Nếu có, Crash App ngay lập tức!").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Handling errors")
    }
    
    // Định nghĩa Lỗi cho các bài test
    enum TestError: Error {
        case bridgeCollapsed
        case backupFailed
    }
    
    // MARK: - 1. Hàm Catch
    func catchPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // 1. Cố tình tạo ra lỗi: Khi đi đến số 3 thì đánh sập luồng gốc
            .tryMap { value -> String in
                if value == "3" {
                    throw TestError.bridgeCollapsed
                }
                return value
            }
        // 2. Cứu viện bằng catch: Hứng lấy lỗi và trả về một Luồng (Publisher) mới
            .catch { error -> AnyPublisher<String, Never> in
                // Khi luồng gốc sập, ta tạo ra một luồng dự phòng phát ra 2 chữ "Cứu" và "Viện"
                // Cách nhau 1 giây giống hệt luồng gốc để bạn dễ quan sát
                let firstBackup = Just("Cứu")
                    .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                let secondBackup = Just("Viện")
                    .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                
                return firstBackup.append(secondBackup).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm TryCatch
    func tryCatchPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // 1. Vẫn tạo ra lỗi ở số 3
            .tryMap { value -> String in
                if value == "3" { throw TestError.bridgeCollapsed }
                return value
            }
        // 2. tryCatch: Cố gắng cứu viện, nhưng quá trình cứu viện cũng có thể gặp lỗi!
            .tryCatch { error -> AnyPublisher<String, Error> in
                // Giả lập: Cố gắng gọi luồng dự phòng nhưng luồng dự phòng cũng bị sập nốt.
                // tryCatch cho phép dùng từ khoá `throw` để ném ra một lỗi MỚI
                throw TestError.backupFailed
            }
        // Vì UI của chúng ta bắt buộc kiểu lỗi là Never, nên ta phải dùng catch 1 lần nữa ở cuối để dọn dẹp
            .catch { newError in
                Just("Toang!")
            }
            .eraseToAnyPublisher()
    }
    
    // Các lỗi dùng để test
    enum NetworkError: Error {
        case timeout
        case serverDown
    }
    
    enum UIError: Error {
        case friendlyMessage(String)
    }
    
    // MARK: - 1. Hàm Retry
    func retryPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        let tracker = RetryTracker()
        
        return publisher
            .tryMap { value -> String in
                // Giả lập mạng chập chờn: 2 lần đầu tiên khi chạm mốc số 3 đều bị văng lỗi.
                // Đến lần thứ 3 mới cho qua.
                if value == "3" && tracker.attempts < 2 {
                    tracker.attempts += 1
                    throw NetworkError.timeout
                }
                return value
            }
        // 👉 Tính năng ma thuật: Thử kết nối lại tối đa 2 lần nếu luồng bị lỗi
            .retry(2)
            .catch { _ in Just("Lỗi vĩnh viễn") } // Nếu sau 2 lần retry vẫn lỗi, thì giăng lưới catch
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm MapError
    func mapErrorPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .tryMap { value -> String in
                if value == "4" {
                    // Hệ thống ném ra một lỗi kĩ thuật (NetworkError)
                    throw NetworkError.serverDown
                }
                return value
            }
        // 👉 "Phiên dịch" lỗi: Đổi từ NetworkError khô khan sang UIError thân thiện
            .mapError { originalError -> UIError in
                return UIError.friendlyMessage("Bảo trì Server")
            }
        // Bắt cái UIError đó để in lên màn hình
            .catch { error -> Just<String> in
                if case let UIError.friendlyMessage(msg) = error {
                    return Just(msg)
                }
                return Just("Lỗi không xác định")
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 3. Hàm AssertNoFailure
    func assertNoFailurePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // setFailureType để giả vờ luồng này CÓ THỂ xảy ra lỗi (Error)
            .setFailureType(to: Error.self)
        
        // 👉 Lời thề: "Tôi cá 100% luồng này không bao giờ có lỗi. Nếu có, hãy crash app!"
        // Toán tử này sẽ ép kiểu luồng từ <String, Error> về lại thành <String, Never>
            .assertNoFailure("Cảnh báo: Nếu thấy dòng này trên console nghĩa là App đã bị Crash!")
            .eraseToAnyPublisher()
    }
}

#Preview {
    HandlingErrorsView()
}
