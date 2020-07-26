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

final class AppDetailCoordinator: BaseCoordinator<AppDetailCoordinator.Flow> {
    // MARK: - * Type Defines --------------------
    enum Flow {
        case showScreenshots([String], Int)
        case popup
    }
    
    // MARK: - * Properties --------------------
    private let app: SearchResultApp
    private let navigationController: UINavigationController
    private var screenshotsCoordinatorDisposable: Disposable?
    
    lazy var viewController: AppDetailViewController = { [unowned self] in
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
    override func start() -> Observable<CoordinationResult> {
        navigationController.pushViewController(viewController, animated: true)
        bindFlow(viewModel: viewController.viewModel)
        
        return viewController.viewModel.flowRelay.asObservable()
    }
    
    private func bindFlow(viewModel: AppDetailViewModel) {
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
        screenshotsCoordinatorDisposable = coordinate(to: coordinator)
            .subscribe(onNext: { [unowned self] result in
                switch result {
                case .dismiss:
                    self.viewController.dismiss(animated: true, completion: nil)
                }
                self.screenshotsCoordinatorDisposable?.dispose()
            })
    }
    
    deinit {
        screenshotsCoordinatorDisposable?.dispose()
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}
