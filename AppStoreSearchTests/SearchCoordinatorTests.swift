//
//  SearchCoordinatorTests.swift
//  AppStoreSearchTests
//
//  Created by HS Lee on 2020/07/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import AppStoreSearch

class SearchCoordinatorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSearchCoordinateDeinit() throws {
        let window = UIWindow()
        var coordinator: SearchCoordinator! = SearchCoordinator(window: window)
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
