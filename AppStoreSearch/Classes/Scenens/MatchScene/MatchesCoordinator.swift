//
//  MatchesCoordinator.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/23.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

enum MatchesCoordinationResult {
    case matches([String])
    case cancel
}

final class MatchesCoordinator: BaseCoordinator<MatchesCoordinationResult> {

    private let viewController: UIViewController
    private let termObs: Observable<String>

    init(termObs: Observable<String>, viewController: UIViewController) {
        self.termObs = termObs
        self.viewController = viewController
    }

    override func start() -> Observable<CoordinationResult> {
        guard let viewController = UIStoryboard(name: "TermScene", bundle: Bundle.main).instantiateViewController(withIdentifier: "TermViewController") as? TermViewController else {
            fatalError("TermViewController can't load")
        }

        let viewModel = TermViewModel(termObs)
        viewController.viewModel = viewModel

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.modalPresentationStyle = .fullScreen
        rootViewController.present(navigationController, animated: true)

        let cancel = viewModel.cancelRelay.map { _ in CoordinationResult.cancel }
        let photo = viewModel.indexRelay.map { CoordinationResult.photo($0) }
        return Observable.merge(cancel, photo)
    }
}
