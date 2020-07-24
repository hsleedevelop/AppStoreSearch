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

final class AppListCoordinator: BaseCoordinator<Void> {
    enum Flow {
        case didFetch(String)
        case detail(SearchResultApp)
    }
    
    // MARK: - * Properties --------------------
    private let term: String
    private let rootViewController: UIViewController
    
    lazy var viewController: AppListViewController = {
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
    override func start() -> Observable<Void> {
        self.add(childViewController: viewController, toParentViewController: rootViewController)
        
        
        return Observable.never()
    }
    
    
    private func showDetail(with app: SearchResultApp) {
        let coordinator = AppDetailCoordinator(rootViewController: viewController, app: app)
        coordinate(to: coordinator)
            .subscribe(onNext: { _ in
                
            })
            .disposed(by: disposeBag)
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
}
