//
//  AppListViewModel.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/23.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftExt

final class AppListViewModel: ViewModelType {
    
    // MARK: - * Properties  --------------------
    let flowRelay = PublishRelay<AppListCoordinator.Flow>()
    
    // MARK: - * Dependencies --------------------
    private let searchProvider: SearchProviding
    private let term: String
    
    // MARK: - * private --------------------
    private let disposeBag = DisposeBag()
    
    init(searchProvider: SearchProviding, term: String) {
        self.searchProvider = searchProvider
        self.term = term
    }
    
    func transform(input: Input) -> Output {
        
        //검색 요청 시
        let results = Observable.just(term)
            .flatMap ({ [weak self] term -> Observable<(String, SearchResponse?)> in
                guard let self = self else { return Observable<(String, SearchResponse?)>.empty() }
                return self.searchProvider.search(term: term)
                    .map { (term, $0) }
                    .catchError ({ error in
                        logW(error.localizedDescription)
                        return .just((term, nil)) //errorTracker?
                    })
            })
            .share()
//            .do(onNext: { results in
//                if results.1.resultCount > 0 {
//                    _ = TermsProvider.shared.store(results.0) //결과가 있을 경우만 검색어를 저장함.
//                        .subscribe()
//                }
//            })
        
        results
            .map { AppListCoordinator.Flow.didFetch($0.0) }
            .bind(to: flowRelay)
            .disposed(by: disposeBag)
        
        return Output(result: results.asDriver(onErrorJustReturn: ("", nil)))
    }
}

extension AppListViewModel {
    
    struct Input {
        //let search: Observable<String>
    }
    
    struct Output {
        let result: Driver<(String, SearchResponse?)>
    }
}
