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
    
    enum Flow {
        case main
        case result
        case matchTerm(String)
        case search(String)
        case cancelSearch
    }
    
    private let window: UIWindow
    private var viewController: SearchViewController!
    private var termRelay: PublishRelay<String>
    
    init(window: UIWindow) {
        self.window = window
        
        termRelay = .init()
    }
    
    override func start() -> Observable<Void> {
        guard let viewController = UIStoryboard(name: "SearchScene", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {
            fatalError("SearchViewController can't load")
        }
        self.viewController = viewController
        
        let viewModel = SearchViewModel(termProvider: TermProvider())
        viewController.viewModel = viewModel
        coordinateMatchingTerm(termObs: termRelay.asObservable())
        
        setupRx(viewModel: viewModel)
        
        //viewController.resultViewController = resultViewController
        //setupResultViewController(resultViewController, searchObs: viewModel.search.asObservable())
        
//        viewModel.showCarousel
//            .flatMap ({ [unowned self] in
//                self.showCarousel(photosObs: $0.0, index: $0.1, on: viewController)
//            })
//            .filter { $0 != nil }
//            .map { $0! }
//            .bind(to: viewModel.carouselIndex)
//            .disposed(by: disposeBag)

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.tabBarItem = .init(tabBarSystemItem: .search, tag: 0)
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([navigationController], animated: false)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        return Observable.never()
    }
    
    private func setupRx(viewModel: SearchViewModel) {
        viewModel.flowRelay
            .subscribe(onNext: { [weak self] flow in
                switch flow {
                case .matchTerm(let term):
                    self?.termRelay.accept(term)
                case .search(let term):
                    self?.coordinateSearch(with: term)
                case .cancelSearch:
                    self?.xxx()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func xxx() {
        viewController.resultViewController.children.forEach { vc in
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
    }
    
    private func match(with term: String) {
        
    }
    
    
    private func coordinateSearch(with term: String) {
        let coordinator = AppListCoordinator(rootViewController: viewController.resultViewController, term: term)
        coordinate(to: coordinator)
            .subscribe(onNext: { _ in
                
            })
            .disposed(by: disposeBag)
    }
    
    private func coordinateMatchingTerm(termObs: Observable<String>) {
        let coordinator = MatchesCoordinator(termObs: termObs)
        viewController.resultViewController = coordinator.viewController
        
        coordinate(to: coordinator)
//            .map ({ [weak self] result in
//                switch result {
//                case .flow(.search(let term)):
//                    self?.search(with: term)
//                default:
//                    break
//                }
//            })
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .flow(.search(let term)):
                    self?.coordinateSearch(with: term)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
//        let matchesViewModel = MatchesViewModel(termObs: termRelay.asObservable())
//        matchesViewController.viewModel = matchesViewModel

//        matchesViewModel.showCarousel
//            .flatMap ({ [unowned self] in
//                self.showCarousel(photosObs: $0.0, index: $0.1, on: resultViewController)
//            })
//            .filter { $0 != nil }
//            .map { $0! }
//            .bind(to: matchesViewModel.carouselIndex)
//            .disposed(by: disposeBag)
    }

//    private func showCarousel(photosObs: Observable<[Photo]>, index: Int, on rootViewController: UIViewController) -> Observable<Int?> {
//        let coordinator = CarouselCoordinator(photosObs: photosObs, index: index, rootViewController: rootViewController)
//        return coordinate(to: coordinator)
//            .map { result in
//                switch result {
//                case .photo(let photoId):
//                    return photoId
//                case .cancel:
//                    self.viewController.parent?.dismiss(animated: true, completion: nil)
//                    return nil
//                }
//            }
//    }
}
