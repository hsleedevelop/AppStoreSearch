//
//  AppListCoordinator.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/23.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

final class AppListCoordinator: BaseCoordinator<AppListCoordinator.Flow> {
    // MARK: - * Type Defines --------------------
    enum Flow {
        case main
        case detail(SearchResultApp)
    }
    
    // MARK: - * Properties --------------------
    private let term: String
    private let rootViewController: UIViewController
    private var appDetailCoordinatorDisposable: Disposable?
    
    lazy var viewController: AppListViewController! = { [unowned self] in
        guard let viewController = UIStoryboard(name: "AppListScene", bundle: Bundle.main).instantiateViewController(withIdentifier: "AppListViewController") as? AppListViewController else {
            fatalError("AppListViewController can't load")
        }
        
        let viewModel = AppListViewModel(searchProvider: SearchProvider(), term: self.term)
        viewController.viewModel = viewModel
        return viewController
    }()

    // MARK: - * Initialize --------------------
    init(rootViewController: UIViewController, term: String) {
        self.rootViewController = rootViewController
        self.term = term
    }
    

    // MARK: - * Cooridate --------------------
    override func start() -> Observable<CoordinationResult> {
        self.add(childViewController: viewController, toParentViewController: rootViewController)
        
        bindFlow(viewModel: viewController.viewModel)
        return viewController.viewModel.flowRelay.asObservable().startWith(.main)
    }
    
    private func bindFlow(viewModel: AppListViewModel) {
        viewModel.flowRelay
            .subscribe(onNext: { [weak self] flow in
                switch flow {
                case .detail(let app):
                    self?.showDetail(with: app)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showDetail(with app: SearchResultApp) {
        guard let navigationController = viewController.navigationController ?? viewController.presentingViewController?.navigationController else {
            return
        }
        let coordinator = AppDetailCoordinator(navigationController: navigationController, app: app)
        appDetailCoordinatorDisposable = coordinate(to: coordinator)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .popup:
                    self?.appDetailCoordinatorDisposable?.dispose()
                default:
                    break
                }
            })
    }
    
    ///페어런트에 차일드를 등록함.
    func add(childViewController child: UIViewController, toParentViewController parent: UIViewController) {
        parent.addChild(viewController)
        
        parent.addChild(child)
        parent.view.addSubview(child.view)
        
        child.view.topAnchor.constraint(equalTo: parent.view.topAnchor).isActive = true
        child.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor).isActive = true
        child.view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor).isActive = true
        child.view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor).isActive = true
        
        child.didMove(toParent: parent)
    }
    
    deinit {
        appDetailCoordinatorDisposable?.dispose()
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}
