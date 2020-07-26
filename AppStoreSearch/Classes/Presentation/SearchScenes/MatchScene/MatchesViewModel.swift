//
//  MatchesViewModel.swift
//  AppStoreSearch
//
//  Created by HS Lee on 2020/07/22.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftExt

final class MatchesViewModel: ViewModelType {
    // MARK: - * Dependencies --------------------
    private let termProvider: TermProviding
    //private var termObs: Observable<String>
    private var termObs: String

    // MARK: - * Properties --------------------
    private var disposeBag = DisposeBag()
    
    let matchesRelay: PublishRelay<String>
    let cancelRelay: PublishRelay<Void>
    
    // MARK: - * Properties  --------------------
    let flowRelay = PublishRelay<MatchesCoordinator.Flow>()
    
    //init(termProvider: TermProviding, termObs: Observable<String>) {
    init(termProvider: TermProviding, termObs: String) {
        self.termProvider = termProvider
        self.termObs = termObs

        self.matchesRelay = .init()
        self.cancelRelay = .init()
    }
    
    func transform(input: Input) -> Output {
        input.search
            .map { MatchesCoordinator.Flow.search($0) }
            .bind(to: flowRelay)
            .disposed(by: disposeBag)
        
        //서치 메인, 키워드 입력 시 매핑
        let matches = Observable.just(termObs)
            .flatMap ({ [weak self] term -> Observable<[String]> in
                guard let self = self else { return Observable.empty() }
                return self.termProvider.fetch()
                    .map ({ terms in
                        terms.filter { $0.contains(term) || term.isEmpty }
                    })
            })
        
        return Output(matches: matches.asDriver(onErrorJustReturn: []))
    }
    
    deinit {
        logD("\(NSStringFromClass(type(of: self))) deinit")
    }
}

extension MatchesViewModel {
    struct Input {
        var search: Observable<String>
    }
    
    struct Output {
        var matches: Driver<[String]>
    }
}
