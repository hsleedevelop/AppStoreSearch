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

protocol MatchesDependencyProtocol: Dependency {
    var termObs: Observable<String> { get set }
    var termProviding: TermProviding { get set }
}

final class MatchesDependency: MatchesDependencyProtocol {
    var termObs: Observable<String>
    var termProviding: TermProviding
    
    init(termProviding: TermProviding, termObs: Observable<String>) {
        self.termProviding = termProviding
        self.termObs = termObs
    }
}

final class MatchesCoordinator: BaseCoordinator<MatchesCoordinator.Flow> {
    // MARK: - * Type Defines --------------------
    enum Flow {
        case search(String)
    }

    // MARK: - * Properties --------------------
    private let dependency: MatchesDependencyProtocol

    lazy var viewController: MatchesViewController = { [unowned self] in
        guard let viewController = UIStoryboard(name: "MatchScene", bundle: Bundle.main).instantiateViewController(withIdentifier: "MatchesViewController") as? MatchesViewController else {
            fatalError("MatchesViewController can't load")
        }
        
        let viewModel = MatchesViewModel(termProvider: self.dependency.termProviding, termObs: self.dependency.termObs)
        viewController.viewModel = viewModel
        return viewController
    }()

    // MARK: - * Initialize --------------------
    init(dependency: MatchesDependencyProtocol) {
        self.dependency = dependency
    }

    // MARK: - * Cooridate --------------------
    override func start() -> Observable<CoordinationResult> {
        return viewController.viewModel.flowRelay.asObservable()
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}
