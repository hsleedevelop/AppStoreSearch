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

protocol ScreenshotsDependencyProtocol: Dependency {
    var presentingViewController: UIViewController { get set }
    var screenshotURLs: [String] { get set }
    var index: Int { get set }
}

final class ScreenshotsDependency: ScreenshotsDependencyProtocol {
    var presentingViewController: UIViewController
    var screenshotURLs: [String]
    var index: Int
    
    init(presentingViewController: UIViewController, screenshotURLs: [String], index: Int) {
        self.presentingViewController = presentingViewController
        self.screenshotURLs = screenshotURLs
        self.index = index
    }
}

final class ScreenshotsCoordinator: BaseCoordinator<ScreenshotsCoordinator.Flow> {
    // MARK: - * Type Defines --------------------
    enum Flow {
        case dismiss
    }
    
    // MARK: - * Properties --------------------
    private let dependency: ScreenshotsDependencyProtocol
    
    // MARK: - * Initialize --------------------
    init(dependency: ScreenshotsDependencyProtocol) {
        self.dependency = dependency
    }
    
    // MARK: - * Coordinante --------------------
    override func start() -> Observable<CoordinationResult> {
        guard let viewController = UIStoryboard(name: "ScreeenshotsScene", bundle: Bundle.main).instantiateViewController(withIdentifier: "ScreenshotsViewController") as? ScreenshotsViewController else {
            fatalError("ScreenshotsViewController can't load")
        }

        let viewModel = ScreenshotsViewModel(screenshotURLs: self.dependency.screenshotURLs, index: self.dependency.index)
        viewController.viewModel = viewModel
                
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.modalPresentationStyle = .fullScreen
        self.dependency.presentingViewController.present(navigationController, animated: true)
        
        return viewModel.coordinatorRelay.asObservable()
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}
