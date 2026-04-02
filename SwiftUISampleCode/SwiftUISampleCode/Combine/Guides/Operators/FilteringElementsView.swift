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
}

#Preview {
    FilteringElementsView()
}
