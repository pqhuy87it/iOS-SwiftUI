import Foundation
@testable import SwiftUI_MVVM_Demo

final class MockAPIService: APIServiceType {
    // Lưu trữ các stubs bằng String (tên kiểu Request) cho đơn giản
    var stubs: [String: Any] = [:]
    
    // Hàm Helper để set mock response
    func stub<Request: APIRequestType>(for type: Request.Type, response: Result<Request.Response, Error>) {
        stubs[String(describing: type)] = response
    }
    
    // Hàm setup: Nhận vào một closure async throws
    func stub<Request: APIRequestType>(
        for type: Request.Type,
        response: @escaping (Request) async throws -> Request.Response
    ) {
        let key = String(describing: type)
        stubs[key] = response
    }
    
    // Implement protocol APIServiceType bằng async throws
    func response<Request: APIRequestType>(from request: Request) async throws -> Request.Response {
        let key = String(describing: Request.self)
        
        guard let result = stubs[key] as? Result<Request.Response, Error> else {
            fatalError("Chưa setup stub cho \(key)")
        }
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
