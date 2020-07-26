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
    
    private let termRelay2 = PublishRelay<String>()
    
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
        
        let viewModel = SearchViewModel(termProvider: TermProvider())
        viewController.viewModel = viewModel
        //coordinateMatchingTerm(termObs: termRelay2.asObservable())
        
        bindRx(viewModel: viewModel)

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.tabBarItem = .init(tabBarSystemItem: .search, tag: 0)
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([navigationController], animated: false)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        return Observable.never()
    }
    
    private func bindRx(viewModel: SearchViewModel) {
        viewModel.flowRelay
            .subscribe(onNext: { [weak self] flow in
                switch flow {
                case .matchTerm(let term):
                    self?.coordinateMatchingTerm(termObs: term)
                case .search(let term):
                    self?.coordinateSearch(with: term)
                case .cancelSearch:
                    self?.coordianteCancelSearch()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func coordianteCancelSearch() {
        viewController.resultViewController.children.forEach { vc in
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
    }
    
    private func coordinateSearch(with term: String) {
        let coordinator = AppListCoordinator(rootViewController: viewController.resultViewController, term: term)
        coordinate(to: coordinator)
            .subscribe(onNext: { _ in
                
            })
            .disposed(by: disposeBag)
    }
    
    //private func coordinateMatchingTerm(termObs: Observable<String>) {
    private func coordinateMatchingTerm(termObs: String) {
        //let coordinator = MatchesCoordinator(termObs: termObs)
        let coordinator = MatchesCoordinator(termObs: termObs)
        viewController.resultViewController = coordinator.viewController
        
        coordinate(to: coordinator)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .flow(.search(let term)):
                    self?.coordinateSearch(with: term)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}
