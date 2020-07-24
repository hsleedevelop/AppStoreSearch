//
//  AppDetailCoordinator.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

final class AppDetailCoordinator: BaseCoordinator<Void> {
    enum Flow {
        case main
        case showCarousel(SearchResultApp)
        case pop
    }
    
    // MARK: - * Properties --------------------
    private let app: SearchResultApp
    private let rootViewController: UIViewController
    
    lazy var viewController: AppDetailViewController = {
        guard let viewController = UIStoryboard(name: "AppDetailScene", bundle: Bundle.main).instantiateViewController(withIdentifier: "AppDetailViewController") as? AppDetailViewController else {
            fatalError("AppDetailViewController can't load")
        }
        
        let viewModel = AppDetailViewModel(app: self.app)
        viewController.viewModel = viewModel
        return viewController
    }()

    // MARK: - * Initialize --------------------
    init(rootViewController: UIViewController, app: SearchResultApp) {
        self.rootViewController = rootViewController
        self.app = app
    }
    
    // MARK: - * Cooridate --------------------
    override func start() -> Observable<Void> {
        rootViewController.navigationController?.pushViewController(viewController, animated: true)
        return Observable.never()
    }
}
