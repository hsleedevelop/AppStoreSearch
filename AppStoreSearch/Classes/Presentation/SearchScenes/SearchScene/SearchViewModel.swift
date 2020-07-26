//
//  SearchViewModel.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

final class SearchViewModel: ViewModelType {
    
    // MARK: - * Properties  --------------------
    let flowRelay = PublishRelay<SearchCoordinator.Flow>()
    
    // MARK: - * Dependencies --------------------
    private let termProvider: TermProviding
    
    // MARK: - * private --------------------
    private let disposeBag = DisposeBag()
    
    init(termProvider: TermProviding) {
        self.termProvider = termProvider
    }
    
    func transform(input: Input) -> Output {

        //검색어 목록 조회
        let terms = input.fetchTerms
            .flatMap { [weak self] _ -> Observable<[String]> in
                guard let self = self else { return Observable.empty() }
                return self.termProvider.fetch()
            }

        //검색어 입력 이벤트
        let searchTermObs = input.matchTerm
            .map { SearchCoordinator.Flow.matchTerm($0) }
        
        //검색 요청
        let searchObs = input.search
            .flatMap({ [weak self] term -> Observable<String> in
                guard let self = self else { return Observable.empty() }
                return self.termProvider.store(term)
                    .filter { $0 }
                    .map { _ in term }
            })
            .map { SearchCoordinator.Flow.search($0) }
            .share()
        
        //검색 요청 시, 저장된 검색 목록 갱신
        let terms2 = searchObs
            .flatMap { [weak self] _ -> Observable<[String]> in
                guard let self = self else { return Observable.empty() }
                return self.termProvider.fetch().delaySubscription(RxTimeInterval.microseconds(500000), scheduler: MainScheduler.instance)
            }
        
        let searchCancelObs = input.searchCancel
            .map { SearchCoordinator.Flow.cancelSearch }
        
        Observable.merge(searchTermObs, searchObs, searchCancelObs)
            .bind(to: flowRelay)
            .disposed(by: disposeBag)
        
        return Output(terms: Observable.merge(terms, terms2).asDriver(onErrorJustReturn: []))
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}

extension SearchViewModel {
    struct Input {
        let fetchTerms: Observable<Void>
        let matchTerm: Observable<String>
        let search: Observable<String>
        let searchCancel: Observable<Void>
    }
    
    struct Output {
        let terms: Driver<[String]>
    }
}
