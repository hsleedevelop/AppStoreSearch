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

final class MatchesCoordinator: BaseCoordinator<MatchesCoordinator.Flow> {
    // MARK: - * Type Defines --------------------
    enum Flow {
        case search(String)
    }

    // MARK: - * Properties --------------------
    private let termObs: Observable<String>

    lazy var viewController: MatchesViewController = { [unowned self] in
        guard let viewController = UIStoryboard(name: "MatchScene", bundle: Bundle.main).instantiateViewController(withIdentifier: "MatchesViewController") as? MatchesViewController else {
            fatalError("MatchesViewController can't load")
        }
        
        let viewModel = MatchesViewModel(termProvider: RealmProvider(), termObs: self.termObs)
        viewController.viewModel = viewModel
        return viewController
    }()

    // MARK: - * Initialize --------------------
    init(termObs: Observable<String>) {
        self.termObs = termObs
    }

    // MARK: - * Cooridate --------------------
    override func start() -> Observable<CoordinationResult> {
        return viewController.viewModel.flowRelay.asObservable()
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}
