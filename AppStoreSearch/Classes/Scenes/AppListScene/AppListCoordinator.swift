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

//enum CarouselCoordinationResult {
//    case matches([String])
//    case cancel
//}
//
//final class CarouselCoordinator: BaseCoordinator<CarouselCoordinationResult> {
//    
//    private let viewController: UIViewController
//    private let photosObs: Observable<[Photo]>
//    private let index: Int
//    
//    init(photosObs: Observable<[Photo]>, index: Int, rootViewController: UIViewController) {
//        self.photosObs = photosObs
//        self.index = index
//        self.rootViewController = rootViewController
//    }
//    
//    override func start() -> Observable<CoordinationResult> {
//        guard let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CarouselViewController") as? CarouselViewController else {
//            fatalError("CarouselViewController can't load")
//        }
//
//        let viewModel = CarouselViewModel(photosObs: self.photosObs, index: self.index)
//        viewController.viewModel = viewModel
//                
//        let navigationController = UINavigationController(rootViewController: viewController)
//        navigationController.modalTransitionStyle = .crossDissolve
//        navigationController.modalPresentationStyle = .fullScreen
//        rootViewController.present(navigationController, animated: true)
//        
//        let cancel = viewModel.cancelRelay.map { _ in CoordinationResult.cancel }
//        let photo = viewModel.indexRelay.map { CoordinationResult.photo($0) }
//        return Observable.merge(cancel, photo)
//    }
//}
