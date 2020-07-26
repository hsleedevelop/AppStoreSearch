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
    // MARK: - * Type Defines --------------------
    enum Flow {
        case showScreenshots([String], Int)
    }
    
    // MARK: - * Properties --------------------
    private let app: SearchResultApp
    private let navigationController: UINavigationController
    
    lazy var viewController: AppDetailViewController = {
        guard let viewController = UIStoryboard(name: "AppDetailScene", bundle: Bundle.main).instantiateViewController(withIdentifier: "AppDetailViewController") as? AppDetailViewController else {
            fatalError("AppDetailViewController can't load")
        }
        
        let viewModel = AppDetailViewModel(app: self.app)
        viewController.viewModel = viewModel
        return viewController
    }()

    // MARK: - * Initialize --------------------
    init(navigationController: UINavigationController, app: SearchResultApp) {
        self.navigationController = navigationController
        self.app = app
    }
    
    // MARK: - * Cooridate --------------------
    override func start() -> Observable<Void> {
        navigationController.pushViewController(viewController, animated: true)
        bindRx(viewModel: viewController.viewModel)
        
        return Observable.never()
    }
    
    private func bindRx(viewModel: AppDetailViewModel) {
        viewModel.flowRelay
            .subscribe(onNext: { [weak self] flow in
                switch flow {
                case let .showScreenshots(screenshotURLs, index):
                    self?.showScreenshotsCarousel(screenshotURLs: screenshotURLs, index: index)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showScreenshotsCarousel(screenshotURLs: [String], index: Int) {
        let coordinator = ScreenshotsCoordinator(rootViewController: viewController, screenshotURLs: screenshotURLs, index: index)
        coordinate(to: coordinator)
            .subscribe(onNext: { result in
                switch result {
                case .dismiss:
                    self.viewController.dismiss(animated: true, completion: nil)
                case .currentIndex(_):
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}
