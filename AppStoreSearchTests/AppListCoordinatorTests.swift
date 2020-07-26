//
//  AppListCoordinatorTests.swift
//  AppStoreSearchTests
//
//  Created by HS Lee on 2020/07/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import AppStoreSearch

class AppListCoordinatorTests: XCTestCase {
    
    override func setUp() {
    }

    func testAppListCoordinateDeinit() throws {
        let rooteViewController = UIViewController()
        let term = "카카오뱅크"
        
        var coordinator: AppListCoordinator! = AppListCoordinator(rootViewController: rooteViewController, term: term)
        _ = coordinator.start().subscribe()
        coordinator = nil
    }
    
    func testAppListViewModel() throws {
        var viewModel: AppListViewModel! = .init(searchProvider: SearchProvider(), term: "앱테스트")
        _ = viewModel.transform(input: .init())
        viewModel = nil
    }
    
    func testAppListViewController() throws {
        var viewController: AppListViewController! = UIStoryboard(name: "AppListScene", bundle: Bundle.main).instantiateViewController(withIdentifier: "AppListViewController") as? AppListViewController
        
        var viewModel: AppListViewModel! = AppListViewModel(searchProvider: SearchProvider(), term: "앱테스트")
        viewController.viewModel = viewModel
        viewModel = nil
        
        viewController.beginAppearanceTransition(true, animated: false)
        viewController.endAppearanceTransition()
        viewController = nil
    }
}
