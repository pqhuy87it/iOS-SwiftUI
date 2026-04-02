//
//  FilteringElementsView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/02.
//

import SwiftUI
import Combine

struct FilteringElementsView: View {
    var body: some View {
        VStack {
            List {
                // 1. Thêm NavigationLink cho compactMap
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "CompactMap",
                        description: ".compactMap { loại bỏ nil }",
                        comparingPublisher: self.compactMapPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("CompactMap").font(.headline)
                        Text("Biến đổi dữ liệu và TỰ ĐỘNG lọc bỏ nil").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 2. Thêm NavigationLink cho tryCompactMap
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryCompactMap",
                        description: ".tryCompactMap { ném lỗi hoặc trả về nil }",
                        comparingPublisher: self.tryCompactMapPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryCompactMap").font(.headline)
                        Text("Lọc bỏ nil, nhưng cũng có quyền ném lỗi").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 3. Thêm NavigationLink cho replaceEmpty
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "ReplaceEmpty",
                        description: ".replaceEmpty(with: \"Trống\")",
                        comparingPublisher: self.replaceEmptyPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("ReplaceEmpty").font(.headline)
                        Text("Phát giá trị mặc định nếu luồng KHÔNG có gì").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 4. filter
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "Filter",
                        description: ".filter { chỉ giữ số chẵn }",
                        comparingPublisher: self.filterPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("Filter").font(.headline)
                        Text("Chỉ cho phép dữ liệu thoả mãn điều kiện đi qua").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 5. tryFilter
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryFilter",
                        description: ".tryFilter { ném lỗi nếu gặp số 4 }",
                        comparingPublisher: self.tryFilterPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryFilter").font(.headline)
                        Text("Lọc dữ liệu, ném lỗi đóng luồng nếu gặp giá trị cấm").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 6. replaceError
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "ReplaceError",
                        description: ".replaceError(with: \"Sửa lỗi\")",
                        comparingPublisher: self.replaceErrorPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("ReplaceError").font(.headline)
                        Text("Thay thế lỗi bằng một giá trị mặc định").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 7. removeDuplicates
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "RemoveDuplicates",
                        description: ".removeDuplicates()",
                        comparingPublisher: self.removeDuplicatesPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("RemoveDuplicates").font(.headline)
                        Text("Loại bỏ các giá trị trùng lặp liên tiếp").font(.caption).foregroundColor(.gray)
                    }
                }
                
                // 8. tryRemoveDuplicates
                NavigationLink(
                    destination: GenericCombineStreamView(
                        navigationBarTitle: "TryRemoveDuplicates",
                        description: ".tryRemoveDuplicates { ném lỗi nếu trùng số 4 }",
                        comparingPublisher: self.tryRemoveDuplicatesPublisher
                    )
                ) {
                    VStack(alignment: .leading) {
                        Text("TryRemoveDuplicates").font(.headline)
                        Text("Loại bỏ trùng lặp hoặc ném lỗi nếu cần").font(.caption).foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationBarTitle("Filtering elements")
    }
    
    // MARK: - 1. Hàm CompactMap
    func compactMapPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // compactMap yêu cầu closure trả về một Optional (String?)
            .compactMap { value -> String? in
                // Giả sử ta muốn loại bỏ các số CHẴN ra khỏi luồng
                guard let intValue = Int(value), intValue % 2 != 0 else {
                    // Nếu trả về nil, giá trị này sẽ bị bốc hơi (không truyền tiếp xuống dưới)
                    return nil
                }
                // Nếu trả về một giá trị thực (Optional unwrapped), nó sẽ được đi tiếp
                return value
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm TryCompactMap
    enum CompactError: Error {
        case fatalNumber
    }
    
    func tryCompactMapPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .tryCompactMap { value -> String? in
                // 1. Nếu là số 4 -> CHỦ ĐỘNG NÉM LỖI (Luồng sẽ bị đóng)
                if value == "4" {
                    throw CompactError.fatalNumber
                }
                // 2. Nếu là số 2 -> LỜ ĐI (Trả về nil, luồng vẫn sống nhưng số 2 bị bỏ qua)
                if value == "2" {
                    return nil
                }
                // 3. Các số khác -> Đi tiếp
                return value
            }
            .catch { _ in Just("Lỗi") } // Hứng lỗi từ throw
            .eraseToAnyPublisher()
    }
    
    // MARK: - 3. Hàm ReplaceEmpty
    func replaceEmptyPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // filter { false } sẽ CHẶN đứng toàn bộ dữ liệu đi qua.
        // Biến luồng này thành một luồng hoàn toàn Rỗng (Chỉ phát tín hiệu Complete, không phát data)
            .filter { _ in false }
        
        // Nếu luồng hoàn thành mà chưa từng phát ra bất kỳ giá trị nào,
        // replaceEmpty sẽ "cứu vớt" bằng cách phát ra giá trị mặc định này.
            .replaceEmpty(with: "Rỗng")
            .eraseToAnyPublisher()
    }
    
    // MARK: - 1. Hàm Filter
    func filterPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // filter yêu cầu closure trả về Bool (true/false)
            .filter { value -> Bool in
                let intValue = Int(value) ?? 0
                // Điều kiện: Chỉ cho phép các số CHẴN đi qua
                return intValue % 2 == 0
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm TryFilter
    enum FilterError: Error {
        case forbiddenValue
    }
    
    func tryFilterPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .tryFilter { value -> Bool in
                let intValue = Int(value) ?? 0
                
                // 1. Nếu gặp số 4 -> CHỦ ĐỘNG NÉM LỖI (Đóng luồng ngay lập tức)
                if intValue == 4 {
                    throw FilterError.forbiddenValue
                }
                
                // 2. Các số còn lại: Chỉ cho phép số LỚN HƠN 1 đi qua
                return intValue > 1
            }
            .catch { _ in Just("Lỗi") } // Hứng lỗi từ throw để hiển thị lên UI
            .eraseToAnyPublisher()
    }
    
    // MARK: - 1. Hàm ReplaceError
    enum MyError: Error { case fail }
    
    func replaceErrorPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
            .tryMap { value -> String in
                // Giả lập: Nếu gặp số 3 thì ném lỗi
                if value == "3" { throw MyError.fail }
                return value
            }
        // 👉 Khi gặp lỗi, thay bằng chữ "Đã Sửa" và HOÀN THÀNH luồng.
            .replaceError(with: "Đã Sửa")
            .eraseToAnyPublisher()
    }
    
    // MARK: - 2. Hàm RemoveDuplicates
    func removeDuplicatesPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        publisher
        // Để thấy rõ hiệu ứng, ta biến đổi luồng 1,2,3,4,5 thành 1,1,1,2,2...
            .flatMap { value -> AnyPublisher<String, Never> in
                return [value, value].publisher.eraseToAnyPublisher()
            }
        // 👉 Loại bỏ các phần tử trùng lặp đứng cạnh nhau
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - 3. Hàm TryRemoveDuplicates
    func tryRemoveDuplicatesPublisher(publisher: AnyPublisher<String, Never>) -> AnyPublisher<String, Never> {
        // Tạo chuỗi có trùng lặp để test: 1, 2, 3, 4, 4, 5
        let customPublisher = publisher.flatMap { value -> AnyPublisher<String, Never> in
            if value == "4" { return ["4", "4"].publisher.eraseToAnyPublisher() }
            return [value].publisher.eraseToAnyPublisher()
        }
        
        return customPublisher
            .tryRemoveDuplicates { prev, current in
                // Nếu thấy 2 số 4 đi liền nhau -> Báo động đỏ, ném lỗi!
                if prev == "4" && current == "4" {
                    throw MyError.fail
                }
                // Điều kiện trùng lặp thông thường
                return prev == current
            }
            .catch { _ in Just("Lỗi Trùng") }
            .eraseToAnyPublisher()
    }
}

#Preview {
    FilteringElementsView()
}
