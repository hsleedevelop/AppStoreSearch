//
//  ScreenshotsCoordinator.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxSwiftExt

final class ScreenshotsCoordinator: BaseCoordinator<ScreenshotsCoordinator.Result> {
    // MARK: - * Type Defines --------------------
    enum Result {
        case currentIndex(Int)
        case dismiss
    }
    
    // MARK: - * Properties --------------------
    private let rootViewController: UIViewController
    private let screenshotURLs: [String]
    private let index: Int
    
    // MARK: - * Initialize --------------------
    init(rootViewController: UIViewController, screenshotURLs: [String], index: Int) {
        self.rootViewController = rootViewController
        self.screenshotURLs = screenshotURLs
        self.index = index
    }
    
    // MARK: - * Coordinante --------------------
    override func start() -> Observable<CoordinationResult> {
        guard let viewController = UIStoryboard(name: "ScreeenshotsScene", bundle: Bundle.main).instantiateViewController(withIdentifier: "ScreenshotsViewController") as? ScreenshotsViewController else {
            fatalError("ScreenshotsViewController can't load")
        }

        let viewModel = ScreenshotsViewModel(screenshotURLs: screenshotURLs, index: index)
        viewController.viewModel = viewModel
                
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.modalPresentationStyle = .fullScreen
        rootViewController.present(navigationController, animated: true)
        
        return viewModel.coordinatorRelay.asObservable()
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}
