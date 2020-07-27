//
//  AppDetailCoordinatorTests.swift
//  AppStoreSearchTests
//
//  Created by HS Lee on 2020/07/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import AppStoreSearch

class AppDetailCoordinatorTests: XCTestCase {
    
    var searchResponseMock: SearchResponse!
    
    override func setUp() {
        do {
            let path = Bundle(for: AppDetailCoordinatorTests.self).path(forResource: "SearchResponseMock", ofType: "json")
            let data = try Data(contentsOf: URL(fileURLWithPath: path!))
            searchResponseMock = try data.map(SearchResponse.self)
        } catch {
            print(error)
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppDetailCoordinateDeinit() throws {
        guard let searchResultApp = searchResponseMock.results?.first else {
            preconditionFailure("No Mock Data")
        }
        
        let navigationController = UINavigationController()
        let appDetailDependency = AppDetailDependency(navigationController: navigationController, app: searchResultApp)
        
        var coordinator: AppDetailCoordinator! = AppDetailCoordinator(dependency: appDetailDependency)
        _ = coordinator.start().subscribe()
        coordinator = nil
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
