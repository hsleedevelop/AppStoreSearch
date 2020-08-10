//
//  AppStoreSearchTests.swift
//  AppStoreSearchTests
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import XCTest
@testable import AppStoreSearch

class AppStoreSearchTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLeakForSearchViewController() throws {
        var viewController: SearchViewController! = UIStoryboard(name: "SearchScene", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        
        viewController.viewModel = .init(termProvider: RealmProvider())
        viewController.beginAppearanceTransition(true, animated: false)
        viewController.endAppearanceTransition()
        
        viewController = nil
    }
    
    func testLeakForSearchCoordinator() throws {
        let window = UIWindow()
        let searchDependency = SearchDependency(window: window, termProviding: RealmProvider(), searchProviding: SearchProvider())
        var coordinator: SearchCoordinator! = SearchCoordinator(dependency: searchDependency)
        _ = coordinator.start()
        coordinator = nil
    }

    func testSearchAddress() throws {
        let a = SearchProvider()
        let b = a
        
        a.printSearch()
        b.printSearch()
        
        let xxx =  a.search(term:)
        let xxxx = b.search(term:)
    }

}
