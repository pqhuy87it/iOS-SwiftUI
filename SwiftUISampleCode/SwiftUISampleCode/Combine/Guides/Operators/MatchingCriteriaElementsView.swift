import Combine
import SwiftUI

struct MatchingCriteriaElementsView: View {
    var body: some View {
        VStack {
            List {
                // 1. allSatisfy
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
                
                // 2. tryAllSatisfy
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
                
                // 3. contains
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Contains",
                        description: ".contains(\"3\")",
                        comparingPublisher: self.containsPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Contains").font(.headline)
                        Text("Tìm kiếm 1 giá trị cụ thể (Ngắt mạch khi thấy)").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 4. contains(where:)
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "ContainsWhere",
                        description: ".contains(where: { $0 > 3 })",
                        comparingPublisher: self.containsWherePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("ContainsWhere").font(.headline)
                        Text("Tìm kiếm theo điều kiện (Ngắt mạch khi thấy)").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 5. tryContains(where:)
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryContainsWhere",
                        description: ".tryContains(where: { ném lỗi nếu là 4 })",
                        comparingPublisher: self.tryContainsWherePublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryContainsWhere").font(.headline)
                        Text("Tìm theo điều kiện, có quyền ném lỗi").font(.caption).foregroundColor(.gray)
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
    
    // MARK: - 3. Hàm Contains
    func containsPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Chỉ đơn giản là kiểm tra xem trong luồng có xuất hiện chuỗi "3" hay không?
            .contains("3")
        // Trả về Bool, ta map sang String để hiện UI
            .map { $0 ? "Có" : "Không" }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 4. Hàm ContainsWhere
    func containsWherePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
        // Kiểm tra xem có phần tử nào LỚN HƠN 3 không?
            .contains(where: { value in
                value > 3
            })
            .map { $0 ? "Có" : "Không" }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 5. Hàm TryContainsWhere
    enum ContainsError: Error {
        case fatalValue
    }
    
    func tryContainsWherePublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .map { Int($0) ?? 0 }
            .tryContains(where: { value -> Bool in
                // 1. Nếu vô tình quét trúng số 4 -> CHỦ ĐỘNG NÉM LỖI
                if value == 4 {
                    throw ContainsError.fatalValue
                }
                
                // 2. Mục tiêu ta đang tìm kiếm là số 5
                return value == 5
            })
            .map { $0 ? "Có" : "Không" }
            .catch { _ in Just("Lỗi") } // Bắt lỗi hiện lên UI
            .eraseToAnyPublisher()
    }
}

#Preview {
    MatchingCriteriaElementsView()
}
