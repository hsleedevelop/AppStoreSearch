//
//  AppDetailViewModel.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/24.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftExt

final class AppDetailViewModel: ViewModelType {
    
    // MARK: - * Properties  --------------------
    let flowRelay = PublishRelay<AppDetailCoordinator.Flow>()
    
    // MARK: - * Dependencies --------------------
    var app: SearchResultApp
    
    // MARK: - * init --------------------
    init(app: SearchResultApp) {
        self.app = app
    }
    
    func transform(input: Input) -> Output {
        return Output(selectedApp: .just(app))
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}

extension AppDetailViewModel {
    
    struct Input {
    }
    
    struct Output {
        let selectedApp: Driver<SearchResultApp>
    }
}
