//
//  SearchCoordinator.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt

final class SearchCoordinator: BaseCoordinator<Void> {
    // MARK: - * Type Defines --------------------
    enum Flow {
        case matchTerm(String)
        case search(String)
        case cancelSearch
    }
    
    // MARK: - * Properties --------------------
    private let window: UIWindow
    private var viewController: SearchViewController!
    
    private let termRelay = BehaviorRelay<String>(value: "")
    private var appListCoordinatorDisposable: Disposable?
    
    // MARK: - * Initialize --------------------
    init(window: UIWindow) {
        self.window = window
    }
    
    // MARK: - * Coordinante --------------------
    override func start() -> Observable<Void> {
        guard let viewController = UIStoryboard(name: "SearchScene", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {
            fatalError("SearchViewController can't load")
        }
        self.viewController = viewController
        
        let viewModel = SearchViewModel(termProvider: RealmProvider())
        viewController.viewModel = viewModel
        setupMatchTermCoodinator()
        
        bindFlow(viewModel: viewModel)

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.tabBarItem = .init(tabBarSystemItem: .search, tag: 0)
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([navigationController], animated: false)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        return Observable.never()
    }
    
    private func bindFlow(viewModel: SearchViewModel) {
        viewModel.flowRelay
            .subscribe(onNext: { [weak self] flow in
                switch flow {
                case .matchTerm(let term):
                    self?.coordianteMatching(with: term)
                case .search(let term):
                    self?.coordinateSearch(with: term)
                case .cancelSearch:
                    self?.coordianteCancelSearch()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func coordianteCancelSearch() {
        var vc = viewController.resultViewController.children.first
        vc?.view.removeFromSuperview()
        vc?.removeFromParent()
        vc = nil
        
        appListCoordinatorDisposable?.dispose()
    }
    
    private func coordinateSearch(with term: String) {
        let coordinator = AppListCoordinator(rootViewController: viewController.resultViewController, term: term)
        appListCoordinatorDisposable = coordinate(to: coordinator)
            .subscribe()
    }
    
    private func coordianteMatching(with term: String) {
        if termRelay.value != term {
            coordianteCancelSearch()
        }
        termRelay.accept(term)
    }
    
    private func setupMatchTermCoodinator() {
        let coordinator = MatchesCoordinator(termObs: termRelay.asObservable())
        viewController.resultViewController = coordinator.viewController
        
        coordinate(to: coordinator)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .search(let term):
                    self?.viewController.viewModel.flowRelay.accept(.cancelSearch)
                    self?.coordinateSearch(with: term)
                }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        appListCoordinatorDisposable?.dispose()
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}
