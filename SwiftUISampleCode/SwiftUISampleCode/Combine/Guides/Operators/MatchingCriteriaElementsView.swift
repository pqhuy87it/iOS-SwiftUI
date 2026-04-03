import Combine
import SwiftUI

struct MatchingCriteriaElementsView: View {
    var body: some View {
        VStack {
            List {
                // 1. NavigationLink cho allSatisfy
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "AllSatisfy",
                        description: ".allSatisfy { $0 < 4 }",
                        comparingPublisher: self.allSatisfyPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("AllSatisfy").font(.headline)
                        Text("Kiểm tra TẤT CẢ có thỏa mãn điều kiện không").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. NavigationLink cho tryAllSatisfy
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryAllSatisfy",
                        description: ".tryAllSatisfy { ném lỗi nếu là số 4 }",
                        comparingPublisher: self.tryAllSatisfyPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryAllSatisfy").font(.headline)
                        Text("Kiểm tra điều kiện nhưng có quyền ném lỗi").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Applying matching criteria to elements")
    }
    
    // MARK: - 1. Hàm AllSatisfy
    func allSatisfyPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
        // Kiểm tra xem CÓ PHẢI TẤT CẢ các số đều NHỎ HƠN 4 hay không?
            .allSatisfy { value in
                value < 4
            }
        // Kết quả của allSatisfy là một Bool (true/false)
        // Ta chuyển nó thành chữ "Đúng"/"Sai" để hiện lên UI
            .map { $0 ? "Đúng" : "Sai" }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm TryAllSatisfy
    enum SatisfyError: Error {
        case fatalValue
    }
    
    func tryAllSatisfyPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            .tryAllSatisfy { value -> Bool in
                // 1. Nếu gặp số 4 -> CHỦ ĐỘNG NÉM LỖI (Báo động đỏ)
                if value == 4 {
                    throw SatisfyError.fatalValue
                }
                
                // 2. Điều kiện kiểm tra bình thường: Tất cả phải nhỏ hơn 10
                return value < 10
            }
            .map { $0 ? "Đúng" : "Sai" }
            .catch { _ in Just("Lỗi") } // Hứng lỗi và in ra UI
            .eraseToAnyPublisher()
    }
}

#Preview {
    MatchingCriteriaElementsView()
}
