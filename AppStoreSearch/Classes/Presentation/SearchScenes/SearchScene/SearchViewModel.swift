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

protocol TermProviding: class {
    @discardableResult
    func store(_ term: String) -> Observable<Bool>
    func fetch() -> Observable<[String]>
}

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

        //서치 메인, 키워드 입력 시 매핑
        let terms = input.fetchTerms
            .flatMap { [weak self] _ -> Observable<[String]> in
                guard let self = self else { return Observable.empty() }
                return self.termProvider.fetch()
            }
        
//        //서치 메인, 키워드 입력 시 매핑
//        let matches = input.searchTerm
//            .flatMap ({ [weak self] term -> Observable<[String]> in
//                guard let self = self else  { return Observable.empty() }
//                return self.searchTermProvider.fetch()
//                    .map { terms in
//                        terms.filter { $0.contains(term) || term.isEmpty }
//                }
//            })
        
        let searchTermObs = input.term
            .map { SearchCoordinator.Flow.matchTerm($0) }
        
        let searchObs = input.search
            .flatMap({ [weak self] term -> Observable<String> in
                guard let self = self else { return Observable.empty() }
                return self.termProvider.store(term)
                    .filter { $0 }
                    .map { _ in term }
            })
            .map { SearchCoordinator.Flow.search($0) }
        
        let searchCancelObs = input.searchCancel
            .map { SearchCoordinator.Flow.cancelSearch }
        
        Observable.merge(searchTermObs, searchObs, searchCancelObs)
            .bind(to: flowRelay)
            .disposed(by: disposeBag)
        
        return Output(terms: terms.asDriver(onErrorJustReturn: []))
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}

extension SearchViewModel {
    struct Input {
        let fetchTerms: Observable<Void>
        let term: Observable<String>
        let search: Observable<String>
        let searchCancel: Observable<Void>
    }
    
    struct Output {
        let terms: Driver<[String]>
    }
}
