import Foundation
import Combine
import XCTest
@testable import SwiftUI_MVVM_Demo

@MainActor // Đánh dấu toàn bộ test class chạy trên Main Thread
final class RepositoryListViewModelTests: XCTestCase {
    
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    func test_updateRepositoriesWhenOnAppear() async {
        let apiService = MockAPIService()
        let expectedResponse = SearchRepositoryResponse(
            items: [
                Repository(
                    id: 1,
                    fullName: "foo",
                    description: nil,
                    stargazersCount: 0,
                    language: nil,
                    owner: User(id: 1, login: "bar", avatarUrl: URL(string: "http://baz.com")!)
                )
            ]
        )
        apiService.stub(for: SearchRepositoryRequest.self, response: .success(expectedResponse))
        
        let viewModel = makeViewModel(apiService: apiService)
        let expectation = XCTestExpectation(description: "Fetch repositories thành công")
        
        // Lắng nghe sự thay đổi của biến repositories
        viewModel.$repositories
            .dropFirst() // Bỏ qua giá trị khởi tạo rỗng ban đầu
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.apply(.onAppear)
        
        // Đợi Task hoàn thành
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertFalse(viewModel.repositories.isEmpty)
        XCTAssertEqual(viewModel.repositories.first?.fullName, "foo")
    }
    
    func test_serviceErrorWhenOnAppear() async {
        let apiService = MockAPIService()
        apiService.stub(for: SearchRepositoryRequest.self, response: .failure(APIServiceError.responseError))
        
        let viewModel = makeViewModel(apiService: apiService)
        let expectation = XCTestExpectation(description: "Bắt được lỗi API")
        
        viewModel.$isErrorShown
            .dropFirst()
            .filter { $0 == true }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.apply(.onAppear)
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertTrue(viewModel.isErrorShown)
    }
    
    func test_logListViewWhenOnAppear() {
        let trackerService = MockTrackerService()
        let viewModel = makeViewModel(trackerService: trackerService)
        
        viewModel.apply(.onAppear)
        
        XCTAssertTrue(trackerService.loggedTypes.contains(.listView))
    }
    
    func test_showIconEnabledWhenOnAppear() {
        let experimentService = MockExperimentService()
        experimentService.stubs[.showIcon] = true
        let viewModel = makeViewModel(experimentService: experimentService)

        viewModel.apply(.onAppear)
        XCTAssertTrue(viewModel.shouldShowIcon)
    }
    
    func test_showIconDisabledWhenOnAppear() {
        let experimentService = MockExperimentService()
        experimentService.stubs[.showIcon] = false
        let viewModel = makeViewModel(experimentService: experimentService)
        
        viewModel.apply(.onAppear)
        XCTAssertFalse(viewModel.shouldShowIcon)
    }
    
    // Helper function
    private func makeViewModel(
        apiService: APIServiceType = MockAPIService(),
        trackerService: TrackerType = MockTrackerService(),
        experimentService: ExperimentServiceType = MockExperimentService()
    ) -> RepositoryListViewModel {
        return RepositoryListViewModel(
            apiService: apiService,
            trackerService: trackerService,
            experimentService: experimentService
        )
    }
}
