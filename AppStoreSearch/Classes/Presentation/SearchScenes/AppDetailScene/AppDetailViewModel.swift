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
    
    // MARK: - * private --------------------
    private let disposeBag = DisposeBag()
    
    init(app: SearchResultApp) {
        self.app = app
    }
    
    func transform(input: Input) -> Output {
//        //검색 요청 시
//        let results = Observable.just(app)
//            .flatMap ({ [weak self] term -> Observable<(String, SearchResponse?)> in
//                guard let self = self else { return Observable<(String, SearchResponse?)>.empty() }
//                return self.searchProvider.search(term: term)
//                    .map { (term, $0) }
//                    .catchError ({ error in
//                        logW(error.localizedDescription)
//                        return .just((term, nil)) //errorTracker?
//                    })
//            })
//
//        results
//            .map { AppListCoordinator.Flow.didFetch($0.0) }
//            .bind(to: flowRelay)
//            .disposed(by: disposeBag)
        
        return Output(selectedApp: .just(app))
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}

extension AppDetailViewModel {
    
    struct Input {
        //let search: Observable<String>
    }
    
    struct Output {
        let selectedApp: Driver<SearchResultApp>
    }
}
